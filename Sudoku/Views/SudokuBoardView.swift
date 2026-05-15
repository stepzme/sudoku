import SwiftUI

struct SudokuBoardView: View {
    @ObservedObject var viewModel: SudokuGameViewModel
    let side: CGFloat

    var body: some View {
        let boardSide = floor(side)
        let cellSide = boardSide / 9

        ZStack(alignment: .topLeading) {
            VStack(spacing: 0) {
                ForEach(0..<9, id: \.self) { row in
                    HStack(spacing: 0) {
                        ForEach(0..<9, id: \.self) { column in
                            let cell = viewModel.cells[(row * 9) + column]
                            SudokuCellView(cell: cell, viewModel: viewModel, cellSide: cellSide)
                                .frame(width: cellSide, height: cellSide)
                                .contentShape(Rectangle())
                                .clipped()
                                .onTapGesture { viewModel.select(cell) }
                        }
                    }
                }
            }

            BoardGridOverlay(boardSide: boardSide, cellSide: cellSide)
        }
        .frame(width: boardSide, height: boardSide)
    }
}

private struct SudokuCellView: View {
    let cell: SudokuCell
    @ObservedObject var viewModel: SudokuGameViewModel
    let cellSide: CGFloat

    var body: some View {
        ZStack {
            Rectangle()
                .fill(background)

            if cell.value == 0 {
                NotesGrid(notes: cell.notes)
                    .padding(4)
            } else {
                Image(symbolName)
                    .resizable()
                    .interpolation(.high)
                    .scaledToFit()
                    .frame(width: cellSide * 0.84, height: cellSide * 0.84)
                    .opacity(cell.isGiven ? 1 : 0.9)
                    .clipped()
            }
        }
        .overlay { cellGridLines }
    }

    private var background: Color {
        let accent = highlightColor
        if viewModel.selectedCellID == cell.id { return accent.opacity(0.30) }
        if viewModel.isIncorrect(cell) { return .red.opacity(0.18) }
        if viewModel.hasSameValue(cell) { return accent.opacity(0.20) }
        if viewModel.isPeer(cell) { return accent.opacity(0.10) }
        if !cell.isGiven && !cell.isEmpty { return .black.opacity(0.15) }
        return .clear
    }

    private var symbolName: String {
        "Digit\(cell.value)"
    }

    private var highlightColor: Color {
        if let selected = viewModel.selectedCell, viewModel.isIncorrect(selected) {
            return .red
        }
        return .blue
    }

    @ViewBuilder
    private var cellGridLines: some View {
        let thinColor = Color.primary.opacity(0.16)

        if cell.column < 8 {
            Rectangle()
                .fill(thinColor)
                .frame(width: 0.5)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }

        if cell.row < 8 {
            Rectangle()
                .fill(thinColor)
                .frame(height: 0.5)
                .frame(maxHeight: .infinity, alignment: .bottom)
        }
    }
}

private struct BoardGridOverlay: View {
    let boardSide: CGFloat
    let cellSide: CGFloat

    var body: some View {
        Canvas { context, _ in
            for index in 1..<9 {
                let position = CGFloat(index) * cellSide
                let isMajor = index.isMultiple(of: 3)
                let lineWidth: CGFloat = isMajor ? 1.5 : 0.8
                let color = isMajor ? Color.primary.opacity(0.45) : Color.primary.opacity(0.12)

                var vertical = Path()
                vertical.move(to: CGPoint(x: position, y: 0))
                vertical.addLine(to: CGPoint(x: position, y: boardSide))
                context.stroke(vertical, with: .color(color), lineWidth: lineWidth)

                var horizontal = Path()
                horizontal.move(to: CGPoint(x: 0, y: position))
                horizontal.addLine(to: CGPoint(x: boardSide, y: position))
                context.stroke(horizontal, with: .color(color), lineWidth: lineWidth)
            }
        }
        .allowsHitTesting(false)
    }
}

private struct NotesGrid: View {
    let notes: Set<Int>
    private let spacing: CGFloat = 4
    private var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: spacing), count: 3)
    }

    var body: some View {
        LazyVGrid(columns: columns, spacing: spacing) {
            ForEach(1...9, id: \.self) { number in
                ZStack {
                    if notes.contains(number) {
                        Circle()
                            .fill(DigitPalette.color(for: number))
                            .frame(width: 8, height: 8)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}
