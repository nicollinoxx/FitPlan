import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails"

// While the app waits on a sign in finishing in another browser, the page asks
// every few seconds. The asking itself trades the code for a session (see
// SessionHandoff), and the page follows wherever that redirects. It cannot wait
// to be shown again instead: iOS keeps it visible under the Safari sheet.
//
// One question at a time, to a route that renders nothing, so a slow server is
// never asked again before it answered.
export default class extends Controller {
  static values = { url: String, interval: { type: Number, default: 2000 }, attempts: { type: Number, default: 150 } }

  connect() {
    this.schedule()
  }

  disconnect() {
    clearTimeout(this.timer)
  }

  schedule() {
    if (this.attemptsValue-- > 0) this.timer = setTimeout(this.check, this.intervalValue)
  }

  check = async () => {
    const response = await fetch(this.urlValue).catch(() => null)

    if (response?.redirected) {
      Turbo.visit(response.url, { action: "replace" })
    } else if (this.element.isConnected) {
      this.schedule()
    }
  }
}
