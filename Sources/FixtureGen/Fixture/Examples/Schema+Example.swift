import SwaggerParser

extension Schema {
    func example(with definitions: [String: Schema], forSchemaNamed name: String? = nil) throws -> Any? {
        switch self.type {
        case .structure(let structure): return try structure.example(with: definitions)
        case .object(let schema): return try schema.example(with: definitions, metadata: self.metadata)
        case .array(let schema): return try schema.example(with: definitions, metadata: self.metadata)
        case .allOf(let schema): return try schema.example(with: definitions, forSchemaNamed: name)
        case .string(let format): return try self.metadata.example(withFormat: format)
        case .number(let format): return try self.metadata.example(withFormat: format)
        case .integer(let format): return try self.metadata.example(withFormat: format)
        case .enumeration(_): return try self.metadata.enumerationExample()
        case .boolean: return try self.metadata.boolExample()
        case .null: return nil
        case .file: throw ExampleError.unsupportedSchemaType(self)
        case .any: return try self.metadata.anyExample()
        }
    }
    
    var discriminator: String? {
        switch self.unwrapped.type {
        case .allOf(let allOf): return allOf.discriminator
        case .object(let objectSchema): return objectSchema.metadata.discriminator
        case .structure(let structure): return structure.structure.discriminator
        default: return nil
        }
    }
    
    // If the schema is a .structure, returns the structure's `structure`
    // (recursively if necessary), otherwise returns self.
    var unwrapped: Schema {
        if case .structure(let structure) = self.type {
            return structure.structure.unwrapped
        }
        
        return self
    }
}
