import SwiftUI

struct DifficultySelectionView: View {
    @EnvironmentObject private var progressStore: ProgressStore

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                ForEach(Difficulty.allCases) { difficulty in
                    NavigationLink {
                        LevelSelectionView(difficulty: difficulty)
                    } label: {
                        DifficultyCard(
                            difficulty: difficulty,
                            completed: progressStore.completedCount(for: difficulty)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Choose Difficulty")
    }
}

private struct DifficultyCard: View {
    let difficulty: Difficulty
    let completed: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(difficulty.title)
                        .font(.largeTitle.bold())
                    Text(difficulty.subtitle)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right.circle.fill")
                    .font(.title)
                    .foregroundStyle(difficulty.color)
            }

            ProgressView(value: Double(completed), total: Double(LevelCatalog.levelsPerDifficulty))
                .tint(difficulty.color)

            HStack {
                Label("\(completed) completed", systemImage: "checkmark.seal.fill")
                Spacer()
                Text("\(LevelCatalog.levelsPerDifficulty) levels")
            }
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.secondary)
        }
        .padding(22)
        .background(.background, in: RoundedRectangle(cornerRadius: 28))
        .overlay(alignment: .leading) {
            RoundedRectangle(cornerRadius: 4)
                .fill(difficulty.color)
                .frame(width: 5)
                .padding(.vertical, 24)
        }
    }
}
