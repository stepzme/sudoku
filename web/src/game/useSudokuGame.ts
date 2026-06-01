import { useCallback, useEffect, useMemo, useReducer, useRef } from 'react'
import { formatSeconds, useProgress } from './progress'
import { difficultyInfo, levelId, type GameSettings, type GameSnapshot, type SudokuCell, type SudokuLevel } from './types'

export const hintLimit = 3

interface HistoryEntry {
  cells: SudokuCell[]
  mistakes: number
  hintsUsed: number
}

interface GameState {
  cells: SudokuCell[]
  selectedCellID: number | null
  mistakes: number
  hintsUsed: number
  elapsedSeconds: number
  isComplete: boolean
  notesMode: boolean
  history: HistoryEntry[]
}

type Action =
  | { type: 'select'; cellID: number }
  | { type: 'enter'; number: number; settings: GameSettings }
  | { type: 'erase' }
  | { type: 'undo' }
  | { type: 'hint'; settings: GameSettings }
  | { type: 'tick' }
  | { type: 'toggleNotes' }
  | { type: 'restart'; level: SudokuLevel }

export function useSudokuGame(level: SudokuLevel, snapshot?: GameSnapshot | null) {
  const progress = useProgress()
  const completedHandled = useRef(false)

  const [state, dispatch] = useReducer(gameReducer, undefined, () => makeInitialState(level, snapshot))
  const mistakeLimit = difficultyInfo[level.difficulty].mistakeLimit
  const isFailed = state.mistakes >= mistakeLimit

  const selectedCell = useMemo(
    () => state.cells.find((cell) => cell.id === state.selectedCellID) ?? null,
    [state.cells, state.selectedCellID],
  )

  const snapshotValue = useMemo(
    () => makeSnapshot(level, state),
    [level, state],
  )

  useEffect(() => {
    if (state.isComplete) {
      if (!completedHandled.current) {
        completedHandled.current = true
        progress.completeLevel(snapshotValue)
      }
      return
    }

    completedHandled.current = false

    if (isFailed) {
      progress.clearActiveGame(level)
      return
    }

    progress.saveActiveGame(snapshotValue)
  }, [isFailed, level, progress, snapshotValue, state.isComplete])

  const vibrate = useCallback(() => {
    if (progress.settings.haptics && 'vibrate' in navigator) {
      navigator.vibrate(8)
    }
  }, [progress.settings.haptics])

  const enter = useCallback(
    (number: number) => {
      dispatch({ type: 'enter', number, settings: progress.settings })
      vibrate()
    },
    [progress.settings, vibrate],
  )

  return {
    level,
    cells: state.cells,
    selectedCellID: state.selectedCellID,
    selectedCell,
    mistakes: state.mistakes,
    hintsUsed: state.hintsUsed,
    elapsedSeconds: state.elapsedSeconds,
    isComplete: state.isComplete,
    isFailed,
    notesMode: state.notesMode,
    mistakeLimit,
    remainingHints: Math.max(0, hintLimit - state.hintsUsed),
    canUseHint: Math.max(0, hintLimit - state.hintsUsed) > 0 && !state.isComplete && !isFailed,
    canErase:
      !state.isComplete &&
      !isFailed &&
      selectedCell != null &&
      !isGiven(selectedCell) &&
      (selectedCell.value !== 0 || selectedCell.notes.length > 0),
    canUndo: state.history.length > 0 && !state.isComplete && !isFailed,
    progressText: `${state.cells.filter((cell) => cell.value !== 0).length}/81`,
    formattedTime: formatSeconds(state.elapsedSeconds),
    remainingPlacements: (number: number) =>
      Math.max(0, 9 - state.cells.filter((cell) => cell.value === number && cell.value === cell.solution).length),
    isNumberExhausted: (number: number) =>
      state.cells.filter((cell) => cell.value === number && cell.value === cell.solution).length >= 9,
    select: (cell: SudokuCell) => dispatch({ type: 'select', cellID: cell.id }),
    enter,
    erase: () => {
      dispatch({ type: 'erase' })
      vibrate()
    },
    undo: () => {
      dispatch({ type: 'undo' })
      vibrate()
    },
    useHint: () => {
      dispatch({ type: 'hint', settings: progress.settings })
      vibrate()
    },
    tick: () => dispatch({ type: 'tick' }),
    toggleNotes: () => {
      dispatch({ type: 'toggleNotes' })
      vibrate()
    },
    restart: () => {
      completedHandled.current = false
      dispatch({ type: 'restart', level })
      vibrate()
    },
    isPeer: (cell: SudokuCell) =>
      progress.settings.highlightPeers &&
      selectedCell != null &&
      selectedCell.id !== cell.id &&
      (selectedCell.row === cell.row || selectedCell.column === cell.column || selectedCell.block === cell.block),
    hasSameValue: (cell: SudokuCell) =>
      selectedCell != null && selectedCell.value !== 0 && selectedCell.id !== cell.id && selectedCell.value === cell.value,
    isIncorrect: (cell: SudokuCell) => cell.value !== 0 && cell.value !== cell.solution,
    snapshot: snapshotValue,
  }
}

