import SwaggerParser
import ManualKit
import Foundation

/// A single example of concrete definition, otherwise a set of concrete 
/// examples that an abstract definition can be represented as.
final class Example: JSONFile {
    let filename: String
    let contents: JSON

    required init?(name: String, definition: Schema, for definitions: [String: Schema]) throws {
        self.filename = "\(name).json"
        self.contents = try definition.exampleContents(withName: name, for: definitions)

        if case .null = self.contents {
            return nil
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.contents)
    }
}

fileprivate extension Schema {
    /// Returns an example in JSON format.
    func exampleContents(withName name: String, for definitions: [String: Schema]) throws -> JSON {
        if self.abstract {
            // Do not create examples for abstract models that do not have a
            // discriminator since it's only used as a protocol and not for
            // polymorphism.
            if self.discriminator == nil {
                return .null
            }

            let examples = try self.exampleArray(with: definitions, name: name)
            return try JSON(examples)
        }

        let example = try self.example(with: definitions, forSchemaNamed: name)
        return try JSON(example)
    }
}
