import XCTest
import Foundation
@testable import LocalizeChecker

final class SourceFileCheckerTests: XCTestCase {
    
    func inputSource(withLocalizeKey key: String) -> String {
        """
        func setupButton() {
           button.configure(title: "\(key)".localized)
        }
        """
    }
    let fileName = ".fixtures/localize_check_test.swift"
    lazy var fileUrl = URL(fileURLWithPath: fileName)
    lazy var defaultBundleUrl = Bundle.module
        .url(forResource: "Localizable", withExtension: "strings", subdirectory: "Fixtures/enlproj")!
    
    override class func tearDown() {
        XCTAssertNoThrow(
            try FileManager().removeItem(atPath: ".fixtures")
        )
    }
    
    override func tearDown() {
        XCTAssertNoThrow(
            try FileManager().removeItem(at: URL(fileURLWithPath: fileName))
        )
    }
    
    private func setup(input: String) {
        XCTAssertNoThrow(
            try FileManager().createDirectory(atPath: ".fixtures", withIntermediateDirectories: true)
        )
        XCTAssertNoThrow(
            try input.write(to: URL(fileURLWithPath: fileName), atomically: true, encoding: .utf8)
        )
    }
    
}

extension SourceFileCheckerTests {
    
    func testSourceFileCheckerWhenAllKnownKeysProducesNoIssues() throws {
        // Given
        setup(input: inputSource(withLocalizeKey: "card_issue_address_details_n_a_option_short"))
        let localizeBundle = LocalizeBundle(fileUrl: defaultBundleUrl)
        
        // When
        let sourceChecker = try SourceFileChecker(
            fileUrl: fileUrl,
            localizeBundle: localizeBundle
        )
        try sourceChecker.start()
        
        // Then
        XCTAssertTrue(sourceChecker.errors.isEmpty, "Should produce no errors, but \(sourceChecker.errors.count) occured")
    }
    
    func testSourceFileCheckerWhenUnknownKeyProducesOneIssue() throws {
        // Given
        setup(input: inputSource(withLocalizeKey: "do_you_know_me"))
        let localizeBundle = LocalizeBundle(fileUrl: defaultBundleUrl)
        let estimatedError = ErrorMessage(
            key: "do_you_know_me",
            file: fileUrl.path,
            line: 2,
            column: 29
        )
        
        // When
        let sourceChecker = try SourceFileChecker(
            fileUrl: fileUrl,
            localizeBundle: localizeBundle
        )
        try sourceChecker.start()
        
        // Then
        XCTAssertEqual(sourceChecker.errors, [estimatedError])
    }
    
    func testSourceFileCheckerOnKeyWithInterpolationProducesNoIssues() throws {
        // Given
        setup(input: inputSource(withLocalizeKey: "do_you_know_me\\(var)"))
        let localizeBundle = LocalizeBundle(fileUrl: defaultBundleUrl)
        
        // When
        let sourceChecker = try SourceFileChecker(
            fileUrl: fileUrl,
            localizeBundle: localizeBundle
        )
        try sourceChecker.start()
        
        // Then
        XCTAssertTrue(sourceChecker.errors.isEmpty)
    }
    
}
