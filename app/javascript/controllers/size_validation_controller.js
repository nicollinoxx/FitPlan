import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  validate(event) {
    const file = event.target.files[0]
    if (!file) return

    const maxSize = file.type.startsWith("video/") ? 16 * 1024 * 1024 : 2 * 1024 * 1024

    if (file.size > maxSize) event.target.value = ''
  }
}
