import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ['fileInput', 'previewUpload', 'currentFile'];

  preview() {
    const file   = this.fileInputTarget.files[0];
    const reader = new FileReader();

    //if field for null old file appears
    if (!file) {
      this.currentFileTarget.style.display   = "block";
      this.previewUploadTarget.style.display = "none";
      return;
    }

    reader.onload = (event) => {
      this.previewUploadTarget.src = event.target.result;
      this.previewUploadTarget.style.display = "block";
      this.currentFileTarget.style.display   = "none";
    };

    reader.readAsDataURL(file);
  }
}
