import { difficulties, isDifficulty, type Difficulty, type SudokuLevel } from './types'

export interface LevelCatalog {
  all: SudokuLevel[]
  byDifficulty: Record<Difficulty, SudokuLevel[]>
}

export async function loadLevelCatalog(): Promise<LevelCatalog> {
  const response = await fetch(`${import.meta.env.BASE_URL}levels.json`)

  if (!response.ok) {
    throw new Error('Не удалось загрузить Levels.json')
  }

  const levels = (await response.json()) as SudokuLevel[]
  return makeLevelCatalog(levels)
}

export function makeLevelCatalog(levels: SudokuLevel[]): LevelCatalog {
  const byDifficulty: Record<Difficulty, SudokuLevel[]> = {
    easy: [],
    medium: [],
    hard: [],
  }

  for (const level of levels) {
    if (!isValidLevel(level)) continue
    byDifficulty[level.difficulty].push(level)
  }

  for (const difficulty of difficulties) {
    byDifficulty[difficulty].sort((a, b) => a.number - b.number)
  }

  return {
    all: difficulties.flatMap((difficulty) => byDifficulty[difficulty]),
    byDifficulty,
  }
}

export function findLevel(catalog: LevelCatalog, difficulty: Difficulty, number: number) {
  return catalog.byDifficulty[difficulty].find((level) => level.number === number)
}

export function countLevels(catalog: LevelCatalog, difficulty: Difficulty) {
  return catalog.byDifficulty[difficulty].length
}

function isValidLevel(level: SudokuLevel) {
  return (
    isDifficulty(level.difficulty) &&
    Number.isInteger(level.number) &&
    Array.isArray(level.puzzle) &&
    level.puzzle.length === 81 &&
    Array.isArray(level.solution) &&
    level.solution.length === 81
  )
}
