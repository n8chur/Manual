import Foundation
import Guaka

private let inputFlagLongName = "input"
private let goModelsFlagLongName = "go-models"
private let goPackageNameFlagLongName = "go-package-name"
private let fixturesFlagLongName = "fixtures"

extension Flags {
    static func makeManualKitFlags() -> [Flag] {
        let inputFlag = Flag(
            shortName: "i",
            longName: inputFlagLongName,
            type: String.self,
            description: "The input Swagger JSON specification file.",
            required: true)

        let goModelsFlag = Flag(
            shortName: "g",
            longName: goModelsFlagLongName,
            type: String.self,
            description: "Generates Go models in the provided output directory.")

        let goPackageNameFlag = Flag(
            shortName: "p",
            longName: goPackageNameFlagLongName,
            type: String.self,
            description: "Specifies the name of the generated Go package. Defaults to Go models' output directory name.")

        let fixturesFlag = Flag(
            shortName: "f",
            longName: fixturesFlagLongName,
            type: String.self,
            description: "Generates test fixtures in the provided output directory.")

        return [
            inputFlag,
            goModelsFlag,
            goPackageNameFlag,
            fixturesFlag,
        ]
    }
    
    var inputFile: URL {
        guard let inputString = getString(name: inputFlagLongName) else {
            fatalError("The input flag is required.")
        }
        return URL(fileURLWithPath: inputString, isDirectory: false)
    }
    
    var fixtureOutput: URL? {
        guard let fixtureOutputString = getString(name: fixturesFlagLongName) else {
            return nil
        }
        return URL(fileURLWithPath: fixtureOutputString, isDirectory: true)
    }
    
    var goModelsOutput: URL? {
        guard let goModelsOutputString = getString(name: goModelsFlagLongName) else {
            return nil
        }
        return URL(fileURLWithPath: goModelsOutputString, isDirectory: true)
    }
    
    func goPackageName(withOutputURL output: URL) -> String {
        return getString(name: goPackageNameFlagLongName) ?? output.lastPathComponent
    }
}
