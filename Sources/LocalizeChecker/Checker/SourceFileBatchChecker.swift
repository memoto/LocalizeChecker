import Foundation

/// Performs multiple checks at once considering certain optimizations depending on the amount of them
public final class SourceFileBatchChecker {
    
    public typealias ReportStream = AsyncThrowingStream<ErrorMessage, Error>
    
    @available(macOS 12, *)
    /// Async stream of obtained check reports
    public var reports: ReportStream {
        get throws {
            try run()
        }
    }
    
    @available(macOS, deprecated: 12, obsoleted: 13, message: "Use much faster reports stream")
    public func getReports() throws -> [ErrorMessage] {
        try syncRun()
    }
    
    @available(macOS 12, *)
    var processedFiles: AsyncMapSequence<ReportStream, String> {
        get throws {
            try reports.map(\.baseFilename)
        }
    }

    private var sourceFiles: [String]
    private var localizeBundleUrl: URL
    
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
    
    private var chunks: [ArraySlice<String>] {
        let chunkIndices = stride(from: sourceFiles.startIndex, to: sourceFiles.endIndex, by: chunkSize)
        
        return chunkIndices.map{
            sourceFiles[$0..<min($0+chunkSize, sourceFiles.endIndex)]
        }
    }
    
    private var chunkSize: Int {
        let jobsCount = ProcessInfo().activeProcessorCount
        let estimatedChunkSize = sourceFiles.count/jobsCount
        return estimatedChunkSize > 0
            ? estimatedChunkSize
            : sourceFiles.count
    }
    
    @available(macOS 12, *)
    @discardableResult
    func run() throws -> ReportStream {
        let localizeBundle = try LocalizeBundle(directoryPath: localizeBundleUrl.path)
        return ReportStream { continuation in
            Task {
                await withThrowingTaskGroup(of: [ErrorMessage].self) { group in
                    for filesChunk in chunks {
                        group.addTask {
                            try self.processBatch(
                                ofSourceFiles: Array(filesChunk),
                                in: localizeBundle
                            )
                        }
                    }
                    
                    do {
                        for try await reportsChunk in group {
                            reportsChunk.forEach {
                                continuation.yield($0)
                            }
                        }
                        continuation.finish(throwing: nil)
                    } catch {
                        continuation.finish(throwing: error)
                    }
                }
            }
        }
    }
    
    @discardableResult
    func syncRun() throws -> [ErrorMessage] {
        let localizeBundle = LocalizeBundle(fileUrl: localizeBundleUrl)
        let reports = try self.processBatch(
            ofSourceFiles: sourceFiles,
            in: localizeBundle
        )
        
        return reports
    }
    
    private func processBatch(ofSourceFiles files: [String], in localizeBundle: LocalizeBundle) throws -> [ErrorMessage] {
        let fileUrls = files.compactMap(URL.init(fileURLWithPath:))
        let sourceCheckers = try fileUrls.map {
            try SourceFileChecker(fileUrl: $0, localizeBundle: localizeBundle)
        }
        for sourceChecker in sourceCheckers {
            try sourceChecker.start()
        }
        
        return sourceCheckers.flatMap(\.errors)
    }
    
}
