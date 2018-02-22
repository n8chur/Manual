extension String {
    var removingLeadingForwardslash: String {
        if self.hasPrefix("/") {
            return String(self.dropFirst())
        }
        return self
    }
    
    var withTrailingForwardslash: String {
        if !self.hasSuffix("/") {
            return self + "/"
        }
        return self
    }
    
    var removingExtraneousEscapeCharacters: String {
        return self.replacingOccurrences(of: "\\/", with: "/")
    }
}
