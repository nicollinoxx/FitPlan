import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["fileInput", "preview", "saveButton", "removeButton"]

  preview() {
    const file = this.fileInputTarget.files[0]
    if (!file) return

    const reader = new FileReader()
    reader.onload = () => {
      this.previewTarget.src = reader.result
      this.showSaveButton()

      if (file.type.startsWith("video/")) this.videoPreview()
    }
    reader.readAsDataURL(file)
  }

  videoPreview() {
    this.previewTarget.hidden = false
    this.previewTarget.load()
  }

  showSaveButton() {
    if (this.hasSaveButtonTarget) this.saveButtonTarget.hidden = false
    if (this.hasRemoveButtonTarget) this.removeButtonTarget.hidden = true
  }
}
