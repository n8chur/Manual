import SwaggerParser
import Foundation

final class FixtureRequest: Encodable {
    let method: OperationType
    let body: String
    let jsonBody: JSON?
    let parameters: FixtureRequestParameters
    let path: String
    let url: String
    let headers: [String: String?]

    enum CodingKeys: String, CodingKey {
        case body
        case jsonBody = "json_body"
        case method
        case parameters
        case path
        case url
        case headers
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.body, forKey: .body)
        try container.encode(self.jsonBody, forKey: .jsonBody)
        let method = self.method.rawValue.uppercased()
        try container.encode(method, forKey: .method)
        try container.encode(self.parameters, forKey: .parameters)
        try container.encode(self.path, forKey: .path)
        try container.encode(self.url, forKey: .url)
        try container.encode(self.headers, forKey: .headers)
    }

    required init(method: OperationType, scheme: String, host: String, basePath: String?, pathTemplate: String, parameters: [Parameter], definitions: [String: Schema]) throws {
        self.method = method
        (self.jsonBody, self.body) = try parameters.bodies(with: definitions)
        self.parameters = try FixtureRequestParameters(parameters)
        self.path = try parameters.path(withPathTemplate: pathTemplate)
        self.headers = try parameters.examples(forType: .header)
        self.url = self.parameters.query.urlWith(scheme: scheme, host: host, basePath: basePath, path: path)
    }
}

private extension Array where Element == Parameter {
    func path(withPathTemplate pathTemplate: String) throws -> String {
        let pathVariableMap = try examples(forType: .path)
        var path = pathTemplate
        pathVariableMap.forEach {
            path = path.replacingOccurrences(of: "{\($0.key)}", with: $0.value ?? "")
        }
        
        return path
    }
}

private extension Dictionary where Key == String, Value == String? {
    /// The receiver of this function should represent query parameters.
    func urlWith(scheme: String, host: String, basePath: String?, path: String) -> String {
        let basePath = basePath ?? "/"
        
        var queryItems: [URLQueryItem]?
        if self.count > 0 {
            queryItems = map {URLQueryItem(name: $0.key, value: $0.value)}
        }
        
        var urlComponents = URLComponents()
        urlComponents.scheme = scheme
        urlComponents.host = host
        urlComponents.path = basePath.withTrailingForwardslash + path
        urlComponents.queryItems = queryItems
        return urlComponents.url!.absoluteString
    }
}
