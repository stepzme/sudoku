export function publicAsset(path: string) {
  return `${import.meta.env.BASE_URL}${path.replace(/^\//, '')}`
}

export const homeCharacterCount = 9

export function homeCharacterSrc(index: number) {
  return publicAsset(`assets/home/character-${index}.png`)
}