export function gameReducer(state: GameState, action: Action): GameState {
  if (state.isComplete && action.type !== 'restart') return state
  if (state.mistakes >= 9 && action.type !== 'restart') return state

  switch (action.type) {
    case 'select':
      return { ...state, selectedCellID: action.cellID }

    case 'toggleNotes':
      return { ...state, notesMode: !state.notesMode }

    case 'enter': {
      const index = selectedIndex(state)
      if (index == null || isGiven(state.cells[index])) return state

      const target = state.cells[index]
      const nextCells = cloneCells(state.cells)
      const nextTarget = nextCells[index]
      const history = pushHistory(state)

      if (state.notesMode) {
        nextTarget.notes =
          nextTarget.notes.includes(action.number)
            ? nextTarget.notes.filter((note) => note !== action.number)
            : [...nextTarget.notes, action.number].sort((a, b) => a - b)

        return { ...state, cells: nextCells, history }
      }

      const previousValue = target.value
      nextTarget.notes = []
      nextTarget.value = action.number

      const mistakes =
        action.number !== target.solution && previousValue !== action.number ? state.mistakes + 1 : state.mistakes

      if (action.settings.autoRemoveNotes) {
        removeResolvedNotes(nextCells, action.number, target.row, target.column, target.block)
      }

      return checkCompletion({ ...state, cells: nextCells, mistakes, history })
    }

    case 'erase': {
      const index = selectedIndex(state)
      if (index == null || isGiven(state.cells[index])) return state
      if (state.cells[index].value === 0 && state.cells[index].notes.length === 0) return state

      const nextCells = cloneCells(state.cells)
      nextCells[index].value = 0
      nextCells[index].notes = []
      return { ...state, cells: nextCells, history: pushHistory(state) }
    }

    case 'undo': {
      const previous = state.history.at(-1)
      if (!previous) return state
      return {
        ...state,
        cells: cloneCells(previous.cells),
        mistakes: previous.mistakes,
        hintsUsed: previous.hintsUsed,
        history: state.history.slice(0, -1),
      }
    }

    case 'hint': {
      if (state.hintsUsed >= hintLimit) return state
      const index = hintTargetIndex(state)
      if (index == null) return state

      const target = state.cells[index]
      const nextCells = cloneCells(state.cells)
      nextCells[index].value = target.solution
      nextCells[index].notes = []

      if (action.settings.autoRemoveNotes) {
        removeResolvedNotes(nextCells, target.solution, target.row, target.column, target.block)
      }

      return checkCompletion({
        ...state,
        cells: nextCells,
        hintsUsed: state.hintsUsed + 1,
        history: pushHistory(state),
      })
    }

    case 'tick':
      return { ...state, elapsedSeconds: state.elapsedSeconds + 1 }

    case 'restart':
      return makeInitialState(action.level)
  }
}

