import { CheckCircle, ChevronRightCircle } from 'lucide-react'
import { Link } from 'react-router-dom'
import BackButton from '../components/BackButton'
import { countLevels, type LevelCatalog } from '../game/levels'
import { useProgress } from '../game/progress'
import { difficulties, difficultyInfo } from '../game/types'

export default function DifficultyScreen({ catalog }: { catalog: LevelCatalog }) {
  const progress = useProgress()

  return (
    <section className="screen">
      <BackButton />
      <h1 className="screen-title">Выберите сложность</h1>

      <div className="difficulty-list">
        {difficulties.map((difficulty) => {
          const completed = progress.completedCount(difficulty)
          const total = countLevels(catalog, difficulty)
          const percent = total > 0 ? (completed / total) * 100 : 0

          return (
            <Link className="difficulty-card" to={`/levels/${difficulty}`} key={difficulty}>
              <span className="difficulty-stripe" style={{ backgroundColor: difficultyInfo[difficulty].color }} />
              <span className="difficulty-copy">
                <strong>{difficultyInfo[difficulty].title}</strong>
                <small>{difficultyInfo[difficulty].subtitle}</small>
              </span>
              <ChevronRightCircle className="difficulty-arrow" color={difficultyInfo[difficulty].color} size={30} />
              <span className="progress-track">
                <span
                  className="progress-fill"
                  style={{ width: `${percent}%`, backgroundColor: difficultyInfo[difficulty].color }}
                />
              </span>
              <span className="difficulty-meta">
                <span>
                  <CheckCircle size={15} fill="currentColor" />
                  {completed} пройдено
                </span>
                <span>{total} уровней</span>
              </span>
            </Link>
          )
        })}
      </div>
    </section>
  )
}
