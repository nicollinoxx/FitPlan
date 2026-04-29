import { Controller } from "@hotwired/stimulus"
import * as bootstrap from "bootstrap"

export default class extends Controller {
  connect() { new bootstrap.Toast(this.element, { delay: 5000 }).show() }
}
