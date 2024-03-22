import Foundation
import ArgumentParser
import LocalizeChecker

@main
struct LocalizeCheckerCLI: AsyncParsableCommandProtocol, SourceFilesTraversalTrait {
    @Argument(help: "Files which to scan")
    var sourceFiles: [String] = []

    @Option(help: "Directory containing sources to scan recursively")
    var sourcesDirectory: String?
    
    @Option(help: "Path to the lproj directory with localized strings")
    var localizedBundlePath: String
    
    @Option(help: "Level of panic on invalid keys usage: (error | warning). `error` is default")
    var strictlicity: ReportStrictlicity?
    
    static var configuration = CommandConfiguration(
        commandName: "check-localize",
        abstract: "Scans for misused localization keys in your project sources",
        version: "0.1.2"
    )
    
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
        
        for try await report in try checker.reports {
            await reportPrinter.print(report)
        }
        
        let end = ProcessInfo.processInfo.systemUptime
        
        print("✅ LocalizeChecker took \(end - start) seconds")
    }
    
}

extension ReportStrictlicity: ExpressibleByArgument {}
