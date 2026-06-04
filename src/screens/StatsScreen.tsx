import BackButton from '../components/BackButton'
import { countLevels, type LevelCatalog } from '../game/levels'
import { useProgress } from '../game/progress'
import { difficulties, difficultyInfo } from '../game/types'

interface StatsScreenProps {
  catalog: LevelCatalog
  totalLevels: number
}

export default function StatsScreen({ catalog, totalLevels }: StatsScreenProps) {
  const progress = useProgress()
  const totalCompleted = Object.keys(progress.completedLevels).length

  return (
    <section className="screen">
      <BackButton />
      <h1 className="screen-title">Статистика</h1>

      <div className="list-card">
        <StatRow title="Пройдено" value={`${totalCompleted}/${totalLevels}`} />
      </div>

      <h2 className="section-title">По сложности</h2>
      <div className="list-card">
        {difficulties.map((difficulty) => (
          <StatRow
            key={difficulty}
            title={difficultyInfo[difficulty].title}
            value={`${progress.completedCount(difficulty)}/${countLevels(catalog, difficulty)}`}
          />
        ))}
      </div>
    </section>
  )
}

function StatRow({ title, value }: { title: string; value: string }) {
  return (
    <div className="list-row">
      <span>{title}</span>
      <strong>{value}</strong>
    </div>
  )
}
