import Foundation
import ArgumentParser
import LocalizeChecker

@main
struct LocalizeCheckerCLI: AsyncParsableCommandProtocol {
    @Argument(help: "Files which to scan")
    var sourceFiles: [String] = []

    @Option(help: "Directory containing sources to scan recursively")
    var sourcesDirectory: String?
    
    @Option(help: "Path to the lproj directory with localized strings")
    var localizedBundlePath: String
    
    @Option(help: "Level of panic on invalid keys usage: (error | warning). `error` is default")
    var strictlicity: ReportStrictlicity?
    
    static var configuration = CommandConfiguration(commandName: "check-localize")
    
    func run() async throws {
        let localizeBundleFile = URL(fileURLWithPath: localizedBundlePath)
        
        let checker = SourceFileBatchChecker(
            sourceFiles: try files,
            localizeBundleFile: localizeBundleFile
        )
        let reportPrinter = ReportPrinter(
            formatter: XcodeReportFormatter(strictlicity: strictlicity ?? .error)
        )
        
        let start = ProcessInfo.processInfo.systemUptime
        
        if #available(macOS 12, *) {
            for try await report in checker.reports {
                await reportPrinter.print(report)
            }
        } else {
            for report in try checker.getReports() {
                reportPrinter.printOnMainQueue(report)
            }
        }
        
        let end = ProcessInfo.processInfo.systemUptime
        
        print("✅ LocalizeChecker took \(end - start) seconds")
    }
    
}

extension ReportStrictlicity: ExpressibleByArgument {}

// MARK: - Source Files

private extension LocalizeCheckerCLI {
    
    private var files: [String] {
        get throws {
            try sourcesDirectory.map(parseSourceDirectory)
            ?? self.sourceFiles
        }
    }
    
    private var sourcesDirectoryUrl: URL? {
        sourcesDirectory.map {
            URL(fileURLWithPath: $0, isDirectory: true)
        }
    }

    private func parseSourceDirectory(_ directoryPath: String) throws -> [String] {
        let fileManager = FileManager()
        guard let sourcesEnumerator = fileManager.enumerator(
            at: URL(fileURLWithPath: directoryPath, isDirectory: true),
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles, .skipsPackageDescendants]
        ) else {
            throw Error.sourcesFileEnumerationFailed
        }
        
        return try sourcesEnumerator
            .compactMap { $0 as? URL }
            .filter { $0.pathExtension == "swift" }
            .filter {
                let attributes = try $0.resourceValues(
                    forKeys: [.isRegularFileKey]
                )
                return attributes.isRegularFile ?? false
            }
            .map(\.path)
    }
    
}

extension LocalizeCheckerCLI {

    enum Error: Swift.Error {
        case sourcesFileEnumerationFailed
    }
    
}
