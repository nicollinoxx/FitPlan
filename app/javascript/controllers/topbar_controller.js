import { Controller } from "@hotwired/stimulus"

// The navbar sticks to the top of the viewport, so anything else that sticks
// has to start below it. Its height is not a constant -- Bootstrap scales the
// brand with the viewport, and the menu grows when it expands -- so it is
// published as a variable and measured rather than guessed.
//
// Where the navbar is hidden, as in the native apps, this measures zero and
// everything sticks to the top, which is what those screens want.
export default class extends Controller {
  connect() {
    this.observer = new ResizeObserver(() => this.#publish())
    this.observer.observe(this.element)
  }

  disconnect() {
    this.observer.disconnect()
    document.documentElement.style.removeProperty("--topbar-height")
  }

  #publish() {
    document.documentElement.style.setProperty("--topbar-height", `${this.element.offsetHeight}px`)
  }
}
