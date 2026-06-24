import Foundation

/// Performs multiple checks at once considering certain optimizations depending on the amount of them
public final class SourceFileBatchChecker: Sendable {

    public typealias ReportStream = AsyncThrowingStream<ErrorMessage, Error>
    public typealias UnusedKeysStream = AsyncThrowingStream<UnusedKeyMessage, Error>
    typealias ReportMessages = (errors: [ErrorMessage], unused: [UnusedKeyMessage], used: [LocalizeEntry])

    @available(macOS 12, *)
    /// Async stream of obtained check reports
    public var reports: ReportStream {
        get throws {
            try run()
        }
    }

    public var unusedKeys: [UnusedKeyMessage] {
        get async throws {
            try await runForUnusedKeys()
        }
    }

    @available(macOS 12, *)
    var processedFiles: AsyncMapSequence<ReportStream, String> {
        get throws {
            try reports.map(\.baseFilename)
        }
    }

    private let sourceFiles: [String]
    private let localizeBundleUrl: URL

    /// Creates batch source file checker
    /// - Parameters:
    ///   - sourceFiles: List of source files to check for localization mistakes
    ///   - localizeBundleFile: Directory url to the localization files
    public init(
        sourceFiles: [String],
        localizeBundleFile: URL
    ) {
        self.sourceFiles = sourceFiles
        self.localizeBundleUrl = localizeBundleFile
    }

    @available(macOS 12, *)
    @discardableResult
    func run() throws -> ReportStream {
        let localizeBundle = try LocalizeBundle(directoryPath: localizeBundleUrl.path)
        let files = sourceFiles
        return ReportStream { continuation in
            Task {
                await withThrowingTaskGroup(of: [ErrorMessage].self) { group in
                    // Per-file tasks. Previously the batch was split into
                    // `activeProcessorCount` chunks processed sequentially
                    // inside each chunk, and — when this type was an actor —
                    // all chunk tasks hopped back onto the actor's serial
                    // executor, eliminating parallelism entirely. Spawning
                    // one task per file lets Swift Concurrency's cooperative
                    // pool load-balance CPU-bound SwiftParser work across
                    // cores.
                    for file in files {
                        group.addTask {
                            try Self.checkSingle(file: file, in: localizeBundle).errors
                        }
                    }

                    do {
                        for try await errors in group {
                            errors.forEach { continuation.yield($0) }
                        }
                        continuation.finish(throwing: nil)
                    } catch {
                        continuation.finish(throwing: error)
                    }
                }
            }
        }
    }

    @available(macOS 12, *)
    @discardableResult
    func runForUnusedKeys() async throws -> [UnusedKeyMessage] {
        let localizeBundle = try LocalizeBundle(directoryPath: localizeBundleUrl.path)
        let files = sourceFiles
        return try await withThrowingTaskGroup(of: (unused: [UnusedKeyMessage], used: [LocalizeEntry]).self) { group in
            for file in files {
                group.addTask {
                    let messages = try Self.checkSingle(file: file, in: localizeBundle)
                    return (messages.unused, messages.used)
                }
            }

            var usedKeys: Set<String> = []
            var unusedKeys: Set<String> = []
            for try await chunk in group {
                chunk.unused.forEach { unusedKeys.insert($0.key) }
                chunk.used.forEach { usedKeys.insert($0.key) }
            }
            let trulyUnusedKeys = unusedKeys.subtracting(usedKeys)
            return trulyUnusedKeys.map(UnusedKeyMessage.init(key:))
        }
    }

    @discardableResult
    func syncRun() throws -> ReportMessages {
        let localizeBundle = LocalizeBundle(fileUrl: localizeBundleUrl)
        return try processBatch(ofSourceFiles: sourceFiles, in: localizeBundle)
    }

    private func processBatch(ofSourceFiles files: [String], in localizeBundle: LocalizeBundle) throws -> ReportMessages {
        let sourceCheckers = try files.compactMap(URL.init(fileURLWithPath:)).map {
            try SourceFileChecker(fileUrl: $0, localizeBundle: localizeBundle)
        }
        for sourceChecker in sourceCheckers {
            try sourceChecker.start()
        }

        return (
            sourceCheckers.flatMap(\.errors),
            sourceCheckers.flatMap(\.unusedKeys).map(UnusedKeyMessage.init(key:)),
            sourceCheckers.flatMap(\.usedKeys)
        )
    }

    private static func checkSingle(file: String, in bundle: LocalizeBundle) throws -> ReportMessages {
        let checker = try SourceFileChecker(
            fileUrl: URL(fileURLWithPath: file),
            localizeBundle: bundle
        )
        try checker.start()
        return (
            checker.errors,
            checker.unusedKeys.map(UnusedKeyMessage.init(key:)),
            checker.usedKeys
        )
    }

}
