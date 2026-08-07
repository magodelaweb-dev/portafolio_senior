import { Controller } from "@hotwired/stimulus"

// Rewrites a <time> element's server-rendered clock into the visitor's own
// time zone. The datetime attribute carries the authoritative UTC instant, so
// without JS the element still shows a valid (server-side) time.
export default class extends Controller {
  connect() {
    const instant = new Date(this.element.dateTime)
    if (isNaN(instant)) return

    this.element.textContent = instant.toLocaleTimeString([], {
      hour: "2-digit",
      minute: "2-digit",
      second: "2-digit",
      hour12: false
    })
    this.element.title = instant.toString()
  }
}
