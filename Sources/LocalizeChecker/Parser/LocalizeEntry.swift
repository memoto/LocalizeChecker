import Foundation
import SwiftSyntax

struct LocalizeEntry: Hashable {
    let key: String
    let sourceLocation: SourceLocation
}
