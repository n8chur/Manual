import SwaggerParser

// MARK: Enum

extension Metadata {
    func enumeration(named name: String, definedInLine: Bool, values: [Any?]) throws -> Enum {
        // TODO: Support types other than string.
        let jsonValues = try values.map { enumerationValue -> String in
            guard let nonNilValue = enumerationValue as? String else {
                throw SwaggerError.enumsValueNotSupported(value: enumerationValue, enumName: name)
            }
            
            return nonNilValue
        }
        
        return Enum(
            name: name,
            comment: self.description,
            isDefinedInline: definedInLine,
            JSONValues: jsonValues)
    }
}

// MARK: Types

extension Metadata {
    func numberGoType(withFormat format: NumberFormat?) -> Type {
        guard let format = format else {
            return .double
        }
        
        switch format {
        case .double: return .double
        case .float: return .float
        }
    }
    
    func integerGoType(withFormat format: IntegerFormat?) -> Type {
        guard let format = format else {
            return .int
        }
        
        switch format {
        case .int32: return .int32
        case .int64: return .int64
        }
    }
}
