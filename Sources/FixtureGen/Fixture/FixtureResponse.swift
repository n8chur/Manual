import SwaggerParser
import Foundation

enum FixtureResponseError: Error {
    case invalidJSONObjectError(Any?)

    var description: String {
        switch self {
        case .invalidJSONObjectError(let json):
            return "Unsupported JSON object found for fixture response JSON body: \(String(describing: json))"
        }
    }
}

final class FixtureResponse: Encodable {
    let statusCode: Int
    let body: String
    let jsonBody: JSON?
    let headers: [String: String?]

    enum CodingKeys: String, CodingKey {
        case body
        case jsonBody = "json_body"
        case statusCode = "status_code"
        case headers
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.body, forKey: .body)
        try container.encode(self.jsonBody, forKey: .jsonBody)
        try container.encode(self.statusCode, forKey: .statusCode)
        try container.encode(self.headers, forKey: .headers)
    }

    required init(statusCode: Int, jsonBody: JSON?, body: String, headers: [String: String?]) {
        self.statusCode = statusCode
        self.body = body
        self.jsonBody = jsonBody
        self.headers = headers
    }
}

extension Response {
    func fixtureResponseWith(statusCode: Int, definitions: [String: Schema]) throws -> FixtureResponse {
        var example: Any?
        if let schema = self.schema {
            example = try schema.example(with: definitions)
        }
        let (jsonBody, body) = try FixtureGen.bodies(withExample: example)
        
        return FixtureResponse(statusCode: statusCode, jsonBody: jsonBody, body: body, headers: try headers.example())
    }
}

extension Dictionary where Key == String, Value == Items {
    func example() throws -> [String: String?] {
        var headers = [String: String]()
        try forEach {
            let example = try $0.value.example(forType: .header, withName: $0.key)
            headers[$0.key] = (example != nil) ? String(describing: example!) : nil
        }
        
        return headers
    }
}
