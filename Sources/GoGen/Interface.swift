import Foundation

struct Interface {
    let name: String
    let properties: [Property]
    let comment: String?
}

extension Interface: SourceContentConvertible {
    var sourceContent: String {
        var sourceContent = String.goTypeSourceComment(describing: self.name, withContent: self.comment)
        sourceContent += "\n"
        
        return sourceContent.appending(goInterfaceNamed: self.name, self.properties.map {"\($0.interfaceSourceContent)"})
    }
}

extension Interface: ModuleImportable {}

fileprivate extension String {
    /// Appends Go interface source content to the receiver. The content will be
    /// new line separated and indented one level.
    /// - parameter lines: The lines that make up the interface's
    ///   implementation.
    func appending(goInterfaceNamed name: String, _ lines: [String]) -> String {
        return self + "type \(name) interface ".appendingScopedGoContent(lines, separatedByNewLines: 1)
    }
}
