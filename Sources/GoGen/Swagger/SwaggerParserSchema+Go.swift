import SwaggerParser

extension SwaggerParser.Schema {
    func propertyWith(JSONName jsonName: String, containerName: String, isDiscriminator: Bool) throws -> Property {
        let goName = jsonName.goName
        let comment = try self.comment(forSchemaNamed: goName, JSONName: jsonName)
        
        switch self.type {
        case .object(let objectSchema):
            // Only support defining empty objects in line.
            guard objectSchema.properties.count == 0 else {
                throw SwaggerError.objectDefinedInLine(self)
            }
            
            // In line object definitions for properties are interpretted as
            // map[string]interface{}.
            // TODO: Add an x-<field> for determining whether the type should be
            // `interface{}` or `map[string]interface{}`
            guard let structure = try objectSchema.goStruct(named: "map[string]interface{}", metadata: self.metadata) else {
                throw SwaggerError.failedToConvertObject(objectSchema)
            }
            
            return Property(
                type: .structure(structure),
                name: goName,
                jsonName: jsonName,
                comment: comment,
                isDiscriminator: isDiscriminator,
                isNullable: self.metadata.nullable)
            
        case .allOf:
            throw SwaggerError.objectDefinedInLine(self)
            
        case .structure(let structure):
            return Property(
                type: try structure.goType(),
                name: goName,
                jsonName: jsonName,
                comment: comment,
                isDiscriminator: isDiscriminator,
                isNullable: self.metadata.nullable)
            
        case .enumeration:
            guard let enumeratedValues = self.metadata.enumeratedValues else {
                fatalError("Enum \(jsonName) has no values")
            }
            let name = enumeratedValues.enumeratedValuesTypeNameWith(containerName: containerName, propertyName: jsonName.goName)
            return Property(
                type: try self.goType(named: name, JSONName: jsonName),
                name: goName,
                jsonName: jsonName,
                comment: comment,
                isDiscriminator: isDiscriminator,
                isNullable: self.metadata.nullable)
            
        case .string:
            var name = goName
            
            // If the type is an enum then we need to provide the enum name
            // instead of the provided name for the type.
            if let enumeratedValues = self.metadata.enumeratedValues {
                name = enumeratedValues.enumeratedValuesTypeNameWith(containerName: containerName, propertyName: jsonName.goName)
            }
            
            return Property(
                type: try self.goType(named: name, JSONName: jsonName),
                name: goName,
                jsonName: jsonName,
                comment: comment,
                isDiscriminator: isDiscriminator,
                isNullable: metadata.nullable)
            
        case .array(_):
            guard !self.metadata.nullable else {
                throw SwaggerError.arrayPropertyCannotBeNullable(named: jsonName)
            }
            
            return Property(
                type: try self.goType(named: goName, JSONName: jsonName),
                name: goName,
                jsonName: jsonName,
                comment: comment,
                isDiscriminator: isDiscriminator,
                isNullable: false)
            
        case .integer(_):
            return Property(
                type: try self.goType(named: goName, JSONName: jsonName),
                name: goName,
                jsonName: jsonName,
                comment: comment,
                isDiscriminator: isDiscriminator,
                isNullable: self.metadata.nullable)
            
        case .number(_):
            return Property(
                type: try self.goType(named: goName, JSONName: jsonName),
                name: goName,
                jsonName: jsonName,
                comment: comment,
                isDiscriminator: isDiscriminator,
                isNullable: self.metadata.nullable)
            
        case .boolean:
            return Property(
                type: try self.goType(named: goName, JSONName: jsonName),
                name: goName,
                jsonName: jsonName,
                comment: comment,
                isDiscriminator: isDiscriminator,
                isNullable: self.metadata.nullable)

        case .any:
            return Property(
                type: try self.goType(named: goName, JSONName: jsonName),
                name: goName,
                jsonName: jsonName,
                comment: comment,
                isDiscriminator: isDiscriminator,
                isNullable: self.metadata.nullable)

        case .file, .null:
            throw SwaggerError.unsupportedSchemaType(self.type)
        }
    }

    func comment(forSchemaNamed name: String, JSONName jsonName: String) throws -> String? {
        switch self.type {
        case .structure(let structure): return try self.metadata.description ?? structure.structure.comment(forSchemaNamed: name, JSONName: jsonName)
        case .object(_): return self.metadata.description
        case .array(_): return self.metadata.description
        case .allOf(let allOf): return try allOf.comment(forObjectNamed: name, JSONName: jsonName, withConformanceDescription: false, metadata: self.metadata)
        case .string(_): return self.metadata.description
        case .number(_): return self.metadata.description
        case .integer(_): return self.metadata.description
        case .enumeration: return self.metadata.description
        case .boolean: return self.metadata.description
        case .file: return self.metadata.description
        case .any: return self.metadata.description
        case .null: return self.metadata.description
        }
    }
    
