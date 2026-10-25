import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails"

export default class extends Controller {
  static targets = ["form", "submit", "questions", "usage", "dietOnly", "error", "preview", "sheets", "sheetTemplate", "workoutTemplate", "dietTemplate"]
  static values = { saveUrl: String, existing: Boolean, sheetType: String, charges: Object, errorMessage: String, modelErrorMessage: String }
  static outlets = ["recommendations--diff"]

  toggle() {
    const kind = new FormData(this.formTarget).get("recommendation[kind]")
    this.dietOnlyTarget.hidden = kind === "workout"
  }

  async generate() {
    this.errorTarget.hidden = true
    this.loading(true)

    try {
      const response = await this.request(this.formTarget.action, new FormData(this.formTarget))
      this.recommendation = await response.json()
      this.render()
    } catch {
      this.failWithModel()
    } finally {
      this.loading(false)
      this.usageTarget.reload()
    }
  }

  async save() {
    try {
      const method = this.recommendation.changes ? "PATCH" : "POST"
      const response = await this.request(this.saveUrlValue, JSON.stringify(this.payload), { "Content-Type": "application/json" }, method)
      const { location } = await response.json()
      Turbo.visit(location)
    } catch {
      this.fail()
    }
  }

  async discard({ currentTarget }) {
    if (!await Turbo.config.forms.confirm(currentTarget.dataset.turboConfirm)) return

    this.recommendation = null
    this.previewTarget.hidden = true
    this.collapse(false)
  }

  collapse(collapsed) {
    const questions = window.bootstrap.Collapse.getOrCreateInstance(this.questionsTarget, { toggle: false })
    collapsed ? questions.hide() : questions.show()
  }

  async request(url, body, headers = {}, method = "POST") {
    const response = await fetch(url, {
      method,
      headers: { "Accept": "application/json", "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content, ...headers },
      body
    })

    if (!response.ok) throw new Error(response.statusText)
    return response
  }

  get payload() {
    const { changes } = this.recommendation

    if (changes) return { [`${this.sheetTypeValue}s`]: changes.map(({ id, after }) => ({ id, ...after })) }
    if (!this.existingValue) return { sheets: this.recommendation.sheets }

    const [sheet] = this.recommendation.sheets
    return { [`${sheet.sheet_type}s`]: sheet[`${sheet.sheet_type}s`] }
  }

  render() {
    const { sheets = [], changes } = this.recommendation

    this.errorTarget.hidden = true
    this.sheetsTarget.replaceChildren(...sheets.map(sheet => this.renderSheet(sheet)))
    if (this.hasRecommendationsDiffOutlet) this.recommendationsDiffOutlet.render(changes ?? [], Boolean(changes))
    this.previewTarget.hidden = false
    this.collapse(true)
    this.previewTarget.scrollIntoView({ behavior: "smooth" })
  }

  renderSheet(sheet) {
    const element = this.sheetTemplateTarget.content.cloneNode(true)
    const header = element.querySelector("[data-field='header']")
    const color = sheet.sheet_type === "workout" ? "success" : "orange"

    header.hidden = this.existingValue
    header.classList.add(`border-${color}`, `pulse-suggested-${color}`)
    this.fill(element, { name: sheet.name, description: sheet.description })

    const items = sheet.sheet_type === "workout"
      ? sheet.workouts.map(workout => this.renderWorkout(workout))
      : sheet.diets.map(diet => this.renderDiet(diet))

    element.querySelector("[data-field='items']").append(...items)
    return element
  }

  renderWorkout(workout) {
    const element = this.workoutTemplateTarget.content.cloneNode(true)

    return this.fill(element, {
      ...workout,
      interval: this.formatInterval(workout.interval),
      charge: this.chargesValue[workout.charge] ?? workout.charge
    })
  }

  renderDiet(diet) {
    const element = this.dietTemplateTarget.content.cloneNode(true)
    const calories = (diet.protein_g * 4) + (diet.carbohydrate_g * 4) + (diet.fat_g * 9)

    return this.fill(element, {
      ...diet,
      protein_g: `${diet.protein_g}g`,
      carbohydrate_g: `${diet.carbohydrate_g}g`,
      fat_g: `${diet.fat_g}g`,
      calories: Math.round(calories)
    })
  }

  fill(element, fields) {
    element.querySelectorAll("[data-field]").forEach(node => {
      if (node.dataset.field in fields) node.textContent = fields[node.dataset.field] ?? ""
    })
    return element
  }

  formatInterval(seconds = 0) {
    const pad = number => String(number).padStart(2, "0")
    return `${pad(Math.floor(seconds / 60))}:${pad(seconds % 60)}`
  }

  loading(loading) {
    this.submitTargets.forEach(submit => {
      submit.disabled = loading
      submit.querySelector("[data-idle]").hidden = loading
      submit.querySelector("[data-busy]").hidden = !loading
    })
  }

  get modelName() {
    return this.formTarget.elements["recommendation[model]"].selectedOptions[0].text
  }

  failWithModel() {
    const [before, after] = this.modelErrorMessageValue.split("%{model}")
    const model = document.createElement("strong")

    model.className = "text-body"
    model.textContent = this.modelName

    this.fail()
    this.errorTarget.replaceChildren(before, model, after)
  }

  fail(message = this.errorMessageValue) {
    this.errorTarget.textContent = message
    this.errorTarget.hidden = false
    this.errorTarget.scrollIntoView({ behavior: "smooth", block: "center" })
  }
}
