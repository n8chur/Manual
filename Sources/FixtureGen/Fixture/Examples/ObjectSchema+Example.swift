import SwaggerParser

extension ObjectSchema {
    func example(with definitions: [String: Schema], metadata: Metadata, forSchemaNamed name: String? = nil) throws -> [String: Any?] {
        if let example = metadata.example {
            guard let value = example as? [String: Any] else {
                throw ExampleError.badExampleType(example: example, supportedTypes: [[String: Any].self])
            }
            return value
        }

        // If the schema is abstract and has a discriminator and a child schema
        // is found, return an example of one of the child schemas.
        if
            self.metadata.abstract,
            self.metadata.discriminator != nil,
            let schemaName = name,
            let nameAndSchema = definitions.childSchemasReferencing(schemaName).first {
                return try nameAndSchema.schema.example(with: definitions, forSchemaNamed: nameAndSchema.childName)
        }
        
        // TODO: Consider schema rules.
        var example = [String: Any?]()
        
        try self.properties.forEach {
            example[$0.key] = try $0.value.example(with: definitions)
        }
        
        if
            let discriminator = self.metadata.discriminator,
            let name = name {
                example[discriminator] = name
        }
        
        switch self.additionalProperties {
        case .a(let hasAdditionalProperties) where hasAdditionalProperties:
            example["additional_property"] = "foo"
        case .b(let additionalSchema):
            example["additional_property"] = try additionalSchema.example(with: definitions)
        default: break
        }
        
        return example
    }
}
