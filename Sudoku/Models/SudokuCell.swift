import Foundation

struct SudokuCell: Identifiable, Equatable {
    let row: Int
    let column: Int
    let solution: Int
    let givenValue: Int
    var value: Int
    var notes: Set<Int>

    var id: Int { row * 9 + column }
    var isGiven: Bool { givenValue != 0 }
    var isEmpty: Bool { value == 0 }
    var block: Int { (row / 3) * 3 + (column / 3) }
}
