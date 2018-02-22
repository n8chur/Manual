import SwaggerParser

extension ArraySchema {
    func itemType() throws -> Type {
        guard case .one(let schema) = self.items else {
            throw SwaggerError.multipleArrayItemDefinitions(self)
        }
        
        return try schema.itemType()
    }
}

private extension SwaggerParser.Schema {
    func itemType() throws -> Type {
        switch self.type {
        case .structure(let structure):
            return try structure.goType()
            
        case .object(let object):
            guard object.properties.count == 0 else {
                throw SwaggerError.arrayItemObjectCannotContainProperties
            }
            return try object.goType(named: "interface{}", metadata: self.metadata)
            
        case .array(let array):
            return .slice(try array.itemType())
            
        case .allOf:
            throw SwaggerError.arrayItemObjectCannotContainProperties
            
        case .string(_):
            return .string
            
        case .number(let format):
            return metadata.numberGoType(withFormat: format)
            
        case .integer(let format):
            return metadata.integerGoType(withFormat: format)
            
        case .boolean:
            return .bool
            
        case .enumeration:
            throw SwaggerError.arrayItemEnumNotSupported

        case .file, .any, .null:
            throw SwaggerError.unsupportedSchemaType(self.type)
        }
    }
}
