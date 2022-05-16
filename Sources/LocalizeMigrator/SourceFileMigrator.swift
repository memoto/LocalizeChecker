import Foundation
import SwiftSyntax
import SwiftSyntaxParser

public final class SourceFileMigrator {
    
    private let inputFileUrl: URL
    private let outputFileUrl: URL
    
    public init(fileUrl: URL, output: URL? = nil) {
        inputFileUrl = fileUrl
        outputFileUrl = output ?? inputFileUrl
    }
    
    public func start() throws {
        guard try fastCheck() else { return }
        
        let syntaxTree = try SyntaxParser.parse(inputFileUrl)
        let rewriter = LocalizationCallRewriter()
        let rewritten = rewriter.visit(syntaxTree)
        let rewrittenText = rewritten.description
        try rewrittenText.write(to: outputFileUrl, atomically: true, encoding: .utf8)
        
    }
    
}

private extension SourceFileMigrator {
    
    func fastCheck() throws -> Bool {
        try String(contentsOf: inputFileUrl).contains("Localisation.")
    }

}
