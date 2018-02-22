import SwaggerParser

final class PathInfo: JSONFile {
    let filename = "info.json"
    let template: String
    let fixturePaths: [String]

    enum CodingKeys: String, CodingKey {
        case template = "path_template"
        case fixturePaths = "fixtures"
    }
    
    required init(pathString: String, fixturePaths: [String]) {
        self.template = pathString.removingLeadingForwardslash.withTrailingForwardslash
        self.fixturePaths = fixturePaths
    }
}
