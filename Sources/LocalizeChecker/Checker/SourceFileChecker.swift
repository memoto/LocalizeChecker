import Foundation
import SwiftSyntax
import SwiftParser

final class SourceFileChecker {

    var errors: [ErrorMessage] = []
    var usedKeys: [LocalizeEntry] = []
    var unusedKeys: [String] = []

    private let fileUrl: URL
    private let bundle: LocalizeBundle
    private let marker: String

    init(fileUrl: URL,
         localizeBundle: LocalizeBundle,
         literalMarker: String = "localized"
    ) throws {
        self.fileUrl = fileUrl
        self.bundle = localizeBundle
        self.marker = ".\(literalMarker)"
    }

    func start() throws {
        // Read the file once and use the same string for both the fast-path
        // scan and SwiftSyntax parsing. The previous implementation re-read
        // the file via `String(contentsOf:)` inside `fastCheck()` and again
        // in `start()`, doubling I/O and UTF-8 decoding for every source file.
        let source = try String(contentsOf: fileUrl, encoding: .utf8)
        guard source.contains(marker) else { return }

        let syntaxTree = Parser.parse(source: source)
        let converter = SourceLocationConverter(fileName: fileUrl.path, tree: syntaxTree)
        let parser = LocalizeParser(converter: converter)

        parser.walk(syntaxTree)
        let foundKeys = parser.foundKeys
        errors = foundKeys
            .filter(notExistsInBundle)
            .compactMap(\.errorMessage)
        usedKeys = foundKeys

        // Avoid an O(N*M) `contains(where:)` over `foundKeys` for every bundle
        // key — build a hash set once.
        let foundKeySet = Set(foundKeys.map(\.key))
        unusedKeys = bundle.keys.filter { !foundKeySet.contains($0) }
    }

}

// MARK: - SourceFileChecker + Key Existence

private extension SourceFileChecker {

    func notExistsInBundle(_ entry: LocalizeEntry) -> Bool {
        bundle[entry.key] == nil
    }

}
