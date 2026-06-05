import { publicAsset } from '../game/assets'
import type { Difficulty } from '../game/types'

export type FigmaIconName = 'chevron-left' | 'chevron-right' | 'close' | 'erase' | 'hint' | 'notes' | 'pause' | 'undo'

interface FigmaIconProps {
  className?: string
  name: FigmaIconName
  theme: Difficulty
}

export default function FigmaIcon({ className, name, theme }: FigmaIconProps) {
  return (
    <img
      className={className}
      src={publicAsset(`assets/ui/figma-icons/${theme}/${name}.svg`)}
      alt=""
      aria-hidden="true"
      draggable={false}
    />
  )
}
