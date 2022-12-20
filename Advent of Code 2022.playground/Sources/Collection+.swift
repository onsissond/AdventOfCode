import Foundation

extension Array {
    public mutating func popLast(_ k: Int) -> SubSequence {
        let items = suffix(k)
        removeLast(k)
        return items
    }
}
