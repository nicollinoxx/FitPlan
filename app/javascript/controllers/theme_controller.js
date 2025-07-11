import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.media = window.matchMedia("(prefers-color-scheme: dark)")
    this.media.addEventListener("change", this.handler = () => this.#update())
  }

  disconnect() { this.media?.removeEventListener("change", this.handler) }

  toggle() {
    this.element.dataset.bsTheme = this.#nextTheme
    localStorage.setItem("theme", this.#nextTheme)
  }

  system() {
    this.element.dataset.bsTheme = this.#systemTheme
    localStorage.removeItem("theme")
  }

  #update() {
    if (!localStorage.getItem("theme")) { this.element.dataset.bsTheme = this.#systemTheme }
  }

  get #systemTheme() { return this.media.matches ? "dark" : "light" }
  get #nextTheme() { return localStorage.getItem("theme") === "dark" ? "light" : "dark" || "light" }
}
