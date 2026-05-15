import SwiftUI

struct PauseView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: SudokuGameViewModel
    let exit: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 18) {
                Image(systemName: "pause.circle.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(.blue)
                Text("Пауза")
                    .font(.largeTitle.bold())
                Text("\(viewModel.level.difficulty.title) · Уровень \(viewModel.level.number)")
                    .foregroundStyle(.secondary)

                VStack(spacing: 12) {
                    Button("Продолжить") { dismiss() }
                        .buttonStyle(.borderedProminent)
                    Button("Начать заново", role: .destructive) {
                        viewModel.restart()
                        dismiss()
                    }
                    .buttonStyle(.bordered)
                    Button("Сохранить и выйти") {
                        viewModel.saveProgress()
                        dismiss()
                        exit()
                    }
                    .buttonStyle(.bordered)
                }
                .controlSize(.large)
            }
            .padding(28)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGroupedBackground))
        }
    }
}
