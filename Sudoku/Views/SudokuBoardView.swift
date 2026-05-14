import SwiftUI

struct SudokuBoardView: View {
    @ObservedObject var viewModel: SudokuGameViewModel

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 9)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 0) {
            ForEach(viewModel.cells) { cell in
                SudokuCellView(cell: cell, viewModel: viewModel)
                    .aspectRatio(1, contentMode: .fit)
                    .onTapGesture { viewModel.select(cell) }
            }
        }
        .background(Color.primary, in: RoundedRectangle(cornerRadius: 14))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

private struct SudokuCellView: View {
    let cell: SudokuCell
    @ObservedObject var viewModel: SudokuGameViewModel

    var body: some View {
        ZStack {
            Rectangle()
                .fill(background)

            if cell.value == 0 {
                NotesGrid(notes: cell.notes)
                    .padding(4)
            } else {
                Text("\(cell.value)")
                    .font(.title3.weight(cell.isGiven ? .bold : .semibold))
                    .foregroundStyle(foreground)
            }
        }
        .overlay(alignment: .trailing) {
            if cell.column == 2 || cell.column == 5 {
                Rectangle().fill(Color.primary).frame(width: 2)
            }
        }
        .overlay(alignment: .bottom) {
            if cell.row == 2 || cell.row == 5 {
                Rectangle().fill(Color.primary).frame(height: 2)
            }
        }
        .border(Color.primary.opacity(0.25), width: 0.5)
    }

    private var background: Color {
        if viewModel.selectedCellID == cell.id { return .blue.opacity(0.30) }
        if viewModel.hasSameValue(cell) { return .blue.opacity(0.20) }
        if viewModel.isPeer(cell) { return .blue.opacity(0.10) }
        return Color(.systemBackground)
    }

    private var foreground: Color {
        if viewModel.isIncorrect(cell) { return .red }
        return cell.isGiven ? .primary : .blue
    }
}

private struct NotesGrid: View {
    let notes: Set<Int>
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 3)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 0) {
            ForEach(1...9, id: \.self) { number in
                Text(notes.contains(number) ? "\(number)" : "")
                    .font(.caption2.monospacedDigit())
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}
