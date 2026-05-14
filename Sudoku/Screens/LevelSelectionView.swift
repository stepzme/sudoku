import SwiftUI

struct LevelSelectionView: View {
    @EnvironmentObject private var progressStore: ProgressStore
    let difficulty: Difficulty

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 5)

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(LevelCatalog.shared.levels(for: difficulty)) { level in
                    let unlocked = progressStore.isUnlocked(level)
                    NavigationLink {
                        GameView(level: level, snapshot: progressStore.activeGame?.level.id == level.id ? progressStore.activeGame : nil)
                    } label: {
                        LevelTile(
                            level: level,
                            isCompleted: progressStore.isCompleted(level),
                            isUnlocked: unlocked
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(!unlocked)
                }
            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(difficulty.title)
    }
}

private struct LevelTile: View {
    let level: SudokuLevel
    let isCompleted: Bool
    let isUnlocked: Bool

    var body: some View {
        VStack(spacing: 6) {
            if isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .font(.caption.bold())
            } else if !isUnlocked {
                Image(systemName: "lock.fill")
                    .font(.caption.bold())
            }

            Text("\(level.number)")
                .font(.headline.monospacedDigit())
        }
        .frame(maxWidth: .infinity, minHeight: 58)
        .foregroundStyle(foreground)
        .background(background, in: RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(isCompleted ? level.difficulty.color : .clear, lineWidth: 2)
        }
    }

    private var foreground: Color {
        if !isUnlocked { return .secondary }
        if isCompleted { return level.difficulty.color }
        return .primary
    }

    private var background: Color {
        if !isUnlocked { return Color(.secondarySystemGroupedBackground) }
        return Color(.systemBackground)
    }
}
