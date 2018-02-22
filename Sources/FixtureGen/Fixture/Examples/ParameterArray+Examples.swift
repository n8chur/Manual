import SwaggerParser
import Foundation

extension Array where Element == Parameter {
    func examples(forType type: ParameterLocation) throws -> [String: String?] {
        let exampleTuples = try flatMap { parameter -> (name: String, example: Any?)? in
            guard case .other(let fixedFields, let items) = parameter, fixedFields.location == type else {
                return nil
            }
            
            let name = fixedFields.name
            let example = try fixedFields.example ?? (try items.example(forType: fixedFields.location, withName: name))
            return (name, example)
        }
        var example = [String: String?]()
        exampleTuples.forEach {
            guard let exampleValue = $0.example else {
                example[$0.name] = nil
                return
            }
            
            let stringValue = String(describing: exampleValue)
            let percentEscapedValue = stringValue.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlPathAllowed)
            
            example[$0.name] = percentEscapedValue ?? ""
        }
        return example
    }
}
