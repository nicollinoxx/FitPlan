import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails"
import consumer from "channels/consumer"

const TIMEOUT = 3 * 60 * 1000

export default class extends Controller {
  static targets = ["form", "submit", "questions", "hint", "usage", "dietOnly", "workoutOnly", "error", "preview", "sheets", "sheetTemplate", "workoutTemplate", "dietTemplate"]
  static values = { saveUrl: String, existing: Boolean, sheetType: String, charges: Object, errorMessage: String, modelErrorMessage: String }
  static outlets = ["recommendations--diff"]

  connect() {
    const stored = this.readRecommendation()
    if (!stored) return

    this.recommendation = stored
    this.render({ scroll: false })
  }

  toggle() {
    const data = new FormData(this.formTarget)
    const kind = data.get("recommendation[kind]")
    const choice = data.get("recommendation[mode]") ?? kind

    this.dietOnlyTarget.hidden = kind === "workout"
    this.workoutOnlyTargets.forEach(target => target.hidden = kind === "diet")
    this.hintTargets.forEach(hint => hint.hidden = hint.dataset.choice !== choice)
  }

  // The suggestion is made by a job and arrives on RecommendationChannel, so the
  // page listens before it asks, and knows its answer by the token it sent.
  async generate() {
    const token = crypto.randomUUID()
    const data = new FormData(this.formTarget)

    this.recommendation = null
    this.clearStoredRecommendation()
    this.stopListening()
    this.errorTarget.hidden = true
    this.loading(true)
    data.append("token", token)

    try {
      await this.listen(token)
      await this.request(this.formTarget.action, data)
      this.timeout = setTimeout(() => this.received({ failed: true }), TIMEOUT)
    } catch {
      this.received({ failed: true })
    }
  }

  listen(token) {
    return new Promise(resolve => {
      this.subscription = consumer.subscriptions.create("RecommendationChannel", {
        connected: resolve,
        received: message => { if (message.token === token) this.received(message) }
      })
    })
  }

  received({ recommendation, failed }) {
    this.stopListening()
    this.loading(false)
    this.usageTarget.reload()

    if (failed) return this.failWithModel()

    this.recommendation = recommendation
    this.storeRecommendation(recommendation)
    this.render()
  }

  stopListening() {
    clearTimeout(this.timeout)
    this.subscription?.unsubscribe()
    this.subscription = null
  }

  disconnect() {
    this.stopListening()
  }

  async save() {
    if (!this.recommendation) return this.fail()

    try {
      const method = this.recommendation.changes ? "PATCH" : "POST"
      const response = await this.request(this.saveUrlValue, JSON.stringify(this.payload), { "Content-Type": "application/json" }, method)
      const { location } = await response.json()
      this.clearStoredRecommendation()
      Turbo.visit(location)
    } catch {
      this.fail()
    }
  }

  async discard({ currentTarget }) {
    if (!await Turbo.config.forms.confirm(currentTarget.dataset.turboConfirm)) return

    this.recommendation = null
    this.clearStoredRecommendation()
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

  render({ scroll = true } = {}) {
    const { sheets = [], changes } = this.recommendation

    this.errorTarget.hidden = true
    this.sheetsTarget.replaceChildren(...sheets.map(sheet => this.renderSheet(sheet)))
    if (this.hasRecommendationsDiffOutlet) this.recommendationsDiffOutlet.render(changes ?? [], Boolean(changes))
    this.previewTarget.hidden = false
    this.collapse(true)
    if (scroll) this.previewTarget.scrollIntoView({ behavior: "smooth" })
  }

  get recommendationStorageKey() {
    return `fitplan:recommendation:${window.location.pathname}${window.location.search}`
  }

  storeRecommendation(recommendation) {
    try {
      sessionStorage.setItem(this.recommendationStorageKey, JSON.stringify({ recommendation, savedAt: Date.now() }))
    } catch {
      // The in-memory recommendation remains available if browser storage is disabled.
    }
  }

  readRecommendation() {
    try {
      const stored = JSON.parse(sessionStorage.getItem(this.recommendationStorageKey))
      if (!stored?.recommendation || Date.now() - stored.savedAt > 30 * 60 * 1000) {
        this.clearStoredRecommendation()
        return null
      }
      return stored.recommendation
    } catch {
      return null
    }
  }

  clearStoredRecommendation() {
    try {
      sessionStorage.removeItem(this.recommendationStorageKey)
    } catch {
      // Ignore unavailable browser storage.
    }
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
