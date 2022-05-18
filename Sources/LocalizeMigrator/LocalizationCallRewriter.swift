import Foundation
import SwiftSyntax
import SwiftSyntaxParser
import SwiftSyntaxBuilder

final class LocalizationCallRewriter: SyntaxRewriter {
    
    override func visit(_ node: MemberAccessExprSyntax) -> ExprSyntax {
        guard let localisationAccess = LocalisationAccess.for(node) else {
            return ExprSyntax(node)
        }
        
        return ExprSyntax(localisationAccess.stringLiteralForm)
    }
    
    override func visit(_ node: FunctionCallExprSyntax) -> ExprSyntax {
        guard let localisationAccess = LocalisationAccess.for(node) else {
            return ExprSyntax(node)
        }
        
        return ExprSyntax(localisationAccess.stringLiteralForm)
    }
    
}
