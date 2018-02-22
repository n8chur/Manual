struct ConstantString: NamedType {
    let name: String
    let value: String
    
    let underlyingType = "string"
    let isDefinedInline = true
    
    var constantDeclarations: [ConstantDeclaration] {
        return [
            ConstantDeclaration(name: self.valueConstantName, value: "\"\(value)\"")
        ]
    }
    
    var marshalContentLines: [String] {
        return [
            // Use '%/q' string formatting to escape unicode characters.
            "return []byte(fmt.Sprintf(\"%+q\", \(self.valueConstantName))), nil"
        ]
    }
    
    let unmarshalContentLines: [String]? = nil
    
    private var valueConstantName: String {
        return "\(self.name)Value"
    }
}

extension ConstantString: ModuleImportable {
    var importedModules: [String] {
        return [ "fmt" ]
    }
}
