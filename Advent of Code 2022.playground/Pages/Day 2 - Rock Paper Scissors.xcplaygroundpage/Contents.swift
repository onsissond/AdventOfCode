/*
 https://adventofcode.com/2022/day/2
 */

enum Variant: Equatable {
    case rock
    case paper
    case scissors
    
    var score: Int {
        switch self {
        case .rock:
            return 1
        case .paper:
            return 2
        case .scissors:
            return 3
        }
    }
}

enum GameResult {
    case lose
    case draw
    case win
    
    var score: Int {
        switch self {
        case .lose:
            return 0
        case .draw:
            return 3
        case .win:
            return 6
        }
    }
}

struct Game {
    let variantA: Variant
    let variantB: Variant
    
    func play() -> GameResult {
        switch (variantA, variantB) {
        case
            (.rock, .paper),
            (.paper, .scissors),
            (.scissors, .rock):
            return .win
        case
            (.rock, .scissors),
            (.paper, .rock),
            (.scissors, .paper):
            return .lose
        default:
            return .draw
        }
    }
}

extension Variant {
    init?(characher: Character) {
        switch characher {
        case "A", "X":
            self = .rock
        case "B", "Y":
            self = .paper
        case "C", "Z":
            self = .scissors
        default:
            return nil
        }
    }
}

func solutionPart1(input: String) -> Int {
    input
        .split(separator: "\n")
        .map {
            Game(
                variantA: Variant(characher: $0.first!)!,
                variantB: Variant(characher: $0.last!)!
            )
        }
        .map { $0.variantB.score + $0.play().score }
        .reduce(0, +)
}

extension Game {
    init(variantA: Variant, result: GameResult) {
        self.variantA = variantA
        self.variantB = {
            switch (variantA, result) {
            case (.rock, .lose), (.paper, .win):
                return .scissors
            case (.rock, .win), (.scissors, .lose):
                return .paper
            case (.scissors, .win), (.paper, .lose):
                return .rock
            case (_, .draw):
                return variantA
            }
        }()
    }
}

extension GameResult {
    init?(characher: Character) {
        switch characher {
        case "X":
            self = .lose
        case "Y":
            self = .draw
        case "Z":
            self = .win
        default:
            return nil
        }
    }
}

func solutionPart2(input: String) -> Int {
    input
        .split(separator: "\n")
        .map {
            Game(
                variantA: Variant(characher: $0.first!)!,
                result: GameResult(characher: $0.last!)!
            )
        }
        .map { $0.variantB.score + $0.play().score }
        .reduce(0, +)
}

let input = readInput()
solutionPart1(input: input)
solutionPart2(input: input)
