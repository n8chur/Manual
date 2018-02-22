import Foundation
import SwaggerParser

func bodies(withExample example: Any?) throws -> (jsonBody: JSON?, body: String) {
    var jsonBody: JSON?
    var body = ""
    if let exampleJSON = example {
        let json = try JSON(exampleJSON)
        jsonBody = json
        body = try json.stringValue()
    }
    
    return (jsonBody: jsonBody, body: body)
}

extension Array where Element == Parameter {
    func bodies(with definitions: [String: Schema]) throws -> (jsonBody: JSON?, body: String) {
        // TODO: Can there be more than one body parameter?
        let bodyParameter = self.first {
            if case .body = $0 {
                return true
            }
            return false
        }
        
        var example: Any?
        if let body = bodyParameter, case .body(_, let schema) = body {
            example = try schema.example(with: definitions)
        }
        
        return try FixtureGen.bodies(withExample: example)
    }
}
