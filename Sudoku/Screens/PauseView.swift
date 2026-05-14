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
                Text("Paused")
                    .font(.largeTitle.bold())
                Text("\(viewModel.level.difficulty.title) · Level \(viewModel.level.number)")
                    .foregroundStyle(.secondary)

                VStack(spacing: 12) {
                    Button("Resume") { dismiss() }
                        .buttonStyle(.borderedProminent)
                    Button("Restart Level", role: .destructive) {
                        viewModel.restart()
                        dismiss()
                    }
                    .buttonStyle(.bordered)
                    Button("Save & Exit") {
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
