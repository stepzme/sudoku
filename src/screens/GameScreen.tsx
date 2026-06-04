import { Eraser, Lightbulb, PauseCircle, Pencil, RotateCcw, Timer, Trophy, Undo2, XCircle } from 'lucide-react'
import { useEffect, useMemo, useState } from 'react'
import { Navigate, useNavigate, useParams } from 'react-router-dom'
import MetricPill from '../components/MetricPill'
import ModalSheet from '../components/ModalSheet'
import NumberPad from '../components/NumberPad'
import SudokuBoard from '../components/SudokuBoard'
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

  if (!level) return <Navigate to="/new" replace />

  return (
    <section className="game-screen">
      <header className="game-topbar">
        <button className="icon-text-button" type="button" onClick={() => navigate(-1)}>
          <Undo2 size={18} />
          Назад
        </button>
        <strong>
          {difficultyInfo[level.difficulty].title} · {level.number}
        </strong>
        <button className="icon-only-button" type="button" onClick={() => setShowPause(true)} aria-label="Пауза">
          <PauseCircle size={28} />
        </button>
      </header>

      <div className="metrics-row">
        <MetricPill title="Время" value={game.formattedTime} icon={Timer} />
        <MetricPill title="Ошибки" value={`${game.mistakes}/${game.mistakeLimit}`} icon={XCircle} />
        <MetricPill title="Подсказки" value={`${game.remainingHints}/${hintLimit}`} icon={Lightbulb} />
      </div>

      <SudokuBoard game={game} />

      <div className="tool-row">
        <ToolButton title="Отмена" icon={Undo2} disabled={!game.canUndo} onClick={game.undo} />
        <ToolButton title="Стереть" icon={Eraser} disabled={!game.canErase} onClick={game.erase} />
        <ToolButton title="Заметки" icon={Pencil} selected={game.notesMode} onClick={game.toggleNotes} />
        <ToolButton title="Подсказка" icon={Lightbulb} disabled={!game.canUseHint} onClick={game.useHint} />
      </div>

      <NumberPad
        isNotesMode={game.notesMode}
        remainingCount={game.remainingPlacements}
        isDisabled={game.isNumberExhausted}
        onTap={game.enter}
      />

      {showPause ? (
        <ModalSheet>
          <PauseCircle className="sheet-icon blue" size={64} />
          <h2>Пауза</h2>
          <p>
            {difficultyInfo[level.difficulty].title} · Уровень {level.number}
          </p>
          <button className="sheet-primary" type="button" onClick={() => setShowPause(false)}>
            Продолжить
          </button>
          <button className="sheet-secondary destructive" type="button" onClick={game.restart}>
            <RotateCcw size={18} />
            Начать заново
          </button>
          <button
            className="sheet-secondary"
            type="button"
            onClick={() => {
              setShowPause(false)
              navigate('/')
            }}
          >
            Сохранить и выйти
          </button>
        </ModalSheet>
      ) : null}

      {game.isComplete ? (
        <ModalSheet>
          <Trophy className="sheet-icon yellow" size={72} fill="currentColor" />
          <h2>Уровень пройден!</h2>
          <p>
            {difficultyInfo[level.difficulty].title} · Уровень {level.number}
          </p>
          <div className="result-box">
            <span>Время <strong>{game.formattedTime}</strong></span>
            <span>Ошибки <strong>{game.mistakes}</strong></span>
            <span>Подсказки <strong>{game.hintsUsed}</strong></span>
          </div>
          <button className="sheet-primary" type="button" onClick={() => navigate('/')}>
            Готово
          </button>
        </ModalSheet>
      ) : null}

      {game.isFailed ? (
        <ModalSheet>
          <XCircle className="sheet-icon red" size={64} />
          <h2>Игра окончена</h2>
          <p>Вы достигли лимита ошибок для этой сложности.</p>
          <button
            className="sheet-primary"
            type="button"
            onClick={() => {
              game.restart()
            }}
          >
            Начать заново
          </button>
          <button className="sheet-secondary" type="button" onClick={() => navigate('/')}>
            Выйти
          </button>
        </ModalSheet>
      ) : null}
    </section>
  )
}

interface ToolButtonProps {
  title: string
  icon: typeof Undo2
  selected?: boolean
  disabled?: boolean
  onClick: () => void
}

function ToolButton({ title, icon: Icon, selected = false, disabled = false, onClick }: ToolButtonProps) {
  return (
    <button className={selected ? 'tool-button is-selected' : 'tool-button'} type="button" disabled={disabled} onClick={onClick}>
      <Icon size={21} strokeWidth={2.3} />
      <span>{title}</span>
    </button>
  )
}
