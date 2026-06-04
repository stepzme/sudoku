import type { LucideIcon } from 'lucide-react'

interface MetricPillProps {
  title: string
  value: string
  icon: LucideIcon
}

export default function MetricPill({ title, value, icon: Icon }: MetricPillProps) {
  return (
    <div className="metric-pill">
      <span className="metric-title">
        <Icon size={13} strokeWidth={2.4} />
        {title}
      </span>
      <strong>{value}</strong>
    </div>
  )
}
