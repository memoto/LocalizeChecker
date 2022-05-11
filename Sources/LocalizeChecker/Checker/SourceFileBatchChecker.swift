import Foundation

public final class SourceFileBatchChecker {
    
    public typealias ReportStream = AsyncThrowingStream<ErrorMessage, Error>
    
    public var reports: ReportStream { run() }
    var processedFiles: AsyncMapSequence<ReportStream, String> {
        reports.map(\.baseFilename)
    }

    private var sourceFiles: [String]
    private var localizeBundleFile: URL
    
    public init(
        sourceFiles: [String],
        localizeBundleFile: URL
    ) {
        self.sourceFiles = sourceFiles
        self.localizeBundleFile = localizeBundleFile
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
    
    @discardableResult
    func run() -> ReportStream {
        let localizeBundle = LocalizeBundle(fileUrl: localizeBundleFile)
        
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
        let localizeBundle = LocalizeBundle(fileUrl: localizeBundleFile)
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
            sourceChecker.main()
        }
        
        return sourceCheckers.flatMap(\.errors)
    }
    
}
