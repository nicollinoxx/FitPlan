import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "icon"]

  toggle() {
    const isPassword = this.inputTarget.type === "password"

    this.#setTargetType(isPassword)
    this.#toggleIcon(isPassword)
  }

  #toggleIcon(isPassword) {
    this.iconTarget.classList.toggle("bi-eye", !isPassword)
    this.iconTarget.classList.toggle("bi-eye-slash", isPassword)
  }

  #setTargetType(isPassword) {
    this.inputTarget.type = isPassword ? "text" : "password"
  }
}
