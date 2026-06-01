import { describe, expect, it } from 'vitest'
import levelsData from '../public/levels.json'
import { gameReducer, makeInitialState } from '../src/game/useSudokuGame'
import type { GameSettings, SudokuLevel } from '../src/game/types'

const settings: GameSettings = {
  highlightPeers: true,
  autoRemoveNotes: true,
  haptics: false,
}

const level = (levelsData as SudokuLevel[]).find((item) => item.difficulty === 'easy' && item.number === 1)!

describe('game reducer', () => {
  it('counts a wrong entry once when the same number is repeated', () => {
    const editable = firstEditableCell()
    const wrongNumber = firstWrongNumber(editable)

    let state = makeInitialState(level)
    state = gameReducer(state, { type: 'select', cellID: editable })
    state = gameReducer(state, { type: 'enter', number: wrongNumber, settings })
    state = gameReducer(state, { type: 'enter', number: wrongNumber, settings })

    expect(state.mistakes).toBe(1)
    expect(state.cells[editable].value).toBe(wrongNumber)
  })

  it('restores cells and mistake count on undo', () => {
    const editable = firstEditableCell()
    const wrongNumber = firstWrongNumber(editable)

    let state = makeInitialState(level)
    state = gameReducer(state, { type: 'select', cellID: editable })
    state = gameReducer(state, { type: 'enter', number: wrongNumber, settings })
    state = gameReducer(state, { type: 'undo' })

    expect(state.mistakes).toBe(0)
    expect(state.cells[editable].value).toBe(0)
  })

  it('uses a hint on the selected editable cell', () => {
    const editable = firstEditableCell()

    let state = makeInitialState(level)
    state = gameReducer(state, { type: 'select', cellID: editable })
    state = gameReducer(state, { type: 'hint', settings })

    expect(state.hintsUsed).toBe(1)
    expect(state.cells[editable].value).toBe(level.solution[editable])
  })
})

function firstEditableCell() {
  return level.puzzle.findIndex((value) => value === 0)
}

function firstWrongNumber(index: number) {
  return Array.from({ length: 9 }, (_, offset) => offset + 1).find((number) => number !== level.solution[index])!
}
