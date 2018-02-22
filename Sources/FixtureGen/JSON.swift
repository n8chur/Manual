import Foundation

enum JSONError: Error {
    case invalidJSONError(Any?)

    var description: String {
        switch self {
        case .invalidJSONError(let json):
            return "Could not convert 'Any' to JSON: \(String(describing: json))"
        }
    }
}

/// An enum that represents any JSON.
///
/// Necessary to support Encodable "Any" JSON property types (like the json
/// property on FixtureRequest)
///
/// Adapted from https://github.com/zoul/generic-json-swift
public enum JSON {
    case array([JSON])
    case bool(Bool)
    case integer(Int)
    case number(Float)
    case object([String: JSON])
    case string(String)
    case null

    public init(_ value: Any?) throws {
        switch value {
        case let array as [Any]:
            self = .array(try array.map(JSON.init))
        case let bool as Bool:
            self = .bool(bool)
        case let integer as Int:
            self = .integer(integer)
        case let integer as Int32:
            self = .integer(Int(integer))
        case let integer as Int64:
            self = .integer(Int(integer))
        case let double as Double:
            self = .number(Float(double))
        case let float as Float:
            self = .number(float)
        case nil:
            self = .null
        case let object as [String: Any?]:
            self = .object(try object.mapValues(JSON.init))
        case let string as String:
            self = .string(string)
        default:
            throw FixtureResponseError.invalidJSONObjectError(value)
        }
    }

    func stringValue() -> String {
        switch self {
        case .string(let string):
            return "\(string)"
        case .number(let number):
            return "\(number)"
        case .bool(let bool):
            return "\(bool)"
        case .null:
            return "null"
        default:
            let encoder = JSONEncoder()
            if #available(OSX 10.13, *) {
                encoder.outputFormatting = .sortedKeys
            }

            let data = try! encoder.encode(self)
            return String(data: data, encoding: .utf8)!.removingExtraneousEscapeCharacters
        }
    }
}

extension JSON: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self {
            case let .array(array):
                try container.encode(array)
            case let .bool(bool):
                try container.encode(bool)
            case let .integer(integer):
                try container.encode(integer)
            case let .number(number):
                try container.encode(number)
            case let .object(object):
                try container.encode(object)
            case let .string(string):
                try container.encode(string)
            case .null:
                try container.encodeNil()
        }
    }
}
