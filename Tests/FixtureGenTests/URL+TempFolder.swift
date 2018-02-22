import Foundation

private let TempFolder = "Temp"

extension URL {
    /// If a folder already exists at the provided location it will be deleted.
    static func tempFolder(withSubfolder subfolder: String) throws -> URL {
        let folder = URL(fileURLWithPath: #file) // $(SOURCE_ROOT)/Tests/FixtureGen/URL+TempFolder.swift
            .deletingLastPathComponent()         // $(SOURCE_ROOT)/Tests/FixtureGen
            .deletingLastPathComponent()         // $(SOURCE_ROOT)/Tests/
            .deletingLastPathComponent()         // $(SOURCE_ROOT)
            .appendingPathComponent(TempFolder, isDirectory: true)
            .appendingPathComponent(subfolder, isDirectory: true)
        
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: folder.path) {
            try fileManager.removeItem(at: folder)
        }
        
        try fileManager.createDirectory(at: folder, withIntermediateDirectories: true, attributes: nil)
        
        return folder
    }
}
