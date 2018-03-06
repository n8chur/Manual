import Foundation

struct Struct {
    let name: String
    let comment: String?
    let properties: [Property]
    
    /// A list of interfaces that the struct conforms to.
    let interfaces: [Interface]
}

extension Struct: SourceContentConvertible {
    var sourceContent: String {
        var sourceContent = String.goTypeSourceComment(describing: self.name, withContent: self.comment)
        sourceContent += "\n"
        
        sourceContent = sourceContent.appending(goStructNamed: self.name, self.properties.map {"\($0.structSourceContent)"})
        
        var sections = [sourceContent]

        var propertiesToIgnore = [Property]()
        for interface in self.interfaces {
            let implementation = self.implementation(ofInterface: interface, ignoringPropertiesMatching: propertiesToIgnore)
            sections.append(implementation)

            propertiesToIgnore += interface.properties
        }

        sections += self.inlineEnums.map {$0.sourceContent}
        sections += self.inlineNamedTypes.map {$0.sourceContent}
        
        return sections.joined(separator: "\n\n")
    }
    
    private func implementation(ofInterface interface: Interface, ignoringPropertiesMatching propertiesToIgnore: [Property]) -> String {
        // Remove properties that have already been defined.
        let properties = interface.properties.flatMap { property -> Property? in
            let hasMatch = propertiesToIgnore.first(where: {$0.name == property.name})
            guard hasMatch == nil else {
                    return nil
            }

            return property
        }

        var sections = [String.goTypeSourceComment(describing: "\(self.name)'s conformance to \(interface.name)")]
        
        sections += properties.map { property -> String in
            guard let structProperty = self.properties.first(where: {$0.name == property.name}) else {
                // This is a programmer error.
                fatalError("\(self.name) does not have property \(property.name) defined on \(interface.name)")
            }
            
            let getterName = "Get\(property.name)"
            
            switch property.type {
            case .slice:
                guard !property.isNullable else {
                    fatalError("Slice properties cannot be nullable.")
                }
                
                let commentContent = "Gets \(self.name)'s \(property.name) as \(interface.name)'s property type."
                var implementation = String.goTypeSourceComment(describing: getterName, withContent: commentContent)
                implementation += "\n"
                implementation += "func (o \(self.name)) \(getterName)() (\(property.typeName), error) "
                return implementation.appendingScopedGoContent([
                    "items := make(\(property.type.name), len(o.\(structProperty.name)))",
                    "for _, item := range o.\(structProperty.name) ".appendingScopedGoContent([
                        "items = append(items, item)"
                    ]),
                    "return items, nil",
                ])
            default:
                let commentContent = "Gets \(self.name)'s \(property.name) property."
                var implementation = String.goTypeSourceComment(describing: getterName, withContent: commentContent)
                implementation += "\n"
                implementation += "func (o \(self.name)) \(getterName)() (\(property.typeName), error) "
                let scopedContent = structProperty.getterContent(withInterfaceProperty: property)
                return implementation.appendingScopedGoContent(scopedContent)
            }
        }
        
        return sections.joined(separator: "\n\n")
    }
}

extension Struct: ModuleImportable {
    var importedModules: [String] {
        let enumModules = self.inlineEnums.flatMap {$0.importedModules}
        let namedTypeModules = self.inlineNamedTypes.flatMap {$0.importedModules}
        return [
            enumModules,
            namedTypeModules,
        ].flatMap {$0}
    }
}

fileprivate extension Struct {
    var inlineEnums: [Enum] {
        return self.properties
            .flatMap { property -> Enum? in
                guard case .enumeration(let enumeration) = property.type else {
                    return nil
                }
                return enumeration
            }
            .filter {$0.isDefinedInline}
    }
    
    var inlineNamedTypes: [NamedType] {
        return self.properties
            .flatMap { property -> NamedType? in
                guard
                    case .namedType(let namedType) = property.type,
                    namedType.isDefinedInline else {
                        return nil
                }
                
                return namedType
            }
    }
}

fileprivate extension Property {
    func getterContent(withInterfaceProperty interfaceProperty: Property) -> [String] {
        if self.isEnumeration && interfaceProperty.isString {
            guard self.isNullable else {
                return ["return o.\(self.name).String()"]
            }
            
            return [
                "v := o.\(self.name)",
                "if v == nil ".appendingScopedGoContent([
                    "return nil, nil"
                ]),
                "str, err := v.String()",
                "if err != nil ".appendingScopedGoContent([
                    "return nil, err"
                ]),
                "return &str, nil",
            ]
        }
        
        if self.isConstantString && interfaceProperty.isString {
            return ["return string(o.\(self.name)), nil"]
        }
        
        return ["return o.\(self.name), nil"]
    }
    
    var isString: Bool {
        switch self.type {
        case .string: return true
        default: return false
        }
    }
    
    var isEnumeration: Bool {
        switch self.type {
        case .enumeration: return true
        default: return false
        }
    }
    
    var isConstantString: Bool {
        switch self.type {
        case .namedType(let namedType): return namedType is ConstantString
        default: return false
        }
    }
}

fileprivate extension String {
    /// Appends Go struct source content to the receiver. The content will be 
    /// new line separated and indented one level.
    /// - parameter lines: The lines that make up the struct's implementation.
    func appending(goStructNamed name: String, _ lines: [String]) -> String {
        return self + "type \(name) struct ".appendingScopedGoContent(lines, separatedByNewLines: 1)
    }
}
