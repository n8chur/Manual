import SwaggerParser

extension Items {
    // TODO: Find a way to specify/consume example content from the swagger
    // spec.
    func example(forType type: ParameterLocation, withName name: String) throws -> Any? {
        switch self.type {
        case .string(let item): return try self.metadata.example(withFormat: item.format)
        case .number(let item): return try self.metadata.example(withFormat: item.format)
        case .integer(let item): return try self.metadata.example(withFormat: item.format)
        case .array(let item): return try item.example(forType: type, metadata: self.metadata, withName: name)
        case .boolean: return try self.metadata.boolExample()
        }
    }
}
