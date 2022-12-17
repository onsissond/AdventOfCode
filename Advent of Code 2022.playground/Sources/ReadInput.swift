import Foundation

public func readInput(fileName: String = "Input") -> String {
    let fileURL = Bundle.main.url(forResource: fileName, withExtension: "txt")
    let input = try! String(contentsOf: fileURL!, encoding: .utf8)
    return input
}
