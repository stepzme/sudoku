import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var progressStore: ProgressStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Судоку")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                    Text("\(LevelCatalog.totalLevels) готовых головоломок в трех уровнях сложности.")
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

                HStack(spacing: 16) {
                    NavigationLink {
                        StatsView()
                    } label: {
                        SecondaryActionCard(title: "Статистика", systemImage: "chart.bar.fill")
                    }
                    .buttonStyle(.plain)

                    NavigationLink {
                        SettingsView()
                    } label: {
                        SecondaryActionCard(title: "Настройки", systemImage: "gearshape.fill")
                    }
                    .buttonStyle(.plain)
                }

                DifficultyProgressSection()
            }
            .padding(24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color(.systemGroupedBackground))
        .toolbar {
            ToolbarItem(placement: .principal) {
                Color.clear
                    .frame(width: 0, height: 0)
            }
        }
        .safeAreaInset(edge: .bottom) {
            NavigationLink {
                DifficultySelectionView()
            } label: {
                BottomPrimaryActionButton(
                    title: "Новая игра",
                    subtitle: "Выберите сложность и уровень",
                    systemImage: "play.fill"
                )
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 24)
            .padding(.top, 12)
            .padding(.bottom, 12)
            .background(.ultraThinMaterial)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.automatic, for: .navigationBar)
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
                Text("Продолжить")
                    .font(.headline.bold())
                Text("\(snapshot.level.difficulty.title) · Уровень \(snapshot.level.number)")
                    .font(.caption)
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

private struct BottomPrimaryActionButton: View {
    let title: String
    let subtitle: String
    let systemImage: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: systemImage)
                .font(.title2.bold())
                .frame(width: 52, height: 52)
                .background(.white.opacity(0.25), in: RoundedRectangle(cornerRadius: 18))
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline.bold())
                Text(subtitle)
                    .font(.caption)
                    .opacity(0.85)
            }
            Spacer()
            Image(systemName: "chevron.right")
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing),
            in: RoundedRectangle(cornerRadius: 24)
        )
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
            Text("Прогресс")
                .font(.title3.bold())
            ForEach(Difficulty.allCases) { difficulty in
                let completed = progressStore.completedCount(for: difficulty)
                let total = LevelCatalog.shared.levelCount(for: difficulty)
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(difficulty.title)
                            .font(.headline)
                        Spacer()
                        Text("\(completed)/\(total)")
                            .font(.subheadline.monospacedDigit())
                            .foregroundStyle(.secondary)
                    }
                    ProgressView(value: Double(completed), total: Double(total))
                        .tint(difficulty.color)
                }
                .padding(16)
                .background(.background, in: RoundedRectangle(cornerRadius: 20))
            }
        }
    }
}
