import SwaggerParser

final class FixtureRequestParameters: Encodable {
    let path: [String: String?]
    let query: [String: String?]

    enum CodingKeys: String, CodingKey {
        case path
        case query
    }

    required init(_ parameters: [Parameter]) throws {
        self.path = try parameters.examples(forType: .path)
        self.query = try parameters.examples(forType: .query)
    }
}
