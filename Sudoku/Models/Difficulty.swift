import SwiftUI

enum Difficulty: String, CaseIterable, Codable, Identifiable, Sendable {
    case easy
    case medium
    case hard

    var id: String { rawValue }

    var title: String {
        switch self {
        case .easy: "Easy"
        case .medium: "Medium"
        case .hard: "Hard"
        }
    }

    var subtitle: String {
        switch self {
        case .easy: "Relaxed puzzles with generous clues."
        case .medium: "Balanced boards for regular play."
        case .hard: "Demanding puzzles for focused solving."
        }
    }

    var givensRange: ClosedRange<Int> {
        switch self {
        case .easy: 42...48
        case .medium: 34...39
        case .hard: 28...32
        }
    }

    var mistakeLimit: Int {
        switch self {
        case .easy: 5
        case .medium: 4
        case .hard: 3
        }
    }

    var color: Color {
        switch self {
        case .easy: .green
        case .medium: .orange
        case .hard: .red
        }
    }
}