    /// If the receiver is a reference then the name of the reference will be
    /// used to construct the Type instead of the provided name.
    func goInterface(named name: String, JSONName jsonName: String) throws -> Interface? {
        guard case .interface(let interface) = try self.goType(named: name, JSONName: jsonName) else {
            return nil
        }
        return interface
    }
    
    /// If the receiver is a reference then the name of the reference will be 
    /// used to construct the Type instead of the provided name.
    func goStruct(named name: String, JSONName jsonName: String) throws -> Struct? {
        guard case .structure(let structure) = try self.goType(named: name, JSONName: jsonName) else {
            return nil
        }
        return structure
    }
    
    /// If the receiver is a reference then the name of the reference will be
    /// used to construct the Type instead of the provided name.
    func goEnum(named name: String, JSONName jsonName: String, definedInLine: Bool) throws -> Enum? {
        guard case .enumeration(let enumeration) = try self.goType(named: name, JSONName: jsonName, definedInLine: definedInLine) else {
            return nil
        }
        return enumeration
    }
    
    var objectSchema: ObjectSchema? {
        switch self.type {
        case .object(let object): return object
        case .structure(let structure): return structure.structure.objectSchema
        default: return nil
        }
    }
    
    var allOfSchema: AllOfSchema? {
        switch self.type {
        case .allOf(let allOf): return allOf
        case .structure(let structure): return structure.structure.allOfSchema
        default: return nil
        }
    }
    
    var enumerationSchema: Metadata? {
        switch self.type {
        case .enumeration: return self.metadata
        case .structure(let structure): return structure.structure.enumerationSchema
        default: return nil
        }
    }
    
    /// If the type returned is from a reference then the name of the reference
    /// will be used to construct the Type instead of the provided name.
    /// - parameter name: The name of the type to be created for .inteface and
    ///     .structure Types. If the receiver is a reference, the name of the
    ///      reference will be used instead. All other Types ignore this name.
    fileprivate func goType(named name: String, JSONName jsonName: String, definedInLine: Bool = true) throws -> Type {
        switch self.type {
        case .structure(let structure):
            return try structure.goType()
            
        case .object(let object):
            return try object.goType(named: name, metadata: metadata)
            
        case .array(let array):
            return .slice(try array.itemType())
            
        case .allOf(let allOf):
            return try allOf.goType(named: name, JSONName: jsonName, metadata: self.metadata)
            
        case .number(let format):
            return metadata.numberGoType(withFormat: format)
            
        case .integer(let format):
            return metadata.integerGoType(withFormat: format)
            
        case .boolean:
            return .bool
            
        case .enumeration:
            guard let values = self.metadata.enumeratedValues else {
                fatalError("Enums require values. This is a bug in SwaggerParser.")
            }
            
            let enumeration = try self.metadata.enumeration(named: name, definedInLine: definedInLine, values: values)
            return .enumeration(enumeration)
            
        case .string(let stringFormat):
            // TODO: Support `*time.Time` type generation.
            
            // If it's contained in an interface describe as a string.
            guard let values = self.metadata.enumeratedValues else {
                return self.metadata.type(forStringFormat: stringFormat)
            }
            
            let enumeration = try self.metadata.enumeration(named: name, definedInLine: definedInLine, values: values)
            return .enumeration(enumeration)

        case .any:
            return .any

        case .file, .null:
            throw SwaggerError.unsupportedSchemaType(self.type)
        }
    }
}

fileprivate extension Array where Element == Any? {
    func enumeratedValuesTypeNameWith(containerName: String, propertyName: String) -> String {
        return "\(containerName)\(propertyName)"
    }
}

fileprivate extension Metadata {
    func type(forStringFormat stringFormat: StringFormat?) -> Type {
        guard let stringFormat = stringFormat else {
            return .string
        }
        
        switch stringFormat {
        case .date:
            return .namedType(JSONTimeType.date())
            
        case .dateTime:
            return .namedType(JSONTimeType.dateTime())
            
        case .other(let format):
            switch format {
            case "iso-8601-week": return .namedType(JSONWeek())
            case "url": return .namedType(JSONURLType())
            default: return .string
            }
            
        default: return .string
        }
    }
}
