import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // Auto dismiss after 4 seconds
    setTimeout(() => {
      this.dismiss()
    }, 4000)
  }

  dismiss() {
    this.element.classList.add("animate-fade-out")
    setTimeout(() => {
      this.element.remove()
    }, 300)
  }
}
