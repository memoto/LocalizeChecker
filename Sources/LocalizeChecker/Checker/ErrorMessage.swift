import Foundation
import SwiftSyntax

/// Contains all necessary meta data to locate and describe localization check error
public struct ErrorMessage: Equatable, Codable {
    /// Key of the localized string in the dictionary
    let key: String
    
    /// Name of the source file where the key is located
    let file: String
    
    /// Line in the source file
    let line: Int
    
    /// Column in the source file
    let column: Int
}

extension ErrorMessage {
    
    var baseFilename: String {
        URL(fileURLWithPath: file).lastPathComponent
    }
    
    var description: String {
        """
        💂‍♀️ Localization [\(key)] is missing in the original bundle
        """
    }
    
}

extension ErrorMessage {
    
    init(entry: LocalizeEntry) {
        self.key = entry.key
        self.file = entry.sourceLocation.file
        self.line = entry.sourceLocation.line
        self.column = entry.sourceLocation.column
    }
    
}

extension LocalizeEntry {
    
    var errorMessage: ErrorMessage? {
        ErrorMessage(entry: self)
    }
    
}
