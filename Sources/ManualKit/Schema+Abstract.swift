import SwaggerParser

extension Schema {
    public var abstract: Bool {
        switch self.type {
        case .allOf(let allOf): return allOf.abstract
        case .object(let object): return object.metadata.abstract
        default: return false
        }
    }
}
