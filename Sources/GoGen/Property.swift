import Foundation

struct Property {
    let type: Type
    let name: String
    let jsonName: String
    let comment: String?
    let isDiscriminator: Bool
    let isNullable: Bool
}

extension Property {
    var structSourceContent: String {
        var sourceContent = ""
        
        if let comment = self.comment {
            // TODO: Wrap new lines approprately
            let commentedComment = comment.components(separatedBy: "\n").joined(separator: "\n// ")
            sourceContent += "// \(commentedComment)\n"
        }
        
        if self.isNullable {
            if sourceContent.hasPrefix("// ") {
                sourceContent += "//\n"
            }
            sourceContent += "// \(self.name) is nullable.\n"
        }
        
        sourceContent += "\(self.name) \(self.typeName) `json:\"\(self.jsonName)\"`"
        
        return sourceContent
    }
    
    var interfaceSourceContent: String {
        var sourceContent = ""
        
        if
            let comment = self.comment,
            comment.count > 0 {
                let commentLines = comment.components(separatedBy: "\n")

                sourceContent += commentLines
                    .map {$0 == "" ? "//" : "// \($0)"}
                    .joined(separator: "\n")

                sourceContent += "\n"
        }
        
        sourceContent += "Get\(self.name)() (\(self.typeName), error)"
        
        return sourceContent
    }
    
    /// The .type.name optionally prepended with an "*" if the property is
    /// nullable.
    var typeName: String {
        if self.isNullable {
            return "*\(self.type.name)"
        }
        
        return self.type.name
    }
}
