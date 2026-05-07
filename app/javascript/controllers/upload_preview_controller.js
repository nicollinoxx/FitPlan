import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["fileInput", "preview", "saveButton", "removeButton", "clearButton"]

  preview() {
    const file = this.fileInputTarget.files[0]
    if (!file) return

    const reader = new FileReader()
    reader.onload = () => {
      this.previewTarget.src = reader.result
      this.previewTarget.hidden = false
      this.showSaveButton()

      if (file.type.startsWith("video/")) this.videoPreview()
    }
    reader.readAsDataURL(file)
  }

  removePreview() {
    this.fileInputTarget.value = ""
    this.previewTarget.src = ""
    this.previewTarget.hidden = true
    if (this.hasClearButtonTarget) this.clearButtonTarget.hidden = true
    if (this.hasRemoveButtonTarget) this.removeButtonTarget.hidden = false
  }

  videoPreview() {
    this.previewTarget.hidden = false
    this.previewTarget.load()
  }

  showSaveButton() {
    if (this.hasSaveButtonTarget) this.saveButtonTarget.hidden = false
    if (this.hasRemoveButtonTarget) this.removeButtonTarget.hidden = true
    if (this.hasClearButtonTarget) this.clearButtonTarget.hidden = false
  }
}
