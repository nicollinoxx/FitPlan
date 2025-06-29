import { Controller } from "@hotwired/stimulus"

const COLOR_SCHEME_DARK = '(prefers-color-scheme: dark)';

export default class extends Controller {
  static targets = ["icon"]

  connect() {
    this.#setColorMode(this.#localStorageTheme || this.#systemColorScheme)
    if (!this.#localStorageTheme) { this.#setupSystemColorSchemeListener() }
  }

  toggleTheme() {
    const theme = this.#localStorageTheme === 'dark' ? 'light' : 'dark'
    this.#setColorMode(theme), this.#setLocalStorage(theme)
  }

  setSystemMode() {
    this.#preferSystemColorScheme(),
    this.#setColorMode(this.#systemColorScheme)
  }

  get #systemColorScheme() { return window.matchMedia(COLOR_SCHEME_DARK).matches ? "dark" : "light" }
  get #localStorageTheme() { return localStorage.getItem('theme') }

  #preferSystemColorScheme() { localStorage.removeItem("theme") }
  #setLocalStorage(theme) { localStorage.setItem("theme", theme) }
  #setColorMode(theme) { document.documentElement.setAttribute("data-bs-theme", theme) }

  #setupSystemColorSchemeListener() {
    window.matchMedia(COLOR_SCHEME_DARK).addEventListener("change", () => { this.#setColorMode(this.#systemColorScheme) })
  }
}
