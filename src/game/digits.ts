const digitColors: Record<number, string> = {
  1: '#5bbcd8',
  2: '#c75277',
  3: '#f6c7d0',
  4: '#e9c1d9',
  5: '#0065ab',
  6: '#7e5695',
  7: '#e26913',
  8: '#f1a300',
  9: '#141213',
}

const digitOutlines: Record<number, string> = {
  1: '#48a9c5',
  2: '#c85378',
  3: '#e38094',
  4: '#d6aec6',
  5: '#0066ac',
  6: '#7f5796',
  7: '#e36913',
  8: '#e79900',
  9: '#333333',
}

export function digitColor(number: number) {
  return digitColors[number] ?? '#007aff'
}

export function digitOutline(number: number) {
  return digitOutlines[number] ?? '#333333'
}

export function digitSrc(number: number) {
  return `${import.meta.env.BASE_URL}digits/${number}.png`
}
