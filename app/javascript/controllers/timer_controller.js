import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "display" ]
  static values = { seconds: Number }

  connect() {
    this.remainingTime = this.secondsValue
  }

  start() {
    if (this.interval) return
    this.interval = setInterval(() => {
      if (this.remainingTime <= 0) {
        this.stop()
        setTimeout(() => { alert("Rest Finished!") }, 100)
        return
      }
      this.remainingTime--
      this.updateDisplay()
    }, 1000)
  }

  pause() {
    clearInterval(this.interval)
    this.interval = null
  }

  stop() {
    this.pause()
    this.remainingTime = this.secondsValue
    this.updateDisplay()
  }

  updateDisplay() {
    this.displayTarget.textContent = `${this.remainingTime}s`
  }
}