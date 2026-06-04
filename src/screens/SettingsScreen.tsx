import { useState } from 'react'
import BackButton from '../components/BackButton'
import ModalSheet from '../components/ModalSheet'
import { useProgress } from '../game/progress'
import type { GameSettings } from '../game/types'

export default function SettingsScreen({ totalLevels }: { totalLevels: number }) {
  const progress = useProgress()
  const [confirmReset, setConfirmReset] = useState(false)

  const update = (patch: Partial<GameSettings>) => {
    progress.updateSettings({ ...progress.settings, ...patch })
  }

  return (
    <section className="screen">
      <BackButton />
      <h1 className="screen-title">Настройки</h1>

      <h2 className="section-title">Игра</h2>
      <div className="list-card">
        <ToggleRow
          title="Подсвечивать связанные клетки"
          checked={progress.settings.highlightPeers}
          onChange={(highlightPeers) => update({ highlightPeers })}
        />
        <ToggleRow
          title="Автоматически удалять заметки"
          checked={progress.settings.autoRemoveNotes}
          onChange={(autoRemoveNotes) => update({ autoRemoveNotes })}
        />
        <ToggleRow
          title="Тактильный отклик"
          checked={progress.settings.haptics}
          onChange={(haptics) => update({ haptics })}
        />
      </div>

      <h2 className="section-title">О приложении</h2>
      <div className="list-card">
        <InfoRow title="Уровней" value={String(totalLevels)} />
        <InfoRow title="Сложности" value="Легко, Средне, Сложно" />
      </div>

      <button className="danger-wide" type="button" onClick={() => setConfirmReset(true)}>
        Сбросить прогресс
      </button>

      {confirmReset ? (
        <ModalSheet>
          <h2>Сбросить прогресс?</h2>
          <p>Пройденные уровни, активная игра и настройки вернутся к начальному состоянию.</p>
          <button
            className="sheet-primary destructive-bg"
            type="button"
            onClick={() => {
              progress.resetProgress()
              setConfirmReset(false)
            }}
          >
            Сбросить
          </button>
          <button className="sheet-secondary" type="button" onClick={() => setConfirmReset(false)}>
            Отмена
          </button>
        </ModalSheet>
      ) : null}
    </section>
  )
}

function ToggleRow({
  title,
  checked,
  onChange,
}: {
  title: string
  checked: boolean
  onChange: (checked: boolean) => void
}) {
  return (
    <label className="toggle-row">
      <span>{title}</span>
      <input type="checkbox" checked={checked} onChange={(event) => onChange(event.currentTarget.checked)} />
      <span className="switch" />
    </label>
  )
}

function InfoRow({ title, value }: { title: string; value: string }) {
  return (
    <div className="list-row">
      <span>{title}</span>
      <strong>{value}</strong>
    </div>
  )
}
