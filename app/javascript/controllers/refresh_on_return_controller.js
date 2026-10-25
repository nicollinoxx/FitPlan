import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails"

// Connecting to OpenRouter finishes in another tab, or in a Custom Tab in the
// native apps, so the page reloads when it is shown again to pick it up.
export default class extends Controller {
  connect() {
    document.addEventListener("visibilitychange", this.reload)
  }

  disconnect() {
    document.removeEventListener("visibilitychange", this.reload)
  }

  reload = () => {
    if (document.visibilityState === "visible") Turbo.visit(window.location.href, { action: "replace" })
  }
}
