import type { ReactNode } from 'react'
import { Link } from 'react-router-dom'

interface ScreenHeaderAction {
  icon: ReactNode
  label: string
  onClick?: () => void
  to?: string
}

interface ScreenHeaderProps {
  className?: string
  leftAction: ScreenHeaderAction
  rightAction: ScreenHeaderAction
  status?: ReactNode
  subtitle: ReactNode
  title: ReactNode
}

export default function ScreenHeader({ className, leftAction, rightAction, status, subtitle, title }: ScreenHeaderProps) {
  return (
    <header className={['screen-header', className].filter(Boolean).join(' ')}>
      <ScreenHeaderActionButton action={leftAction} side="left" />

      <div className="screen-title-card">
        <h1>{title}</h1>
        <p>{subtitle}</p>
      </div>

      <ScreenHeaderActionButton action={rightAction} side="right" />

      {status ? <div className="screen-header-status">{status}</div> : null}
    </header>
  )
}

function ScreenHeaderActionButton({ action, side }: { action: ScreenHeaderAction; side: 'left' | 'right' }) {
  const className = `round-theme-button screen-header-action is-${side}`

  if (action.to) {
    return (
      <Link className={className} to={action.to} aria-label={action.label}>
        {action.icon}
      </Link>
    )
  }

  return (
    <button className={className} type="button" onClick={action.onClick} aria-label={action.label}>
      {action.icon}
    </button>
  )
}
