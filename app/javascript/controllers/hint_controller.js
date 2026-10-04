import { Controller } from "@hotwired/stimulus"
import "bootstrap"

// Shows a card's explanation in the dialog it shares with every other card, so
// the page carries one dialog instead of one per card.
//
// Bootstrap is pinned as a UMD bundle, which under an importmap exports nothing
// and leaves its classes on the window, so this reaches for it there.
export default class extends Controller {
  static targets = ["dialog", "title", "body"]

  show({ params: { title, body } }) {
    this.titleTarget.textContent = title
    this.bodyTarget.textContent = body

    window.bootstrap.Modal.getOrCreateInstance(this.dialogTarget).show()
  }
}
