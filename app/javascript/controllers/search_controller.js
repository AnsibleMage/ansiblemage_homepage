import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input"]
  static values = { debounceDelay: { type: Number, default: 300 } }

  connect() {
    this.timeout = null
  }

  disconnect() {
    if (this.timeout) {
      clearTimeout(this.timeout)
    }
  }

  submit(event) {
    // Clear existing timeout
    if (this.timeout) {
      clearTimeout(this.timeout)
    }

    // Debounce the form submission
    this.timeout = setTimeout(() => {
      const form = this.element.querySelector('form')
      if (form) {
        form.requestSubmit()
      }
    }, this.debounceDelayValue)
  }

  clear() {
    if (this.hasInputTarget) {
      this.inputTarget.value = ''
      const form = this.element.querySelector('form')
      if (form) {
        form.requestSubmit()
      }
    }
  }
}
