import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="theme"
export default class extends Controller {
  static targets = ["icon"]

  connect() {
    const theme = this.getlocalStorage()
    document.documentElement.setAttribute("data-bs-theme", theme), this.changeIcon(theme)
  }

  applyTheme() {
    const theme = this.getlocalStorage() === "light" ? "dark" : "light"
    document.documentElement.setAttribute("data-bs-theme", theme), this.setLocalStorage(theme)
    this.changeIcon(theme)
  }

  changeIcon(theme) {
    this.iconTargets.forEach((icon) => {
      icon.classList.toggle("bi-sun-fill", theme === "light")
      icon.classList.toggle("bi-moon-stars-fill", theme === "dark")
    })
  }

  getlocalStorage() {return localStorage.getItem("theme") || "light"}
  setLocalStorage(theme) {localStorage.setItem("theme", theme)}
}
