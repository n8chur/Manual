import Foundation
import FixtureGen
import ManualKit
import SwaggerParser
import GoGen
import Guaka

let flags = Flags.makeManualKitFlags()

let command = Command(usage: "manual -i [input]", flags: flags)

command.run = { flags, args in
    do {
        let contents = try String(contentsOf: flags.inputFile)
        let swagger = try Swagger(from: contents)
        
        if let fixtureOutput = flags.fixtureOutput {
            try swagger.writeFixtures(in: fixtureOutput)
        }
        
        if let goModelsOutput = flags.goModelsOutput {
            let goPackageName = flags.goPackageName(withOutputURL: goModelsOutput)
            try swagger.writeGoModels(in: goModelsOutput, withPackageName: goPackageName)
        }
    } catch {
        let errorString: String
        if (error as NSError).domain == NSCocoaErrorDomain {
            errorString = "\(error.localizedDescription)\n\n\(String(describing: error))"
        } else {
            errorString = String(describing: error)
        }
        
        command.fail(statusCode: Int(EXIT_FAILURE), errorMessage: errorString)
    }
}

command.execute()
