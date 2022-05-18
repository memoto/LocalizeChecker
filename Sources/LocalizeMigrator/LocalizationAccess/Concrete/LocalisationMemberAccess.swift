import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder

struct LocalisationMemberAccess {
    let context: LocalisationAccessContext
    let keyIdentifier: String
    
    init?(
        _ node: MemberAccessExprSyntax,
        context: LocalisationAccessContext
    ) {
        guard let firstChild = node.children.first?
            .as(IdentifierExprSyntax.self) else {
            return nil
        }
        
        guard
            firstChild.identifier.text == context.namespace,
            firstChild.nextToken?.tokenKind == .period,
            let key = firstChild.nextToken?.nextToken?.text
        else {
            return nil
        }
        
        self.keyIdentifier = key
        self.context = context
    }
    
}

extension LocalisationMemberAccess {
    
    var stringLiteralForm: MemberAccessExprSyntax {
        SyntaxFactory.makeMemberAccessExpr(
            base: keyIdentifier.createStringLiteralExpr()
                .buildExpr(format: Format()),
            dot: TokenSyntax.period,
            name: TokenSyntax.identifier(context.localizeFuncName),
            declNameArguments: nil
        )
    }
    
}
