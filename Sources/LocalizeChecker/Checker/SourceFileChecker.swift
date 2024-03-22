import Foundation
import SwiftSyntax
import SwiftParser

final class SourceFileChecker {
    
    var errors: [ErrorMessage] = []
    
    private let fileUrl: URL
    private let bundle: LocalizeBundle
    private let literalMarker: String
    
    init(fileUrl: URL,
         localizeBundle: LocalizeBundle,
         literalMarker: String = "localized"
    ) throws {
        self.fileUrl = fileUrl
        bundle = localizeBundle
        self.literalMarker = literalMarker
    }
    
    func start() throws {
        guard try fastCheck() else { return }
        
        let syntaxTree = Parser.parse(source: try String(contentsOf: fileUrl))
        let converter = SourceLocationConverter(fileName: fileUrl.path, tree: syntaxTree)
        let parser = LocalizeParser(converter: converter)
        
        parser.walk(syntaxTree)
        errors = parser.foundKeys
            .filter(notExistsInBundle)
            .compactMap(\.errorMessage)
    }
    
}

private extension SourceFileChecker {
    
    func fastCheck() throws -> Bool {
        try String(contentsOf: fileUrl).contains(".\(literalMarker)")
    }
    
}

// MARK: - SourceFileChecker + Key Existance

private extension SourceFileChecker {
    
    func notExistsInBundle(_ entry: LocalizeEntry) -> Bool {
        bundle[entry.key] == nil
    }
    
}
