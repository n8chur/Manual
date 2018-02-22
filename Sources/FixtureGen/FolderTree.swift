import SwaggerParser
import Foundation
import ManualKit

/// This is the primary class for fixture generation.
public struct FolderTree {
    public let swagger: Swagger
    public let scheme: String
    public let host: String
    public let root: Folder
    
    public enum ParseError: Error {
        case hostNotFound
        
        public var description: String {
            switch self {
            case .hostNotFound: return "Host not found in swagger schema"
            }
        }
    }
    
    public init(swaggerURL: URL) throws {
        let swagger = try Swagger(URL: swaggerURL)
        try self.init(swagger: swagger)
    }
    
    public init(swagger: Swagger) throws {
        self.swagger = swagger
        (self.scheme, self.host, self.root) = try swagger.folderTreeProperties()
    }
}

extension FolderTree: Writable {
    public func write(in containingURL: URL) throws {
        try self.root.write(in: containingURL)
    }
}

extension Swagger {
    fileprivate func folderTreeProperties() throws -> (scheme: String, host: String, rootFolder: Folder) {
        guard let host = self.host?.absoluteString else {
            throw FolderTree.ParseError.hostNotFound
        }
        // TODO: Support schemes other than https
        let scheme = "https"
        let rootFolder = try rootFolderWith(scheme: scheme, host: host)
        return (scheme, host, rootFolder)
    }
    
    private func rootFolderWith(scheme: String, host: String) throws -> Folder {
        var (pathFolders, pathFolderPaths) = try pathFoldersWith(scheme: scheme, host: host)
        
        let subfolders: [Folder]
        if let (folder, baseFolderPath) = basePathFolderWith(basePath: self.basePath, subfolders: pathFolders) {
            subfolders = [folder]
            pathFolderPaths = pathFolderPaths.map {baseFolderPath + $0}
        } else {
            subfolders = pathFolders
        }

        let rootFolder = Folder(name: host)
        rootFolder.subfolders = subfolders

        let examplePaths = try rootFolder.addExamples(of: self.definitions)

        let rootInfo = try RootInfo(scheme: scheme, host: host, basePath: basePath, folderPaths: pathFolderPaths, examplePaths: examplePaths)
        rootFolder.files = [rootInfo]

        return rootFolder
    }
    
    func pathFoldersWith(scheme: String, host: String) throws -> (folders: [Folder], folderPaths: [String]) {
        let rootFolder = Folder(name: "")
        var folderPaths = [String]()
        
        for (pathString, path) in self.paths {
            let pathString = pathString.removingLeadingForwardslash
            
            var leafFolder = rootFolder
            for component in (pathString as NSString).pathComponents {
                var matchingNode = leafFolder.subfolders.first {$0.name == component}
                if matchingNode == nil {
                    matchingNode = Folder(name: component)
                    leafFolder.subfolders.append(matchingNode!)
                }
                leafFolder = matchingNode!
            }
            let fixtures = try path.fixturesWith(scheme: scheme, host: host, basePath: self.basePath, pathString: pathString, definitions: self.definitions)
            try leafFolder.add(fixtures: fixtures, withPathString: pathString)
            folderPaths.append(pathString.withTrailingForwardslash)
        }
        
        return (rootFolder.subfolders, folderPaths.sorted())
    }
    
    /// Takes a `basePath` rather than using the `basePath` property on self for
    /// unit testing purposes.
    func basePathFolderWith(basePath: String?, subfolders: [Folder]) -> (folder: Folder, folderPath: String)? {
        guard let path = basePath?.removingLeadingForwardslash, !path.isEmpty else {
            return nil
        }
        
        let folder = recursiveBasePathFolderWith(path: path, subfolders: subfolders)
        
        let folderPath = path.removingLeadingForwardslash.withTrailingForwardslash
        
        return (folder, folderPath)
    }
    
    private func recursiveBasePathFolderWith(path: String, subfolders: [Folder]) -> Folder {
        let name = (path as NSString).lastPathComponent
        let folder = Folder(name: name)
        folder.subfolders = subfolders
        
        let remainingPath = (path as NSString).deletingLastPathComponent
        
        guard !remainingPath.isEmpty else {
            return folder
        }
        
        return recursiveBasePathFolderWith(path: remainingPath, subfolders: [folder])
    }
}
