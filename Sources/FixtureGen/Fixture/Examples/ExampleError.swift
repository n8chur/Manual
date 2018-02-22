import ManualKit
import SwaggerParser

enum ExampleError: Error {
    case allOfSchemaInvalidType(Schema)
    case tooManyArrayItems
    case badExampleType(example: Any, supportedTypes: [Any.Type])
    case enumerationValueTypeMismatch(example: Any?, supportedTypes: [Any.Type])
    case unsupportedSchemaType(Schema)
    
    var description: String {
        switch self {
        case .allOfSchemaInvalidType(let structure):
            return "Schema of type \(String(describing: structure)) found in `allOf`. Must be an object or another `allOf`."
        case .tooManyArrayItems:
            return "Found more than one schema for an array's `items`. Only a single schema is supported for array `items`."
        case .badExampleType(let example, let supportedTypes):
            let exampleDescription = "\(type(of: example))(\(String(describing: example)))"
            if supportedTypes.count == 1 {
                return "Got example value \(exampleDescription) when \(supportedTypes[0]) was expected."
            }
            
            return "Got example value \(exampleDescription) when one of \([supportedTypes]) were expected."
        case .enumerationValueTypeMismatch(let example, let supportedTypes):
            var exampleDescription = "nil"
            if let example = example {
                exampleDescription = "\(type(of: example))(\(String(describing: example)))"
            }
            
            if supportedTypes.count == 1 {
                return "Got example value \(exampleDescription) when \(supportedTypes[0]) was expected."
            }
            
            return "Got example value \(exampleDescription) when one of \(supportedTypes) were expected."
        case .unsupportedSchemaType(let schema):
            return "\(String(describing: schema.type)) is not a supported schema type. Found on schema: \(String(describing: schema))"
        }
    }
}
