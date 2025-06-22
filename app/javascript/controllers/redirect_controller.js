import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails"

// Connects to data-controller="redirect"
// To mobiles navigate to a specific URL after a form submission.
export default class extends Controller {
  static values = { url: String }

  connect() {
    this.element.addEventListener("turbo:submit-end", this.handleSubmitEnd.bind(this))
  }

  disconnect() {
    this.element.removeEventListener("turbo:submit-end", this.handleSubmitEnd.bind(this))
  }

  handleSubmitEnd(event) {
    if (event.detail.success && this.hasUrlValue) {Turbo.visit(this.urlValue)}
  }
}
