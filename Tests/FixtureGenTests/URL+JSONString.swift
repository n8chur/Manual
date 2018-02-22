import Foundation

enum JSONStringParsingError: Error {
    case badURL(relativeURL: URL, filename: String)

    public var description: String {
        switch self {
        case .badURL(let relativeURL, let filename): return "Could not construct URL relative to \"\(relativeURL.path)/\" with filename \"\(filename)\""
        }
    }
}

extension URL {
    /// Returns a JSON string for the content of the file with the name provided
    /// where the receiver is the folder that the file is contained in.
    func JSONString(for filename: String) throws -> String {
        guard let testJSONURL = URL(string: filename, relativeTo: self) else {
            throw JSONStringParsingError.badURL(relativeURL: self, filename: filename)
        }

        return try String(contentsOf: testJSONURL)
    }
}
