import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    type: String,
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
      interaction: { mode: "index", intersect: false },
      scales: this.typeValue === "Bar" ? { x: value, y: category } : { x: category, y: value },
      elements: {
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
