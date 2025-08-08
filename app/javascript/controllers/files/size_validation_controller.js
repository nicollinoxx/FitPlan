import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  validate(event) {
    const file = event.target.files[0]
    if (!file) return
    if (file.size > this.#sizeLimit(file)) event.target.value = ''
  }

  #sizeLimit(file) {
    if (file.type.startsWith("video/")) {
      return 16 * 1024 * 1024;
    } else {
      return 8 * 1024 * 1024;
    }
  }
}
