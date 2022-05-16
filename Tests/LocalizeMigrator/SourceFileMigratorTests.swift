import Foundation
import XCTest
@testable import LocalizeMigrator

final class SourceFileMigratorTests: XCTestCase {
    
    override func setUp() {
        XCTAssertNoThrow(
            try FileManager().createDirectory(atPath: ".fixtures", withIntermediateDirectories: true)
        )
    }
    
    override func tearDown() {
        XCTAssertNoThrow(
            try FileManager().removeItem(atPath: ".fixtures")
        )
    }
 
    func testSimplePropertyAccessMigrated() throws {
        // Given
        let fileUrl = Bundle.module
            .url(forResource: "MigrateMe", withExtension: "swift", subdirectory: "Fixtures")!
        let estimatedOutput = try Bundle.module
            .url(forResource: "MeMigrated", withExtension: "swift", subdirectory: "Fixtures")
            .map(String.init(contentsOf:))!
        let outputFileUrl = URL(fileURLWithPath: ".fixtures")
            .appendingPathComponent("MigratedMe.swift")
        let sourceMigrator = SourceFileMigrator(fileUrl: fileUrl, output: outputFileUrl)
        
        // When
        try sourceMigrator.start()
        
        // Then
        let migratedContent = try String(contentsOf: outputFileUrl)
        XCTAssertEqual(estimatedOutput, migratedContent)
    }
    
    func testParameteredPropertyAccessMigrated() throws {
        // Given
        let fileUrl = Bundle.module
            .url(forResource: "MigrateMeWithParams", withExtension: "swift", subdirectory: "Fixtures")!
        let estimatedOutput = try Bundle.module
            .url(forResource: "MeMigratedWithParams", withExtension: "swift", subdirectory: "Fixtures")
            .map(String.init(contentsOf:))!
        let outputFileUrl = URL(fileURLWithPath: ".fixtures")
            .appendingPathComponent("MigrateMeWithParams.swift")
        let sourceMigrator = SourceFileMigrator(fileUrl: fileUrl, output: outputFileUrl)
        
        // When
        try sourceMigrator.start()
        
        // Then
        let migratedContent = try String(contentsOf: outputFileUrl)
        XCTAssertEqual(estimatedOutput, migratedContent)
    }
    
    func testNoLocalizationContentFileDoesNotChange() throws {
        // Given
        let fileUrl = Bundle.module
            .url(forResource: "DontMigrateMe", withExtension: "swift", subdirectory: "Fixtures")!
        let outputFileUrl = URL(fileURLWithPath: ".fixtures")
            .appendingPathComponent("MigratedMe.swift")
        let sourceMigrator = SourceFileMigrator(fileUrl: fileUrl, output: outputFileUrl)
        
        // When
        try sourceMigrator.start()
        
        // Then
        let migratedContent = try? String(contentsOf: outputFileUrl)
        XCTAssertNil(migratedContent)
    }
    
}
