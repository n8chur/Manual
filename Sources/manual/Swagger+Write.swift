import Foundation
import SwaggerParser
import FixtureGen
import GoGen

extension Swagger {
    func writeFixtures(in containingURL: URL) throws {
        try FileManager.default.createDirectoryIfItDoesNotExist(atURL: containingURL)
        
        let tree = try FixtureGen.FolderTree(swagger: self)
        try tree.write(in: containingURL)
    }
    
    func writeGoModels(in containingURL: URL, withPackageName packageName: String) throws {
        try FileManager.default.createDirectoryIfItDoesNotExist(atURL: containingURL)
        
        let files = try GoGen.File.makeFilesWith(packageName: packageName, swagger: self)
        try files.forEach {try $0.write(in: containingURL)}
    }
}

fileprivate extension FileManager {
    func createDirectoryIfItDoesNotExist(atURL url: URL) throws {
        if !self.fileExists(atPath: url.path) {
            try self.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        }
    }
}
