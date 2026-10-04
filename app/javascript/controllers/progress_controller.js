import { Controller } from "@hotwired/stimulus"

// Grows the bar from empty once it is on screen, so it fills in like the charts
// below it instead of being painted already finished.
export default class extends Controller {
  static values = { percentage: Number }

  connect() {
    requestAnimationFrame(() => this.element.style.width = `${this.percentageValue}%`)
  }
}
