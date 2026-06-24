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

    private func parseSourceDirectory(_ directoryPath: String) throws -> [String] {
        let fileManager = FileManager()
        guard let sourcesEnumerator = fileManager.enumerator(
            at: URL(fileURLWithPath: directoryPath, isDirectory: true),
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles, .skipsPackageDescendants]
        ) else {
            throw SourceFileTraversalError.sourcesFileEnumerationFailed
        }

        var paths: [String] = []
        for case let url as URL in sourcesEnumerator {
            guard url.pathExtension == "swift" else { continue }
            // The enumerator was created with `.isRegularFileKey` prefetched,
            // so reading the resource value here hits the cached value and
            // avoids an extra `stat` syscall per file.
            let attributes = try url.resourceValues(forKeys: [.isRegularFileKey])
            guard attributes.isRegularFile == true else { continue }
            paths.append(url.path)
        }
        return paths
    }

}

public enum SourceFileTraversalError: Swift.Error {
    case sourcesFileEnumerationFailed
}
