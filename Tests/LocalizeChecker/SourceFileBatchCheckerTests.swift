import XCTest
import Foundation
@testable import LocalizeChecker

final class SourceFileBatchCheckerTests: XCTestCase {
    
    func inputSource(withLocalizeKey key: String) -> String {
        """
        func setupButton() {
           button.configure(title: "\(key)".localized)
        }
        """
    }
    
    func fileName(_ id: Int) -> String {
        "localize_check_test_\(id).swift"
    }
    
    func filePath(_ id: Int) -> String {
        ".fixtures/\(fileName(id))"
    }
    
    func fileUrl(_ id: Int) -> URL {
        URL(fileURLWithPath: filePath(id))
    }
    
    private func setup(input: String, fileId: Int) {
        XCTAssertNoThrow(
            try FileManager().createDirectory(atPath: ".fixtures", withIntermediateDirectories: true)
        )
        XCTAssertNoThrow(
            try input.write(toFile: filePath(fileId), atomically: true, encoding: .utf8)
        )
    }
    
    override class func tearDown() {
        XCTAssertNoThrow(
            try FileManager().removeItem(atPath: ".fixtures")
        )
    }
    
}

extension SourceFileBatchCheckerTests {
    
    func testAllFilesProcessed() async throws {
        // Given
        let stringsBundleUrl = Bundle.module.resourceURL?.appendingPathComponent("Fixtures/enlproj")
        let filesIdRange = 0...400
        let fileNames = filesIdRange.map(fileName)
        let files = filesIdRange.map(filePath)
        for id in filesIdRange {
            setup(
                input: inputSource(
                    withLocalizeKey: "do_you_know_me"),
                fileId: id
            )
        }
        let checker = SourceFileBatchChecker(
            sourceFiles: files,
            localizeBundleFile: stringsBundleUrl!
        )
        
        // When
        let start = ProcessInfo.processInfo.systemUptime
        let processedFilenames: [String] = try await checker.processedFiles.reduce([]) {
            $0 + [$1]
        }
        
        let end = ProcessInfo.processInfo.systemUptime
        
        // Then
        XCTAssertEqual(processedFilenames.sorted(), fileNames.sorted())
        XCTAssertLessThan(end - start, 1.2)
    }
    
    func testIfHalfWrongFilesProducedErrors() async throws {
        // Given
        let stringsBundleUrl = Bundle.module.resourceURL?.appendingPathComponent("Fixtures/enlproj")
        let filesIdRange = 0...1000
        let wrongFilesIdRange = 0..<filesIdRange.upperBound/2
        let rightFilesIdRange = filesIdRange.upperBound/2...filesIdRange.upperBound
        let wrongFiles = wrongFilesIdRange.map(fileName)
        for id in wrongFilesIdRange {
            setup(
                input: inputSource(
                    withLocalizeKey: "do_you_know_me"),
                fileId: id
            )
        }
        for id in rightFilesIdRange {
            setup(
                input: inputSource(
                    withLocalizeKey: "category_name_cash"),
                fileId: id
            )
        }
        
        let checker = SourceFileBatchChecker(
            sourceFiles: wrongFilesIdRange.map(filePath),
            localizeBundleFile: stringsBundleUrl!
        )
        
        // When
        let processedFiles: [String] = try await checker.processedFiles.reduce([]) {
            $0 + [$1]
        }
        
        // Then
        XCTAssertEqual(processedFiles.sorted(), wrongFiles.sorted())
    }
    
    func testAllProcessedFilesContainsCorrespondingErrors() async throws {
        // Given
        let stringsBundleUrl = Bundle.module.resourceURL?.appendingPathComponent("Fixtures/enlproj")
        let filesIdRange = 0...20
        let files = filesIdRange.map(filePath)
        for id in filesIdRange {
            setup(
                input: inputSource(
                    withLocalizeKey: "do_you_know_me"),
                fileId: id
            )
        }
        XCTAssertNotNil(stringsBundleUrl)
        let checker = SourceFileBatchChecker(
            sourceFiles: files,
            localizeBundleFile: stringsBundleUrl!
        )
        
        // When
        let reports: [ErrorMessage] = try await checker.reports.reduce([]) {
            $0 + [$1]
        }
        
        // Then
        XCTAssertTrue(reports.allSatisfy { $0.key == "do_you_know_me" })
    }
    
    func testAllProcessedFilesDoesNotContainAnyErrors() async throws {
        // Given
        let stringsBundleUrl = Bundle.module.resourceURL?.appendingPathComponent("Fixtures/enlproj")
        let filesIdRange = 0...20
        let files = filesIdRange.map(filePath)
        for id in filesIdRange {
            setup(
                input: inputSource(
                    withLocalizeKey: "category_name_cash"),
                fileId: id
            )
        }
        let checker = SourceFileBatchChecker(
            sourceFiles: files,
            localizeBundleFile: stringsBundleUrl!
        )
        
        // When
        let reports: [ErrorMessage] = try await checker.reports.reduce([]) {
            $0 + [$1]
        }
        
        // Then
        XCTAssertTrue(reports.isEmpty)
    }
    
}
