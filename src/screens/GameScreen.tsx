import { useEffect, useMemo, useState, type ReactNode } from 'react'
import { Navigate, useNavigate, useParams } from 'react-router-dom'
import FigmaIcon from '../components/FigmaIcon'
import NumberPad from '../components/NumberPad'
import ScreenHeader from '../components/ScreenHeader'
import SudokuBoard from '../components/SudokuBoard'
import { publicAsset } from '../game/assets'
import { findLevel, type LevelCatalog } from '../game/levels'
import { useProgress } from '../game/progress'
import { difficultyInfo, isDifficulty, levelId } from '../game/types'
import { hintLimit, useSudokuGame } from '../game/useSudokuGame'

export default function GameScreen({ catalog }: { catalog: LevelCatalog }) {
  const navigate = useNavigate()
  const params = useParams()
  const progress = useProgress()
  const [showPause, setShowPause] = useState(false)

  const difficulty = isDifficulty(params.difficulty) ? params.difficulty : null
  const number = Number(params.number)
  const level = difficulty && Number.isInteger(number) ? findLevel(catalog, difficulty, number) : null
  const snapshot = useMemo(() => {
    if (!level || !progress.activeGame) return null
    return levelId(progress.activeGame.level) === levelId(level) ? progress.activeGame : null
  }, [level, progress.activeGame])

  const game = useSudokuGame(level ?? catalog.all[0], snapshot)
  const timerPaused = showPause || game.isComplete || game.isFailed

  useEffect(() => {
    if (!level || timerPaused) return
    const id = window.setInterval(() => game.tick(), 1000)
    return () => window.clearInterval(id)
  }, [game, level, timerPaused])

  if (!level) return <Navigate to="/levels/easy" replace />

  return (
    <section className={`game-screen theme-${level.difficulty}`}>
      <ScreenHeader
        leftAction={{
          icon: <FigmaIcon className="screen-header-icon is-close" name="close" />,
          label: 'Закрыть',
          onClick: () => navigate(`/levels/${level.difficulty}`),
        }}
        rightAction={{
          icon: <FigmaIcon className="screen-header-icon is-pause" name="pause" />,
          label: 'Пауза',
          onClick: () => setShowPause(true),
        }}
        title={`Уровень ${level.number}`}
        subtitle={`${difficultyInfo[level.difficulty].title}・${game.formattedTime}`}
        status={
          <>
            <span>Ошибки・{game.mistakes}/{game.mistakeLimit}</span>
            <span>Подсказки・{game.remainingHints}/{hintLimit}</span>
          </>
        }
      />

      <SudokuBoard game={game} />

      <div className="tool-row">
        <ToolButton title="Отмена" icon={<FigmaIcon className="tool-icon is-undo" name="undo" />} disabled={!game.canUndo} onClick={game.undo} />
        <ToolButton title="Стереть" icon={<FigmaIcon className="tool-icon is-erase" name="erase" />} disabled={!game.canErase} onClick={game.erase} />
        <ToolButton title="Заметки" icon={<FigmaIcon className="tool-icon is-notes" name="notes" />} selected={game.notesMode} onClick={game.toggleNotes} />
        <ToolButton title="Подсказка" icon={<FigmaIcon className="tool-icon is-hint" name="hint" />} disabled={!game.canUseHint} onClick={game.useHint} />
      </div>

      <NumberPad
        isNotesMode={game.notesMode}
        remainingCount={game.remainingPlacements}
        isDisabled={game.isNumberExhausted}
        onTap={game.enter}
      />

      <div className="asset-preload" aria-hidden="true">
        <img src={publicAsset('assets/modal/pause.png')} alt="" />
        <img src={publicAsset('assets/modal/completed.png')} alt="" />
        <img src={publicAsset('assets/modal/failed.png')} alt="" />
      </div>

      {showPause ? (
        <GameDialog image="pause" title="Пауза" subtitle={`${difficultyInfo[level.difficulty].title}・Уровень ${level.number}`}>
          <button className="toy-button toy-button-theme dialog-button" type="button" onClick={() => setShowPause(false)}>
            Продолжить
          </button>
          <button
            className="toy-button toy-button-neutral dialog-button"
            type="button"
            onClick={() => {
              setShowPause(false)
              game.restart()
            }}
          >
            Начать заново
          </button>
        </GameDialog>
      ) : null}

      {game.isComplete ? (
        <GameDialog image="completed" title="Уровень пройден!" subtitle={`${difficultyInfo[level.difficulty].title}・Уровень ${level.number}`}>
          <div className="result-lines">
            <span>
              <em>Время</em>
              <i />
              <strong>{game.formattedTime}</strong>
            </span>
            <span>
              <em>Ошибки</em>
              <i />
              <strong>{game.mistakes}</strong>
            </span>
          </div>
          <button className="toy-button toy-button-theme dialog-button" type="button" onClick={() => navigate('/')}>
            Выйти
          </button>
        </GameDialog>
      ) : null}

      {game.isFailed ? (
        <GameDialog image="failed" title="Игра окончена" subtitle="Ошибки закончились :(">
          <button className="toy-button toy-button-theme dialog-button" type="button" onClick={game.restart}>
            Начать заново
          </button>
          <button className="toy-button toy-button-neutral dialog-button" type="button" onClick={() => navigate('/')}>
            Выйти
          </button>
        </GameDialog>
      ) : null}
    </section>
  )
}

interface ToolButtonProps {
  title: string
  icon: ReactNode
  selected?: boolean
  disabled?: boolean
  onClick: () => void
}

function ToolButton({ title, icon, selected = false, disabled = false, onClick }: ToolButtonProps) {
  return (
    <button className={selected ? 'tool-button is-selected' : 'tool-button'} type="button" disabled={disabled} onClick={onClick}>
      {icon}
      <span>{title}</span>
    </button>
  )
}

interface GameDialogProps {
  image: 'pause' | 'completed' | 'failed'
  title: string
  subtitle: string
  children: ReactNode
}

function GameDialog({ image, title, subtitle, children }: GameDialogProps) {
  return (
    <div className="game-dialog-backdrop" role="presentation">
      <section className="game-dialog" role="dialog" aria-modal="true" aria-labelledby="game-dialog-title">
        <img className="game-dialog-image" src={publicAsset(`assets/modal/${image}.png`)} alt="" aria-hidden="true" />
        <div className="game-dialog-copy">
          <h2 id="game-dialog-title">{title}</h2>
          <p>{subtitle}</p>
        </div>
        {children}
      </section>
    </div>
  )
}
