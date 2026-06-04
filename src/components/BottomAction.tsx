import type { ReactNode } from 'react'

interface BottomActionProps {
  children: ReactNode
}

export default function BottomAction({ children }: BottomActionProps) {
  return <div className="bottom-action">{children}</div>
}
