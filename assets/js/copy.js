// "Copy bio" on the About tab: copy the bio as plain text, so it pastes
// cleanly into a call-for-papers form. Labels come from data attributes, so
// they follow the page's language.
document.querySelectorAll('button.copy[data-copy]').forEach((button) => {
  const label = button.textContent
  button.addEventListener('click', async () => {
    const source = document.getElementById(button.dataset.copy)
    try {
      await navigator.clipboard.writeText(source.innerText.trim())
      button.textContent = button.dataset.copied
    } catch {
      // Clipboard API unavailable (http, old browser): select it for Ctrl+C.
      const range = document.createRange()
      range.selectNodeContents(source)
      getSelection().removeAllRanges()
      getSelection().addRange(range)
      button.textContent = button.dataset.selected
    }
    button.classList.add('done')
    setTimeout(() => { button.textContent = label; button.classList.remove('done') }, 1800)
  })
})
