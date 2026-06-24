import Foundation
import SwiftSyntax

final class LocalizeParser: SyntaxVisitor {

    var foundKeys: [LocalizeEntry] = []

    private let converter: SourceLocationConverter
    private let literalMarker: String
    private let markerTokenKind: TokenKind

    init(converter: SourceLocationConverter, literalMarker: String = "localized") {
        self.converter = converter
        self.literalMarker = literalMarker
        self.markerTokenKind = .identifier(literalMarker)

        super.init(viewMode: .fixedUp)
    }

    override func visit(_ node: StringLiteralExprSyntax) -> SyntaxVisitorContinueKind {
        // Cache the first `nextToken` lookup — every call walks the syntax tree
        // and the original code performed the walk twice in a row.
        guard
            let dotToken = node.nextToken(viewMode: .sourceAccurate),
            dotToken.tokenKind == .period,
            dotToken.nextToken(viewMode: .sourceAccurate)?.tokenKind == markerTokenKind,
            !node.hasInterpolation
        else {
            return .skipChildren
        }

        for segment in node.segments {
            let key: String
            if let stringSegment = segment.as(StringSegmentSyntax.self) {
                key = String(stringSegment.content.text)
            } else {
                key = String(describing: segment)
            }
            let start = segment.startLocation(converter: converter)
            foundKeys.append(.init(key: key, sourceLocation: start))
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
