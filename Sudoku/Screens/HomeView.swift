import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var progressStore: ProgressStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Sudoku")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                    Text("60 curated puzzles across three difficulties.")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                if let snapshot = progressStore.activeGame {
                    NavigationLink {
                        GameView(level: snapshot.level, snapshot: snapshot)
                    } label: {
                        ContinueCard(snapshot: snapshot)
                    }
                    .buttonStyle(.plain)
                }

                NavigationLink {
                    DifficultySelectionView()
                } label: {
                    PrimaryActionCard(title: "New Game", subtitle: "Choose a difficulty and level", systemImage: "play.fill")
                }
                .buttonStyle(.plain)

                HStack(spacing: 16) {
                    NavigationLink {
                        StatsView()
                    } label: {
                        SecondaryActionCard(title: "Stats", systemImage: "chart.bar.fill")
                    }
                    .buttonStyle(.plain)

                    NavigationLink {
                        SettingsView()
                    } label: {
                        SecondaryActionCard(title: "Settings", systemImage: "gearshape.fill")
                    }
                    .buttonStyle(.plain)
                }

                DifficultyProgressSection()
            }
            .padding(24)
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct ContinueCard: View {
    let snapshot: GameSnapshot

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.title2.bold())
                .frame(width: 52, height: 52)
                .background(.blue.opacity(0.15), in: RoundedRectangle(cornerRadius: 18))
                .foregroundStyle(.blue)

            VStack(alignment: .leading, spacing: 4) {
                Text("Continue")
                    .font(.title3.bold())
                Text("\(snapshot.level.difficulty.title) · Level \(snapshot.level.number)")
                    .foregroundStyle(.secondary)
            }

            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(.tertiary)
        }
        .padding(20)
        .background(.background, in: RoundedRectangle(cornerRadius: 28))
        .shadow(color: .black.opacity(0.06), radius: 18, y: 8)
    }
}

private struct PrimaryActionCard: View {
    let title: String
    let subtitle: String
    let systemImage: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: systemImage)
                .font(.title2.bold())
                .frame(width: 56, height: 56)
                .background(.white.opacity(0.25), in: RoundedRectangle(cornerRadius: 18))
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.title2.bold())
                Text(subtitle)
                    .font(.subheadline)
                    .opacity(0.85)
            }
            Spacer()
            Image(systemName: "chevron.right")
        }
        .foregroundStyle(.white)
        .padding(22)
        .background(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing), in: RoundedRectangle(cornerRadius: 30))
    }
}

private struct SecondaryActionCard: View {
    let title: String
    let systemImage: String

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Image(systemName: systemImage)
                .font(.title2.bold())
                .foregroundStyle(.blue)
            Text(title)
                .font(.headline)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(.background, in: RoundedRectangle(cornerRadius: 24))
    }
}

private struct DifficultyProgressSection: View {
    @EnvironmentObject private var progressStore: ProgressStore

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Progress")
                .font(.title3.bold())
            ForEach(Difficulty.allCases) { difficulty in
                let completed = progressStore.completedCount(for: difficulty)
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(difficulty.title)
                            .font(.headline)
                        Spacer()
                        Text("\(completed)/\(LevelCatalog.levelsPerDifficulty)")
                            .font(.subheadline.monospacedDigit())
                            .foregroundStyle(.secondary)
                    }
                    ProgressView(value: Double(completed), total: Double(LevelCatalog.levelsPerDifficulty))
                        .tint(difficulty.color)
                }
                .padding(16)
                .background(.background, in: RoundedRectangle(cornerRadius: 20))
            }
        }
    }
}
