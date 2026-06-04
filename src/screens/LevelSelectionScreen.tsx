import { CheckCircle, Lock } from 'lucide-react'
import { Link, Navigate, useParams } from 'react-router-dom'
import BackButton from '../components/BackButton'
import { type LevelCatalog } from '../game/levels'
import { bestResultLabel, useProgress } from '../game/progress'
import { difficultyInfo, isDifficulty } from '../game/types'

export default function LevelSelectionScreen({ catalog }: { catalog: LevelCatalog }) {
  const { difficulty } = useParams()
  const progress = useProgress()

  if (!isDifficulty(difficulty)) return <Navigate to="/new" replace />

  const levels = catalog.byDifficulty[difficulty]

  return (
    <section className="screen">
      <BackButton />
      <h1 className="screen-title">{difficultyInfo[difficulty].title}</h1>

      <div className="level-grid">
        {levels.map((level) => {
          const unlocked = progress.isUnlocked(level)
          const completed = progress.isCompleted(level)

          return unlocked ? (
            <Link
              className={completed ? 'level-tile is-completed' : 'level-tile'}
              to={`/game/${level.difficulty}/${level.number}`}
              key={level.number}
              style={{ '--difficulty-color': difficultyInfo[level.difficulty].color } as React.CSSProperties}
            >
              {completed ? <CheckCircle size={15} fill="currentColor" /> : <span />}
              <strong>{level.number}</strong>
              <small>{bestResultLabel(level, progress.completedLevels)}</small>
            </Link>
          ) : (
            <div className="level-tile is-locked" key={level.number}>
              <Lock size={14} fill="currentColor" />
              <strong>{level.number}</strong>
              <small>закрыт</small>
            </div>
          )
        })}
      </div>
    </section>
  )
}
