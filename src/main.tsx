import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import App from './App'
import './styles.css'

document.head.insertAdjacentHTML(
  'beforeend',
  `<style>
    @font-face {
      font-family: 'Rotonda';
      src: url('${import.meta.env.BASE_URL}fonts/Rotonda-Bold.woff2') format('woff2');
      font-display: swap;
      font-style: normal;
      font-weight: 700;
    }
  </style>`,
)

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <App />
  </StrictMode>,
)
