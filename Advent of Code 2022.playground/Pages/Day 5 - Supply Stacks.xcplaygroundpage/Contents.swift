/*
 https://adventofcode.com/2022/day/5
 */

struct Map {
    private var array: [[Character]]
    
    let count: Int
    private var carryingСapacity: Int? = 1
    
    init(count: Int) {
        self.count = count
        array = .init(repeating: [], count: count)
    }
    
    func peekTop(at index: Int) -> Character? {
        array[index].last
    }
    
    mutating func upgrade() {
        carryingСapacity = nil
    }
    
    mutating func push(_ item: Character, at index: Int) {
        array[index].append(item)
    }
    
    mutating func execute(_ command: Command) {
        let capacity = carryingСapacity ?? command.count
        (capacity...command.count).forEach { _ in
            let items = array[command.from - 1].popLast(capacity)
            array[command.to - 1].append(contentsOf: items)
        }
        
    }
}

struct Command: CustomDebugStringConvertible {
    let count: Int
    let from: Int
    let to: Int

    var debugDescription: String {
        "move: \(count) from: \(from) to: \(to)"
    }
}

private func parseMap(_ input: Array<Substring>) -> Map {
    let reversed = input
        .reversed()
    let numberOfColumn = reversed.first!.filter { $0.isNumber }.count
    var map = Map(count: numberOfColumn)
    let lines = reversed.dropFirst()
    lines.forEach { line in
        var i = 0
        while (i < line.count) {
            let index = i / 4
            let ch = line[line.index(line.startIndex, offsetBy: i + 1)]
            if ch.isLetter { map.push(ch, at: index) }
            i += 4
        }
    }
    return map
}

private func parseCommands(_ input: Array<Substring>) -> [Command] {
    input
        .map {
            $0.split(separator: try! Regex("move | from | to ")).map { Int($0)! }
        }
        .map { Command(count: $0[0], from: $0[1], to: $0[2]) }
}

private func parseInput(_ input: String) -> (Map, [Command]) {
    let lines = input
        .split(separator: "\n\n")
        .map { $0.split(separator: "\n") }
    let map = parseMap(lines[0])
    let commands = parseCommands(lines[1])
    return (map, commands)
}

func solutionPart1(_ input: String) -> String {
    var (map, commands) = parseInput(input)
    commands.forEach { map.execute($0) }
    return (0..<map.count)
        .compactMap { map.peekTop(at: $0).map(String.init) }
        .joined()
}

func solutionPart2(_ input: String) -> String {
    var (map, commands) = parseInput(input)
    map.upgrade()
    commands.forEach { map.execute($0) }
    return (0..<map.count)
        .compactMap { map.peekTop(at: $0).map(String.init) }
        .joined()
}

let input = readInput()
solutionPart1(input)
solutionPart2(input)
