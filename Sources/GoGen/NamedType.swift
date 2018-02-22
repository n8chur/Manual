// MARK: - NamedType

protocol NamedType: SourceContentConvertible, ModuleImportable {
    var name: String { get }
    var underlyingType: String { get }
    var constantDeclarations: [ConstantDeclaration] { get }
    var helperFunctionContentLines: [String] { get }
    var marshalContentLines: [String] { get }
    var unmarshalContentLines: [String]? { get }
    var isDefinedInline: Bool { get }
}

extension NamedType {
    var constantDeclarations: [ConstantDeclaration] {
        return []
    }
    
    var helperFunctionContentLines: [String] {
        return []
    }
}

// MARK: NamedType: SourceContentConvertible

extension NamedType {
    var sourceContent: String {
        var lines = [String]()
        
        lines.append("type \(self.name) \(self.underlyingType)")
        
        if self.constantDeclarations.count > 0 {
            lines += self.constantDeclarations.map {$0.sourceContent}
        }
        
        lines += self.helperFunctionContentLines
        
        lines.append("func (o \(self.name)) MarshalJSON() ([]byte, error) ".appendingScopedGoContent(self.marshalContentLines))
        
        if let unmarshalContentLines = self.unmarshalContentLines {
            lines.append("func (o *\(self.name)) UnmarshalJSON(bytes []byte) error ".appendingScopedGoContent(unmarshalContentLines))
        }
        
        return lines.joined(separator: "\n\n")
    }
}

// MARK: - ConstantDeclaration

struct ConstantDeclaration {
    let name: String
    let value: String
}

extension ConstantDeclaration: SourceContentConvertible {
    var sourceContent: String {
        return "const \(name) = \(value)"
    }
}
