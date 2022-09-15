import Foundation

enum Localizable: String {
    case strings = "Localizable.strings"
    case dict = "Localizable.stringsdict"
}

/// Represents a merged bundle structure for **Localizable.strings** and **Localizable.stringsdict**
/// Each key can be obtained by subscript
public final class LocalizeBundle {
    
    typealias LocalizeHash = [String : Any]
    
    private let dictionary: LocalizeHash
    
    /// Create bundle from file
    /// - Parameter fileUrl: URL of the strings file
    public init(fileUrl: URL) {
        dictionary = Self.parseStrings(fileUrl: fileUrl)
        
        print("LocalizeBundle(fileUrl:): dict.count = \(dictionary.keys.count)")
    }
    
    /// Create bundle from strings files inside directory
    /// - Parameter directoryPath: path to the directory containing both strings and stringsdict files
    public init(directoryPath: String) throws {
        let directoryUrl = URL(fileURLWithPath: directoryPath, isDirectory: true)
        let fileManager = FileManager()
        let items = try fileManager.contentsOfDirectory(atPath: directoryPath)

        dictionary = try items.reduce(into: [:]) { accDict, item in
            let fileUrl = directoryUrl.appendingPathComponent(item)
            switch Localizable(rawValue: item) {
            case .strings:
                let newDict = Self.parseStrings(
                    fileUrl: fileUrl
                )
                accDict.merge(newDict) { lhs, _ in lhs }
            case .dict:
                let newDict = try NSDictionary(contentsOf: fileUrl, error: ()) as? LocalizeHash
                ?? [:]
                accDict.merge(newDict) { lhs, _ in lhs }
            case .none:
                break
            }
        }
        
        print("LocalizeBundle(directoryPath:): dict.count = \(dictionary.keys.count)")
    }
    
    public subscript(key: String) -> Any? {
        dictionary[key]
    }
    
}

// MARK:- Parsing

private extension LocalizeBundle {
    
    static func parseStrings(fileUrl: URL) -> [String: String] {
        let rawContent = try? String(contentsOf: fileUrl)
        return rawContent.map(Self.parseStrings) ?? [:]
    }
    
    static func parseStrings(content: String) -> [String: String] {
        let dictionary: [String: String] = content
            .split(separator: ";")
            .reduce(into: [:]) { dict, entry in
                let keyValue = entry
                    .split(separator: "=", maxSplits: 1)
                    .map(String.init)
                    .map(trimSpacesAndNewlines)
                    .map(removeQuotes)
                
                guard keyValue.count == 2 else { return }
                dict[keyValue[0]] = keyValue[1]
        }
        
        return dictionary
    }
    
    static func trimSpacesAndNewlines(_ content: String) -> String {
        content.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    static func removeQuotes(_ content: String) -> String {
        content.trimmingCharacters(in: CharacterSet(charactersIn: "\""))
    }
    
}

// MARK:- ExpressibleByStringLiteral

extension LocalizeBundle: ExpressibleByStringLiteral {
    
    convenience public init(stringLiteral string: String) {
        self.init(fileUrl: URL(fileURLWithPath: string))
    }
    
}
