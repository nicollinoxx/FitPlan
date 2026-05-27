import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["fileInput", "preview", "saveButton", "removeButton"]

  preview() {
    const file = this.fileInputTarget.files[0]
    if (!file) return

    const reader = new FileReader()
    reader.onload = () => { this.#applyPreview(reader.result, file) }
    reader.readAsDataURL(file)
  }

  #applyPreview(src, file) {
    this.#setPreviewSrc(src)
    this.#showSaveButton()
    this.#loadVideoPreview(file)
  }

  #setPreviewSrc(src) {
    this.previewTarget.src = src
    this.previewTarget.hidden = false
  }

  #loadVideoPreview(file) {
    if (file.type.startsWith("video/")) this.previewTarget.load()
  }

  #showSaveButton() {
    if (this.hasSaveButtonTarget)   this.saveButtonTarget.hidden   = false
    if (this.hasRemoveButtonTarget) this.removeButtonTarget.hidden = true
  }
}
