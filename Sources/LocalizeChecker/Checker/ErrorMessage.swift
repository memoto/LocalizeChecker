import Foundation
import SwiftSyntax

public struct ErrorMessage: Equatable, Codable {
    let key: String
    let file: String
    let line: Int
    let column: Int
}

extension ErrorMessage {
    
    var baseFilename: String {
        URL(fileURLWithPath: file).lastPathComponent
    }
    
    var description: String {
        """
        💂‍♀️ Localization [\(key)] referenced in \(file) is missing in the original bundle
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
