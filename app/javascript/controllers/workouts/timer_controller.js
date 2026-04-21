import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["display"]
  static values = { seconds: Number }

  connect() {
    this.remaining = this.secondsValue
    this.render()
  }

  start() {
    if (this.timer) return

    this.timer = setInterval(() => {
      if (--this.remaining < 0) return this.finish()

      this.render()
    }, 1000)
  }

  pause() {
    clearInterval(this.timer)
    this.timer = null
  }

  stop() {
    this.pause()
    this.remaining = this.secondsValue
    this.render()
  }

  finish() {
    this.stop()
    this.element.querySelector(".completion-button")?.click()
  }

  render() {
    this.displayTarget.textContent = `${this.remaining}s`
  }
}
