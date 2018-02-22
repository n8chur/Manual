import XCTest
import SwaggerParser
@testable import FixtureGen

class FixtureTests: XCTestCase {
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
    
    func testFixtureWithResponseObject() throws {
        let fixture = try swagger.responseTestFixtureWith(method: .get, scheme: scheme, pathString: "/pet/{petId}", statusCode: 200)
        validate(that: fixture, serializesTo: try testFixturesFolder.JSONString(for: "test_fixture_get_pet_id.json"))
    }
    
    func testFixtureWithQueryParamsAndResponseHeaders() throws {
        let fixture = try swagger.responseTestFixtureWith(method: .get, scheme: scheme, pathString: "/user/login", statusCode: 200)
        validate(that: fixture, serializesTo: try testFixturesFolder.JSONString(for: "test_fixture_get_user_login.json"))
    }
    
    func testFixtureWithRequestBody() throws {
        let fixture = try swagger.responseTestFixtureWith(method: .post, scheme: scheme, pathString: "/pet", statusCode: 405)
        validate(that: fixture, serializesTo: try testFixturesFolder.JSONString(for: "test_fixture_post_pet.json"))
    }
    
    func testResponseWithParentObject() throws {
        let fixture = try swagger.responseTestFixtureWith(method: .get, scheme: scheme, pathString: "/event", statusCode: 200)
        validate(that: fixture, serializesTo: try testFixturesFolder.JSONString(for: "test_fixture_get_event.json"))
    }
    
    func testResponseWithAllOfObject() throws {
        let fixture = try swagger.responseTestFixtureWith(method: .get, scheme: scheme, pathString: "/success-event", statusCode: 200)
        validate(that: fixture, serializesTo: try testFixturesFolder.JSONString(for: "test_fixture_get_success_event.json"))
    }
    
    func testFixtureWithRequestHeaders() throws {
        let fixture = try swagger.responseTestFixtureWith(method: .delete, scheme: scheme, pathString: "/pet/{petId}", statusCode: 204)
        validate(that: fixture, serializesTo: try testFixturesFolder.JSONString(for: "test_fixture_delete_pet_id.json"))
    }
    
    func testAbstractBaseArray() throws {
        let swaggerURL = URL(string: "test_swagger_array_items.json", relativeTo: testFixturesFolder)!
        let swaggerString = try String(contentsOf: swaggerURL)
        let swagger = try Swagger(from: swaggerString)

        let fixture = try swagger.responseTestFixtureWith(method: .get, scheme: scheme, pathString: "/test-abstract", statusCode: 200)
        validate(that: fixture, serializesTo: try testFixturesFolder.JSONString(for: "test_fixture_abstract_array.json"))
    }
    
    func testNonAbstractBaseArray() throws {
        let swaggerURL = URL(string: "test_swagger_array_items.json", relativeTo: testFixturesFolder)!
        let swaggerString = try String(contentsOf: swaggerURL)
        let swagger = try Swagger(from: swaggerString)
        
        let fixture = try swagger.responseTestFixtureWith(method: .get, scheme: scheme, pathString: "/test-non-abstract", statusCode: 200)
        validate(that: fixture, serializesTo: try testFixturesFolder.JSONString(for: "test_fixture_non_abstract_array.json"))
    }
    
    func testNestedSchemaArray() throws {
        let swaggerURL = URL(string: "test_swagger_array_items.json", relativeTo: testFixturesFolder)!
        let swaggerString = try String(contentsOf: swaggerURL)
        let swagger = try Swagger(from: swaggerString)
        
        let fixture = try swagger.responseTestFixtureWith(method: .get, scheme: scheme, pathString: "/test-nested", statusCode: 200)
        validate(that: fixture, serializesTo: try testFixturesFolder.JSONString(for: "test_fixture_nested_array.json"))
    }
    
    func testFixtures() throws {
        let pathString = "/pet/{petId}"
        let path = swagger!.paths[pathString]!
        let fixtures = try path.fixturesWith(scheme: scheme, host: host, basePath: basePath, pathString: pathString, definitions: swagger!.definitions)
        XCTAssertNotNil(fixtures)
        XCTAssertEqual(fixtures.count, 7)
        XCTAssertNotNil(fixtures.first{$0.filename == "GET-400.json"})
        XCTAssertNotNil(fixtures.first{$0.filename == "GET-404.json"})
        XCTAssertNotNil(fixtures.first{$0.filename == "POST-405.json"})
        XCTAssertNotNil(fixtures.first{$0.filename == "DELETE-204.json"})
        XCTAssertNotNil(fixtures.first{$0.filename == "DELETE-404.json"})
        XCTAssertNotNil(fixtures.first{$0.filename == "DELETE-400.json"})
        
        let get200 = fixtures.first{$0.filename == "GET-200.json"}
        XCTAssertNotNil(get200)
        XCTAssertTrue(get200!.response.body.count > 0)
    }
    
    func testEnum() throws {
        let swaggerURL = URL(string: "test_enum.json", relativeTo: testFixturesFolder)!
        let swaggerString = try String(contentsOf: swaggerURL)
        let swagger = try Swagger(from: swaggerString)
        
        let fixture = try swagger.responseTestFixtureWith(method: .get, scheme: "https", pathString: "/test-enum", statusCode: 200)
        let jsonData = fixture.response.body.data(using: String.Encoding.utf8)!
        let jsonBody = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any?]
        XCTAssertNotNil(jsonBody)
        XCTAssertEqual(jsonBody?["value"] as? String, "Value")
    }
}

fileprivate extension FixtureTests {
    func validate(that fixture: Fixture, serializesTo expectedString: String) {
        // Initializing a new string force unwrapped seems to solve debug
        // description issues where the underlying object is still an optional.
        let result = String(try! fixture.toJSONString())!
        let expected = String(expectedString)!
        XCTAssertEqual(result, expected)
    }
}

fileprivate extension Swagger {
    func responseTestFixtureWith(method: OperationType, scheme: String, pathString: String, statusCode: Int) throws -> Fixture {
        let path = self.paths[pathString]!
        let operation = path.operations[method]!
        let response = operation.responses[statusCode]!.value
        let parameters = (operation.parameters + path.parameters).map { $0.value }
        let pathTemplate = pathString.removingLeadingForwardslash.withTrailingForwardslash
        return try Fixture(method: method, scheme: scheme, host: self.host!.absoluteString, basePath: basePath, pathTemplate: pathTemplate, parameters: parameters, statusCode: statusCode, response: response, definitions: self.definitions)
    }
}
