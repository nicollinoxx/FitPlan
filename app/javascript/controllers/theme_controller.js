import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["switch"]

  connect() {
    this.media = window.matchMedia("(prefers-color-scheme: dark)")
    this.media.addEventListener("change", this.handler = () => this.#update()); this.#update()
  }

  disconnect() {
    this.media?.removeEventListener("change", this.handler)
  }

  toggle() {
    const next = this.#nextTheme
    this.element.dataset.bsTheme = next
    localStorage.setItem("theme", next)
    this.#syncSwitch(next)
  }

  system() {
    const next = this.#systemTheme
    this.element.dataset.bsTheme = next
    localStorage.removeItem("theme")
    this.#syncSwitch(next)
  }

  #update() {
    const storedTheme = localStorage.getItem("theme");
    const theme = storedTheme || this.#systemTheme
    this.element.dataset.bsTheme = theme
    this.#syncSwitch(theme)
  }

  #syncSwitch(theme) {
    if (this.hasSwitchTarget) this.switchTarget.checked = theme === "dark"
  }

  get #systemTheme() {
    return this.media.matches ? "dark" : "light"
  }

  get #nextTheme() {
    return this.element.dataset.bsTheme === "dark" ? "light" : "dark";
  }
}
