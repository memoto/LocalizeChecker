import Foundation
import ArgumentParser
import LocalizeChecker
import LocalizeMigrator

@main
struct LocalizeMigrator: ParsableCommand, SourceFilesTraversalTrait {

    @Argument(help: "Files which to scan")
    var sourceFiles: [String] = []

    @Option(help: "Directory containing sources to scan recursively")
    var sourcesDirectory: String?

    static var configuration = CommandConfiguration(
        commandName: "migrate-localize",
        abstract: "Rewrites all occcurances of codegen based localization keys with string literal based",
        version: "0.1.2"
    )

    func run() throws {
        for file in try files {
            let migrator = SourceFileMigrator(fileUrl: URL(fileURLWithPath: file))
            try migrator.start()
        }
    }

}

