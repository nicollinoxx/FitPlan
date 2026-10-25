import { Controller } from "@hotwired/stimulus"
import "bootstrap"

export default class extends Controller {
  connect() { setTimeout(() => window.bootstrap.Alert.getOrCreateInstance(this.element).close(), 5000) }
}
