import { Controller } from "@hotwired/stimulus"

// Lays each change the model proposes over the workout or meal as it is now,
// field by field, so the preview shows exactly what saving would replace.
export default class extends Controller {
  static targets = ["list", "empty", "changeTemplate", "fieldTemplate"]
  static values = { labels: Object, charges: Object, color: String }

  render(changes, improving) {
    this.listTarget.replaceChildren(...changes.map(change => this.renderChange(change)))
    this.emptyTarget.hidden = !improving || changes.length > 0
  }

  renderChange({ before, after, reason }) {
    const element = this.changeTemplateTarget.content.cloneNode(true)
    const fields = Object.keys(after).filter(field => String(after[field]) !== String(before[field]))

    element.querySelector("[data-field='card']").classList.add(`pulse-suggested-${this.colorValue}`)
    element.querySelector("[data-field='name']").textContent = before.exercise ?? before.meal
    element.querySelector("[data-field='reason']").textContent = reason ?? ""
    element.querySelector("[data-field='fields']").append(...fields.map(field => this.renderField(field, before[field], after[field])))

    return element
  }

  renderField(field, before, after) {
    const element = this.fieldTemplateTarget.content.cloneNode(true)

    element.querySelector("[data-field='label']").textContent = this.labelsValue[field] ?? field
    element.querySelector("[data-field='before']").textContent = this.format(field, before)
    element.querySelector("[data-field='after']").textContent = this.format(field, after)

    return element
  }

  format(field, value) {
    if (value === null || value === undefined || value === "") return "—"
    if (field === "charge") return this.chargesValue[value] ?? value
    if (field === "interval") return `${value}s`
    if (field.endsWith("_g")) return `${value}g`

    return value
  }
}
