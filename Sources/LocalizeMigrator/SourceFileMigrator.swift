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
        
        let contents = try String(contentsOf: inputFileUrl)
        let negations = #"(?!\bself\b)(?!\bType\b)"#
        let rewrittenContent = contents.replacingOccurrences(
            of: "(?<module>Localisation|localisation).\(negations)(?<key>\\w+)",
            with: #""$2".localized"#,
            options: .regularExpression
        )
        
        try rewrittenContent.write(to: outputFileUrl, atomically: true, encoding: .utf8)
    }
    
}

private extension SourceFileMigrator {
    
    func fastCheck() throws -> Bool {
        try String(contentsOf: inputFileUrl).contains("Localisation.")
    }
    
}
