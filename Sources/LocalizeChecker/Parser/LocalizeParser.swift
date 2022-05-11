import Foundation
import SwiftSyntax

final class LocalizeParser: SyntaxVisitor {

    var isCorrect: Bool = false
    var foundKeys: [LocalizeEntry] = []
    
    let converter: SourceLocationConverter
    
    init(converter: SourceLocationConverter) {
        self.converter = converter
    }
    
    override func visit(_ node: StringLiteralExprSyntax) -> SyntaxVisitorContinueKind {
        guard
            node.nextToken?.tokenKind == TokenKind.period,
            node.nextToken?.nextToken?.tokenKind == TokenKind.identifier("localized")
        else {
            return .skipChildren
        }
        
        for segment in node.segments {
            let key = String(describing: segment)
            let start = segment.startLocation(converter: converter)
            foundKeys.append(
                .init(key: key, sourceLocation: start)
            )
        }
        return .skipChildren
    }
    
}
