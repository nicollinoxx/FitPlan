import { Controller } from "@hotwired/stimulus"
import { get } from "https://esm.sh/@rails/request.js@0.0.12?standalone"
import TomSelect from "https://esm.sh/tom-select@2.4.3?standalone"

export default class extends Controller {
  static values = {
    url: String,
    optionCreate: { type: String, default: "Add" },
    noResults: { type: String, default: "No results found" }
  }

  connect() {
    const settings = this.element.nodeName === "INPUT" ? this.#inputSettings : this.#selectSettings
    this.tomSelect = new TomSelect(this.element, settings)
  }

  disconnect() {
    this.tomSelect?.destroy()
  }

  async load(query, callback) {
    const response = await get(this.urlValue, {
      responseKind: "json",
      query: { q: query }
    })

    const json = await response.json
    callback(json)
  }

  get #inputSettings() {
    return {
      render: this.#render,
      load: this.#loadSetting,
      persist: false,
      createOnBlur: true,
      create: true,
      plugins: ['remove_button']
    }
  }

  get #selectSettings() {
    return {
      render: this.#render,
      load: this.#loadSetting,
      plugins: ['remove_button']
    }
  }

  get #render() {
    return {
      option_create: (data, escape) =>`<div class="create">${this.optionCreateValue} <b>${escape(data.input)}</b>...</div>`,
      no_results: () => `<div class="no-results">${this.noResultsValue}</div>`}
  }

  get #loadSetting() {
    return this.hasUrlValue && this.load
  }
}
