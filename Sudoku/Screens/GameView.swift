import SwiftUI

struct GameView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: SudokuGameViewModel
    @State private var showPause = false
    @State private var showVictory = false
    @State private var showFailure = false

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    init(level: SudokuLevel, snapshot: GameSnapshot? = nil) {
        _viewModel = StateObject(wrappedValue: SudokuGameViewModel(level: level, snapshot: snapshot))
    }

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            GeometryReader { geometry in
                let contentHorizontalPadding: CGFloat = 16
                let boardHorizontalPadding: CGFloat = 4
                let boardSide = max(geometry.size.width - (boardHorizontalPadding * 2), 0)

                VStack(spacing: 12) {
                    header
                        .padding(.horizontal, contentHorizontalPadding)

                    SudokuBoardView(viewModel: viewModel, side: boardSide)
                        .frame(width: boardSide, height: boardSide)
                        .frame(maxWidth: .infinity)

                    tools
                        .padding(.horizontal, contentHorizontalPadding)

                    NumberPadView(
                        isNotesMode: viewModel.notesMode,
                        remainingCount: { viewModel.remainingPlacements(for: $0) },
                        isDisabled: { viewModel.isNumberExhausted($0) }
                    ) { viewModel.enter($0) }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.horizontal, contentHorizontalPadding)
                }
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .top
                )
                .padding(.top, 8)
                .padding(.bottom, 12)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
        .onChange(of: viewModel.mistakes) { _, _ in
            showFailure = viewModel.isFailed
        }
        .sheet(isPresented: $showPause) {
            PauseView(viewModel: viewModel) { dismiss() }
        }
        .sheet(isPresented: $showVictory) {
            VictoryView(level: viewModel.level, elapsed: viewModel.formattedTime, mistakes: viewModel.mistakes, hints: viewModel.hintsUsed)
        }
        .sheet(isPresented: $showFailure) {
            FailureView(viewModel: viewModel) {
                showFailure = false
                dismiss()
            } restart: {
                showFailure = false
                viewModel.restart()
            }
        }
        .interactiveDismissDisabled(showFailure)
        .onDisappear { viewModel.saveProgress() }
    }

    private var header: some View {
        HStack(spacing: 12) {
            MetricPill(title: "Время", value: viewModel.formattedTime, systemImage: "timer")
            MetricPill(title: "Ошибки", value: "\(viewModel.mistakes)/\(viewModel.mistakeLimit)", systemImage: "xmark.circle")
            MetricPill(title: "Подсказки", value: "\(viewModel.remainingHints)/\(SudokuGameViewModel.hintLimit)", systemImage: "lightbulb")
        }
    }

    private var tools: some View {
        HStack(spacing: 10) {
            ToolButton(title: "Назад", systemImage: "arrow.uturn.backward") { viewModel.undo() }
            ToolButton(
                title: "Стереть",
                systemImage: "eraser",
                isDisabled: !viewModel.canErase
            ) { viewModel.erase() }
            ToolButton(
                title: "Заметки",
                systemImage: "pencil",
                isSelected: viewModel.notesMode
            ) {
                viewModel.notesMode.toggle()
            }
            ToolButton(
                title: "Подсказка",
                systemImage: "lightbulb",
                isDisabled: !viewModel.canUseHint
            ) {
                viewModel.useHint()
            }
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
    var isDisabled = false
    var isSelected = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: systemImage)
                    .font(.headline)
                    .foregroundStyle(isSelected ? .white : .primary)
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(isSelected ? .white : .primary)
            }
            .frame(maxWidth: .infinity, minHeight: 58)
            .background(backgroundColor, in: RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.45 : 1)
    }

    private var backgroundColor: Color {
        isSelected ? .black : Color(.systemBackground)
    }
}

private struct FailureView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: SudokuGameViewModel
    let exit: () -> Void
    let restart: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 18) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(.red)
                Text("Игра окончена")
                    .font(.largeTitle.bold())
                Text("Вы достигли лимита ошибок для этой сложности.")
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                Text("\(viewModel.level.difficulty.title) · Уровень \(viewModel.level.number)")
                    .foregroundStyle(.secondary)

                VStack(spacing: 12) {
                    Button("Начать заново") {
                        restart()
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)

                    Button("Выйти") {
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
