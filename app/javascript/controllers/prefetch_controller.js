import { Controller } from "@hotwired/stimulus"

// A lazy frame starts loading the moment it scrolls into view, so with the
// server an ocean away the spinner is on screen for the whole round trip,
// every time. This starts the fetch while the frame is still below the fold,
// which usually leaves the next page already rendered by the time it is
// reached. Turbo loads a frame when its loading attribute turns eager.
export default class extends Controller {
  static values = { margin: { type: String, default: "1200px" } }

  connect() {
    this.observer = new IntersectionObserver(([entry]) => {
      if (entry.isIntersecting) this.#load()
    }, { rootMargin: this.marginValue })

    this.observer.observe(this.element)
  }

  disconnect() {
    this.observer.disconnect()
  }

  #load() {
    this.observer.disconnect()
    this.element.loading = "eager"
  }
}
