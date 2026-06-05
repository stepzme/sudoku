import { Link, Navigate, useParams } from 'react-router-dom'
import FigmaIcon from '../components/FigmaIcon'
import FlowerIcon from '../components/FlowerIcon'
import ScreenHeader from '../components/ScreenHeader'
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

      <ScreenHeader
        leftAction={{
          icon: <FigmaIcon className="screen-header-icon is-chevron" name="chevron-left" />,
          label: 'Предыдущая сложность',
          to: `/levels/${previousDifficulty}`,
        }}
        rightAction={{
          icon: <FigmaIcon className="screen-header-icon is-chevron" name="chevron-right" />,
          label: 'Следующая сложность',
          to: `/levels/${nextDifficulty}`,
        }}
        title={difficultyInfo[difficulty].title}
        subtitle={
          <>
            <FlowerIcon className="difficulty-progress-flower" variant="progress" />
            Пройдено {completed} из {total}
          </>
        }
      />

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
                <FlowerIcon className="level-completed-flower" variant="completed" />
              ) : null}
              {!unlocked ? <img className="level-lock" src={publicAsset('assets/ui/lock.svg')} alt="" aria-hidden="true" /> : null}
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
