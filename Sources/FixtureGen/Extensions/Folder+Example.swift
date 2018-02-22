import ManualKit
import SwaggerParser

extension Folder {
    static let ExamplesName = "examples"

    /// Adds examples for the provided definitions to the folder.
    ///
    /// Returns the paths of all of the files that were added.
    func addExamples(of definitions: [String: Schema]) throws -> [String] {
        let examples = try definitions.flatMap {try Example(name: $0.key, definition: $0.value, for: definitions)}

        guard !self.subfolders.contains(where: {$0.name == Folder.ExamplesName}) else {
            fatalError("Examples subfolder already exists in \(self.name).")
        }

        let examplesFolder = Folder(name: Folder.ExamplesName)
        examplesFolder.files = examples
        self.subfolders.append(examplesFolder)

        return examplesFolder.files.map {"\(Folder.ExamplesName)/\($0.filename)"}
    }
}
