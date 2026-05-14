import Foundation
import SwiftUI

final class SudokuGameViewModel: ObservableObject {
    @Published private(set) var cells: [SudokuCell]
    @Published var selectedCellID: Int?
    @Published private(set) var mistakes: Int
    @Published private(set) var hintsUsed: Int
    @Published private(set) var elapsedSeconds: Int
    @Published private(set) var isComplete = false
    @Published var notesMode = false

    let level: SudokuLevel
    private let progressStore: ProgressStore
    private var history: [[SudokuCell]] = []

    init(level: SudokuLevel, progressStore: ProgressStore = .shared, snapshot: GameSnapshot? = nil) {
        self.level = level
        self.progressStore = progressStore

        if let snapshot, snapshot.level.id == level.id {
            cells = Self.makeCells(level: level, values: snapshot.values, notes: snapshot.notes)
            mistakes = snapshot.mistakes
            elapsedSeconds = snapshot.elapsedSeconds
            hintsUsed = snapshot.hintsUsed
        } else {
            cells = Self.makeCells(
                level: level,
                values: level.puzzle,
                notes: Array(repeating: [], count: 81)
            )
            mistakes = 0
            elapsedSeconds = 0
            hintsUsed = 0
        }
    }

    var selectedCell: SudokuCell? {
        guard let selectedCellID else { return nil }
        return cells.first { $0.id == selectedCellID }
    }

    var mistakeLimit: Int { level.difficulty.mistakeLimit }
    var isFailed: Bool { mistakes >= mistakeLimit }
    var progressText: String { "\(filledCells)/81" }
    var filledCells: Int { cells.filter { !$0.isEmpty }.count }
    var formattedTime: String { Self.format(seconds: elapsedSeconds) }

    func select(_ cell: SudokuCell) {
        selectedCellID = cell.id
    }

    func enter(_ number: Int) {
        guard !isComplete, !isFailed, let selectedCellID else { return }
        guard let index = cells.firstIndex(where: { $0.id == selectedCellID }) else { return }
        guard !cells[index].isGiven else { return }

        pushHistory()

        if notesMode {
            if cells[index].notes.contains(number) {
                cells[index].notes.remove(number)
            } else {
                cells[index].notes.insert(number)
            }
            saveProgress()
            return
        }

        cells[index].notes.removeAll()
        cells[index].value = number

        if number != cells[index].solution {
            mistakes += 1
        }

        removeResolvedNotes(number: number, row: cells[index].row, column: cells[index].column, block: cells[index].block)
        checkCompletion()
        saveProgress()
    }

    func erase() {
        guard !isComplete, let selectedCellID else { return }
        guard let index = cells.firstIndex(where: { $0.id == selectedCellID }), !cells[index].isGiven else { return }
        pushHistory()
        cells[index].value = 0
        cells[index].notes.removeAll()
        saveProgress()
    }

    func undo() {
        guard let previous = history.popLast() else { return }
        cells = previous
        saveProgress()
    }

    func useHint() {
        guard !isComplete, let targetIndex = hintTargetIndex() else { return }
        pushHistory()
        cells[targetIndex].value = cells[targetIndex].solution
        cells[targetIndex].notes.removeAll()
        hintsUsed += 1
        removeResolvedNotes(
            number: cells[targetIndex].solution,
            row: cells[targetIndex].row,
            column: cells[targetIndex].column,
            block: cells[targetIndex].block
        )
        checkCompletion()
        saveProgress()
    }

    func tick() {
        guard !isComplete, !isFailed else { return }
        elapsedSeconds += 1
        if elapsedSeconds % 5 == 0 {
            saveProgress()
        }
    }

    func restart() {
        history.removeAll()
        cells = Self.makeCells(level: level, values: level.puzzle, notes: Array(repeating: [], count: 81))
        mistakes = 0
        hintsUsed = 0
        elapsedSeconds = 0
        isComplete = false
        selectedCellID = nil
        saveProgress()
    }

    func snapshot() -> GameSnapshot {
        GameSnapshot(
            level: level,
            values: cells.map(\.value),
            notes: cells.map { Array($0.notes).sorted() },
            mistakes: mistakes,
            elapsedSeconds: elapsedSeconds,
            hintsUsed: hintsUsed
        )
    }

    func saveProgress() {
        guard !isComplete else { return }
        progressStore.saveActiveGame(snapshot())
    }

    func isPeer(_ cell: SudokuCell) -> Bool {
        guard let selectedCell else { return false }
        return selectedCell.id != cell.id && (selectedCell.row == cell.row || selectedCell.column == cell.column || selectedCell.block == cell.block)
    }

    func hasSameValue(_ cell: SudokuCell) -> Bool {
        guard let selectedCell, selectedCell.value != 0 else { return false }
        return selectedCell.id != cell.id && selectedCell.value == cell.value
    }

    func isIncorrect(_ cell: SudokuCell) -> Bool {
        !cell.isEmpty && cell.value != cell.solution
    }

    private func checkCompletion() {
        guard cells.allSatisfy({ !$0.isEmpty && $0.value == $0.solution }) else { return }
        isComplete = true
        progressStore.complete(level: level, elapsedSeconds: elapsedSeconds, mistakes: mistakes, hintsUsed: hintsUsed)
    }

    private func pushHistory() {
        history.append(cells)
        if history.count > 50 {
            history.removeFirst()
        }
    }

    private func hintTargetIndex() -> Int? {
        if let selectedCellID,
           let selectedIndex = cells.firstIndex(where: { $0.id == selectedCellID }),
           !cells[selectedIndex].isGiven,
           cells[selectedIndex].value != cells[selectedIndex].solution {
            return selectedIndex
        }

        return cells.firstIndex { !$0.isGiven && $0.value != $0.solution }
    }

    private func removeResolvedNotes(number: Int, row: Int, column: Int, block: Int) {
        for index in cells.indices where cells[index].row == row || cells[index].column == column || cells[index].block == block {
            cells[index].notes.remove(number)
        }
    }

    private static func makeCells(level: SudokuLevel, values: [Int], notes: [[Int]]) -> [SudokuCell] {
        (0..<81).map { index in
            SudokuCell(
                row: index / 9,
                column: index % 9,
                solution: level.solution[index],
                givenValue: level.puzzle[index],
                value: values[index],
                notes: Set(notes.indices.contains(index) ? notes[index] : [])
            )
        }
    }

    private static func format(seconds: Int) -> String {
        let minutes = seconds / 60
        let seconds = seconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
