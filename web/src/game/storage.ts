import type { CompletedLevel, GameSettings, GameSnapshot } from './types'

const completedKey = 'sudoku.completedLevels'
const activeGameKey = 'sudoku.activeGame'
const settingsKey = 'sudoku.settings'

export interface StoredProgress {
  completedLevels: Record<string, CompletedLevel>
  activeGame: GameSnapshot | null
  settings: GameSettings
}

export const defaultSettings: GameSettings = {
  highlightPeers: true,
  autoRemoveNotes: true,
  haptics: true,
}

export function loadStoredProgress(): StoredProgress {
  return {
    completedLevels: readJson<Record<string, CompletedLevel>>(completedKey) ?? {},
    activeGame: readJson<GameSnapshot>(activeGameKey),
    settings: {
      ...defaultSettings,
      ...(readJson<Partial<GameSettings>>(settingsKey) ?? {}),
    },
  }
}

export function writeCompletedLevels(completedLevels: Record<string, CompletedLevel>) {
  writeJson(completedKey, completedLevels)
}

export function writeActiveGame(activeGame: GameSnapshot | null) {
  if (activeGame) {
    writeJson(activeGameKey, activeGame)
  } else {
    localStorage.removeItem(activeGameKey)
  }
}

export function writeSettings(settings: GameSettings) {
  writeJson(settingsKey, settings)
}

function readJson<T>(key: string): T | null {
  try {
    const raw = localStorage.getItem(key)
    return raw ? (JSON.parse(raw) as T) : null
  } catch {
    localStorage.removeItem(key)
    return null
  }
}

function writeJson(key: string, value: unknown) {
  localStorage.setItem(key, JSON.stringify(value))
}
