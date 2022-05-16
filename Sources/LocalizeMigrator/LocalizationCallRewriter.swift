import Foundation
import SwiftSyntax
import SwiftSyntaxParser
import SwiftSyntaxBuilder

final class LocalizationCallRewriter: SyntaxRewriter {
    
    override func visit(_ node: MemberAccessExprSyntax) -> ExprSyntax {
        guard let localisationAccess = LocalisationAccess(node) else {
            return ExprSyntax(node)
        }
        
        return ExprSyntax(localisationAccess.stringLiteralForm)
    }
    
}

private struct LocalisationAccess {
    let keyIdentifier: String
    let argumentsSyntax: DeclNameArgumentsSyntax?
    
    init?(_ node: MemberAccessExprSyntax) {
        guard let firstChild = node.children.first?
            .as(IdentifierExprSyntax.self) else {
            return nil
        }
        
        guard
            firstChild.identifier.text == "Localisation",
            firstChild.nextToken?.tokenKind == .period,
            let key = firstChild.nextToken?.nextToken?.text
        else {
            return nil
        }
        
        argumentsSyntax = node.declNameArguments
        
        keyIdentifier = key
    }
}

private extension LocalisationAccess {
    
    var stringLiteralForm: MemberAccessExprSyntax {
        SyntaxFactory.makeMemberAccessExpr(
            base: keyIdentifier.createStringLiteralExpr()
                .buildExpr(format: Format()),
            dot: TokenSyntax.period,
            name: TokenSyntax.identifier("localized"),
            declNameArguments: argumentsSyntax
        )
    }
    
}
