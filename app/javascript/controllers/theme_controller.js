import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["icon"]

  connect() {
    this.#applyTheme(this.#current)
    this.#setupSystemColorSchemeListener()
  }

  toggleTheme() {
    const theme = this.#current === 'dark' ? 'light' : 'dark'
    localStorage.setItem("theme", theme)
    this.#applyTheme(theme)
  }

  setSystemTheme() {
    localStorage.removeItem("theme")
    this.#applyTheme(this.#system)
  }

  get #current() { return localStorage.getItem('theme') || this.#system }
  get #system() { return matchMedia('(prefers-color-scheme: dark)').matches ? "dark" : "light" }

  #applyTheme(theme) { document.documentElement.setAttribute("data-bs-theme", theme) }

  #setupSystemColorSchemeListener() {
    if (!localStorage.getItem('theme')) {
      matchMedia('(prefers-color-scheme: dark)').addEventListener("change", () => this.#applyTheme(this.#system))
    }
  }
}
