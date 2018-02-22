import SwaggerParser

extension ArraySchema {
    func example(with definitions: [String: Schema], metadata: Metadata) throws -> [Any?] {
        if let example = metadata.example {
            guard let value = example as? [Any?] else {
                throw ExampleError.badExampleType(example: example, supportedTypes: [[Any?].self])
            }
            return value
        }

        // TODO: Consider schema rules.
        var example: [Any?]
        switch self.items {
        case .one(let schema):
            switch schema.type {
            case .structure(let structure):
                example = try structure.exampleArray(with: definitions)
            default:
                example = [ (try schema.example(with: definitions)) ]
            }
        case .many:
            throw ExampleError.tooManyArrayItems
        }
        
        switch self.additionalItems {
        case .a(let hasAdditionalItems):
            if hasAdditionalItems {
                example.append("foo")
            }
        case .b(let additionalSchema):
            example += [ (try additionalSchema.example(with: definitions)) ]
        }
        
        return example
    }
}
