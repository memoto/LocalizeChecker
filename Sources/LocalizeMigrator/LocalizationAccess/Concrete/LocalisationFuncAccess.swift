import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder

struct LocalisationFuncAccess {
    let memberAccess: LocalisationMemberAccess
    let argumentList: TupleExprElementListSyntax
    let context: LocalisationAccessContext
    
    init?(
        _ node: FunctionCallExprSyntax,
        context: LocalisationAccessContext
    ) {
        guard
            let firstChild = node.children.first?
                .as(MemberAccessExprSyntax.self),
            let memberAccess = LocalisationMemberAccess(firstChild, context: context) else {
            return nil
        }
        
        argumentList = node.argumentList
        self.memberAccess = memberAccess
        self.context = context
    }
}

extension LocalisationFuncAccess {
    var syntax: SyntaxFactory.Type { SyntaxFactory.self }
}

extension LocalisationFuncAccess {
    
    var stringLiteralForm: FunctionCallExprSyntax {
        
        return syntax.makeFunctionCallExpr(
            calledExpression: ExprSyntax(memberAccess.stringLiteralForm),
            leftParen: syntax.makeLeftParenToken(),
            argumentList: fixedArgumentList ?? argumentList,
            rightParen: syntax.makeRightParenToken(),
            trailingClosure: nil,
            additionalTrailingClosures: nil
        )
    }
    
    var fixedArgumentList: TupleExprElementListSyntax? {
        guard let firstArgument = argumentList.first,
              let firstLabel = context.firstLabel else {
            return nil
        }
        
        return argumentList.replacing(
            childAt: 0,
            with: firstArgument
                .withLabel(
                    TokenSyntax.identifier(firstLabel)
                )
                .withColon(syntax.makeColonToken(trailingTrivia: .spaces(1)))
        )
    }
    
}
