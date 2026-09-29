// Light/dark switch. Until the visitor chooses, the page follows the system
// setting (CSS prefers-color-scheme); a choice is stored and re-applied by the
// inline script in <head> before first paint.
const toggle = document.querySelector('.theme-toggle')
if (toggle) {
  const media = matchMedia('(prefers-color-scheme: dark)')
  const current = () => document.documentElement.dataset.theme || (media.matches ? 'dark' : 'light')
  const label = () => {
    const next = current() === 'dark' ? toggle.dataset.labelLight : toggle.dataset.labelDark
    toggle.setAttribute('aria-label', next)
    toggle.title = next
  }
  toggle.addEventListener('click', () => {
    const theme = current() === 'dark' ? 'light' : 'dark'
    document.documentElement.dataset.theme = theme
    try { localStorage.setItem('theme', theme) } catch (e) {}
    label()
  })
  media.addEventListener('change', label)
  label()
}
