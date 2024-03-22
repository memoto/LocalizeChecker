import XCTest
import SwiftSyntax
import SwiftParser
@testable import LocalizeChecker

final class LocalizeParserTests: XCTestCase {
    let inputSource = """
    func setupButton() {
       button.configure(title: "welcome_title".localized)
    }
    """
    let inputSource1 = """
    func setupButton() {
       button.configure(title: "welcome_title")
    }
    """
    let inputSource2 = 1
    
    let fileName = "localize_check_test.swift"
    lazy var fileUrl = URL(fileURLWithPath: fileName)
    
    override func tearDown() {
        XCTAssertNoThrow(
            try FileManager().removeItem(at: URL(fileURLWithPath: fileName))
        )
    }
    
    private func setup(input: String) {
        XCTAssertNoThrow(
            try input.write(toFile: fileName, atomically: true, encoding: .utf8)
        )
    }
}

extension LocalizeParserTests {
    
    func testFoundLocalizedString() throws {
        // GIVEN
        setup(input: inputSource)
        let parsed = Parser.parse(source: try String(contentsOf: fileUrl))
        let converter = SourceLocationConverter(fileName: fileUrl.path, tree: parsed)
        let checker = LocalizeParser(converter: converter)
        
        // WHEN
        checker.walk(parsed)
        
        // THEN
        XCTAssertEqual(["welcome_title"], checker.foundKeys.map(\.key))
    }
    
    func testUsualStringLiteralNotTreatedAsLocalizedString() throws {
        // GIVEN
        setup(input: inputSource1)
        let parsed = Parser.parse(source: try String(contentsOf: fileUrl))
        let converter = SourceLocationConverter(fileName: fileUrl.path, tree: parsed)
        let checker = LocalizeParser(converter: converter)
        
        // WHEN
        checker.walk(parsed)
        
        // THEN
        XCTAssertTrue(checker.foundKeys.map(\.key).isEmpty)
    }
    
}
