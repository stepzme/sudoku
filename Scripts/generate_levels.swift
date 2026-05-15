import Foundation

enum Difficulty: String, CaseIterable, Codable {
    case easy
    case medium
    case hard

    var givensRange: ClosedRange<Int> {
        switch self {
        case .easy: 42...48
        case .medium: 34...39
        case .hard: 28...32
        }
    }
}

struct SudokuLevel: Codable {
    let difficulty: Difficulty
    let number: Int
    let puzzle: [Int]
    let solution: [Int]
}

struct SeededRandomNumberGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed == 0 ? 0x4d595df4d0f33173 : seed
    }

    mutating func next() -> UInt64 {
        state = 2862933555777941757 &* state &+ 3037000493
        return state
    }
}

struct SolveStats {
    var nakedSingles = 0
    var hiddenSingles = 0
    var guesses = 0
    var backtrackNodes = 0

    var tier: Difficulty {
        if guesses > 0 || backtrackNodes > 2 {
            return .hard
        }
        if hiddenSingles > 8 || (hiddenSingles > 0 && nakedSingles > 12) {
            return .medium
        }
        return .easy
    }
}

struct SudokuEvaluator {
    static func classify(_ puzzle: [Int]) -> SolveStats? {
        var board = puzzle
        var stats = SolveStats()
        guard solve(&board, stats: &stats) else { return nil }
        return stats
    }

    private static func solve(_ board: inout [Int], stats: inout SolveStats) -> Bool {
        while true {
            if fillNakedSingles(&board, stats: &stats) { continue }
            if fillHiddenSingles(&board, stats: &stats) { continue }
            break
        }

        guard let index = nextEmptyCell(in: board) else { return true }
        let candidates = candidatesForCell(index, in: board)
        guard !candidates.isEmpty else { return false }

        stats.guesses += 1
        for candidate in candidates {
            stats.backtrackNodes += 1
            var copy = board
            copy[index] = candidate
            var nestedStats = stats
            if solve(&copy, stats: &nestedStats) {
                board = copy
                stats = nestedStats
                return true
            }
        }

        return false
    }

    private static func fillNakedSingles(_ board: inout [Int], stats: inout SolveStats) -> Bool {
        var changes: [(Int, Int)] = []
        for index in board.indices where board[index] == 0 {
            let candidates = candidatesForCell(index, in: board)
            if candidates.count == 1, let value = candidates.first {
                changes.append((index, value))
            }
        }
        guard !changes.isEmpty else { return false }
        for (index, value) in changes {
            board[index] = value
            stats.nakedSingles += 1
        }
        return true
    }

    private static func fillHiddenSingles(_ board: inout [Int], stats: inout SolveStats) -> Bool {
        for unit in units {
            var candidateMap: [Int: [Int]] = [:]
            for index in unit where board[index] == 0 {
                for candidate in candidatesForCell(index, in: board) {
                    candidateMap[candidate, default: []].append(index)
                }
            }
            for (candidate, indexes) in candidateMap where indexes.count == 1 {
                board[indexes[0]] = candidate
                stats.hiddenSingles += 1
                return true
            }
        }
        return false
    }

    private static let units: [[Int]] = {
        var result: [[Int]] = []

        for row in 0..<9 {
            result.append((0..<9).map { row * 9 + $0 })
        }

        for column in 0..<9 {
            result.append((0..<9).map { $0 * 9 + column })
        }

        for blockRow in 0..<3 {
            for blockColumn in 0..<3 {
                var block: [Int] = []
                for rowOffset in 0..<3 {
                    for columnOffset in 0..<3 {
                        let row = blockRow * 3 + rowOffset
                        let column = blockColumn * 3 + columnOffset
                        block.append(row * 9 + column)
                    }
                }
                result.append(block)
            }
        }

        return result
    }()

    private static func nextEmptyCell(in board: [Int]) -> Int? {
        var bestIndex: Int?
        var bestCandidateCount = 10

        for index in board.indices where board[index] == 0 {
            let candidateCount = candidatesForCell(index, in: board).count
            if candidateCount < bestCandidateCount {
                bestCandidateCount = candidateCount
                bestIndex = index
            }
        }

        return bestIndex
    }

    private static func candidatesForCell(_ index: Int, in board: [Int]) -> [Int] {
        guard board[index] == 0 else { return [] }
        return (1...9).filter { canPlace($0, at: index, in: board) }
    }

    static func canPlace(_ number: Int, at index: Int, in board: [Int]) -> Bool {
        let row = index / 9
        let column = index % 9
        let blockRow = (row / 3) * 3
        let blockColumn = (column / 3) * 3

        for offset in 0..<9 {
            if board[row * 9 + offset] == number { return false }
            if board[offset * 9 + column] == number { return false }
        }

        for rowOffset in 0..<3 {
            for columnOffset in 0..<3 {
                let cell = (blockRow + rowOffset) * 9 + blockColumn + columnOffset
                if board[cell] == number { return false }
            }
        }

        return true
    }
}

