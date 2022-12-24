import Foundation

public struct Parser<Output> {
    public var parse: (String) -> Output?
    
    public init(parse: @escaping (String) -> Output?) {
        self.parse = parse
    }
    
    public func or(_ parser: Parser<Output>) -> Parser<Output> {
        Parser { self.parse($0) ?? parser.parse($0)}
    }
    
    public func map<T>(_ f: @escaping (Output) -> T) -> Parser<T> {
        Parser<T> { self.parse($0).map(f) }
    }
}
