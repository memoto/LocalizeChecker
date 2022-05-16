import Foundation

public protocol SourceFilesTraversalTrait {
    var sourceFiles: [String] { get }
    var sourcesDirectory: String? { get }
}

public extension SourceFilesTraversalTrait {
    
    var files: [String] {
        get throws {
            try sourcesDirectory.map(parseSourceDirectory)
            ?? self.sourceFiles
        }
    }
    
    private var sourcesDirectoryUrl: URL? {
        sourcesDirectory.map {
            URL(fileURLWithPath: $0, isDirectory: true)
        }
    }

    private func parseSourceDirectory(_ directoryPath: String) throws -> [String] {
        let fileManager = FileManager()
        guard let sourcesEnumerator = fileManager.enumerator(
            at: URL(fileURLWithPath: directoryPath, isDirectory: true),
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles, .skipsPackageDescendants]
        ) else {
            throw SourceFileTraversalError.sourcesFileEnumerationFailed
        }
        
        return try sourcesEnumerator
            .compactMap { $0 as? URL }
            .filter { $0.pathExtension == "swift" }
            .filter {
                let attributes = try $0.resourceValues(
                    forKeys: [.isRegularFileKey]
                )
                return attributes.isRegularFile ?? false
            }
            .map(\.path)
    }
    
}

public enum SourceFileTraversalError: Swift.Error {
    case sourcesFileEnumerationFailed
}
