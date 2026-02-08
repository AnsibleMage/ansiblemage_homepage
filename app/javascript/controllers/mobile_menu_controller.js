import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "openIcon", "closeIcon", "searchForm"]

  connect() {
    this.isOpen = false
    this.searchOpen = false
  }

  toggle() {
    // Guard against missing targets
    if (!this.hasMenuTarget || !this.hasOpenIconTarget || !this.hasCloseIconTarget) {
      console.warn('MobileMenuController: Required targets not found')
      return
    }

    this.isOpen = !this.isOpen

    if (this.isOpen) {
      this.menuTarget.classList.remove("hidden")
      this.menuTarget.classList.add("flex")
      this.openIconTarget.classList.add("hidden")
      this.closeIconTarget.classList.remove("hidden")
    } else {
      this.menuTarget.classList.add("hidden")
      this.menuTarget.classList.remove("flex")
      this.openIconTarget.classList.remove("hidden")
      this.closeIconTarget.classList.add("hidden")
    }
  }

  close() {
    // Guard against missing targets
    if (!this.hasMenuTarget || !this.hasOpenIconTarget || !this.hasCloseIconTarget) {
      console.warn('MobileMenuController: Required targets not found')
      return
    }

    this.isOpen = false
    this.menuTarget.classList.add("hidden")
    this.menuTarget.classList.remove("flex")
    this.openIconTarget.classList.remove("hidden")
    this.closeIconTarget.classList.add("hidden")
  }

  toggleSearch() {
    if (!this.hasSearchFormTarget) {
      console.warn('MobileMenuController: searchForm target not found')
      return
    }

    this.searchOpen = !this.searchOpen

    if (this.searchOpen) {
      this.searchFormTarget.classList.remove("hidden")
      // Focus on input field
      const input = this.searchFormTarget.querySelector('input[type="text"]')
      if (input) {
        setTimeout(() => input.focus(), 100)
      }
    } else {
      this.searchFormTarget.classList.add("hidden")
    }
  }

  closeSearch() {
    if (this.hasSearchFormTarget && this.searchOpen) {
      this.searchOpen = false
      this.searchFormTarget.classList.add("hidden")
    }
  }
}
