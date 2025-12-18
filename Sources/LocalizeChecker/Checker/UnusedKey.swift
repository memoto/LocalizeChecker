import Foundation

public struct UnusedKeyMessage: Equatable, Hashable, Codable, Sendable {
    /// Key of the localized string in the dictionary
    public let key: String
}
