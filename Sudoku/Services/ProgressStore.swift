import Foundation
import SwiftUI

final class ProgressStore: ObservableObject {
    static let shared = ProgressStore()

    @Published private(set) var completedLevels: [String: CompletedLevel]
    @Published private(set) var activeGame: GameSnapshot?

    private let completedKey = "completedLevels"
    private let activeGameKey = "activeGame"

    private init() {
        completedLevels = Self.decode([String: CompletedLevel].self, key: completedKey) ?? [:]
        activeGame = Self.decode(GameSnapshot.self, key: activeGameKey)
    }

    func complete(level: SudokuLevel, elapsedSeconds: Int, mistakes: Int, hintsUsed: Int) {
        let result = CompletedLevel(
            levelID: level.id,
            difficulty: level.difficulty,
            number: level.number,
            elapsedSeconds: elapsedSeconds,
            mistakes: mistakes,
            hintsUsed: hintsUsed,
            completedAt: Date()
        )

        if let existing = completedLevels[level.id], existing.elapsedSeconds <= elapsedSeconds {
            clearActiveGame(for: level)
            return
        }

        completedLevels[level.id] = result
        persist(completedLevels, key: completedKey)
        clearActiveGame(for: level)
    }

    func saveActiveGame(_ snapshot: GameSnapshot) {
        activeGame = snapshot
        persist(snapshot, key: activeGameKey)
    }

    func clearActiveGame(for level: SudokuLevel? = nil) {
        guard level == nil || activeGame?.level.id == level?.id else { return }
        activeGame = nil
        UserDefaults.standard.removeObject(forKey: activeGameKey)
    }

    func isCompleted(_ level: SudokuLevel) -> Bool {
        completedLevels[level.id] != nil
    }

    func completedCount(for difficulty: Difficulty) -> Int {
        completedLevels.values.filter { $0.difficulty == difficulty }.count
    }

    func isUnlocked(_ level: SudokuLevel) -> Bool {
        level.number == 1 || completedLevels["\(level.difficulty.rawValue)-\(level.number - 1)"] != nil || isCompleted(level)
    }

    private func persist<T: Encodable>(_ value: T, key: String) {
        guard let data = try? JSONEncoder().encode(value) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

    private static func decode<T: Decodable>(_ type: T.Type, key: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }
}
