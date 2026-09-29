// About section: show one bio language at a time behind the PL | EN switch.
// The page renders every language, so without this script all stay visible.
const langSwitch = document.querySelector('.lang-switch')
if (langSwitch) {
  const bios = document.querySelectorAll('.bio[data-lang]')
  const buttons = langSwitch.querySelectorAll('button[data-lang]')
  const show = (lang) => {
    bios.forEach((bio) => { bio.hidden = bio.dataset.lang !== lang })
    buttons.forEach((b) => b.setAttribute('aria-pressed', String(b.dataset.lang === lang)))
  }
  buttons.forEach((b) => b.addEventListener('click', () => show(b.dataset.lang)))
  langSwitch.hidden = false
  show(buttons[0].dataset.lang)
}
