# Sudoku PWA

Web/PWA version of the Sudoku app.

## Commands

- `npm run dev` - start local dev server.
- `npm run build` - type-check and build production PWA.
- `npm run build:pages` - build for GitHub Pages under `/sudoku/`.
- `npm run lint` - run ESLint.
- `npm test` - run unit tests.

## Notes

- Levels are loaded from `public/levels.json`.
- Digit images are copied from the native app into `public/digits`.
- Progress, active game and settings are stored locally on the device.
- `dev/generate_levels.swift` is kept as an internal generator reference.
