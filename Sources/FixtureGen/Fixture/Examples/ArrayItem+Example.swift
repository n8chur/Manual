import SwaggerParser

extension ArrayItem {
    func example(forType type: ParameterLocation, metadata: Metadata, withName name: String) throws -> Any {
        if let example = metadata.example {
            return example
        }
        
        // TODO: Consider schema rules.
        let array = try (0..<3).map {_ in return (try self.items.example(forType: type, withName: ""))}
        switch type {
            // Currently assumes a `collectionFormat` of `multi`.
            // TODO: Support other `collectionFormat`s.
        // TODO: Come up with a better way to represent this.
        case .query: return array.compactMap {$0 as? String}.joined(separator: "&\(name)=")
        case .body: return array
        // TODO:
        case .formData: return "TODO"
        // TODO: Fatal error?
        case .header, .path: return "TODO"
        }
    }
}
