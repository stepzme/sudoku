import SwiftUI

struct LevelSelectionView: View {
    @EnvironmentObject private var progressStore: ProgressStore
    @State private var levels: [SudokuLevel] = []
    @State private var isLoading = true
    let difficulty: Difficulty

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 5)

    var body: some View {
        Group {
            if isLoading {
                loadingView
            } else {
                levelGrid
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(difficulty.title)
        .task(id: difficulty) {
            await loadLevels()
        }
    }

    private var levelGrid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(levels) { level in
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
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .controlSize(.large)
                .tint(difficulty.color)
            Text("Preparing \(difficulty.title) levels")
                .font(.headline)
            Text("This only happens the first time you open this difficulty.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @MainActor
    private func loadLevels() async {
        isLoading = true
        let difficulty = difficulty
        let loadedLevels = await Task.detached(priority: .userInitiated) {
            LevelCatalog.shared.levels(for: difficulty)
        }.value
        levels = loadedLevels
        isLoading = false
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
