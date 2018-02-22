import SwaggerParser

final class RootInfo: JSONFile {
    let filename = "info.json"
    let host: String
    let scheme: String
    let basePath: String?
    let folderPaths: [String]
    let examplePaths: [String]

    enum CodingKeys: String, CodingKey {
        case host
        case scheme
        case basePath = "base_path"
        case folderPaths = "folder_paths"
        case examplePaths = "example_paths"
    }
    
    required init(scheme: String, host: String, basePath: String?, folderPaths: [String], examplePaths: [String]) throws {
        self.host = host
        self.scheme = scheme
        self.basePath = basePath
        self.folderPaths = folderPaths
        self.examplePaths = examplePaths
    }
}
