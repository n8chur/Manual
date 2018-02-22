import XCTest
import SwaggerParser
@testable import FixtureGen

class ExampleTests: XCTestCase {
    var testFixturesFolder: URL!
    var swagger: Swagger!
    var scheme: String!
    var host: String!
    var basePath: String?

    override func setUp() {
        testFixturesFolder = URL(fileURLWithPath: #file).deletingLastPathComponent().appendingPathComponent("Fixtures")
        let swaggerURL = URL(string: "test_swagger.json", relativeTo: testFixturesFolder.appendingPathComponent("Single"))!
        swagger = try! Swagger(URL: swaggerURL)
        scheme = "https"
        host = swagger.host!.absoluteString
        basePath = swagger.basePath
    }

    func testFixtureWithManyProperties() throws {
        let example = try swagger.exampleFor(objectNamed: "Order")
        validate(that: example, serializesTo: try testFixturesFolder.JSONString(for: "test_example_order.json"))
    }

    func testExampleWithNestedDefinitionProperties() throws {
        let example = try swagger.exampleFor(objectNamed: "Pet")
        validate(that: example, serializesTo: try testFixturesFolder.JSONString(for: "test_example_pet.json"))
    }

    func testAbstractExample() throws {
        let example = try swagger.exampleFor(objectNamed: "Event")
        validate(that: example, serializesTo: try testFixturesFolder.JSONString(for: "test_example_event.json"))
    }

    func testAbstractAllOfExample() throws {
        let example = try swagger.exampleFor(objectNamed: "ErrorEvent")
        validate(that: example, serializesTo: try testFixturesFolder.JSONString(for: "test_example_error_event.json"))
    }

    func testConcreteAllOfExample() throws {
        let example = try swagger.exampleFor(objectNamed: "UnauthorizedErrorEvent")
        validate(that: example, serializesTo: try testFixturesFolder.JSONString(for: "test_example_unauthorized_error_event.json"))
    }
}

fileprivate extension ExampleTests {
    func validate(that example: Example, serializesTo expectedString: String) {
        // Initializing a new string force unwrapped seems to solve debug
        // description issues where the underlying object is still an optional.
        let result = String(try! example.toJSONString())!
        let expected = String(expectedString)!
        XCTAssertEqual(result, expected)
    }
}

struct NilExampleError: Error {}

fileprivate extension Swagger {
    func exampleFor(objectNamed objectName: String) throws -> Example {
        guard let definition = self.definitions[objectName],
            let example = try Example(name: objectName, definition: definition, for: self.definitions) else {
                throw NilExampleError()
        }

        return example
    }
}
