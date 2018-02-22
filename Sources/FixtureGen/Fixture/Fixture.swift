import SwaggerParser
import Foundation

/// A Fixture file that represents a request/response combination to be used
/// in unit tests by clients that consume the API and by servers that serve it.
final class Fixture: JSONFile {
    let filename: String
    let request: FixtureRequest
    let response: FixtureResponse

    enum CodingKeys: String, CodingKey {
        case request
        case response
    }

    required init(method: OperationType, scheme: String, host: String, basePath: String?, pathTemplate: String, parameters: [Parameter], statusCode: Int, response: Response, definitions: [String: Schema]) throws {
        self.filename = method.rawValue.uppercased() + "-\(statusCode).json"
        self.request = try FixtureRequest(method: method, scheme: scheme, host: host, basePath: basePath, pathTemplate: pathTemplate, parameters: parameters, definitions: definitions)
        self.response = try response.fixtureResponseWith(statusCode: statusCode, definitions: definitions)
    }
}

extension Path {
    func fixturesWith(scheme: String, host: String, basePath: String?, pathString: String, definitions: [String: Schema]) throws -> [Fixture] {
        var fixtures = [Fixture]()
        let pathTemplate = pathString.removingLeadingForwardslash.withTrailingForwardslash
        
        for (method, operation) in self.operations {
            var responses: [(Int?, Response)] = operation.responses.map {($0.key, $0.value.value)}
            if let defaultResponse = operation.defaultResponse {
                responses.append((nil, defaultResponse.value))
            }
            
            for (optionalStatusCode, response) in responses {
                guard let statusCode = optionalStatusCode else {
                    continue
                }
                
                let parameters = (operation.parameters + self.parameters).map {$0.value}
                let fixture = try Fixture(method: method, scheme: scheme, host: host, basePath: basePath, pathTemplate: pathTemplate, parameters: parameters, statusCode: statusCode, response: response, definitions: definitions)
                
                fixtures.append(fixture)
            }
        }
        return fixtures
    }
}
