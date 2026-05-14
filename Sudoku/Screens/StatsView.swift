import SwiftUI

struct StatsView: View {
    @EnvironmentObject private var progressStore: ProgressStore

    var body: some View {
        List {
            Section("Overall") {
                StatRow(title: "Completed", value: "\(progressStore.completedLevels.count)/300")
            }

            Section("By Difficulty") {
                ForEach(Difficulty.allCases) { difficulty in
                    StatRow(
                        title: difficulty.title,
                        value: "\(progressStore.completedCount(for: difficulty))/100"
                    )
                }
            }
        }
        .navigationTitle("Stats")
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
