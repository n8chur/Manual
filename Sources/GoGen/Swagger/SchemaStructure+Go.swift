import SwaggerParser

extension Structure where T == SwaggerParser.Schema {
    func goType() throws -> Type {
        if let goStruct = try self.goStruct() {
            return .structure(goStruct)
        }
        
        if let goInterface = try self.goInterface() {
            return .interface(goInterface)
        }
        
        if let goEnum = try self.goEnum() {
            return .enumeration(goEnum)
        }
        
        throw SwaggerError.failedToConvertReference(self.structure)
    }
    
    func goStruct() throws -> Struct? {
        return try self.structure.goStruct(named: self.name.goName, JSONName: self.name)
    }
    
    func goInterface() throws -> Interface? {
        return try self.structure.goInterface(named: self.name.goName, JSONName: self.name)
    }
    
    func goEnum() throws -> Enum? {
        return try self.structure.goEnum(named: self.name.goName, JSONName: self.name, definedInLine: false)
    }
}
