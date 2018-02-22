import Foundation

enum Schema {
    case structure(Struct)
    case enumeration(Enum)
    case interface(Interface)
    case namedType(NamedType)
}

extension Schema: SourceContentConvertible {
    var sourceContent: String {
        switch self {
        case .structure(let structure): return structure.sourceContent
        case .enumeration(let enumeration): return enumeration.sourceContent
        case .interface(let interface): return interface.sourceContent
        case .namedType(let namedType): return namedType.sourceContent
        }
    }
}

extension Schema: ModuleImportable {
    var importedModules: [String] {
        switch self {
        case .structure(let structure): return structure.importedModules
        case .enumeration(let enumeration): return enumeration.importedModules
        case .interface(let interface): return interface.importedModules
        case .namedType(let namedType): return namedType.importedModules
        }
    }
}
