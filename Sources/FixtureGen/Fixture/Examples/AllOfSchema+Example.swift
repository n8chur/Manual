import SwaggerParser

extension AllOfSchema {
    func example(with definitions: [String: Schema], forSchemaNamed name: String? = nil) throws -> [String: Any?] {
        var discriminator: String?
        var exampleObjects = try self.subschemas.map { schema -> [String: Any?] in
            switch schema.unwrapped.type {
            case .object(let object):
                discriminator = discriminator ?? object.metadata.discriminator
                return try object.example(with: definitions, metadata: schema.unwrapped.metadata)
            case .allOf(let allOf):
                discriminator = discriminator ?? allOf.discriminator
                return try allOf.example(with: definitions, forSchemaNamed: nil)
            default:
                throw ExampleError.allOfSchemaInvalidType(schema)
            }
        }
        
        if let discriminatorKey = discriminator, let discriminatorValue = name {
            exampleObjects.append([discriminatorKey: discriminatorValue])
        }
        
        var example = exampleObjects.reduce([String: Any?]()) { (result, object) -> [String: Any?] in
            var newResult = result
            object.forEach {
                newResult[$0.key] = $0.value
            }
            return newResult
        }
        
        if let discriminatorKey = discriminator, let discriminatorValue = name {
            example[discriminatorKey] = discriminatorValue
        }
        
        return example
    }
    
    var discriminator: String? {
        return self.subschemas.lazy
            .flatMap {$0.discriminator}
            .first
    }
}
