import { Controller } from "@hotwired/stimulus"

// Draws any Chartkick chart from data attributes, so the styling lives in one
// place instead of being repeated at every call site.
//
// Colors are read from the Bootstrap custom properties rather than written as
// literals. That keeps the charts on the site palette, and it is what lets them
// follow the color mode: the chart is redrawn whenever `data-bs-theme` changes.
export default class extends Controller {
  static values = {
    type: String,
    // Chartkick takes either a hash or an array of series, and a value has to
    // commit to one of them, so the data travels as JSON text.
    data: String,
    accents: { type: Array, default: ["success"] },
    options: { type: Object, default: {} }
  }

  connect() {
    this.draw()

    this.observer = new MutationObserver(() => this.draw())
    this.observer.observe(document.documentElement, { attributeFilter: ["data-bs-theme"] })
  }

  disconnect() {
    this.observer.disconnect()
    this.chart.destroy()
  }

  draw() {
    this.chart?.destroy()

    const data = JSON.parse(this.dataValue)
    const colors = this.accentsValue.map((accent) => this.#css(accent))

    this.chart = new window.Chartkick[`${this.typeValue}Chart`](this.element, data, {
      colors: colors,
      points: false,
      legend: data.length > 1 && "top",
      dataset: this.#dataset(colors),
      library: this.#library(),
      ...this.optionsValue
    })
  }

  // MARK: Private

  // Chartkick halves the opacity of every fill and leaves lines flat on the
  // axis. Bars read better solid, and a line better closing onto the axis.
  #dataset(colors) {
    const color = ({ datasetIndex }) => colors[datasetIndex % colors.length]

    if (this.typeValue !== "Line") return { backgroundColor: color, borderWidth: 0, borderRadius: 8 }

    return { fill: true, backgroundColor: (context) => this.#gradient(context, color(context)) }
  }

  #gradient({ chart }, color) {
    const { ctx, chartArea } = chart
    if (!chartArea) return

    const gradient = ctx.createLinearGradient(0, chartArea.top, 0, chartArea.bottom)
    gradient.addColorStop(0, `${color}59`)
    gradient.addColorStop(1, `${color}00`)

    return gradient
  }

  #library() {
    // A bar chart lays its categories down the y axis, so which axis carries the
    // grid lines is the one measuring values, not a fixed side.
    const category = {
      grid: { display: false },
      border: { display: false },
      ticks: { color: this.#css("secondary-color"), padding: 6, maxRotation: 0, autoSkipPadding: 16 }
    }

    const value = {
      beginAtZero: true,
      grid: { color: this.#css("border-color"), drawTicks: false },
      border: { display: false },
      ticks: { color: this.#css("secondary-color"), padding: 8, precision: 0 }
    }

    return {
      maintainAspectRatio: false,
      animation: { duration: 700, easing: "easeOutQuart" },
      // Hovering anywhere above a date reports every series at that date,
      // instead of asking for a hit on the line itself.
      interaction: { mode: "index", intersect: false },
      scales: this.typeValue === "Bar" ? { x: value, y: category } : { x: category, y: value },
      elements: {
        // Monotone keeps a smooth line from overshooting below zero between two
        // quiet days, which a plain curve does.
        line: { borderWidth: 2.5, cubicInterpolationMode: "monotone" },
        point: { radius: 0, hoverRadius: 5, hitRadius: 16 }
      },
      plugins: {
        legend: {
          labels: { color: this.#css("body-color"), usePointStyle: true, pointStyle: "circle", boxWidth: 8, padding: 16 }
        },
        tooltip: {
          backgroundColor: this.#css("body-bg"),
          titleColor: this.#css("body-color"),
          bodyColor: this.#css("body-color"),
          borderColor: this.#css("border-color"),
          borderWidth: 1,
          cornerRadius: 8,
          padding: 12,
          usePointStyle: true
        }
      }
    }
  }

  #css(name) {
    return getComputedStyle(document.documentElement).getPropertyValue(`--bs-${name}`).trim()
  }
}
