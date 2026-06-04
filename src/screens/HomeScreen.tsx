import { Play } from 'lucide-react'
import { useState } from 'react'
import { Link } from 'react-router-dom'
import { homeCharacterCount, homeCharacterSrc, publicAsset } from '../game/assets'
import { formatSeconds, useProgress } from '../game/progress'
import { difficultyInfo } from '../game/types'

export default function HomeScreen() {
  const progress = useProgress()
  const [characterIndex] = useState(randomCharacterIndex)
  const activeGame = progress.activeGame

  return (
    <section className={activeGame ? 'home-scene has-active-game' : 'home-scene'}>
      <img className="home-bg" src={publicAsset('assets/home/background.png')} alt="" aria-hidden="true" />
      <img className="home-logo" src={publicAsset('assets/home/logo.png')} alt="Судоку" draggable={false} />
      <img
        className="home-character"
        src={homeCharacterSrc(characterIndex)}
        alt=""
        aria-hidden="true"
        draggable={false}
      />

      {activeGame ? (
        <Link
          className="continue-game-card"
          to={`/game/${activeGame.level.difficulty}/${activeGame.level.number}`}
        >
          <span className="continue-play-icon">
            <Play size={23} fill="currentColor" strokeWidth={3} />
          </span>
          <span className="continue-copy">
            <strong>Продолжить игру</strong>
            <small>
              {difficultyInfo[activeGame.level.difficulty].title}・Уровень {activeGame.level.number} ・
              {formatSeconds(activeGame.elapsedSeconds)}
            </small>
          </span>
        </Link>
      ) : null}

      <Link className="toy-button toy-button-orange home-new-game" to="/levels/easy">
        Новая игра
      </Link>
    </section>
  )
}

function randomCharacterIndex() {
  const buffer = new Uint32Array(1)
  crypto.getRandomValues(buffer)
  return (buffer[0] % homeCharacterCount) + 1
}
