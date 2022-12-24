import Foundation

public class Node<Element> {
    public var value: Element
    public private(set) var children: [Node] = []
    public private(set) weak var parent: Node?
    
    public init(value: Element) {
        self.value = value
    }
    
    public func add(child: Node) {
        children.append(child)
        child.parent = self
    }

    public var items: [Node<Element>] {
        [self] + children.flatMap { $0.items }
    }
}

extension Node: CustomDebugStringConvertible {
    public var debugDescription: String {
        var text = "\(value)"
        
        if !children.isEmpty {
            text += " {" + children.map { $0.debugDescription }.joined(separator: ", ") + "} "
        }
        
        return text
    }
}
