import { Controller } from "@hotwired/stimulus"

// Toggles the mobile navigation panel. The links are always in the DOM so the
// desktop layout and search engines see them; this only shows/hides the panel
// below the `md` breakpoint and keeps the trigger's ARIA state in sync.
export default class extends Controller {
  static targets = ["panel", "openIcon", "closeIcon", "trigger"]

  connect() {
    this.close()
  }

  toggle() {
    this.panelTarget.classList.contains("hidden") ? this.open() : this.close()
  }

  open() {
    this.panelTarget.classList.remove("hidden")
    this.openIconTarget.classList.add("hidden")
    this.closeIconTarget.classList.remove("hidden")
    this.triggerTarget.setAttribute("aria-expanded", "true")
  }

  close() {
    this.panelTarget.classList.add("hidden")
    this.openIconTarget.classList.remove("hidden")
    this.closeIconTarget.classList.add("hidden")
    this.triggerTarget.setAttribute("aria-expanded", "false")
  }

  // Collapse when a link is followed, otherwise the panel stays open across
  // Turbo navigations, and when the viewport grows past the mobile breakpoint.
  closeOnNavigation() {
    this.close()
  }

  closeOnResize() {
    if (window.innerWidth >= 768) this.close()
  }
}
