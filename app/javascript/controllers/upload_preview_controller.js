import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["fileInput", "preview", "saveButton", "removeButton"]

  preview() {
    const file = this.fileInputTarget.files[0]
    if (!file) return

    const reader = new FileReader()
    reader.onload = () => {
      this.#showPreview(reader.result)
      this.#showSaveButton()
      if (file.type.startsWith("video/")) this.previewTarget.load()
    }
    reader.readAsDataURL(file)
  }

  #showPreview(src) {
    const el = this.previewTarget
    if (el.tagName === "IMG") {
      el.src = src
    } else {
      el.style.backgroundImage    = `url('${src}')`
      el.style.backgroundSize     = "cover"
      el.style.backgroundPosition = "center"
      el.querySelector("i")?.remove()
    }
  }

  #showSaveButton() {
    if (this.hasSaveButtonTarget)   this.saveButtonTarget.hidden   = false
    if (this.hasRemoveButtonTarget) this.removeButtonTarget.hidden = true
  }
}
