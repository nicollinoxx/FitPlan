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
        this.finish() 
        return
      }
      this.remainingTime--
      this.updateDisplay()
    }, 1000)
  }

  finish() {
    this.stop()
    
    const completionBtn = this.element.closest('.border').querySelector('.completion-button')
    
    if (completionBtn) {
      completionBtn.click()
    } else {

      setTimeout(() => { alert("Rest Finished!") }, 100)
    }
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