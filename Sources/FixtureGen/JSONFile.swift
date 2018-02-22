import Foundation
import ManualKit

public protocol JSONFile: File, Encodable {}

public extension JSONFile {
    /// Returns the JSON String for the object removing backslashes that are
    /// escaping forwardslash characters in generated JSON strings, and ensures
    /// that there is a newline character at the end of the returned String.
    func toJSONString() throws -> String {
        let encoder = JSONEncoder()

        var outputFormatting = encoder.outputFormatting
        outputFormatting.insert(.prettyPrinted)
        if #available(OSX 10.13, *) {
            outputFormatting.insert(.sortedKeys)
        }
        encoder.outputFormatting = outputFormatting

        let data = try encoder.encode(self)
        let string = String(data: data, encoding: String.Encoding.utf8)!.removingExtraneousEscapeCharacters
        
        if !string.hasSuffix("\n") {
            return string + "\n"
        }
        
        return string
    }
}

// MARK: JSONFile - File

public extension JSONFile {
    func write(in containingURL: URL) throws {
        let jsonString: String
        do {
            jsonString = try toJSONString()
        } catch (let error) {
            throw SerializationError.file(self, inFolderURL: containingURL, error: error)
        }
        
        let fileURL = containingURL.appendingPathComponent(self.filename)
        
        try jsonString.write(toFile: fileURL.path, atomically: false, encoding: .utf8)
    }
}
