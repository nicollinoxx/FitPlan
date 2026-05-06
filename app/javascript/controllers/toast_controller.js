import { Controller } from "@hotwired/stimulus"
import * as bootstrap from "bootstrap"

export default class extends Controller {
  connect() { setTimeout(() => bootstrap.Alert.getOrCreateInstance(this.element).close(), 5000) }
}
