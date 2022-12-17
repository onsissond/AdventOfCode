/*
 https://adventofcode.com/2022/day/3
 */

private func property(for ch: Character) -> Int {
    let asciiValue = ch.asciiValue!
    if asciiValue >= Character("A").asciiValue! && asciiValue <= Character("Z").asciiValue! {
        return Int(asciiValue - 38)
    }
    return Int(asciiValue - 96)
}

func solutionPart1(_ input: String) -> Int {
    input
        .split(separator: "\n")
        .compactMap {
            let middleIndex = $0.index($0.startIndex, offsetBy: $0.count / 2)
            let leftCompartment = Set($0[$0.startIndex..<middleIndex])
            let rightCompartment = Set($0[middleIndex..<$0.endIndex])
            let wrongItem = leftCompartment.intersection(rightCompartment).first
            return wrongItem.map(property(for:))
        }
        .reduce(0, +)
}

func solutionPart2(_ input: String) -> Int {
    input
        .split(separator: "\n")
        .map(Set.init)
        .enumerated()
        .reduce(Array<Array<Set<Character>>>()) { partialResult, offsetAndBackpack in
            let (offset, backpack) = offsetAndBackpack
            var result = partialResult
            if offset % 3 == 0 || offset == 0 {
                result.append([backpack])
                return result
            }
            result[result.count - 1].append(backpack)
            return result
        }
        .compactMap { backpackGroups in
            let commonItem = backpackGroups.dropFirst().reduce(backpackGroups.first!) { partialResult, currentSet in
                partialResult.intersection(currentSet)
            }.first
            return commonItem.map(property(for:))
        }
        .reduce(0, +)
}

let input = readInput()
solutionPart1(input)
solutionPart2(input)
