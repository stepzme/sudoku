import { ChevronLeft, ChevronRight, Lock } from 'lucide-react'
import { Link, Navigate, useParams } from 'react-router-dom'
import { publicAsset } from '../game/assets'
import { countLevels, type LevelCatalog } from '../game/levels'
import { useProgress } from '../game/progress'
import { difficulties, difficultyInfo, isDifficulty } from '../game/types'

export default function LevelSelectionScreen({ catalog }: { catalog: LevelCatalog }) {
  const { difficulty } = useParams()
  const progress = useProgress()

  if (!isDifficulty(difficulty)) return <Navigate to="/levels/easy" replace />

  const levels = catalog.byDifficulty[difficulty]
  const currentIndex = difficulties.indexOf(difficulty)
  const previousDifficulty = difficulties[(currentIndex + difficulties.length - 1) % difficulties.length]
  const nextDifficulty = difficulties[(currentIndex + 1) % difficulties.length]
  const completed = progress.completedCount(difficulty)
  const total = countLevels(catalog, difficulty)

  return (
    <section className={`level-select-screen theme-${difficulty}`}>
      <div className="level-select-bg" aria-hidden="true" />

      <header className="difficulty-switcher">
        <Link className="round-theme-button difficulty-arrow-button" to={`/levels/${previousDifficulty}`} aria-label="Предыдущая сложность">
          <ChevronLeft size={31} strokeWidth={4} />
        </Link>

        <div className="difficulty-title-card">
          <strong>{difficultyInfo[difficulty].title}</strong>
          <span>
            <img src={publicAsset('assets/ui/flower.png')} alt="" aria-hidden="true" />
            Пройдено {completed} из {total}
          </span>
        </div>

        <Link className="round-theme-button difficulty-arrow-button" to={`/levels/${nextDifficulty}`} aria-label="Следующая сложность">
          <ChevronRight size={31} strokeWidth={4} />
        </Link>
      </header>

      <div className="level-choice-grid" aria-label={`Уровни: ${difficultyInfo[difficulty].title}`}>
        {levels.map((level) => {
          const unlocked = progress.isUnlocked(level)
          const isCompleted = progress.isCompleted(level)
          const className = [
            'level-choice-tile',
            unlocked ? 'is-unlocked' : 'is-locked',
            isCompleted ? 'is-completed' : '',
          ]
            .filter(Boolean)
            .join(' ')

          const content = (
            <>
              <strong>{level.number}</strong>
              {isCompleted ? (
                <img className="level-completed-flower" src={publicAsset('assets/ui/flower.png')} alt="" aria-hidden="true" />
              ) : null}
              {!unlocked ? (
                <span className="level-lock" aria-hidden="true">
                  <Lock size={17} strokeWidth={3.4} />
                </span>
              ) : null}
            </>
          )

          return unlocked ? (
            <Link className={className} to={`/game/${level.difficulty}/${level.number}`} key={level.number}>
              {content}
            </Link>
          ) : (
            <div className={className} key={level.number} aria-label={`Уровень ${level.number} закрыт`}>
              {content}
            </div>
          )
        })}
      </div>

      <Link className="toy-button toy-button-neutral level-back-button" to="/">
        Назад
      </Link>
    </section>
  )
}
