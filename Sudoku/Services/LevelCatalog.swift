import Foundation

final class LevelCatalog {
    static let shared = LevelCatalog()
    static let levelsPerDifficulty = 100

    let levels: [Difficulty: [SudokuLevel]]

    private init() {
        var generated: [Difficulty: [SudokuLevel]] = [:]
        for difficulty in Difficulty.allCases {
            generated[difficulty] = (1...Self.levelsPerDifficulty).map { number in
                Self.makeLevel(difficulty: difficulty, number: number)
            }
        }
        levels = generated
    }

    func level(difficulty: Difficulty, number: Int) -> SudokuLevel? {
        levels[difficulty]?.first { $0.number == number }
    }

    func levels(for difficulty: Difficulty) -> [SudokuLevel] {
        levels[difficulty] ?? []
    }

    private static func makeLevel(difficulty: Difficulty, number: Int) -> SudokuLevel {
        var random = SeededRandomNumberGenerator(seed: seed(for: difficulty, number: number))
        let solution = makeSolution(using: &random)
        let givens = Int.random(in: difficulty.givensRange, using: &random)
        let puzzle = makePuzzle(from: solution, givens: givens, using: &random)
        return SudokuLevel(difficulty: difficulty, number: number, puzzle: puzzle, solution: solution)
    }

    private static func seed(for difficulty: Difficulty, number: Int) -> UInt64 {
        let base: UInt64
        switch difficulty {
        case .easy: base = 10_000
        case .medium: base = 20_000
        case .hard: base = 30_000
        }
        return base + UInt64(number * 7919)
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
        solve(&board, count: &count, limit: limit)
        return count
    }

    private static func solve(_ board: inout [Int], count: inout Int, limit: Int) {
        guard count < limit else { return }
        guard let index = nextEmptyCell(in: board) else {
            count += 1
            return
        }

        for number in 1...9 where canPlace(number, at: index, in: board) {
            board[index] = number
            solve(&board, count: &count, limit: limit)
            board[index] = 0

            if count >= limit { return }
        }
    }

    private static func nextEmptyCell(in board: [Int]) -> Int? {
        var bestIndex: Int?
        var bestCandidateCount = 10

        for index in board.indices where board[index] == 0 {
            let candidateCount = (1...9).filter { canPlace($0, at: index, in: board) }.count
            if candidateCount < bestCandidateCount {
                bestCandidateCount = candidateCount
                bestIndex = index
            }
        }

        return bestIndex
    }

    private static func canPlace(_ number: Int, at index: Int, in board: [Int]) -> Bool {
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
