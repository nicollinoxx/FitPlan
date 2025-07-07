import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.listener = () => this.#applyTheme(this.#system)
    matchMedia('(prefers-color-scheme: dark)').addEventListener("change", this.listener)
    this.#applyTheme(this.#current)
  }

  disconnect() {
    matchMedia('(prefers-color-scheme: dark)').removeEventListener("change", this.listener)
  }

  toggleTheme() {
    this.#applyTheme(this.#current === 'dark' ? 'light' : 'dark')
  }

  setSystemTheme() {
    this.#applyTheme(this.#system)
  }

  get #current() {
    return document.cookie.match(/theme=(light|dark)/)?.[1] || this.#system
  }

  get #system() {
    return matchMedia('(prefers-color-scheme: dark)').matches ? "dark" : "light"
  }

  #applyTheme(theme) {
    document.cookie = `theme=${theme}; path=/; max-age=31536000; SameSite=Lax`
    document.documentElement.dataset.bsTheme = theme
  }
}
