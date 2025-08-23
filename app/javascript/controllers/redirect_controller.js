import { Controller } from "@hotwired/stimulus";
import { Turbo } from "@hotwired/turbo-rails";

export default class extends Controller {
  static values = { url: String, refresh: Boolean };

  connect() {
    this.handleSubmitEndBound = this.handleSubmitEnd.bind(this);
    this.target = this.element.closest("form") || this.element;
    this.target.addEventListener("turbo:submit-end", this.handleSubmitEndBound);
  }

  disconnect() {
    this.target.removeEventListener("turbo:submit-end", this.handleSubmitEndBound);
  }

  handleSubmitEnd(event) {
    if (!event.detail.success || !this.hasUrlValue) return;
    this.#redirect()(this.urlValue || window.location.href);
  }

  #redirect()   { return this.refreshValue ? this.#refresh : this.#visit; }
  #visit(url)   { Turbo.visit(url); }
  #refresh(url) { Turbo.visit(url, { action: "replace" }); }
}
