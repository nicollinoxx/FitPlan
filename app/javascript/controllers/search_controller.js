import { Controller } from "@hotwired/stimulus"

const DEBOUNCE_DELAY = 300

export default class extends Controller {
  connect() {
    this.submitTimeout = null
  }

  disconnect() {
    clearTimeout(this.submitTimeout)
  }

  submit() {
    clearTimeout(this.submitTimeout)

    this.submitTimeout = setTimeout(() => {
      this.element.requestSubmit()
    }, DEBOUNCE_DELAY)
  }
}