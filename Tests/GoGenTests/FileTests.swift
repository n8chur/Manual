import XCTest
import SwaggerParser
@testable import GoGen

class GoFileTests: XCTestCase {
    var testFixturesFolder: URL!
    
    override func setUp() {
        testFixturesFolder = URL(fileURLWithPath: #file).deletingLastPathComponent().appendingPathComponent("Fixtures")
    }
    
    func testInitializer() {
        // Create a Base interface.
        let foo = Property(
            type: .string,
            name: "Foo",
            jsonName: "foo",
            comment: "This is a foo property.",
            isDiscriminator: true,
            isNullable: false)
        let base = Interface(
            name: "Base",
            properties: [foo],
            comment: "The base interface.")
        
        // Create a struct that conforms to that interface.
        let qux = Property(
            type: .bool,
            name: "Qux",
            jsonName: "qux",
            comment: nil,
            isDiscriminator: false,
            isNullable: false)
        let baz = Struct(
            name: "Baz",
            comment: nil,
            properties: [qux, foo],
            interfaces: [base])
        
        // Create a struct with a property that references another.
        let bar = Property(
            type: .structure(baz),
            name: "Bar",
            jsonName: "bar",
            comment: nil,
            isDiscriminator: false,
            isNullable: false)
        let corge = Struct(
            name: "Corge",
            comment: "This is the corge.",
            properties: [bar],
            interfaces: [])
        
        // Create an interface that has a []interface{} getter.
        let object = Struct(
            name: "interface{}",
            comment: nil,
            properties: [],
            interfaces: [])
        let items = Property(
            type: .slice(.structure(object)),
            name: "Items",
            jsonName: "items",
            comment: "A list of items.",
            isDiscriminator: false,
            isNullable: false)
        let list = Interface(
            name: "List",
            properties: [items],
            comment: "A list.")
        
        // Create an struct that implements List and overrides the type of
        // `items`.
        let bazItems = Property(
            type: .slice(.structure(baz)),
            name: items.name,
            jsonName: items.jsonName,
            comment: "Baz items.",
            isDiscriminator: false,
            isNullable: true)
        let listBaz = Struct(
            name: "ListBaz",
            comment: "A list of Baz.",
            properties: [bazItems],
            interfaces: [list])
        
        let schemas: [GoGen.Schema] = [
            .interface(base),
            .structure(baz),
            .structure(corge),
            .interface(list),
            .structure(listBaz),
        ]
        let file = File(
            filename: "models.go",
            package: "models",
            schemas: schemas)

        let testJSONURL = URL(string: "test_go_file.go", relativeTo: testFixturesFolder)!
        let expectedContent =  try! String(contentsOf: testJSONURL)
        
        XCTAssertEqual(file.sourceContent, expectedContent)
    }
    
    func testSwaggerGeneration() {
        let swaggerURL = URL(string: "test_swagger_go_gen.json", relativeTo: testFixturesFolder)!
        let swagger = try! Swagger(URL: swaggerURL)
        
        let files: [File]
        do {
            files = try File.makeFilesWith(packageName: "models", swagger: swagger)
        } catch {
            XCTFail("Generating files failed: \(String(describing: error))"); return
        }
        
        let combinedContent = files
            .map { file in
                return "/*---------------------\(file.filename)----------------------*/\n" + file.sourceContent
            }
            .joined(separator: "\n")

        let testJSONURL = URL(string: "test_go_files.go", relativeTo: testFixturesFolder)!
        let expectedContent =  try! String(contentsOf: testJSONURL)
        
        XCTAssertEqual(combinedContent, expectedContent)
    }
}
