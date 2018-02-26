import SwaggerParser

extension Structure where T == Schema {
    func example(with definitions: [String: Schema]) throws -> Any? {
        return try self.structure.example(with: definitions, referencingName: self.name) {
            try self.example(with: definitions)
        }
    }

    func exampleArray(with definitions: [String: Schema]) throws -> [Any?] {
        return try self.structure.exampleArray(with: definitions, referencingName: self.name) {
            try self.example(with: definitions)
        }
    }
}

extension Schema {
    func exampleArray(with definitions: [String: Schema], name: String) throws -> [Any?] {
        return try self.exampleArray(with: definitions, referencingName: name) {
            try self.example(with: definitions)
        }
    }
}

fileprivate extension Schema {
    func example(with definitions: [String: Schema], referencingName: String, example: () throws -> Any?) throws -> Any? {
        switch self.type {
        case .allOf(let allOf): return try allOf.example(with: definitions, forSchemaNamed: referencingName)
        case .object(let object): return try object.example(with: definitions, metadata: metadata, forSchemaNamed: referencingName)
        default: return try example()
        }
    }
    
    func exampleArray(with definitions: [String: Schema], referencingName: String, example: () throws -> Any?) throws -> [Any?] {
        let exampleChildren = childrenFilteringAbstract(from: definitions, referencingName: referencingName)
        
        guard exampleChildren.count > 0 else {
            return [ (try example()) ]
        }

        var examples: [Any?] = try exampleChildren.map {
            return try $0.schema.example(with: definitions, forSchemaNamed: $0.childName)
        }

        if !self.unwrapped.abstract {
            examples.append(try example())
        }
        
        return examples
    }

    func childrenFilteringAbstract(from definitions: [String: Schema], referencingName: String) -> [(childName: String, schema: AllOfSchema)] {
        // Must be an object or allOf schema.
        switch self.unwrapped.type {
        case .object(_), .allOf(_): break
        default: return []
        }
        
        return definitions.childSchemasReferencing(referencingName)
    }
}

extension Dictionary where Key == String, Value == Schema {
    func childSchemasReferencing(_ referencingName: String) -> [(childName: String, schema: AllOfSchema)]  {
        return self
            .flatMap { (name, definition) -> (name: String, schema: AllOfSchema)? in
                guard
                    case .allOf(let allOf) = definition.unwrapped.type,
                    !allOf.abstract else {
                        return nil
                }

                return (name, allOf)
            }
            .flatMap { allOf -> (String, AllOfSchema)? in
                let references = allOf.schema.subschemas.structuresReferencing(referencingName)
                guard references.count > 0 else {
                    return nil
                }

                // TODO: Add support for redefinitions of discriminator values
                // in children.
                return (allOf.name, allOf.schema)
            }
    }
}

fileprivate extension Array where Element == Schema {
    func structuresReferencing(_ definitionName: String) -> [Structure<Schema>] {
        return flatMap { schema -> [Structure<Schema>] in
            guard case .structure(let structure) = schema.type else {
                return []
            }
            
            if structure.name == definitionName {
                return [structure]
            }
            
            guard case .allOf(let allOf) = structure.structure.type else {
                return []
            }
            
            return allOf.subschemas.structuresReferencing(definitionName)
        }
    }
}