enum SudokuGenerator {
    static func generateLevels(perDifficulty: Int) -> [SudokuLevel] {
        var levels: [SudokuLevel] = []

        for difficulty in Difficulty.allCases {
            var generated: [SudokuLevel] = []
            var attempt = 1

            while generated.count < perDifficulty {
                if let level = makeLevel(
                    targetDifficulty: difficulty,
                    number: generated.count + 1,
                    attempt: attempt
                ) {
                    generated.append(level)
                    print("Generated \(difficulty.rawValue) level \(generated.count)/\(perDifficulty)")
                }
                attempt += 1
            }

            levels.append(contentsOf: generated)
        }

        return levels
    }

    private static func makeLevel(
        targetDifficulty: Difficulty,
        number: Int,
        attempt: Int
    ) -> SudokuLevel? {
        var random = SeededRandomNumberGenerator(seed: seed(for: targetDifficulty, number: number, attempt: attempt))
        let solution = makeSolution(using: &random)
        let givens = Int.random(in: targetDifficulty.givensRange, using: &random)
        let puzzle = makePuzzle(from: solution, givens: givens, using: &random)

        guard solutionCount(for: puzzle, limit: 2) == 1 else { return nil }
        guard let stats = SudokuEvaluator.classify(puzzle), stats.tier == targetDifficulty else { return nil }

        return SudokuLevel(
            difficulty: targetDifficulty,
            number: number,
            puzzle: puzzle,
            solution: solution
        )
    }

    private static func seed(for difficulty: Difficulty, number: Int, attempt: Int) -> UInt64 {
        let base: UInt64
        switch difficulty {
        case .easy: base = 10_000
        case .medium: base = 20_000
        case .hard: base = 30_000
        }
        return base + UInt64(number * 7_919) + UInt64(attempt * 104_729)
    }

    private static func makeSolution(using random: inout SeededRandomNumberGenerator) -> [Int] {
        let base = [1, 2, 3, 4, 5, 6, 7, 8, 9].shuffled(using: &random)
        let rowBands = [0, 1, 2].shuffled(using: &random)
        let columnStacks = [0, 1, 2].shuffled(using: &random)
        let rows = rowBands.flatMap { band in [0, 1, 2].shuffled(using: &random).map { band * 3 + $0 } }
        let columns = columnStacks.flatMap { stack in [0, 1, 2].shuffled(using: &random).map { stack * 3 + $0 } }

        return rows.flatMap { row in
            columns.map { column in
                base[(row * 3 + row / 3 + column) % 9]
            }
        }
    }

    private static func makePuzzle(
        from solution: [Int],
        givens: Int,
        using random: inout SeededRandomNumberGenerator
    ) -> [Int] {
        var puzzle = solution
        let cells = Array(0..<81).shuffled(using: &random)
        let removals = 81 - givens

        var removed = 0
        for index in cells where removed < removals {
            let previous = puzzle[index]
            puzzle[index] = 0

            if solutionCount(for: puzzle, limit: 2) == 1 {
                removed += 1
            } else {
                puzzle[index] = previous
            }
        }

        return puzzle
    }

    private static func solutionCount(for puzzle: [Int], limit: Int) -> Int {
        var board = puzzle
        var count = 0
        solveCount(&board, count: &count, limit: limit)
        return count
    }

    private static func solveCount(_ board: inout [Int], count: inout Int, limit: Int) {
        guard count < limit else { return }
        guard let index = nextEmptyCell(in: board) else {
            count += 1
            return
        }

        for number in 1...9 where SudokuEvaluator.canPlace(number, at: index, in: board) {
            board[index] = number
            solveCount(&board, count: &count, limit: limit)
            board[index] = 0
            if count >= limit { return }
        }
    }

    private static func nextEmptyCell(in board: [Int]) -> Int? {
        var bestIndex: Int?
        var bestCandidateCount = 10

        for index in board.indices where board[index] == 0 {
            let candidateCount = (1...9).filter { SudokuEvaluator.canPlace($0, at: index, in: board) }.count
            if candidateCount < bestCandidateCount {
                bestCandidateCount = candidateCount
                bestIndex = index
            }
        }

        return bestIndex
    }
}

let outputPath = CommandLine.arguments.dropFirst().first ?? "Sudoku/Levels.json"
let levels = SudokuGenerator.generateLevels(perDifficulty: 20)
let encoder = JSONEncoder()
encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
let data = try encoder.encode(levels)
try data.write(to: URL(fileURLWithPath: outputPath), options: .atomic)
print("Wrote \(levels.count) levels to \(outputPath)")
