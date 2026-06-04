import { useEffect, useMemo, useState } from 'react'
import { HashRouter, Navigate, Route, Routes } from 'react-router-dom'
import { ProgressProvider } from './game/progress'
import { loadLevelCatalog, type LevelCatalog } from './game/levels'
import HomeScreen from './screens/HomeScreen'
import DifficultyScreen from './screens/DifficultyScreen'
import LevelSelectionScreen from './screens/LevelSelectionScreen'
import GameScreen from './screens/GameScreen'
import StatsScreen from './screens/StatsScreen'
import SettingsScreen from './screens/SettingsScreen'

function App() {
  const [catalog, setCatalog] = useState<LevelCatalog | null>(null)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    let cancelled = false

    loadLevelCatalog()
      .then((nextCatalog) => {
        if (!cancelled) setCatalog(nextCatalog)
      })
      .catch((nextError: unknown) => {
        if (!cancelled) {
          setError(nextError instanceof Error ? nextError.message : 'Не удалось загрузить уровни')
        }
      })

    return () => {
      cancelled = true
    }
  }, [])

  const totalLevels = useMemo(() => catalog?.all.length ?? 0, [catalog])

  if (error) {
    return (
      <main className="app-shell centered-state">
        <h1>Судоку</h1>
        <p>{error}</p>
      </main>
    )
  }

  if (!catalog) {
    return (
      <main className="app-shell centered-state">
        <div className="loading-mark" />
        <p>Загружаем уровни</p>
      </main>
    )
  }

  return (
    <ProgressProvider>
      <HashRouter>
        <main className="app-shell">
          <Routes>
            <Route index element={<HomeScreen catalog={catalog} totalLevels={totalLevels} />} />
            <Route path="new" element={<DifficultyScreen catalog={catalog} />} />
            <Route
              path="levels/:difficulty"
              element={<LevelSelectionScreen catalog={catalog} />}
            />
            <Route path="game/:difficulty/:number" element={<GameScreen catalog={catalog} />} />
            <Route path="stats" element={<StatsScreen catalog={catalog} totalLevels={totalLevels} />} />
            <Route path="settings" element={<SettingsScreen totalLevels={totalLevels} />} />
            <Route path="*" element={<Navigate to="/" replace />} />
          </Routes>
        </main>
      </HashRouter>
    </ProgressProvider>
  )
}

export default App
