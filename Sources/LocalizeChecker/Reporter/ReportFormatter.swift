import Foundation

public protocol ReportFormatter {
    
    func format(_ message: ErrorMessage) -> String
}
