import Foundation
import SwaggerParser

public extension File {
    static func makeFilesWith(packageName: String, swagger: Swagger) throws -> [File] {
        // Structures
        var files = try swagger.definitions
            .flatMap {try $0.value.goStruct(named: $0.key.goName, JSONName: $0.key)}
            .map { structure in
                return File(
                    filename: "\(structure.name).go",
                    package: packageName,
                    schemas: [Schema.structure(structure)])
            }
        
        // Interfaces
        files += try swagger.definitions
            .flatMap {try $0.value.goInterface(named: $0.key.goName, JSONName: $0.key)}
            .map { structure in
                return File(
                    filename: "\(structure.name).go",
                    package: packageName,
                    schemas: [Schema.interface(structure)])
            }
        
        // Enums
        files += try swagger.definitions
            .flatMap {try $0.value.goEnum(named: $0.key.goName, JSONName: $0.key, definedInLine: false)}
            .map { enumeration in
                return File(
                    filename: "\(enumeration.name).go",
                    package: packageName,
                    schemas: [Schema.enumeration(enumeration)])
            }
        
        // Additional Files
        let additionalFiles = [
            File.JSONTypes(withPackageName: packageName)
        ]
        files += additionalFiles
        
        let missingDefinitions = swagger.definitions.count + additionalFiles.count - files.count
        guard missingDefinitions == 0 else {
            throw SwaggerError.missingDefinitions(count: missingDefinitions)
        }
        
        return files.sorted {$0.filename < $1.filename}
    }
}
