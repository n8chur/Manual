import XCTest
import SwaggerParser
@testable import FixtureGen

class PathInfoTests: XCTestCase {
    var testJSONString: String!
    var pathInfo: PathInfo!
    
    override func setUp() {
        let testFixturesFolder = URL(fileURLWithPath: #file).deletingLastPathComponent().appendingPathComponent("Fixtures")
        let testSwaggerURL = URL(string: "test_swagger.json", relativeTo: testFixturesFolder.appendingPathComponent("Single"))!
        let swagger = try! Swagger(URL: testSwaggerURL)
        
        let (pathString, _) = swagger.paths.first {$0.key == "/pet/{petId}"}!
        pathInfo = PathInfo(pathString: pathString, fixturePaths: ["fixtures/GET-200.json", "fixtures/POST-422.json"])

        let testJSONURL = URL(string: "test_path_info.json", relativeTo: testFixturesFolder)!
        testJSONString = try! String(contentsOf: testJSONURL)
    }
    
    func testPathInfo() {
        // Initializing a new string force unwrapped seems to solve debug
        // description issues where the underlying object is still an optional.
        let result = String(try! pathInfo.toJSONString())
        let expected = String(testJSONString)
        XCTAssertEqual(result, expected)
    }
    
    func testWrite() throws {
        let subfolder = URL(fileURLWithPath: #file).deletingPathExtension().lastPathComponent
        let tempFolder = try URL.tempFolder(withSubfolder: subfolder)
        
        try pathInfo.write(in: tempFolder)
        
        let fileURL = URL(fileURLWithPath: tempFolder.appendingPathComponent(pathInfo.filename).path)
        XCTAssertTrue(FileManager.default.fileExists(atPath: fileURL.path))
        
        let contents = try String(contentsOf: fileURL)
        
        // Initializing a new string force unwrapped seems to solve debug
        // description issues where the underlying object is still an optional.
        let expected = String(testJSONString)
        XCTAssertEqual(contents, expected)
    }
}
