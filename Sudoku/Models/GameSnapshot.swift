import Foundation

struct GameSnapshot: Codable, Sendable {
    let level: SudokuLevel
    var values: [Int]
    var notes: [[Int]]
    var mistakes: Int
    var elapsedSeconds: Int
    var hintsUsed: Int
}

struct CompletedLevel: Codable, Equatable, Sendable {
    let levelID: String
    let difficulty: Difficulty
    let number: Int
    let elapsedSeconds: Int
    let mistakes: Int
    let hintsUsed: Int
    let completedAt: Date
}
