import Foundation
import SwaggerParser

final public class Folder {
    public let name: String
    public var subfolders = [Folder]()
    public var files = [File]()

    public init(name: String) {
        self.name = name
    }
}

// MARK: Folder - Writable

extension Folder: Writable {
    public func write(in containingURL: URL) throws {
        let folderURL = containingURL.appendingPathComponent(self.name)
        
        let fileManager = FileManager.default
        
        if fileManager.fileExists(atPath: folderURL.path) {
            try fileManager.removeItem(at: folderURL)
        }
        
        try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: false, attributes: nil)
        
        for file in self.files {
            try file.write(in: folderURL)
        }
        
        for folder in self.subfolders {
            try folder.write(in: folderURL)
        }
    }
}
