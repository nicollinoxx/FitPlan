import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["fileInput", "preview", "saveButton", "removeButton", "clearButton"]

  preview() {
    const file = this.fileInputTarget.files[0]
    if (!file) return

    this.#showPreview(file)
    this.#toggle({ save: false, remove: true, clear: false })
  }

  removePreview() {
    this.#clearPreview()
    this.#toggle({ save: true, remove: false, clear: true })
  }

  #showPreview(file) {
    if (this.previewTarget.src.startsWith("blob:")) URL.revokeObjectURL(this.previewTarget.src)
    this.previewTarget.src    = URL.createObjectURL(file)
    this.previewTarget.hidden = false
    if (file.type.startsWith("video/")) this.previewTarget.load()
  }

  #clearPreview() {
    URL.revokeObjectURL(this.previewTarget.src)
    this.previewTarget.src     = ""
    this.previewTarget.hidden  = true
    this.fileInputTarget.value = ""
  }

  #toggle({ save, remove, clear }) {
    if (this.hasSaveButtonTarget)   this.saveButtonTarget.hidden   = save
    if (this.hasRemoveButtonTarget) this.removeButtonTarget.hidden = remove
    if (this.hasClearButtonTarget)  this.clearButtonTarget.hidden  = clear
  }
}
