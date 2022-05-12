import Foundation
import SwiftSyntax
import SwiftSyntaxParser

final class SourceFileChecker {
    
    var errors: [ErrorMessage] = []
    
    private let fileUrl: URL
    private let bundle: LocalizeBundle
    
    init(fileUrl: URL, localizeBundle: LocalizeBundle) throws {
        self.fileUrl = fileUrl
        bundle = localizeBundle
    }
    
    func start() throws {
        guard try fastCheck() else { return }
        
        let syntaxTree = try SyntaxParser.parse(fileUrl)
        let converter = SourceLocationConverter(file: fileUrl.path, tree: syntaxTree)
        let parser = LocalizeParser(converter: converter)
        
        parser.walk(syntaxTree)
        errors = parser.foundKeys
            .filter(notExistsInBundle)
            .compactMap(\.errorMessage)
    }
    
}

private extension SourceFileChecker {
    
    func fastCheck() throws -> Bool {
        try String(contentsOf: fileUrl).contains(".localized")
    }
    
}

// MARK: - SourceFileChecker + Key Existance

private extension SourceFileChecker {
    
    func notExistsInBundle(_ entry: LocalizeEntry) -> Bool {
        bundle[entry.key] == nil
    }
    
}
