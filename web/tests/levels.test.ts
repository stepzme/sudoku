import { describe, expect, it } from 'vitest'
import levelsData from '../public/levels.json'
import { makeLevelCatalog } from '../src/game/levels'
import { difficulties, type SudokuLevel } from '../src/game/types'

const levels = levelsData as SudokuLevel[]

describe('level catalog', () => {
  it('contains 20 levels for each difficulty', () => {
    const catalog = makeLevelCatalog(levels)

    expect(catalog.all).toHaveLength(60)
    for (const difficulty of difficulties) {
      expect(catalog.byDifficulty[difficulty]).toHaveLength(20)
    }
  })

  it('contains valid puzzles that match their solutions', () => {
    for (const level of levels) {
      expect(level.puzzle).toHaveLength(81)
      expect(level.solution).toHaveLength(81)
      expect(isSolvedGrid(level.solution)).toBe(true)

      for (let index = 0; index < 81; index += 1) {
        const value = level.puzzle[index]
        expect(value).toBeGreaterThanOrEqual(0)
        expect(value).toBeLessThanOrEqual(9)
        if (value !== 0) expect(value).toBe(level.solution[index])
      }
    }
  })
})

function isSolvedGrid(grid: number[]) {
  const expected = '1,2,3,4,5,6,7,8,9'
  const units: number[][] = []

  for (let row = 0; row < 9; row += 1) {
    units.push(Array.from({ length: 9 }, (_, column) => grid[row * 9 + column]))
  }

  for (let column = 0; column < 9; column += 1) {
    units.push(Array.from({ length: 9 }, (_, row) => grid[row * 9 + column]))
  }

  for (let blockRow = 0; blockRow < 3; blockRow += 1) {
    for (let blockColumn = 0; blockColumn < 3; blockColumn += 1) {
      const unit: number[] = []
      for (let rowOffset = 0; rowOffset < 3; rowOffset += 1) {
        for (let columnOffset = 0; columnOffset < 3; columnOffset += 1) {
          const row = blockRow * 3 + rowOffset
          const column = blockColumn * 3 + columnOffset
          unit.push(grid[row * 9 + column])
        }
      }
      units.push(unit)
    }
  }

  return units.every((unit) => [...unit].sort((a, b) => a - b).join(',') === expected)
}
