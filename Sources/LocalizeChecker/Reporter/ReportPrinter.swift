import Foundation

public final class ReportPrinter {
    
    private let formatter: ReportFormatter
    
    public init(formatter: ReportFormatter) {
        self.formatter = formatter
    }
    
    @MainActor
    public func print(_ message: ErrorMessage) {
        Swift.print(formatter.format(message))
    }
    
    @available(macOS, deprecated: 12, obsoleted: 13, message: "Prefer modern actor based version of this method")
    public func printOnMainQueue(_ message: ErrorMessage) {
        DispatchQueue.main.async { [formatter] in
            Swift.print(formatter.format(message))
        }
    }
}


