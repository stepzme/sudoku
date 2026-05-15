import SwiftUI

struct VictoryView: View {
    @Environment(\.dismiss) private var dismiss
    let level: SudokuLevel
    let elapsed: String
    let mistakes: Int
    let hints: Int

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 72))
                    .foregroundStyle(.yellow)
                VStack(spacing: 8) {
                    Text("Уровень пройден!")
                        .font(.largeTitle.bold())
                    Text("\(level.difficulty.title) · Уровень \(level.number)")
                        .foregroundStyle(.secondary)
                }

                VStack(spacing: 12) {
                    ResultRow(title: "Время", value: elapsed, systemImage: "timer")
                    ResultRow(title: "Ошибки", value: "\(mistakes)", systemImage: "xmark.circle")
                    ResultRow(title: "Подсказки", value: "\(hints)", systemImage: "lightbulb")
                }
                .padding(20)
                .background(.background, in: RoundedRectangle(cornerRadius: 24))

                Button("Готово") { dismiss() }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
            }
            .padding(28)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGroupedBackground))
        }
    }
}

private struct ResultRow: View {
    let title: String
    let value: String
    let systemImage: String

    var body: some View {
        HStack {
            Label(title, systemImage: systemImage)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.headline.monospacedDigit())
        }
    }
}
