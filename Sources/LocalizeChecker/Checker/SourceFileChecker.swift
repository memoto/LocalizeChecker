import Foundation
import SwiftSyntax
import SwiftSyntaxParser

final class SourceFileChecker: Operation {
    
    var errors: [ErrorMessage] = []
    
    private let syntaxTree: SourceFileSyntax
    private let parser: LocalizeParser
    private let bundle: LocalizeBundle
    
    init(fileUrl: URL, localizeBundle: LocalizeBundle) throws {
        syntaxTree = try SyntaxParser.parse(fileUrl)
        bundle = localizeBundle
        let converter = SourceLocationConverter(file: fileUrl.path, tree: syntaxTree)
        parser = LocalizeParser(converter: converter)
    }
    
    override func main() {
        guard !isCancelled else { return }
        
        parser.walk(syntaxTree)
        errors = parser.foundKeys
            .filter(notExistsInBundle)
            .compactMap(\.errorMessage)
    }
    
}

// MARK: - SourceFileChecker + Key Existance

private extension SourceFileChecker {
    
    func notExistsInBundle(_ entry: LocalizeEntry) -> Bool {
        bundle[entry.key] == nil
    }
    
}
