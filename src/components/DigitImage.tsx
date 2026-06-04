import { digitSrc } from '../game/digits'

interface DigitImageProps {
  value: number
  className?: string
  alt?: string
}

export default function DigitImage({ value, className, alt = String(value) }: DigitImageProps) {
  return <img className={className} src={digitSrc(value)} alt={alt} draggable={false} />
}
