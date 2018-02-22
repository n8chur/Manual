import Foundation

public protocol Writable {
    func write(in containingUrl: URL) throws
}

public enum SerializationError: Error {
    case file(File, inFolderURL: URL, error: Error?)

    public var description: String {
        switch self {
        case .file(let file, let folderURL, let error): return "Unable to serialize \(folderURL.path)/\(file.filename): \(String(describing:error))"
        }
    }
}
