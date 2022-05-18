import Foundation
import SwiftSyntax

struct LocalisationAccess {
    
    static func `for`(_ node: MemberAccessExprSyntax) -> LocalisationMemberAccess? {
        LocalisationMemberAccess(
            node,
            context: .default
        )
    }
    
    static func `for`(_ node: FunctionCallExprSyntax) -> LocalisationFuncAccess? {
        LocalisationFuncAccess(
            node,
            context: .default
        )
    }
    
}
