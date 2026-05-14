import SwiftUI

struct GameView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: SudokuGameViewModel
    @State private var showPause = false
    @State private var showVictory = false

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    init(level: SudokuLevel, snapshot: GameSnapshot? = nil) {
        _viewModel = StateObject(wrappedValue: SudokuGameViewModel(level: level, snapshot: snapshot))
    }

    var body: some View {
        VStack(spacing: 18) {
            header
            SudokuBoardView(viewModel: viewModel)
            tools
            NumberPadView { viewModel.enter($0) }
            Spacer(minLength: 0)
        }
        .padding(18)
        .background(Color(.systemGroupedBackground))
        .navigationTitle("\(viewModel.level.difficulty.title) · \(viewModel.level.number)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { showPause = true } label: {
                    Image(systemName: "pause.circle.fill")
                }
            }
        }
        .onReceive(timer) { _ in viewModel.tick() }
        .onChange(of: viewModel.isComplete) { _, isComplete in
            showVictory = isComplete
        }
        .sheet(isPresented: $showPause) {
            PauseView(viewModel: viewModel) { dismiss() }
        }
        .sheet(isPresented: $showVictory) {
            VictoryView(level: viewModel.level, elapsed: viewModel.formattedTime, mistakes: viewModel.mistakes, hints: viewModel.hintsUsed)
        }
        .alert("Game Over", isPresented: .constant(viewModel.isFailed)) {
            Button("Restart") { viewModel.restart() }
            Button("Exit", role: .cancel) { dismiss() }
        } message: {
            Text("You reached the mistake limit for this difficulty.")
        }
        .onDisappear { viewModel.saveProgress() }
    }

    private var header: some View {
        HStack(spacing: 12) {
            MetricPill(title: "Time", value: viewModel.formattedTime, systemImage: "timer")
            MetricPill(title: "Mistakes", value: "\(viewModel.mistakes)/\(viewModel.mistakeLimit)", systemImage: "xmark.circle")
            MetricPill(title: "Filled", value: viewModel.progressText, systemImage: "square.grid.3x3")
        }
    }

    private var tools: some View {
        HStack(spacing: 10) {
            ToolButton(title: "Undo", systemImage: "arrow.uturn.backward") { viewModel.undo() }
            ToolButton(title: "Erase", systemImage: "eraser") { viewModel.erase() }
            ToolButton(title: "Notes", systemImage: viewModel.notesMode ? "pencil.circle.fill" : "pencil.circle") {
                viewModel.notesMode.toggle()
            }
            ToolButton(title: "Hint", systemImage: "lightbulb") { viewModel.useHint() }
        }
    }
}

private struct MetricPill: View {
    let title: String
    let value: String
    let systemImage: String

    var body: some View {
        VStack(spacing: 4) {
            Label(title, systemImage: systemImage)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.subheadline.bold().monospacedDigit())
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(.background, in: RoundedRectangle(cornerRadius: 16))
    }
}

private struct ToolButton: View {
    let title: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: systemImage)
                    .font(.headline)
                Text(title)
                    .font(.caption.weight(.semibold))
            }
            .frame(maxWidth: .infinity, minHeight: 56)
            .background(.background, in: RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}
