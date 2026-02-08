import { Controller } from "@hotwired/stimulus"

/**
 * Dark Mode Controller
 *
 * Features:
 * - Toggle between light and dark themes
 * - Persist theme preference to localStorage
 * - Detect system color scheme preference
 * - Update icon based on current theme
 * - Turbo Drive compatibility
 * - WCAG AA compliant color contrast
 *
 * Usage:
 *   <html data-controller="dark-mode">
 *   <button data-action="click->dark-mode#toggle">Toggle Theme</button>
 */
export default class extends Controller {
  static targets = ["lightIcon", "darkIcon"]

  // Theme constants
  static THEME_DARK = 'dark'
  static THEME_LIGHT = 'light'
  static STORAGE_KEY = 'theme'
  static MEDIA_QUERY = '(prefers-color-scheme: dark)'

  // Lifecycle

  connect() {
    this.applyTheme()
    this.setupTurboListeners()
    this.setupSystemPreferenceListener()
  }

  disconnect() {
    this.teardownSystemPreferenceListener()
  }

  // Actions

  toggle() {
    const currentTheme = this.getTheme()
    const newTheme = this.isThemeDark(currentTheme)
      ? this.constructor.THEME_LIGHT
      : this.constructor.THEME_DARK

    this.setTheme(newTheme)
    this.applyTheme()
  }

  // Theme Management

  applyTheme() {
    const theme = this.getTheme()

    this.applyThemeToHtml(theme)
    this.updateIcon()
    this.updateMetaThemeColor(theme)
  }

  getTheme() {
    return this.getStoredTheme() || this.getSystemTheme() || this.constructor.THEME_LIGHT
  }

  setTheme(theme) {
    localStorage.setItem(this.constructor.STORAGE_KEY, theme)
  }

  getStoredTheme() {
    return localStorage.getItem(this.constructor.STORAGE_KEY)
  }

  getSystemTheme() {
    if (!this.supportsMatchMedia()) {
      return null
    }

    const prefersDark = window.matchMedia(this.constructor.MEDIA_QUERY).matches
    return prefersDark ? this.constructor.THEME_DARK : this.constructor.THEME_LIGHT
  }

  isThemeDark(theme) {
    return theme === this.constructor.THEME_DARK
  }

  supportsMatchMedia() {
    return window.matchMedia !== undefined
  }

  // DOM Updates

  applyThemeToHtml(theme) {
    const html = document.documentElement
    const isDark = this.isThemeDark(theme)

    html.classList.toggle('dark', isDark)
  }

  updateIcon() {
    if (!this.hasIconTargets()) {
      return
    }

    const theme = this.getTheme()
    const isDark = this.isThemeDark(theme)

    // Show opposite icon: sun in dark mode, moon in light mode
    this.showIcon(this.lightIconTarget, isDark)
    this.showIcon(this.darkIconTarget, !isDark)
  }

  updateMetaThemeColor(theme) {
    const metaTag = this.getMetaThemeColorTag()

    if (!metaTag) {
      return
    }

    const color = this.isThemeDark(theme) ? '#0D0D0D' : '#FFFFFF'
    metaTag.setAttribute('content', color)
  }

  hasIconTargets() {
    return this.hasLightIconTarget && this.hasDarkIconTarget
  }

  showIcon(iconElement, shouldShow) {
    iconElement.classList.toggle('hidden', !shouldShow)
  }

  getMetaThemeColorTag() {
    return document.querySelector('meta[name="theme-color"]')
  }

  // Turbo Drive Integration

  setupTurboListeners() {
    this.boundTurboBeforeRender = this.handleTurboBeforeRender.bind(this)
    this.boundTurboBeforeCache = this.handleTurboBeforeCache.bind(this)

    document.addEventListener('turbo:before-render', this.boundTurboBeforeRender)
    document.addEventListener('turbo:before-cache', this.boundTurboBeforeCache)
  }

  handleTurboBeforeRender(event) {
    const theme = this.getTheme()
    const { newBody } = event.detail

    newBody.classList.toggle('dark', this.isThemeDark(theme))
  }

  handleTurboBeforeCache() {
    document.documentElement.style.transition = ''
  }

  // System Preference Detection

  setupSystemPreferenceListener() {
    if (!this.supportsMatchMedia()) {
      return
    }

    this.mediaQuery = window.matchMedia(this.constructor.MEDIA_QUERY)
    this.boundSystemPreferenceHandler = this.handleSystemPreferenceChange.bind(this)

    this.addMediaQueryListener(this.mediaQuery, this.boundSystemPreferenceHandler)
  }

  teardownSystemPreferenceListener() {
    if (!this.mediaQuery || !this.boundSystemPreferenceHandler) {
      return
    }

    this.removeMediaQueryListener(this.mediaQuery, this.boundSystemPreferenceHandler)
  }

  addMediaQueryListener(mediaQuery, handler) {
    if (mediaQuery.addEventListener) {
      mediaQuery.addEventListener('change', handler)
    } else {
      mediaQuery.addListener(handler) // Fallback for older browsers
    }
  }

  removeMediaQueryListener(mediaQuery, handler) {
    if (mediaQuery.removeEventListener) {
      mediaQuery.removeEventListener('change', handler)
    } else {
      mediaQuery.removeListener(handler) // Fallback for older browsers
    }
  }

  handleSystemPreferenceChange() {
    // Only apply system preference if user hasn't set explicit preference
    if (!this.getStoredTheme()) {
      this.applyTheme()
    }
  }
}
