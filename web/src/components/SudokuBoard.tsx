import type { SudokuCell } from '../game/types'
import type { useSudokuGame } from '../game/useSudokuGame'
import { digitColor } from '../game/digits'
import DigitImage from './DigitImage'

type GameApi = ReturnType<typeof useSudokuGame>

interface SudokuBoardProps {
  game: GameApi
}

export default function SudokuBoard({ game }: SudokuBoardProps) {
  return (
    <div className="sudoku-board" aria-label="Доска судоку">
      {game.cells.map((cell) => (
        <button
          className={cellClassName(cell, game)}
          type="button"
          key={cell.id}
          onClick={() => game.select(cell)}
          aria-label={`Строка ${cell.row + 1}, столбец ${cell.column + 1}`}
        >
          {cell.value === 0 ? <NotesGrid notes={cell.notes} /> : <DigitImage value={cell.value} className="board-digit" />}
        </button>
      ))}
    </div>
  )
}

function NotesGrid({ notes }: { notes: number[] }) {
  return (
    <div className="notes-grid">
      {Array.from({ length: 9 }, (_, index) => {
        const number = index + 1
        return (
          <span key={number} className="note-dot-cell">
            {notes.includes(number) ? (
              <span className="note-dot" style={{ backgroundColor: digitColor(number) }} />
            ) : null}
          </span>
        )
      })}
    </div>
  )
}

function cellClassName(cell: SudokuCell, game: GameApi) {
  const classes = ['sudoku-cell']

  if (game.selectedCellID === cell.id) classes.push('is-selected')
  if (game.isIncorrect(cell)) classes.push('is-incorrect')
  else if (game.hasSameValue(cell)) classes.push('has-same-value')
  else if (game.isPeer(cell)) classes.push('is-peer')
  else if (cell.givenValue === 0 && cell.value !== 0) classes.push('is-filled')

  if (cell.givenValue !== 0) classes.push('is-given')
  if ((cell.column + 1) % 3 === 0 && cell.column !== 8) classes.push('major-right')
  if ((cell.row + 1) % 3 === 0 && cell.row !== 8) classes.push('major-bottom')

  return classes.join(' ')
}
