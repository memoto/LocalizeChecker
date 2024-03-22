import Foundation
import SwiftSyntax

final class LocalizeParser: SyntaxVisitor {

    var foundKeys: [LocalizeEntry] = []
    
    private let converter: SourceLocationConverter
    private let literalMarker: String
    
    init(converter: SourceLocationConverter, literalMarker: String = "localized") {
        self.converter = converter
        self.literalMarker = literalMarker
        
        super.init(viewMode: .fixedUp)
    }
    
    override func visit(_ node: StringLiteralExprSyntax) -> SyntaxVisitorContinueKind {
        guard
            node.nextToken(viewMode: .sourceAccurate)?
                .tokenKind == TokenKind.period,
            node.nextToken(viewMode: .sourceAccurate)?
                .nextToken(viewMode: .sourceAccurate)?
                .tokenKind == TokenKind.identifier(literalMarker),
            !node.hasInterpolation
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

private extension StringLiteralExprSyntax {
    
    var hasInterpolation: Bool {
        segments.contains { syntax in
            syntax.is(ExpressionSegmentSyntax.self)
        }
    }
    
}
