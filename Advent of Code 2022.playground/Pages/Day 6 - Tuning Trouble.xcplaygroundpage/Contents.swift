/*
 https://adventofcode.com/2022/day/6
 */

func solution(_ input: String, windowSize: Int) -> Int {
    var startIndex = input.startIndex
    var endIndex = input.startIndex
    var savedIndexOfCharacter: [Character: String.Index] = [:]
    
    while(endIndex < input.endIndex && input.distance(from: startIndex, to: endIndex) != windowSize) {
        let ch = input[endIndex]
        if let repeatedIndex = savedIndexOfCharacter[ch], repeatedIndex >= startIndex {
            startIndex = input.index(after: repeatedIndex)
        }
        savedIndexOfCharacter[ch] = endIndex
        endIndex = input.index(after: endIndex)
    }

    return input.distance(from: startIndex, to: endIndex) == windowSize
    ? input.count
    : -1
}

let input = "abcd"
// Part 1
solution(input, windowSize: 4)
// Part 2
solution(input, windowSize: 14)
