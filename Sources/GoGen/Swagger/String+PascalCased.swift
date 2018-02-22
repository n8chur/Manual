import Foundation

extension String {
    var goName: String {
        // First convert camelcase to snake case so that camelcase segments are
        // separated with .components(separatedBy:).
        let pattern = "([a-z0-9])([A-Z])"
        
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        
        let range = NSRange(location: 0, length: self.count)
        let snakeCased = regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: "$1_$2")
        
        var goName = snakeCased.components(separatedBy: CharacterSet.alphanumerics.inverted)
            .map {$0.capitalizingFirstLetter}
            .joined()
        
        // Replace names ending with Id with ID
        if goName.hasSuffix("Id") {
            let start = goName.index(goName.endIndex, offsetBy: -2)
            goName.replaceSubrange(start..<goName.endIndex, with: "ID")
        }
        
        return goName
    }
    
    var capitalizingFirstLetter: String {
        let first = String(self.prefix(1)).capitalized
        let other = String(self.dropFirst())
        return first + other
    }
}
