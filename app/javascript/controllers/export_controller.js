import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["source"]
  static values = {
    title: String,
    ignore: { type: Array, default: ["button", "form", ".btn", "[data-bs-toggle]", "img[src*='illustration']", "svg", "footer"] }
  }

  print() {
    const content = this.sourceTarget.cloneNode(true)

    content.querySelectorAll(this.ignoreValue.join(",")).forEach((el) => el.remove())

    const styles = [...document.querySelectorAll('link[rel="stylesheet"]')]
      .map((link) => `<link rel="stylesheet" href="${link.href}">`)
      .join("")
    
    const title = this.#escape(this.titleValue)

    const frame = document.createElement("iframe")
    frame.style.cssText = "position:fixed;width:0;height:0;border:0;visibility:hidden"
    frame.srcdoc = `<!DOCTYPE html>
      <html data-bs-theme="light">
        <head>
          <title>${title}</title>
          ${styles}
          <style>
            * { -webkit-print-color-adjust: exact; print-color-adjust: exact; }
            body { background: #fff !important; color: #000 !important; }
            .card { border: 1px solid #dee2e6 !important; margin-bottom: 1rem; }
          </style>
        </head>
        <body class="p-4">
          <h1 class="h3 mb-4 fw-bold">${title}</h1>
          ${content.outerHTML}
        </body>
      </html>`

    frame.onload = () => {
      frame.contentWindow.onafterprint = () => frame.remove()
      frame.contentWindow.focus()
      frame.contentWindow.print()
    }

    document.body.appendChild(frame)
  }

  #escape(text) {
    const div = document.createElement("div")
    div.textContent = text || ""
    return div.innerHTML
  }
}