import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails"

export default class extends Controller {
  sync({ target }) {
    if (!target.src) return

    const { history } = Turbo.session
    history.replace(new URL(target.src, window.location.href), history.restorationIdentifier)
  }
}
