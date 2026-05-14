import Foundation

struct SudokuLevel: Identifiable, Codable, Equatable, Sendable {
    let difficulty: Difficulty
    let number: Int
    let puzzle: [Int]
    let solution: [Int]

    var id: String { "\(difficulty.rawValue)-\(number)" }
    var title: String { "Level \(number)" }
}
