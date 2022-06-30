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
    
    func testParsedBundleContaintsKeyWithCDATA() throws {
        // Given
        let key = "common_donates_screen_description"
        let directoryPath = Bundle.module.resourceURL?.appendingPathComponent("Fixtures/short_cdata_lproj").path
        
        // When
        XCTAssertNotNil(directoryPath)
        let bundle = try LocalizeBundle(directoryPath: directoryPath!)
        
        // Then
        XCTAssertNotNil(bundle[key], "The [\(key)] was found but shouldn't be!")
    }
    
    func testParsedBundleContaintsKeyWithComplexCDATA() throws {
        // Given
        let key = "banking_tariff_upgrade_terms"
        let directoryPath = Bundle.module.resourceURL?.appendingPathComponent("Fixtures/short_cdata_complex_lproj").path
        
        // When
        XCTAssertNotNil(directoryPath)
        let bundle = try LocalizeBundle(directoryPath: directoryPath!)
        
        // Then
        XCTAssertNotNil(bundle[key], "The [\(key)] was found but shouldn't be!")
    }
    
//    banking_tariff_upgrade_terms
    
    func testParsedBundleNotContaintUnknownKey() throws {
        // Given
        let key = "louis_ck_falafel"
        let directoryPath = Bundle.module.resourceURL?.appendingPathComponent("Fixtures/enlproj").path
        
        // When
        XCTAssertNotNil(directoryPath)
        let bundle = try LocalizeBundle(directoryPath: directoryPath!)
        
        // Then
        XCTAssertNil(bundle[key], "The [\(key)] was found but shouldn't be!")
    }
    
}
