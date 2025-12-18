import Foundation

public struct UnusedKeyMessage: Equatable, Hashable, Codable {
    /// Key of the localized string in the dictionary
    public let key: String
}
