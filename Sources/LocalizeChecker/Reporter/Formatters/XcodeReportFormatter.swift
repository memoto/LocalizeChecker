import Foundation

/// Formats localization check error to the suitable format for Xcode
public struct XcodeReportFormatter: ReportFormatter {
    
    private let strictlicity: ReportStrictlicity
    
    public init(strictlicity: ReportStrictlicity) {
        self.strictlicity = strictlicity
    }
    
    public func format(_ message: ErrorMessage) -> String {
        
        // {full_path_to_file}{:line}{:character}: {error,warning}: {content}
        return [
            "\(message.file):",
            "\(message.line):",
            "\(message.column): ",
            "\(strictlicity.rawValue): ",
            "\(message.description)"
        ].joined()
    }
    
}
