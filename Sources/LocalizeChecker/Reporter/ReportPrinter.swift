import Foundation

/// Prints checker reports in the given format
public final class ReportPrinter {
    
    private let formatter: ReportFormatter
    
    public init(formatter: ReportFormatter) {
        self.formatter = formatter
    }
    
    @MainActor
    public func print(_ message: ErrorMessage) {
        Swift.print(formatter.format(message))
    }
}


