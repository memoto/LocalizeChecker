import XCTest
@testable import LocalizeChecker

final class ReportFormatter: XCTestCase {
    
    func testXcodeFormatterForValidReportProducesValidFormat() {
        // Given
        let strictlicity = ReportStrictlicity.error
        let formatter = XcodeReportFormatter(strictlicity: strictlicity)
        let errorMessage = ErrorMessage(key: "tap_me", file: "ProfileView.swift", line: 23, column: 14)
        
        // When
        let formattedMessage = formatter.format(errorMessage)
        
        // Then
        XCTAssertEqual(
            formattedMessage,
            "ProfileView.swift23:14:error: 💂‍♀️ Localization [tap_me] referenced in ProfileView.swift is missing in the original bundle"
        )
    }
    
}
