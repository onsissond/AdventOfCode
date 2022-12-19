/*
 https://adventofcode.com/2022/day/4
 */

extension ClosedRange where Element == Int {
    init(_ input: String) {
        let rawValues = input.split(separator: "-").map { Int($0)! }
        self.init(uncheckedBounds: (rawValues.first!, rawValues.last!))
    }
    
    func contains(_ pair: ClosedRange) -> Bool {
        lowerBound <= pair.lowerBound && pair.upperBound <= upperBound
    }
}

func solutionPart1(_ input: String) -> Int {
    input
        .split(separator: "\n")
        .map { $0.split(separator: ",").map { ClosedRange(String($0)) }}
        .filter { $0.first!.contains($0.last!) || $0.last!.contains($0.first!) }
        .count
}

func solutionPart2(_ input: String) -> Int {
    input
        .split(separator: "\n")
        .map { $0.split(separator: ",").map { ClosedRange(String($0)) }}
        .filter { $0.first!.overlaps($0.last!) }
        .count
}

let input = readInput()
solutionPart1(input)
solutionPart2(input)
