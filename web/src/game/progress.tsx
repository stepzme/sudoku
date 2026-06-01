/* eslint-disable react-refresh/only-export-components */
import { createContext, useCallback, useContext, useMemo, useState, type ReactNode } from 'react'
import {
  defaultSettings,
  loadStoredProgress,
  writeActiveGame,
  writeCompletedLevels,
  writeSettings,
} from './storage'
import {
  difficultyInfo,
  levelId,
  type CompletedLevel,
  type Difficulty,
  type GameSettings,
  type GameSnapshot,
  type SudokuLevel,
} from './types'

interface ProgressContextValue {
  completedLevels: Record<string, CompletedLevel>
  activeGame: GameSnapshot | null
  settings: GameSettings
  completeLevel: (snapshot: GameSnapshot) => void
  saveActiveGame: (snapshot: GameSnapshot) => void
  clearActiveGame: (level?: SudokuLevel) => void
  isCompleted: (level: SudokuLevel) => boolean
  completedCount: (difficulty: Difficulty) => number
  isUnlocked: (level: SudokuLevel) => boolean
  updateSettings: (settings: GameSettings) => void
  resetProgress: () => void
}

const ProgressContext = createContext<ProgressContextValue | null>(null)

export function ProgressProvider({ children }: { children: ReactNode }) {
  const [completedLevels, setCompletedLevels] = useState(() => loadStoredProgress().completedLevels)
  const [activeGame, setActiveGame] = useState<GameSnapshot | null>(() => loadStoredProgress().activeGame)
  const [settings, setSettings] = useState<GameSettings>(() => loadStoredProgress().settings)

  const clearActiveGame = useCallback((level?: SudokuLevel) => {
    setActiveGame((current) => {
      if (level && current?.level && levelId(current.level) !== levelId(level)) return current
      writeActiveGame(null)
      return null
    })
  }, [])

  const saveActiveGame = useCallback((snapshot: GameSnapshot) => {
    setActiveGame(snapshot)
    writeActiveGame(snapshot)
  }, [])

  const completeLevel = useCallback((snapshot: GameSnapshot) => {
    const id = levelId(snapshot.level)
    const existing = completedLevels[id]

    if (!existing || existing.elapsedSeconds > snapshot.elapsedSeconds) {
      const next = {
        ...completedLevels,
        [id]: {
          levelID: id,
          difficulty: snapshot.level.difficulty,
          number: snapshot.level.number,
          elapsedSeconds: snapshot.elapsedSeconds,
          mistakes: snapshot.mistakes,
          hintsUsed: snapshot.hintsUsed,
          completedAt: new Date().toISOString(),
        },
      }

      setCompletedLevels(next)
      writeCompletedLevels(next)
    }

    setActiveGame(null)
    writeActiveGame(null)
  }, [completedLevels])

  const updateSettings = useCallback((nextSettings: GameSettings) => {
    setSettings(nextSettings)
    writeSettings(nextSettings)
  }, [])

  const resetProgress = useCallback(() => {
    setCompletedLevels({})
    setActiveGame(null)
    setSettings(defaultSettings)
    writeCompletedLevels({})
    writeActiveGame(null)
    writeSettings(defaultSettings)
  }, [])

  const value = useMemo<ProgressContextValue>(
    () => ({
      completedLevels,
      activeGame,
      settings,
      completeLevel,
      saveActiveGame,
      clearActiveGame,
      isCompleted: (level) => completedLevels[levelId(level)] != null,
      completedCount: (difficulty) =>
        Object.values(completedLevels).filter((level) => level.difficulty === difficulty).length,
      isUnlocked: (level) =>
        level.number === 1 ||
        completedLevels[`${level.difficulty}-${level.number - 1}`] != null ||
        completedLevels[levelId(level)] != null,
      updateSettings,
      resetProgress,
    }),
    [
      activeGame,
      clearActiveGame,
      completeLevel,
      completedLevels,
      resetProgress,
      saveActiveGame,
      settings,
      updateSettings,
    ],
  )

  return <ProgressContext.Provider value={value}>{children}</ProgressContext.Provider>
}

export function useProgress() {
  const context = useContext(ProgressContext)
  if (!context) throw new Error('useProgress must be used inside ProgressProvider')
  return context
}

export function bestResultLabel(level: SudokuLevel, completedLevels: Record<string, CompletedLevel>) {
  const completed = completedLevels[levelId(level)]
  if (!completed) return difficultyInfo[level.difficulty].title
  return `${formatSeconds(completed.elapsedSeconds)} · ${completed.mistakes} ош.`
}

export function formatSeconds(totalSeconds: number) {
  const minutes = Math.floor(totalSeconds / 60)
  const seconds = totalSeconds % 60
  return `${String(minutes).padStart(2, '0')}:${String(seconds).padStart(2, '0')}`
}
