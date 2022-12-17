import Foundation

public func mesure(_ f: () -> Void) {
    let start = CFAbsoluteTimeGetCurrent()
    f()
    let diff = CFAbsoluteTimeGetCurrent() - start
    print("Took \(diff) seconds")
}
