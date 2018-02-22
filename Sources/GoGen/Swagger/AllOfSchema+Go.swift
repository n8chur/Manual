import SwaggerParser

extension AllOfSchema {
    func goStruct(named name: String, JSONName jsonName: String, metadata: Metadata? = nil) throws -> Struct? {
        guard !self.abstract else {
            return nil
        }
        
        let interfaces = try self.subschemas.flatMap {try $0.goInterface(named: name, JSONName: jsonName)}
        
        return Struct(
            name: name,
            comment: try self.comment(forObjectNamed: name, JSONName: jsonName, withConformanceDescription: true, metadata: metadata),
            properties: try self.goProperties(forStructNamed: name, JSONName: jsonName),
            interfaces: interfaces)
    }
    
    func goInterface(named name: String, JSONName jsonName: String, metadata: Metadata? = nil) throws -> Interface? {
        guard self.abstract else {
            return nil
        }
        
        let properties = try self.goProperties(forStructNamed: name, JSONName: jsonName)
        
        return Interface(
            name: name,
            properties: properties,
            comment: try self.comment(forObjectNamed: name, JSONName: jsonName, withConformanceDescription: true))
    }
    
    func comment(forObjectNamed name: String, JSONName jsonName: String, withConformanceDescription: Bool, metadata: Metadata? = nil) throws -> String? {
        var comment = try self.subschemas.flatMap { schema -> String? in
            if let structure = try schema.goStruct(named: name, JSONName: jsonName) {
                return structure.comment
            }
            
            if let interface = try schema.goInterface(named: name, JSONName: jsonName) {
                return self.abstract ? interface.comment : nil
            }
            
            throw SwaggerError.allOfItemCouldNotParse(schema)
        }.last

        if (comment == nil && metadata?.description != nil) {
            comment =  metadata?.description
        }
        
        guard withConformanceDescription else {
            return comment
        }
        
        let conformingInterfaceNames = self.subschemas.flatMap {$0.abstractStructureName}
        if conformingInterfaceNames.count > 0 {
            var conformanceComment: String
            if let existingComment = comment {
                conformanceComment = "\(existingComment)\n\n"
            } else {
                conformanceComment = ""
            }
            
            conformanceComment += "\(name) conforms to:"
            
            let segments = [conformanceComment] + conformingInterfaceNames
            comment = segments.joined(separator: "\n- ")
        }
        
        return comment
    }
    
    func goProperties(forStructNamed name: String, JSONName jsonName: String) throws -> [Property] {
        var propertyMap = [String: Property]()
        
        // TODO: Support combine aspects of duplicate property definitions?
        try self.subschemas
            .flatMap { schema -> [Property] in
                switch schema.type {
                case .structure(let structure):
                    return try structure.goProperties(inContainerNamed: name, JSONName: jsonName)
                    
                case .object(let object):
                    return try object.goProperties(inContainerNamed: name)
                    
                case .allOf(let allOf):
                    return try allOf.goProperties(forStructNamed: name, JSONName: jsonName)
                    
                default: throw SwaggerError.allOfItemCouldNotParse(schema)
                }
            }
            .forEach {propertyMap.merge(property: $0)}
        
        var properties = Array(propertyMap.values).sorted {$0.name < $1.name}
        
        if !self.abstract {
            properties = try properties.map { property in
                guard property.isDiscriminator else {
                    return property
                }
                
                guard !property.isNullable else {
                    throw SwaggerError.discriminatorCannotBeNullable(self)
                }
                
                // Use ConstantString type for discriminators.
                let constantString = ConstantString(
                    name: "\(name)\(property.name)",
                    value: jsonName)
                let type = Type.namedType(constantString)
                return Property(
                    type: type,
                    name: property.name,
                    jsonName: property.jsonName,
                    comment: property.comment,
                    isDiscriminator: true,
                    isNullable: false)
            }
        }
        
        return properties
    }
    
    func goType(named name: String, JSONName jsonName: String, metadata: Metadata? = nil) throws -> Type {
        if let structure = try self.goStruct(named: name, JSONName: jsonName, metadata: metadata) {
            return .structure(structure)
        }
        
        guard let goInterface = try self.goInterface(named: name, JSONName: jsonName, metadata: metadata) else {
            throw SwaggerError.failedToConvertAllOf(self)
        }
        
        return .interface(goInterface)
    }
}

fileprivate extension Dictionary where Key == String, Value == Property {
    mutating func merge(property: Property) {
        guard let existingProperty = self[property.name] else {
            self[property.name] = property
            return
        }
        
        let comment = property.comment ?? existingProperty.comment
        let isDiscriminator = property.isDiscriminator || existingProperty.isDiscriminator
        let isNullable = property.isNullable || existingProperty.isNullable
        
        self[property.name] = Property(
            type: property.type,
            name: property.name,
            jsonName: property.jsonName,
            comment: comment,
            isDiscriminator: isDiscriminator,
            isNullable: isNullable)
    }
}

fileprivate extension SwaggerParser.Schema {
    var abstractStructureName: String? {
        switch self.type {
        case .structure(let structure):
            switch structure.structure.type {
            case .allOf(let allOf):
                return allOf.abstract ? structure.name.goName : nil
                
            case .object(let object):
                return object.metadata.abstract ? structure.name.goName : nil
                
            default: return nil
            }
            
        default: return nil
        }
    }
}

fileprivate extension Structure where T == SwaggerParser.Schema {
    func goProperties(inContainerNamed name: String, JSONName jsonName: String) throws -> [Property] {
        switch self.structure.type {
        case .object(let object): return try object.goProperties(inContainerNamed: name)
        case .allOf(let allOf): return try allOf.goProperties(forStructNamed: name, JSONName: jsonName)
        default: throw SwaggerError.allOfItemCouldNotParse(self.structure)
        }
    }
}
