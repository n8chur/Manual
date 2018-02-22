extension String {
    static func goTypeSourceComment(describing name: String, withContent content: String? = nil) -> String {
        var commentLines = ["\(name) is machine-generated."]
        
        if let content = content, content.count > 0 {
            commentLines += [""] + content.components(separatedBy: "\n")
        }
        
        return commentLines
            .map {$0 == "" ? "//" : "// \($0)"}
            .joined(separator: "\n")
    }
}
