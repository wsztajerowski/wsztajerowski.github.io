// "Copy" buttons in the About section: copy the bio as plain text, so it pastes
// cleanly into a call-for-papers form.
document.querySelectorAll('button.copy[data-copy]').forEach((button) => {
  button.addEventListener('click', async () => {
    const label = button.textContent
    const source = document.getElementById(button.dataset.copy)
    const text = source.innerText.trim()
    try {
      await navigator.clipboard.writeText(text)
      button.textContent = 'Copied'
    } catch {
      // Clipboard API unavailable (http, old browser): select it for Ctrl+C.
      const range = document.createRange()
      range.selectNodeContents(source)
      getSelection().removeAllRanges()
      getSelection().addRange(range)
      button.textContent = 'Selected'
    }
    button.classList.add('done')
    setTimeout(() => { button.textContent = label; button.classList.remove('done') }, 1800)
  })
})
