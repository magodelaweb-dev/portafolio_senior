import { Controller } from "@hotwired/stimulus"

// Periodically reloads a <turbo-frame> to keep the /ops dashboard live,
// without any heavy client-side framework.
export default class extends Controller {
  static values = { interval: { type: Number, default: 5000 } }

  connect() {
    this.timer = setInterval(() => this.element.reload(), this.intervalValue)
  }

  disconnect() {
    if (this.timer) {
      clearInterval(this.timer)
      this.timer = null
    }
  }
}