export function makeInitialState(level: SudokuLevel, snapshot?: GameSnapshot | null): GameState {
  const canUseSnapshot = snapshot && levelId(snapshot.level) === levelId(level)

  return {
    cells: makeCells(
      level,
      canUseSnapshot && snapshot.values.length === 81 ? snapshot.values : level.puzzle,
      canUseSnapshot && snapshot.notes.length === 81 ? snapshot.notes : emptyNotes(),
    ),
    selectedCellID: null,
    mistakes: canUseSnapshot ? Math.max(0, snapshot.mistakes) : 0,
    hintsUsed: canUseSnapshot ? Math.max(0, snapshot.hintsUsed) : 0,
    elapsedSeconds: canUseSnapshot ? Math.max(0, snapshot.elapsedSeconds) : 0,
    isComplete: false,
    notesMode: false,
    history: [],
  }
}

export function makeSnapshot(level: SudokuLevel, state: GameState): GameSnapshot {
  return {
    level,
    values: state.cells.map((cell) => cell.value),
    notes: state.cells.map((cell) => [...cell.notes].sort((a, b) => a - b)),
    mistakes: state.mistakes,
    elapsedSeconds: state.elapsedSeconds,
    hintsUsed: state.hintsUsed,
  }
}

function makeCells(level: SudokuLevel, values: number[], notes: number[][]): SudokuCell[] {
  return Array.from({ length: 81 }, (_, index) => {
    const row = Math.floor(index / 9)
    const column = index % 9

    return {
      id: index,
      row,
      column,
      block: Math.floor(row / 3) * 3 + Math.floor(column / 3),
      solution: level.solution[index],
      givenValue: level.puzzle[index],
      value: Number.isInteger(values[index]) ? values[index] : level.puzzle[index],
      notes: normalizeNotes(notes[index] ?? []),
    }
  })
}

function selectedIndex(state: GameState) {
  if (state.selectedCellID == null) return null
  const index = state.cells.findIndex((cell) => cell.id === state.selectedCellID)
  return index >= 0 ? index : null
}

function isGiven(cell: SudokuCell) {
  return cell.givenValue !== 0
}

function cloneCells(cells: SudokuCell[]) {
  return cells.map((cell) => ({ ...cell, notes: [...cell.notes] }))
}

function pushHistory(state: GameState): HistoryEntry[] {
  const next = [
    ...state.history,
    {
      cells: cloneCells(state.cells),
      mistakes: state.mistakes,
      hintsUsed: state.hintsUsed,
    },
  ]

  return next.length > 50 ? next.slice(1) : next
}

function removeResolvedNotes(cells: SudokuCell[], number: number, row: number, column: number, block: number) {
  for (const cell of cells) {
    if (cell.row === row || cell.column === column || cell.block === block) {
      cell.notes = cell.notes.filter((note) => note !== number)
    }
  }
}

function hintTargetIndex(state: GameState) {
  const selected = selectedIndex(state)

  if (selected != null && !isGiven(state.cells[selected]) && state.cells[selected].value !== state.cells[selected].solution) {
    return selected
  }

  const firstIncorrectOrEmpty = state.cells.findIndex((cell) => !isGiven(cell) && cell.value !== cell.solution)
  return firstIncorrectOrEmpty >= 0 ? firstIncorrectOrEmpty : null
}

function checkCompletion(state: GameState): GameState {
  return state.cells.every((cell) => cell.value !== 0 && cell.value === cell.solution)
    ? { ...state, isComplete: true }
    : state
}

function emptyNotes() {
  return Array.from({ length: 81 }, () => [])
}

function normalizeNotes(notes: number[]) {
  return [...new Set(notes.filter((note) => Number.isInteger(note) && note >= 1 && note <= 9))].sort((a, b) => a - b)
}
