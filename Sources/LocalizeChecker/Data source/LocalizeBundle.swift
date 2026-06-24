import Foundation

enum Localizable: String {
    case strings = "Localizable.strings"
    case dict = "Localizable.stringsdict"
}

/// Represents a merged bundle structure for **Localizable.strings** and **Localizable.stringsdict**
/// Each key can be obtained by subscript
public final class LocalizeBundle: Sendable {

    typealias LocalizeHash = [String: Any]

    private nonisolated(unsafe) let dictionary: LocalizeHash

    /// Create bundle from file
    /// - Parameter fileUrl: URL of the strings file
    public init(fileUrl: URL) {
        dictionary = Self.parseStrings(fileUrl: fileUrl)
    }

    /// Create bundle from strings files inside directory
    /// - Parameter directoryPath: path to the directory containing both strings and stringsdict files
    public init(directoryPath: String) throws {
        let directoryUrl = URL(fileURLWithPath: directoryPath, isDirectory: true)
        let fileManager = FileManager()
        let items = try fileManager.contentsOfDirectory(atPath: directoryPath)

        let dict: LocalizeHash = try items.reduce(into: [:]) { accDict, item in
            let fileUrl = directoryUrl.appendingPathComponent(item)
            switch Localizable(rawValue: item) {
            case .strings:
                let newDict = Self.parseStrings(fileUrl: fileUrl)
                accDict.merge(newDict) { lhs, _ in lhs }
            case .dict:
                let newDict = try NSDictionary(contentsOf: fileUrl, error: ()) as? LocalizeHash
                    ?? [:]
                accDict.merge(newDict) { lhs, _ in lhs }
            case .none:
                break
            }
        }
        dictionary = dict
    }

    public subscript(key: String) -> Any? {
        dictionary[key]
    }

    public var keys: [String] {
        Array(dictionary.keys)
    }

}

// MARK: - Parsing

private extension LocalizeBundle {

    /// Parses an old-style `.strings` plist using Foundation's NSDictionary loader.
    ///
    /// This replaces the previous hand-rolled tokenizer that split on `;`
    /// — which mis-parsed values containing semicolons and was substantially
    /// slower because of repeated `String` allocations.
    static func parseStrings(fileUrl: URL) -> [String: String] {
        guard let parsed = try? NSDictionary(contentsOf: fileUrl, error: ()) as? [String: String] else {
            return [:]
        }
        return parsed
    }

}

// MARK: - ExpressibleByStringLiteral

extension LocalizeBundle: ExpressibleByStringLiteral {

    public convenience init(stringLiteral string: String) {
        self.init(fileUrl: URL(fileURLWithPath: string))
    }

}
