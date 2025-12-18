import Foundation
@preconcurrency import SwiftSyntax

struct LocalizeEntry: Hashable, Sendable {
    let key: String
    let sourceLocation: SourceLocation
}
