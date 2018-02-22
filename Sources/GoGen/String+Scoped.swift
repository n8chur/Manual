enum GoScopeType {
    case curlyBraces
    case parenthesis
}

extension GoScopeType {
    var open: Character {
        switch self {
        case .curlyBraces: return "{"
        case .parenthesis: return "("
        }
    }
    
    var close: Character {
        switch self {
        case .curlyBraces: return "}"
        case .parenthesis: return ")"
        }
    }
}

extension String {
    /// Appends scoped Go source content to the receiver. The content will be
    /// new line separated and indented one level.
    /// - parameter lines: The lines that make up the scoped content's 
    ///   implementation.
    func appendingScopedGoContent(_ lines: [String], withScopeType scopeType: GoScopeType = .curlyBraces, separatedByNewLines: Int = 0) -> String {
        var scopedContent = "\(scopeType.open)\n"
        
        let indentedLines = lines.map { line in
            return "\t" + line.replacingOccurrences(of: "\n", with: "\n\t")
        }
        
        var separator = ""
        for _ in 0...separatedByNewLines {
            separator += "\n"
        }
        scopedContent += indentedLines.joined(separator: separator)
        
        scopedContent += "\n\(scopeType.close)"
        
        return self + scopedContent
    }
}
