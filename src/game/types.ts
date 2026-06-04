export const difficulties = ['easy', 'medium', 'hard'] as const

export type Difficulty = (typeof difficulties)[number]

export interface DifficultyInfo {
  title: string
  subtitle: string
  color: string
  mistakeLimit: number
}

export const difficultyInfo: Record<Difficulty, DifficultyInfo> = {
  easy: {
    title: 'Легко',
    subtitle: 'Спокойные головоломки с большим количеством подсказок.',
    color: '#4db9e6',
    mistakeLimit: 5,
  },
  medium: {
    title: 'Средне',
    subtitle: 'Сбалансированные уровни для обычной игры.',
    color: '#f79518',
    mistakeLimit: 4,
  },
  hard: {
    title: 'Сложно',
    subtitle: 'Требовательные головоломки для вдумчивого решения.',
    color: '#f7187c',
    mistakeLimit: 3,
  },
}

export interface SudokuLevel {
  difficulty: Difficulty
  number: number
  puzzle: number[]
  solution: number[]
}

export interface SudokuCell {
  id: number
  row: number
  column: number
  block: number
  solution: number
  givenValue: number
  value: number
  notes: number[]
}

export interface GameSnapshot {
  level: SudokuLevel
  values: number[]
  notes: number[][]
  mistakes: number
  elapsedSeconds: number
  hintsUsed: number
}

export interface CompletedLevel {
  levelID: string
  difficulty: Difficulty
  number: number
  elapsedSeconds: number
  mistakes: number
  hintsUsed: number
  completedAt: string
}

export interface GameSettings {
  highlightPeers: boolean
  autoRemoveNotes: boolean
  haptics: boolean
}

export function levelId(level: Pick<SudokuLevel, 'difficulty' | 'number'>) {
  return `${level.difficulty}-${level.number}`
}

export function isDifficulty(value: string | undefined): value is Difficulty {
  return difficulties.includes(value as Difficulty)
}
