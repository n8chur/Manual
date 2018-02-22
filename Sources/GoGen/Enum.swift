import Foundation

struct Enum {
    let name: String
    let comment: String?
    let isDefinedInline: Bool
    
    // TODO: Support types other than string.
    let JSONValues: [String]
}

extension Enum: SourceContentConvertible {
    var sourceContent: String {
        // TODO: Will need to include methods to convert to/from json string.
        return [
            "type \(self.name) int",
            self.enumDefinition,
            self.getStringContent,
            self.marshalContent,
            ].joined(separator: "\n\n")
    }
    
    var enumDefinition: String {
        let lines = self.JSONValues.enumerated().map { (args: (index: Int, value: String)) -> String in
            
            var line = "\t\(args.value.enumValueString)"
            if args.index == 0 {
                line += " \(self.name) = iota"
            }
            return line
        }
        return "const ".appendingScopedGoContent(lines, withScopeType: .parenthesis)
    }
    
    private var getStringContent: String {
        return "func (e \(self.name)) String() (string, error) ".appendingScopedGoContent([
            self.switchStatement,
        ])
    }
    
    private var switchStatement: String {
        return "switch e ".appendingScopedGoContent(self.switchContentLines)
    }
    
    private var switchContentLines: [String] {
        var lines = self.JSONValues.flatMap { jsonValue -> [String] in
            return [
                "case \(jsonValue.enumValueString):",
                "\treturn \"\(jsonValue)\", nil"
            ]
        }
        lines += [
            "default:",
            "\treturn \"\", fmt.Errorf(\"Bad \(self.name) value %v.\", e)",
        ]
        return lines
    }
    
    private var marshalContent: String {
        return "func (e \(self.name)) MarshalJSON() ([]byte, error) ".appendingScopedGoContent([
            "str, err := e.String()",
            "if err != nil ".appendingScopedGoContent([
                "return nil, err"
            ]),
            // Use '%/q' string formatting to escape unicode characters.
            "return []byte(fmt.Sprintf(\"%+q\", str)), nil"
        ])
    }
}

extension Enum: ModuleImportable {
    var importedModules: [String] {
        return [ "fmt" ]
    }
}

extension String {
    var enumValueString: String {
        return self.goName + "EnumValue"
    }
}
