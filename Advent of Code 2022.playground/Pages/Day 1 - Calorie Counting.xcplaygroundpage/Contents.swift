/*
 https://adventofcode.com/2022/day/2
 */

import Foundation

func solutionPart1(_ input: String) -> Int {
    input
        .split(separator: "\n\n")
        .map { $0.split(separator: "\n").map { Int($0)! } }
        .map { $0.reduce(0, +) }
        .max()!
}

func solutionPart2(_ input: String) -> Int {
    let sorted = input
        .split(separator: "\n\n")
        .map { $0.split(separator: "\n").map { Int($0)! } }
        .map { $0.reduce(0, +) }
        .sorted(by: <)
    // Can't infer type
    return sorted
        .suffix(3)
        .reduce(0, +)
}

let input = readInput()
solutionPart1(input)
solutionPart2(input)
