import type { ReactNode } from 'react'

interface ModalSheetProps {
  children: ReactNode
}

export default function ModalSheet({ children }: ModalSheetProps) {
  return (
    <div className="sheet-backdrop" role="presentation">
      <section className="sheet-panel" role="dialog" aria-modal="true">
        {children}
      </section>
    </div>
  )
}
