import { Controller } from "@hotwired/stimulus";
import { Turbo } from "@hotwired/turbo-rails";

export default class extends Controller {
  static values = { url: String };

  connect() {
    this.handleSubmitEndBound = this.handleSubmitEnd.bind(this);
    this.target = this.element.closest("form") || this.element;
    this.target.addEventListener("turbo:submit-end", this.handleSubmitEndBound);
  }

  disconnect() {
    this.target.removeEventListener("turbo:submit-end", this.handleSubmitEndBound);
  }

  handleSubmitEnd(event) {
    if (event.detail.success && this.hasUrlValue) {Turbo.visit(this.urlValue);}
  }
}
