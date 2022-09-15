import Foundation
import SwiftSyntax

/// Contains all neccessary meta data to locate and describe localization check error
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
    
    init?(entry: LocalizeEntry) {
        guard
            let file = entry.sourceLocation.file,
            let line = entry.sourceLocation.line,
            let column = entry.sourceLocation.column
        else {
            return nil
        }
        
        key = entry.key
        self.file = file
        self.line = line
        self.column = column
    }
    
}

extension LocalizeEntry {
    
    var errorMessage: ErrorMessage? {
        ErrorMessage(entry: self)
    }
    
}
