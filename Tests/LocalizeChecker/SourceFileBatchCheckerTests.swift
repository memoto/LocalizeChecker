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
                input: inputSource(withLocalizeKey: "do_you_know_me"),
                fileId: id
            )
        }
        let checker = SourceFileBatchChecker(
            sourceFiles: files,
            localizeBundleFile: stringsBundleUrl!
        )

        // When
        let start = ProcessInfo.processInfo.systemUptime
        let processedFilenames: [String] = try await checker.processedFiles.reduce([]) { $0 + [$1] }
        let elapsed = ProcessInfo.processInfo.systemUptime - start
        print("⏱ testAllFilesProcessed (\(filesIdRange.count) files): \(String(format: "%.3f", elapsed))s")

        // Then
        XCTAssertEqual(processedFilenames.sorted(), fileNames.sorted())
        XCTAssertLessThan(elapsed, 3.0)
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
                input: inputSource(withLocalizeKey: "do_you_know_me"),
                fileId: id
            )
        }
        for id in rightFilesIdRange {
            setup(
                input: inputSource(withLocalizeKey: "category_name_cash"),
                fileId: id
            )
        }
        let checker = SourceFileBatchChecker(
            sourceFiles: wrongFilesIdRange.map(filePath),
            localizeBundleFile: stringsBundleUrl!
        )

        // When
        let start = ProcessInfo.processInfo.systemUptime
        let processedFiles: [String] = try await checker.processedFiles.reduce([]) { $0 + [$1] }
        let elapsed = ProcessInfo.processInfo.systemUptime - start
        print("⏱ testIfHalfWrongFilesProducedErrors (\(wrongFilesIdRange.count) files): \(String(format: "%.3f", elapsed))s")

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
                input: inputSource(withLocalizeKey: "do_you_know_me"),
                fileId: id
            )
        }
        XCTAssertNotNil(stringsBundleUrl)
        let checker = SourceFileBatchChecker(
            sourceFiles: files,
            localizeBundleFile: stringsBundleUrl!
        )

        // When
        let start = ProcessInfo.processInfo.systemUptime
        let reports: [ErrorMessage] = try await checker.reports.reduce([]) { $0 + [$1] }
        let elapsed = ProcessInfo.processInfo.systemUptime - start
        print("⏱ testAllProcessedFilesContainsCorrespondingErrors (\(filesIdRange.count) files): \(String(format: "%.3f", elapsed))s")

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
                input: inputSource(withLocalizeKey: "category_name_cash"),
                fileId: id
            )
        }
        let checker = SourceFileBatchChecker(
            sourceFiles: files,
            localizeBundleFile: stringsBundleUrl!
        )

        // When
        let start = ProcessInfo.processInfo.systemUptime
        let reports: [ErrorMessage] = try await checker.reports.reduce([]) { $0 + [$1] }
        let elapsed = ProcessInfo.processInfo.systemUptime - start
        print("⏱ testAllProcessedFilesDoesNotContainAnyErrors (\(filesIdRange.count) files): \(String(format: "%.3f", elapsed))s")

        // Then
        XCTAssertTrue(reports.isEmpty)
    }

    func testAllProcessedFilesUseOnlyOneKey() async throws {
        // Given
        let stringsBundleUrl = Bundle.module.resourceURL?.appendingPathComponent("Fixtures/enlproj")
        let filesIdRange = 0...20
        let files = filesIdRange.map(filePath)
        for id in filesIdRange {
            setup(
                input: inputSource(withLocalizeKey: "alert_ok"),
                fileId: id
            )
        }
        XCTAssertNotNil(stringsBundleUrl)
        let checker = SourceFileBatchChecker(
            sourceFiles: files,
            localizeBundleFile: stringsBundleUrl!
        )

        // When
        let start = ProcessInfo.processInfo.systemUptime
        let unusedKeys: [UnusedKeyMessage] = try await checker.unusedKeys
        let elapsed = ProcessInfo.processInfo.systemUptime - start
        print("⏱ testAllProcessedFilesUseOnlyOneKey (\(filesIdRange.count) files): \(String(format: "%.3f", elapsed))s")

        // Then
        XCTAssertEqual(unusedKeys.count, 5435)
    }

    func testAllProcessedFilesDontUseAnyKeys() async throws {
        // Given
        let stringsBundleUrl = Bundle.module.resourceURL?.appendingPathComponent("Fixtures/enlproj")
        let filesIdRange = 0...20
        let files = filesIdRange.map(filePath)
        for id in filesIdRange {
            setup(
                input: inputSource(withLocalizeKey: "do_you_know_me"),
                fileId: id
            )
        }
        XCTAssertNotNil(stringsBundleUrl)
        let checker = SourceFileBatchChecker(
            sourceFiles: files,
            localizeBundleFile: stringsBundleUrl!
        )

        // When
        let start = ProcessInfo.processInfo.systemUptime
        let unusedKeys: [UnusedKeyMessage] = try await checker.unusedKeys
        let elapsed = ProcessInfo.processInfo.systemUptime - start
        print("⏱ testAllProcessedFilesDontUseAnyKeys (\(filesIdRange.count) files): \(String(format: "%.3f", elapsed))s")

        // Then
        XCTAssertEqual(unusedKeys.count, 5436)
    }

}
