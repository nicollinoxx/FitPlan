import { Controller } from "@hotwired/stimulus";
import { Turbo } from "@hotwired/turbo-rails";

export default class extends Controller {
  connect() {
    Turbo.config.forms.confirm = (message) => this.showConfirm(message);
  }

  showConfirm(message) {
    this.#message(message);
    this.#modal();

    return new Promise((resolve) => this.element.addEventListener(
      "close", () => resolve(this.element.returnValue === "confirm"), { once: true })
    );
  }

  #message(message) {
    this.element.querySelector("p").textContent = message;
  }

  #modal() {
    this.element.showModal();
  }
}
