import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

export default class extends Controller {
  static targets = ["list", "toggle"]
  static values = { resource: String }

  listTargetConnected(list) {
    list.sortable = Sortable.create(list, {
      draggable: "[data-sortable-url]",
      disabled: !this.sorting,
      forceFallback: true,
      delay: 150,
      delayOnTouchOnly: true,
      animation: 150,
      ghostClass: "opacity-25",
      onEnd: this.move.bind(this)
    })
  }

  listTargetDisconnected(list) {
    list.sortable.destroy()
  }

  toggleTargetConnected(toggle) {
    this.renderToggle(toggle)
  }

  toggle() {
    this.sorting = !this.sorting

    this.element.classList.toggle("sorting", this.sorting)
    this.listTargets.forEach(list => list.sortable.option("disabled", !this.sorting))
    this.toggleTargets.forEach(toggle => this.renderToggle(toggle))
  }

  renderToggle(toggle) {
    toggle.setAttribute("aria-pressed", Boolean(this.sorting))
    toggle.classList.toggle("btn-outline-secondary", !this.sorting)
    toggle.classList.toggle("btn-success", Boolean(this.sorting))
  }

  async move({ item, from: list, oldIndex, newIndex }) {
    if (oldIndex === newIndex) return

    const neighbor = newIndex > oldIndex ? item.previousElementSibling : item.nextElementSibling
    const from = Number(item.dataset.sortablePosition)
    const to = Number(neighbor.dataset.sortablePosition)

    const response = await fetch(item.dataset.sortableUrl, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content
      },
      body: JSON.stringify({ [this.resourceValue]: { position: to } })
    })

    if (response.ok) {
      this.shiftPositions(list, item, from, to)
    } else {
      Turbo.visit(window.location.href, { action: "replace" })
    }
  }

  // Mirrors Positionable so the cards keep matching the server after each move
  shiftPositions(list, item, from, to) {
    list.querySelectorAll("[data-sortable-position]").forEach(element => {
      let position = Number(element.dataset.sortablePosition)

      if (element === item)                                   position = to
      else if (to < from && position >= to && position < from) position += 1
      else if (to > from && position > from && position <= to) position -= 1

      element.dataset.sortablePosition = position
    })
  }
}
