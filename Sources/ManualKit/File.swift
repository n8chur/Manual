import Foundation

public protocol File: Writable {
    var filename: String { get }
}
