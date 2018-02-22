import SwaggerParser

enum SwaggerError: Error {
    case missingDefinitions(count: Int)
    case allOfItemCouldNotParse(SwaggerParser.Schema)
    case objectDefinedInLine(SwaggerParser.Schema)
    case failedToConvertObject(ObjectSchema)
    case failedToConvertAllOf(AllOfSchema)
    case failedToConvertReference(SwaggerParser.Schema)
    case multipleArrayItemDefinitions(ArraySchema)
    case enumsValueNotSupported(value: Any?, enumName: String)
    case arrayItemObjectCannotContainProperties
    case arrayItemEnumNotSupported
    case arrayPropertyCannotBeNullable(named: String)
    case discriminatorCannotBeNullable(AllOfSchema)
    case unsupportedSchemaType(SchemaType)
}

extension SwaggerError: CustomStringConvertible {
    var description: String {
        switch self {
        case .missingDefinitions(let count):
            return "Could not generate all models. Missing \(count) definitions."
            
        case .allOfItemCouldNotParse(let schema):
            return "Could not parse allOf item as a structure: \(String(describing: schema))"
            
        case .objectDefinedInLine(let schema):
            return "An object was defined in line. `allOf` and `object` type definitions must be defined in `definitions`.\n\(String(describing: schema))"
            
        case .failedToConvertObject(let schema):
            return "Failed to convert object schema to Go type: \(String(describing: schema))"
            
        case .failedToConvertAllOf(let schema):
            return "Failed to convert all-of schema to Go type: \(String(describing: schema))"
            
        case .failedToConvertReference(let schema):
            return "Failed to convert to go type from reference type: \(String(describing: schema))"
            
        case .multipleArrayItemDefinitions(let arraySchema):
            return "Multiple item definitions are not supported for array items: \(String(describing: arraySchema))"
            
        case .enumsValueNotSupported(let value, let enumName):
            let type = Swift.type(of: value)
            return "Enum value \(type)(\(String(describing: value))) found on \(enumName). \(type) enum values are not supported"
            
        case .arrayItemObjectCannotContainProperties:
            return "Array items that are objects must not contain any properties (map[string]interface{})."
        
        case .arrayItemEnumNotSupported:
            return "Array items cannot be enums."
            
        case .arrayPropertyCannotBeNullable(let name):
            return "Array property \(name) cannot be nullable."
        
        case .discriminatorCannotBeNullable(let schema):
            return "Discriminators cannot be nullable. Found schema with nullable discriminator: \(String(describing: schema))"

        case .unsupportedSchemaType(let schema):
            return "\(String(describing: schema)) is not a supported schema type."
        }
    }
}
