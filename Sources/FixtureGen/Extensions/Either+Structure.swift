import SwaggerParser

extension Either where B == Structure<A> {
    var value: A {
        switch self {
        case .a(let value): return value
        case .b(let structure):
            return structure.structure
        }
    }
}
