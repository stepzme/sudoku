import { BarChart3, ChevronRight, Clock3, Play, Settings } from 'lucide-react'
import { Link } from 'react-router-dom'
import BottomAction from '../components/BottomAction'
import { type LevelCatalog, countLevels } from '../game/levels'
import { formatSeconds, useProgress } from '../game/progress'
import { difficulties, difficultyInfo, levelId } from '../game/types'

interface HomeScreenProps {
  catalog: LevelCatalog
  totalLevels: number
}

export default function HomeScreen({ catalog, totalLevels }: HomeScreenProps) {
  const progress = useProgress()

  return (
    <section className="screen home-screen with-bottom-action">
      <div className="home-title">
        <h1>Судоку</h1>
        <p>{totalLevels} готовых головоломок в трех уровнях сложности.</p>
      </div>

      {progress.activeGame ? (
        <Link
          className="continue-card"
          to={`/game/${progress.activeGame.level.difficulty}/${progress.activeGame.level.number}`}
        >
          <span className="card-icon blue-soft">
            <Clock3 size={26} strokeWidth={2.5} />
          </span>
          <span>
            <strong>Продолжить</strong>
            <small>
              {difficultyInfo[progress.activeGame.level.difficulty].title} · Уровень{' '}
              {progress.activeGame.level.number} · {formatSeconds(progress.activeGame.elapsedSeconds)}
            </small>
          </span>
          <ChevronRight className="chevron" size={22} />
        </Link>
      ) : null}

      <div className="secondary-actions">
        <Link className="secondary-card" to="/stats">
          <BarChart3 size={27} strokeWidth={2.5} />
          <strong>Статистика</strong>
        </Link>
        <Link className="secondary-card" to="/settings">
          <Settings size={27} strokeWidth={2.5} />
          <strong>Настройки</strong>
        </Link>
      </div>

      <section className="progress-section">
        <h2>Прогресс</h2>
        {difficulties.map((difficulty) => {
          const completed = progress.completedCount(difficulty)
          const total = countLevels(catalog, difficulty)
          const percent = total > 0 ? (completed / total) * 100 : 0

          return (
            <article className="progress-card" key={difficulty}>
              <div className="row">
                <strong>{difficultyInfo[difficulty].title}</strong>
                <span>
                  {completed}/{total}
                </span>
              </div>
              <div className="progress-track">
                <span
                  className="progress-fill"
                  style={{
                    width: `${percent}%`,
                    backgroundColor: difficultyInfo[difficulty].color,
                  }}
                />
              </div>
            </article>
          )
        })}
      </section>

      <BottomAction>
        <Link className="primary-action" to="/new">
          <span className="primary-icon">
            <Play size={22} fill="currentColor" />
          </span>
          <span>
            <strong>Новая игра</strong>
            <small>Выберите сложность и уровень</small>
          </span>
          <ChevronRight size={22} />
        </Link>
      </BottomAction>

      <span className="sr-only">{progress.activeGame ? levelId(progress.activeGame.level) : 'no-active-game'}</span>
    </section>
  )
}
