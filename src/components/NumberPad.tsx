import { digitColor, digitOutline } from '../game/digits'
import DigitImage from './DigitImage'

interface NumberPadProps {
  isNotesMode: boolean
  remainingCount: (number: number) => number
  isDisabled: (number: number) => boolean
  onTap: (number: number) => void
}

export default function NumberPad({ isNotesMode, remainingCount, isDisabled, onTap }: NumberPadProps) {
  return (
    <div className="number-pad" aria-label="Цифры">
      {Array.from({ length: 9 }, (_, index) => {
        const number = index + 1
        const disabled = isDisabled(number)

        return (
          <button
            className={isNotesMode ? 'number-button notes-active' : 'number-button'}
            type="button"
            key={number}
            disabled={disabled}
            onClick={() => onTap(number)}
            style={{
              '--digit-color': digitColor(number),
              '--digit-outline': digitOutline(number),
            } as React.CSSProperties}
          >
            <DigitImage value={number} className="pad-digit" alt="" />
            <span className="remaining-count">{remainingCount(number)}</span>
          </button>
        )
      })}
    </div>
  )
}
