import { Controller } from "@hotwired/stimulus";
import { Turbo } from "@hotwired/turbo-rails";

export default class extends Controller {
  static values = { url: String, refresh: Boolean };

  connect() {
    this.handleSubmitEndBound = this.handleSubmitEnd.bind(this);
    this.form = this.element.closest("form");

    if (this.form) {
      this.form.addEventListener("turbo:submit-end", this.handleSubmitEndBound);
    } else {
      this.#redirect();
    }
  }

  disconnect() {
    this.form?.removeEventListener("turbo:submit-end", this.handleSubmitEndBound);
  }

  handleSubmitEnd(event) {
    if (event.detail.success) this.#redirect();
  }

  #redirect() {
    if (!this.hasUrlValue) return;
    Turbo.visit(this.urlValue || window.location.href, this.refreshValue ? { action: "replace" } : {});
  }
}
