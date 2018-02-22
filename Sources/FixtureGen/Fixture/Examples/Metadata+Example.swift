import SwaggerParser

// MARK: - String

extension Metadata {
    private static let SupportedStringTypes: [Any.Type] = [String.self]
    private static let DefaultString = "String"
    
    /// Values will be determined based on presence in the following order:
    /// - metadata.example
    /// - metadata.enumeratedValues.first
    /// - A string based on the format if it is recognized
    /// - "String"
    func example(withFormat format: StringFormat?) throws -> String {
        if let example = self.example {
            guard let value = example as? String else {
                throw ExampleError.badExampleType(example: example, supportedTypes: Metadata.SupportedStringTypes)
            }
            return value
        }
        
        if self.enumeratedValues != nil {
            let example = try self.enumerationExample()
            guard let castedValue = example as? String else {
                throw ExampleError.enumerationValueTypeMismatch(example: example, supportedTypes: Metadata.SupportedStringTypes)
            }
            return castedValue
        }
        
        // TODO: Consider schema/metadata enumerated values.
        guard let format = format else {
            return Metadata.DefaultString
        }
        switch format {
        case .byte: return "bjhjaHVy"
        case .binary: return "01101110 00111000 01100011 01101000 01110101 01110010"
        case .date: return "2017-04-14"
        case .dateTime: return "2017-04-14T12:00:00Z+00:00"
        case .email: return "john.doe@email.com"
        case .hostname: return "example.automatic.com"
        case .ipv4: return "192.168.1.1"
        case .ipv6: return "2001:0DB8:AC10:FE01"
        case .other(let other):
            switch other {
            case "iso-8601-week": return "2017W02"
            case "url": return "http://www.automatic.com/v5/vehicles/"
            default: return Metadata.DefaultString
            }
        case .password: return "password123"
        case .uri: return "http://www.automatic.com/v5/users/"
        }
    }
}

// MARK: - Number

extension Double {
    /// Returns a Double or Float depending on the format supplied. If no format is
    /// supplied a Double will be returned.
    func example(withFormat format: NumberFormat?) -> Any {
        guard let format = format else {
            return self
        }
        switch format {
        case .double: return self
        case .float: return Float(self)
        }
    }
}

extension Metadata {
    private static let SupportedNumberTypes: [Any.Type] = [Double.self, Float.self]
    
    /// Returns a Double or Float depending on the format supplied. If no format is
    /// supplied a Double will be returned.
    ///
    /// Values will be determined based on presence in the following order:
    /// - metadata.example
    /// - metadata.enumeratedValues.first
    /// - 42
    func example(withFormat format: NumberFormat?) throws -> Any {
        if let example = self.example {
            guard let exampleDouble = example as? Double else {
                throw ExampleError.badExampleType(example: example, supportedTypes: Metadata.SupportedNumberTypes)
            }
            return exampleDouble.example(withFormat: format)
        }
        
        if self.enumeratedValues != nil {
            let example = try self.enumerationExample()
            guard let castedValue = example as? Double else {
                throw ExampleError.enumerationValueTypeMismatch(example: example, supportedTypes: Metadata.SupportedNumberTypes)
            }
            return castedValue
        }
        
        // TODO: Consider schema/metadata rules (maximum, minimum, etc.).
        return Double(42).example(withFormat: format)
    }
}

// MARK: - Integer

extension Int {
    /// Returns an Int32 or Int64 depending on the format supplied. If no format is
    /// supplied an Int will be returned.
    func example(withFormat format: IntegerFormat?) -> Any {
        guard let format = format else {
            return self
        }
        switch format {
        case .int32: return Int32(self)
        case .int64: return Int64(self)
        }
    }
}

extension Metadata {
    private static let SupportedIntegerTypes: [Any.Type] = [Int.self]
    
    /// Returns an Int32 or Int64 depending on the format supplied. If no format is
    /// supplied an Int will be returned.
    ///
    /// Values will be determined based on presence in the following order:
    /// - metadata.example
    /// - metadata.enumeratedValues.first
    /// - 42
    func example(withFormat format: IntegerFormat?) throws -> Any {
        if let example = self.example {
            guard let exampleInteger = example as? Int else {
                throw ExampleError.badExampleType(example: example, supportedTypes: Metadata.SupportedIntegerTypes)
            }
            return exampleInteger.example(withFormat: format)
        }
        
        if self.enumeratedValues != nil {
            let example = try self.enumerationExample()
            guard let castedValue = example as? Double else {
                throw ExampleError.enumerationValueTypeMismatch(example: example, supportedTypes: Metadata.SupportedIntegerTypes)
            }
            return castedValue
        }
        
        // TODO: Consider schema/metadata rules (maximum, minimum, etc.).
        return Int(42).example(withFormat: format)
    }
}

// MARK: - Bool

extension Metadata {
    private static let SupportedBoolTypes: [Any.Type] = [Bool.self]
    
    /// Values will be determined based on presence in the following order:
    /// - metadata.example
    /// - metadata.enumeratedValues.first
    /// - true
    func boolExample() throws -> Bool {
        if let example = self.example {
            guard let value = example as? Bool else {
                throw ExampleError.badExampleType(example: example, supportedTypes: Metadata.SupportedBoolTypes)
            }
            return value
        }
        
        if self.enumeratedValues != nil {
            let example = try self.enumerationExample()
            guard let castedValue = example as? Bool else {
                throw ExampleError.enumerationValueTypeMismatch(example: example, supportedTypes: Metadata.SupportedBoolTypes)
            }
            return castedValue
        }
        
        // TODO: Consider metadata rules.
        return true
    }

    func anyExample() throws -> Any {
        if let example = self.example {
            return example
        }

        return "any_value"
    }
}

// MARK: - Enum

extension Metadata {
    /// Values will be determined based on presence in the following order:
    /// - metadata.example
    /// - metadata.enumeratedValues.first
    func enumerationExample() throws -> Any? {
        if let example = self.example {
            return example
        }
        guard
            let enumeration = self.enumeratedValues,
            !enumeration.isEmpty else {
                fatalError("Enumerated type specified without any values")
        }
        
        return enumeration.first!
    }
}
