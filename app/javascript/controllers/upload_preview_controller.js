import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ['fileInput', 'previewUpload', 'currentFile', 'removeButton'];

  preview() {
    const file = this.fileInputTarget.files[0];
    const reader = new FileReader();

    if (!file) {
      this.toggleVisibility(!!file);
      return;
  }

  reader.onload = () => {
    this.previewUploadTarget.src = reader.result;
    this.toggleVisibility(!!file);
  };

    reader.readAsDataURL(file);
  }

  removePreview() {
    this.fileInputTarget.value = null;
    this.toggleVisibility(false);
  }

  toggleVisibility(hasFile) {
    if (this.hasPreviewUploadTarget) this.previewUploadTarget.hidden = !hasFile;
    if (this.hasCurrentFileTarget) this.currentFileTarget.hidden = hasFile;
    if (this.hasRemoveButtonTarget) this.removeButtonTarget.hidden = !hasFile;
  }
}
