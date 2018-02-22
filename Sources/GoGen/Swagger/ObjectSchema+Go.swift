import SwaggerParser

extension ObjectSchema {
    func goStruct(named name: String, metadata: Metadata) throws -> Struct? {
        guard !self.metadata.abstract else {
            return nil
        }
        
        return Struct(
            name: name,
            comment: metadata.description,
            properties: try self.goProperties(inContainerNamed: name),
            interfaces: [])
    }
    
    func goProperties(inContainerNamed containerName: String) throws -> [Property] {
        return try self.properties
            .map { (args: (propertyName: String, schema: SwaggerParser.Schema)) -> Property in
                
                let isDiscriminator = (metadata.discriminator == args.propertyName)
                return try args.schema.propertyWith(
                    JSONName: args.propertyName,
                    containerName: containerName,
                    isDiscriminator: isDiscriminator)
            }
            .sorted {$0.name < $1.name}
    }
    
    func goInterface(named name: String, metadata: Metadata) throws -> Interface? {
        guard self.metadata.abstract else {
            return nil
        }
        
        let properties = try self.properties
            .map { (args: (propertyName: String, schema: SwaggerParser.Schema)) throws -> Property in
                
                let isDiscriminator = (self.metadata.discriminator == args.propertyName)
                return try args.schema.propertyWith(
                    JSONName: args.propertyName,
                    containerName: name,
                    isDiscriminator: isDiscriminator)
            }
            .sorted {$0.name < $1.name}
        
        return Interface(
            name: name,
            properties: properties,
            comment: metadata.description)
    }
    
    func goType(named name: String, metadata: Metadata) throws -> Type {
        if let structure = try self.goStruct(named: name, metadata: metadata) {
            return .structure(structure)
        }
        
        guard let goInterface = try self.goInterface(named: name, metadata: metadata) else {
            throw SwaggerError.failedToConvertObject(self)
        }
        
        return .interface(goInterface)
    }
}
