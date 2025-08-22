import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["fileInput", "preview", "clearButton", "removeButton"]

  preview() {
    const file = this.fileInputTarget.files[0]
    if (!file) return

    const reader = new FileReader()
    reader.onload = () => {
      this.previewTarget.src = reader.result
      this.previewTarget.hidden = false
      this.updateButtons()
    }
    reader.readAsDataURL(file)
  }

  removePreview() {
    this.fileInputTarget.value = null
    this.previewTarget.src = this.previewTarget.dataset.default || ""
    this.previewTarget.hidden = this.previewTarget.dataset.default ? false : true
    this.updateButtons()
  }

  updateButtons() {
    const hasFile = this.fileInputTarget.files.length > 0

    if (this.hasClearButtonTarget) this.clearButtonTarget.hidden = !hasFile
    if (this.hasRemoveButtonTarget) this.removeButtonTarget.hidden = hasFile
  }
}
