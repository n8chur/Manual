import Foundation

indirect enum Type {
    // TODO: Add `*time.Time` types.
    case string
    case int
    case int32
    case int64
    case float
    case double
    case bool
    case enumeration(Enum)
    case structure(Struct)
    case slice(Type)
    case interface(Interface)
    case namedType(NamedType)
    case any
    
    var name: String {
        switch self {
        case .string: return "string"
        case .int: return "int"
        case .int32: return "int32"
        case .int64: return "int64"
        case .float: return "float32"
        case .double: return "float64"
        case .bool: return "bool"
        case .enumeration(let enumeration): return enumeration.name
        case .structure(let structure): return structure.name
        case .slice(let type): return "[]\(type.name)"
        case .interface(let interface): return interface.name
        case .namedType(let namedType): return namedType.name
        case .any: return "interface{}"
        }
    }
}
