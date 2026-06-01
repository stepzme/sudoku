import { ChevronLeft } from 'lucide-react'
import { useNavigate } from 'react-router-dom'

export default function BackButton({ label = 'Назад' }: { label?: string }) {
  const navigate = useNavigate()

  return (
    <button className="nav-back" type="button" onClick={() => navigate(-1)}>
      <ChevronLeft size={19} strokeWidth={2.4} />
      <span>{label}</span>
    </button>
  )
}
