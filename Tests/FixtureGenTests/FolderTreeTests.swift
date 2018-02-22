import XCTest
import SwaggerParser
import ManualKit
@testable import FixtureGen

class FolderTreeTests: XCTestCase {
    var folderTree: FolderTree!

    override func setUp() {
        let testFixturesFolder = URL(fileURLWithPath: #file).deletingLastPathComponent().appendingPathComponent("Fixtures")
        let swaggerURL = URL(string: "test_swagger.json", relativeTo: testFixturesFolder.appendingPathComponent("Single"))!
        folderTree = try! FolderTree(swaggerURL: swaggerURL)
    }

    func testFolderTree() {
        let root = folderTree.root
        XCTAssertEqual(root.name, "petstore.swagger.io")
        XCTAssertEqual(root.files.count, 1)

        let rootInfo = root.files.first as? RootInfo
        XCTAssertNotNil(rootInfo)
        XCTAssertEqual(rootInfo?.filename, "info.json")
        XCTAssertEqual(rootInfo?.host, "petstore.swagger.io")
        XCTAssertEqual(rootInfo?.folderPaths.count, 15)
        if let info = rootInfo {
            for path in info.folderPaths {
                XCTAssertTrue(path.hasPrefix("v2/"))
            }
        }
        
        let basePath = root.subfolders.first
        XCTAssertNotNil(basePath)
        XCTAssertEqual(basePath?.name, "v2")
        XCTAssertEqual(basePath?.files.count, 0)
        XCTAssertEqual(basePath?.subfolders.count, 5)
    }
    
    func testPathFolders() throws {
        let (folders, folderPaths) = try folderTree.swagger.pathFoldersWith(scheme: folderTree.scheme, host: folderTree.host)
        
        XCTAssertEqual(folderPaths, [
            "event/",
            "pet/",
            "pet/findByStatus/",
            "pet/findByTags/",
            "pet/{petId}/",
            "store/inventory/",
            "store/order/",
            "store/order/{orderId}/",
            "success-event/",
            "user/",
            "user/createWithArray/",
            "user/createWithList/",
            "user/login/",
            "user/logout/",
            "user/{username}/"
        ].sorted())
        
        XCTAssertEqual(folders.count, 5)
        
        let pet = folders.first{$0.name == "pet"}
        XCTAssertNotNil(pet)
        
        XCTAssertEqual(pet?.files.count, 1)
        XCTAssertNotNil(pet?.files.first as? PathInfo)
        
        XCTAssertEqual(pet?.subfolders.count, 4)
        
        let petID = pet?.subfolders.first{$0.name == "{petId}"}
        XCTAssertNotNil(petID)
        
        XCTAssertEqual(petID?.files.count, 1)
        XCTAssertNotNil(petID?.files.first as? PathInfo)
        
        XCTAssertEqual(petID?.subfolders.count, 1)
        
        let petIDFixtures = petID?.subfolders.first{$0.name == "fixtures"}
        XCTAssertNotNil(petIDFixtures)
        XCTAssertEqual(petIDFixtures?.files.count, 7)
        XCTAssertEqual(petIDFixtures?.subfolders.count, 0)
    }
    
    func testBasePathFolderForPath() {
        let result = folderTree.swagger.basePathFolderWith(basePath: "/foo/bar/baz", subfolders: [])
        XCTAssertNotNil(result)
        
        XCTAssertEqual(result?.folderPath, "foo/bar/baz/")
        
        let foo = result?.folder
        XCTAssertEqual(foo?.name, "foo")
        XCTAssertEqual(foo?.files.count, 0)
        XCTAssertEqual(foo?.subfolders.count, 1)
        
        let bar = foo?.subfolders.first
        XCTAssertEqual(bar?.name, "bar")
        XCTAssertEqual(bar?.files.count, 0)
        XCTAssertEqual(bar?.subfolders.count, 1)
        
        let baz = bar?.subfolders.first
        XCTAssertEqual(baz?.name, "baz")
        XCTAssertEqual(baz?.files.count, 0)
        XCTAssertEqual(baz?.subfolders.count, 0)
    }
    
    func testWrite() throws {
        let subfolder = URL(fileURLWithPath: #file).deletingPathExtension().lastPathComponent
        let tempFolder = try URL.tempFolder(withSubfolder: subfolder)
        
        try folderTree.write(in: tempFolder)
        
        let iterationCount = assertFilesWritten(for: folderTree.root, in: tempFolder)
        XCTAssertEqual(iterationCount, 99)
    }
    
    /// Returns the number of `File`s and `Folder`s that were checked.
    private func assertFilesWritten(for folder: Folder, in containingURL: URL) -> Int {
        let fileManager = FileManager.default
        
        let folderURL = containingURL.appendingPathComponent(folder.name, isDirectory: true)
        var isDirectory: ObjCBool = false
        XCTAssertTrue(fileManager.fileExists(atPath: folderURL.path, isDirectory: &isDirectory))
        XCTAssertTrue(isDirectory.boolValue)
        
        var checkedFilesAndFolders = 1
        
        for file in folder.files {
            let fileURL = folderURL.appendingPathComponent(file.filename)
            XCTAssertTrue(fileManager.fileExists(atPath: fileURL.path))
            checkedFilesAndFolders += 1
        }
        
        for subfolder in folder.subfolders {
            checkedFilesAndFolders += assertFilesWritten(for: subfolder, in: folderURL)
        }
        
        return checkedFilesAndFolders
    }
}
