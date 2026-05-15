import Foundation

final class LevelCatalog: @unchecked Sendable {
    static let shared = LevelCatalog()
    static var totalLevels: Int {
        shared.levels.values.reduce(0) { $0 + $1.count }
    }

    let levels: [Difficulty: [SudokuLevel]]

    private init() {
        let allLevels = Self.loadLevels()
        var grouped = Dictionary(grouping: allLevels, by: \.difficulty)
        for difficulty in Difficulty.allCases {
            grouped[difficulty] = (grouped[difficulty] ?? []).sorted { $0.number < $1.number }
        }
        levels = grouped
    }

    func level(difficulty: Difficulty, number: Int) -> SudokuLevel? {
        levels(for: difficulty).first { $0.number == number }
    }

    func levels(for difficulty: Difficulty) -> [SudokuLevel] {
        levels[difficulty] ?? []
    }

    func levelCount(for difficulty: Difficulty) -> Int {
        levels[difficulty]?.count ?? 0
    }

    private static func loadLevels() -> [SudokuLevel] {
        guard let url = Bundle.main.url(forResource: "Levels", withExtension: "json") else {
            assertionFailure("Missing Levels.json in app bundle")
            return []
        }

        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode([SudokuLevel].self, from: data)
        } catch {
            assertionFailure("Failed to load Levels.json: \(error)")
            return []
        }
    }
}
