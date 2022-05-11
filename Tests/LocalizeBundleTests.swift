import XCTest
import SwiftSyntax
@testable import LocalizeChecker

final class LocalizeBundleTests: XCTestCase {
    
    func testParsedBundleWithWhitespacesContainsKeyAccountBlocked() {
        // Given
        let key = "account_blocked_button"
        let fileUrl = Bundle.module
            .url(forResource: "Localizable", withExtension: "strings", subdirectory: "Fixtures/enlproj")!
        
        // When
        let bundle = LocalizeBundle(fileUrl: fileUrl)
        
        // Then
        XCTAssertNotNil(bundle[key], "No [\(key)] was found!")
    }
    
    func testParsedBundleContaintKeyFromStringsDict() throws {
        // Given
        let key = "test_plural_key"
        let directoryPath = Bundle.module.resourceURL?.appendingPathComponent("Fixtures/enlproj").path
        
        // When
        XCTAssertNotNil(directoryPath)
        let bundle = try LocalizeBundle(directoryPath: directoryPath!)
        
        // Then
        XCTAssertNotNil(bundle[key], "No [\(key)] was found!")
    }
    
}
