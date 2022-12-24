import Foundation

public func print<T>(array: any Sequence<T>) {
    array.forEach { print($0) }
}
