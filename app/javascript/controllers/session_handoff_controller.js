import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails"

// While the app waits on a sign in finishing in another browser, the page asks
// every few seconds. The asking itself trades the code for a session (see
// SessionHandoff), and the page follows wherever that redirects. It cannot wait
// to be shown again instead: iOS keeps it visible under the Safari sheet.
export default class extends Controller {
  static values = { interval: { type: Number, default: 2000 }, attempts: { type: Number, default: 150 } }

  connect() {
    this.timer = setInterval(this.check, this.intervalValue)
  }

  disconnect() {
    clearInterval(this.timer)
  }

  check = async () => {
    if (--this.attemptsValue < 0) return this.disconnect()

    const response = await fetch(window.location.href, { method: "HEAD" })

    if (response.redirected) {
      this.disconnect()
      Turbo.visit(response.url, { action: "replace" })
    }
  }
}
