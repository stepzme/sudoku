import SwiftUI

struct StatsView: View {
    @EnvironmentObject private var progressStore: ProgressStore

    var body: some View {
        List {
            Section("Общее") {
                StatRow(title: "Пройдено", value: "\(progressStore.completedLevels.count)/\(LevelCatalog.totalLevels)")
            }

            Section("По сложности") {
                ForEach(Difficulty.allCases) { difficulty in
                    StatRow(
                        title: difficulty.title,
                        value: "\(progressStore.completedCount(for: difficulty))/\(LevelCatalog.shared.levelCount(for: difficulty))"
                    )
                }
            }
        }
        .navigationTitle("Статистика")
    }
}

private struct StatRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
                .monospacedDigit()
        }
    }
}
