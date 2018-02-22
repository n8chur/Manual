import XCTest
import SwaggerParser
@testable import FixtureGen

class RootInfoTests: XCTestCase {
    var testJSONString: String!
    var rootInfo: RootInfo!
    
    override func setUp() {
        let testsFolder = URL(fileURLWithPath: #file).deletingLastPathComponent().appendingPathComponent("Fixtures")
        let testJSONURL = URL(string: "test_root_info.json", relativeTo: testsFolder)!
        testJSONString = try! String(contentsOf: testJSONURL)
        
        rootInfo = try! RootInfo(scheme: "https", host: "petstore.swagger.io", basePath: "/v2", folderPaths: ["v2/foo/","v2/foo/bar/"], examplePaths: ["examples/foo.json","examples/bar.json"])
    }
    
    func testRootInfo() {
        // Initializing a new string force unwrapped seems to solve debug 
        // description issues where the underlying object is still an optional.
        let result = String(try! rootInfo.toJSONString())!
        let expected = String(testJSONString)!
        XCTAssertEqual(result, expected)
    }
    
    func testWrite() throws {
        let subfolder = URL(fileURLWithPath: #file).deletingPathExtension().lastPathComponent
        let tempFolder = try URL.tempFolder(withSubfolder: subfolder)
        
        try rootInfo.write(in: tempFolder)
        
        let fileURL = URL(fileURLWithPath: tempFolder.appendingPathComponent(rootInfo.filename).path)
        XCTAssertTrue(FileManager.default.fileExists(atPath: fileURL.path))
        
        let contents = try String(contentsOf: fileURL)
        
        // Initializing a new string force unwrapped seems to solve debug
        // description issues where the underlying object is still an optional.
        let expected = String(testJSONString)!
        XCTAssertEqual(contents, expected)
    }
}
