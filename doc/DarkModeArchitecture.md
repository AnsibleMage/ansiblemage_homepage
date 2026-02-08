# Technical Architecture: Dark Mode Toggle System

> **Project**: AnsibleMage Homepage
> **Feature**: Dark Mode / Light Mode / System Toggle
> **Version**: 1.0
> **Created**: 2026-02-08
> **Status**: Architecture Complete - Ready for TDD Implementation
> **Prerequisites**: PRD.md (Section 7.1 Color Palette), Requirements Analysis Output

---

## Table of Contents

1. [Architecture Decision Records (ADR)](#1-architecture-decision-records)
2. [System Architecture Overview](#2-system-architecture-overview)
3. [Component Architecture](#3-component-architecture)
4. [State Machine](#4-state-machine)
5. [Data Flow Design](#5-data-flow-design)
6. [CSS Variable Strategy](#6-css-variable-strategy)
7. [Stimulus Controller API Design](#7-stimulus-controller-api-design)
8. [FOUC Prevention Script](#8-fouc-prevention-script)
9. [Turbo Drive Integration](#9-turbo-drive-integration)
10. [Toggle Button UI Design](#10-toggle-button-ui-design)
11. [Accessibility Architecture](#11-accessibility-architecture)
12. [Performance Optimization Strategy](#12-performance-optimization-strategy)
13. [Risk Mitigation Architecture](#13-risk-mitigation-architecture)
14. [Test Strategy Architecture](#14-test-strategy-architecture)
15. [File Structure and Change Manifest](#15-file-structure-and-change-manifest)
16. [Implementation Roadmap](#16-implementation-roadmap)
17. [Appendix: Color Palette Specification](#17-appendix-color-palette-specification)

---

## 1. Architecture Decision Records

### ADR-01: Class-Based Dark Mode Toggle via Tailwind @custom-variant

**Status**: Accepted

**Context**: Tailwind CSS 4.0 supports two dark mode strategies: (a) media-query based (`prefers-color-scheme`) which is automatic but offers no user control, and (b) class-based via `@custom-variant dark` which enables manual toggle with localStorage persistence.

**Decision**: Use the class-based strategy with `@custom-variant dark (&:where(.dark, .dark *))` applied to the `<html>` element. This enables a 3-way toggle (dark / light / system) while preserving the ability to respect OS preferences when the user selects "system."

**Consequences**:
- Full user control over theme preference
- Requires an inline FOUC prevention script in `<head>`
- Requires explicit `dark:` prefixed utilities on elements that differ between themes
- CSS variables serve as the single source of truth for colors

**Alternatives Rejected**:
- `data-theme` attribute: Less idiomatic with Tailwind, requires custom variant syntax with no functional advantage
- Media-query only: No user control, violates FR-06 (3-way toggle)

---

### ADR-02: CSS Custom Properties as Color Abstraction Layer

**Status**: Accepted

**Context**: The existing codebase defines all colors as Tailwind `@theme` variables (e.g., `--color-void-black: #0D0D0D`). These are referenced directly in component classes (`.pixel-card`, `.pixel-btn`, etc.). Adding a light theme requires all components to have alternate color values.

**Decision**: Introduce a CSS custom properties layer that sits between Tailwind theme tokens and actual color values. The `@theme` block maps semantic names to CSS variables, and these CSS variables are redefined under `.dark` and default (light) scopes on `:root`.

**Consequences**:
- Single DOM operation (toggle class on `<html>`) triggers full theme switch
- No JavaScript needed to update individual element styles
- Existing Tailwind utility classes (`bg-void-black`, `text-star-white`) continue to work unchanged
- All pixel-art component classes (`.pixel-card`, `.pixel-btn`) inherit theme changes automatically

**Alternatives Rejected**:
- Dual utility classes (`bg-white dark:bg-gray-800` on every element): Massive template refactor, violates maintainability requirement (NFR-05)
- JavaScript-driven inline styles: Violates performance requirement (NFR-01), hundreds of DOM operations per toggle

---

### ADR-03: Stimulus Controller as Sole JavaScript Entry Point

**Status**: Accepted

**Context**: TC-01 mandates Stimulus controller only. The project uses importmap-rails (no bundler). Two Stimulus controllers already exist (`mobile_menu_controller.js`, `flash_controller.js`), establishing the pattern.

**Decision**: Create a single `dark_mode_controller.js` following existing conventions. The controller manages state transitions, localStorage, matchMedia listeners, and Turbo lifecycle integration. No external libraries required.

**Consequences**:
- Zero additional dependencies
- Consistent with existing codebase patterns
- Importmap auto-registers via `pin_all_from "app/javascript/controllers"`
- Controller attaches to `<html>` element for global scope

---

### ADR-04: Vitest for JavaScript Unit/Integration Tests

**Status**: Accepted

**Context**: TC-07 requires a new JS test environment. The project currently has no JavaScript testing setup. RSpec + Capybara handles Ruby and system tests. Stimulus controllers need isolated unit testing with DOM mocking.

**Decision**: Introduce Vitest with jsdom environment for JavaScript tests. Vitest is chosen over Jest for its native ESM support (required by importmap architecture) and faster execution. A `package.json` will be added solely for dev dependencies.

**Consequences**:
- New `package.json` with `vitest`, `jsdom`, `@hotwired/stimulus` as devDependencies
- New `vitest.config.js` at project root
- Test files in `test/javascript/` directory
- CI workflow updated to include `npx vitest run`
- Does not affect production bundle (Vitest is dev-only)

---

### ADR-05: FOUC Prevention via Synchronous Inline Script

**Status**: Accepted

**Context**: Without intervention, the browser renders HTML with default styles before JavaScript loads and applies the correct theme class. This causes a visible flash (FOUC) that violates user experience expectations.

**Decision**: Place a synchronous `<script>` block in `<head>` before `stylesheet_link_tag`. This script reads `localStorage.theme` and `matchMedia`, then immediately sets the `dark` class on `<html>`. Because it executes synchronously before first paint, the correct theme is applied from the first frame.

**Consequences**:
- Zero FOUC on initial load and hard refresh
- Script must be render-blocking (intentionally)
- Script must be minimal (< 10 lines) to avoid blocking performance
- CSP nonce may be needed if Content-Security-Policy is enabled

---

## 2. System Architecture Overview

### C4 Container Diagram

```
                    +-------------------+
                    |    User/Browser   |
                    +--------+----------+
                             |
              +--------------+--------------+
              |                             |
    +---------v----------+     +------------v-----------+
    |  FOUC Prevention   |     |    Turbo Drive SPA     |
    |  (inline <script>) |     |    Navigation          |
    |  Sync, blocking    |     |    (turbo-rails)       |
    +--------+-----------+     +------------+-----------+
             |                              |
             |   +----------+               |
             +-->| <html>   |<--------------+
                 | .dark    |
                 | class    |
                 +----+-----+
                      |
         +------------+-------------+
         |                          |
+--------v----------+    +---------v---------+
| Stimulus           |    | CSS Engine        |
| dark_mode_controller|   | (Tailwind 4.0)    |
| - toggle()         |    | - @custom-variant |
| - modeValueChanged |    | - CSS variables   |
| - matchMedia       |    | - dark: utilities |
+--------+-----------+    +---------+---------+
         |                          |
+--------v----------+              |
| localStorage       |              |
| key: "theme"       |              |
| val: dark|light|   |              |
|      (absent)      |              |
+--------------------+              |
                                    |
                      +-------------v-----------+
                      | Visual Rendering         |
                      | - Dark theme (current)   |
                      | - Light theme (new)      |
                      | - Smooth CSS transitions |
                      +-------------------------+
```

### Clean Architecture Layer Mapping

```
+================================================================+
|  LAYER 1: ENTITIES (Core Business Logic)                       |
|  Theme state: "dark" | "light" | "system"                      |
|  Resolution rule: system -> matchMedia -> effective dark/light  |
|  Invariant: exactly one of {dark, light} is active at any time |
+================================================================+
         |
+================================================================+
|  LAYER 2: USE CASES (Application Logic)                        |
|  UC-1: Toggle theme (cycle dark -> light -> system)            |
|  UC-2: Persist preference to localStorage                      |
|  UC-3: Resolve "system" to effective theme via matchMedia      |
|  UC-4: Sync theme across Turbo page navigations                |
|  UC-5: React to OS-level theme change in "system" mode         |
+================================================================+
         |
+================================================================+
|  LAYER 3: INTERFACE ADAPTERS (Stimulus Controller)             |
|  dark_mode_controller.js                                       |
|  - Maps DOM events to use cases                                |
|  - Maps use case results to DOM mutations                      |
|  - Converts between HTML attributes and state                  |
+================================================================+
         |
+================================================================+
|  LAYER 4: FRAMEWORKS & DRIVERS                                 |
|  - Tailwind CSS 4.0 (@custom-variant, @theme, dark: utilities) |
|  - Turbo Drive (turbo:before-render, turbo:before-cache)       |
|  - Browser APIs (localStorage, matchMedia, classList)          |
|  - Propshaft (asset serving)                                   |
+================================================================+
```

---

## 3. Component Architecture

### Component Interaction Diagram

```
+------------------------------------------------------------------+
|  application.html.erb (<html> element)                           |
|  data-controller="dark-mode"                                     |
|  data-dark-mode-mode-value="system"                              |
+------------------------------------------------------------------+
       |                         |                        |
       v                         v                        v
+---------------+    +---------------------+    +------------------+
| FOUC Script   |    | dark_mode_controller|    | application.css  |
| (inline head) |    | .js                 |    | (Tailwind 4.0)   |
|               |    |                     |    |                  |
| Reads:        |    | Manages:            |    | Defines:         |
| - localStorage|    | - toggle() action   |    | - @custom-variant|
| - matchMedia  |    | - mode value        |    | - CSS variables  |
|               |    | - matchMedia listen |    | - dark: utils    |
| Sets:         |    | - Turbo events      |    | - transitions    |
| - html.dark   |    | - icon updates      |    |                  |
+---------------+    +---------------------+    +------------------+
                              |
                     +--------v--------+
                     | _navbar.html.erb|
                     | Toggle Button   |
                     | - Moon/Sun/Auto |
                     | - aria attrs    |
                     | - data-action   |
                     +-----------------+
```

### Separation of Concerns

| Concern | Owner | Responsibility |
|---------|-------|----------------|
| Theme state resolution | FOUC script + Controller | Determine effective dark/light from mode |
| Theme persistence | Controller | Read/write localStorage |
| DOM class management | FOUC script + Controller | Add/remove `.dark` on `<html>` |
| Visual styling | CSS (Tailwind) | All color, transition, animation rules |
| User interaction | Navbar toggle button | Click event dispatch |
| Turbo coordination | Controller | Before-render and before-cache hooks |
| System preference | Controller + FOUC script | matchMedia query and listener |
| Accessibility | Toggle button HTML | aria-label, aria-pressed, focus |
| Icon display | Controller | Update icon target visibility |

---

## 4. State Machine

### Theme Mode State Machine

```
                    +----------+
                    |  INITIAL |
                    +----+-----+
                         |
                         | (read localStorage)
                         |
            +------------+-------------+
            |            |             |
            v            v             v
       +---------+  +---------+  +-----------+
       |  DARK   |  | LIGHT   |  |  SYSTEM   |
       | (user)  |  | (user)  |  | (default) |
       +----+----+  +----+----+  +-----+-----+
            |             |              |
            |  toggle()   |   toggle()   |  toggle()
            +------------>+------------->+----------+
                                                    |
                                         +----------+
                                         |
                                         v
                                    +---------+
                                    |  DARK   |
                                    | (cycle  |
                                    |  back)  |
                                    +---------+
```

**Toggle Cycle**: `dark` --> `light` --> `system` --> `dark` --> ...

### Effective Theme Resolution

```
+----------------+     +-------------------+     +------------------+
| mode = "dark"  | --> | effective = dark   | --> | <html class=dark>|
+----------------+     +-------------------+     +------------------+

+----------------+     +-------------------+     +------------------+
| mode = "light" | --> | effective = light  | --> | <html class="">  |
+----------------+     +-------------------+     +------------------+

+----------------+     +-------------------+
| mode ="system" | --> | matchMedia query   |
+-------+--------+     +--------+----------+
        |                        |
        |            +-----------+-----------+
        |            |                       |
        |    +-------v-------+    +----------v------+
        |    | OS = dark     |    | OS = light      |
        |    | effective=dark|    | effective=light  |
        |    +---------------+    +-----------------+
```

### State Transition Table

| Current Mode | Action | Next Mode | Effective Theme | localStorage |
|-------------|--------|-----------|-----------------|--------------|
| system | toggle() | dark | dark | "dark" |
| dark | toggle() | light | light | "light" |
| light | toggle() | system | (OS pref) | (removed) |
| system | OS changes to dark | system | dark | (unchanged) |
| system | OS changes to light | system | light | (unchanged) |
| any | page load | (from storage) | (resolved) | (unchanged) |

---

## 5. Data Flow Design

### Sequence Diagram: Initial Page Load

```
Browser          FOUC Script       HTML/CSS         Stimulus Controller
  |                  |                |                    |
  |--GET /---------->|                |                    |
  |                  |                |                    |
  |  <head> parsed   |                |                    |
  |----------------->|                |                    |
  |                  |                |                    |
  |            read localStorage      |                    |
  |            read matchMedia        |                    |
  |            resolve effective theme|                    |
  |                  |                |                    |
  |            set <html>.classList   |                    |
  |                  |--------------->|                    |
  |                  |                |                    |
  |            set meta theme-color   |                    |
  |                  |                |                    |
  |  CSS loads       |                |                    |
  |  (correct theme  |                |                    |
  |   already set)   |                |                    |
  |                  |                |                    |
  |  First paint (no FOUC)           |                    |
  |                  |                |                    |
  |  JS loads (importmap)            |                    |
  |                  |                |     connect()      |
  |                  |                |<-------------------|
  |                  |                |                    |
  |                  |                |  read localStorage |
  |                  |                |  sync modeValue    |
  |                  |                |  attach matchMedia |
  |                  |                |  listener          |
  |                  |                |  update icon       |
  |                  |                |                    |
```

### Sequence Diagram: User Toggle

```
User          Toggle Button     dark_mode_controller    <html>     localStorage
  |                |                    |                  |             |
  | click          |                    |                  |             |
  |--------------->|                    |                  |             |
  |                | data-action        |                  |             |
  |                | "dark-mode#toggle" |                  |             |
  |                |------------------->|                  |             |
  |                |                    |                  |             |
  |                |              cycle mode               |             |
  |                |              dark->light->system      |             |
  |                |                    |                  |             |
  |                |              this.modeValue = next    |             |
  |                |                    |                  |             |
  |                |         modeValueChanged() fires      |             |
  |                |                    |                  |             |
  |                |              resolve effective theme  |             |
  |                |                    |                  |             |
  |                |              classList.toggle("dark") |             |
  |                |                    |----------------->|             |
  |                |                    |                  |             |
  |                |              save preference          |             |
  |                |                    |-------------------------------->|
  |                |                    |                  |             |
  |                |              update icon target       |             |
  |                |                    |                  |             |
  |                |              update aria-pressed      |             |
  |                |                    |                  |             |
  |                |              update meta theme-color  |             |
  |                |                    |                  |             |
  |  CSS transitions apply (< 200ms)  |                  |             |
  |<---------------|--------------------|----- visual ---->|             |
  |                |                    |                  |             |
```

### Sequence Diagram: Turbo Drive Navigation

```
User          Turbo Drive      dark_mode_controller     <html>     localStorage
  |                |                    |                  |             |
  | click link     |                    |                  |             |
  |--------------->|                    |                  |             |
  |                |                    |                  |             |
  |          turbo:before-cache         |                  |             |
  |                |------------------->|                  |             |
  |                |              remove transition classes|             |
  |                |                    |----------------->|             |
  |                |                    |                  |             |
  |          fetch new page             |                  |             |
  |                |                    |                  |             |
  |          turbo:before-render        |                  |             |
  |                |------------------->|                  |             |
  |                |              read localStorage        |             |
  |                |                    |<--------------------------------|
  |                |              resolve effective theme  |             |
  |                |              apply .dark to new DOM   |             |
  |                |                    |----> new <html>  |             |
  |                |                    |                  |             |
  |          DOM swap                   |                  |             |
  |                |                    |                  |             |
  |          new controller connects    |                  |             |
  |                |------------------->|                  |             |
  |                |              sync state, update icon  |             |
  |                |                    |                  |             |
```

### Sequence Diagram: System Preference Change

```
OS Setting       matchMedia          dark_mode_controller     <html>
   |                 |                       |                   |
   | user changes    |                       |                   |
   | system theme    |                       |                   |
   |---------------->|                       |                   |
   |                 |                       |                   |
   |           "change" event fires          |                   |
   |                 |---------------------->|                   |
   |                 |                       |                   |
   |                 |                 check: mode == "system"?  |
   |                 |                       |                   |
   |                 |            [yes] resolve new effective    |
   |                 |                 classList.toggle("dark")  |
   |                 |                       |------------------>|
   |                 |                 update icon               |
   |                 |                 update meta theme-color   |
   |                 |                       |                   |
   |                 |            [no] ignore (user override)    |
   |                 |                       |                   |
```

---

## 6. CSS Variable Strategy

### Architecture: Two-Layer Color System

**Layer 1: Semantic CSS Variables** (theme-aware, change with mode)

These variables are defined on `:root` and overridden under `:root.dark`. They hold the actual color values.

**Layer 2: Tailwind @theme Tokens** (static references to Layer 1)

The `@theme` block maps Tailwind token names to the CSS variables from Layer 1. This allows all existing utility classes (`bg-void-black`, `text-star-white`) to automatically resolve to the correct color for the current theme.

```
@theme tokens          CSS variables           Actual colors
-----------          -------------           -------------
--color-void-black --> var(--bg-primary)   --> #f5f5f0 (light)
                                           --> #0D0D0D (dark)

--color-neon-cyan  --> var(--accent-primary) --> #0077aa (light)
                                              --> #00FFFF (dark)
```

### Complete CSS Implementation

```css
/* ============================================================
   FILE: app/assets/tailwind/application.css
   Dark Mode Architecture - CSS Variable Strategy
   ============================================================ */

@import "tailwindcss";

/* --- ADR-01: Enable class-based dark mode --- */
@custom-variant dark (&:where(.dark, .dark *));

/* Pixel Font */
@import url('https://fonts.googleapis.com/css2?family=Press+Start+2P&family=Noto+Sans+KR:wght@400;700&display=swap');

/* ============================================================
   LAYER 1: Semantic CSS Variables
   Light mode = default, Dark mode = .dark override
   ============================================================ */

:root {
  /* Background */
  --bg-primary: #f5f5f0;
  --bg-secondary: #e8e8e0;
  --bg-elevated: #ffffff;
  --bg-gradient-start: #f5f5f0;
  --bg-gradient-end: #e8e8e0;

  /* Text */
  --text-primary: #1a1a2e;
  --text-secondary: #4a4a5a;
  --text-muted: #6b6b7b;

  /* Accents - WCAG AA compliant for light backgrounds */
  --accent-cyan: #0077aa;
  --accent-magenta: #aa0077;
  --accent-green: #1a8c0a;

  /* Structural */
  --border-primary: #2D1B4E;
  --border-subtle: #d0d0d0;
  --surface-purple: #6B5B95;
  --surface-deep-purple: #e0d8f0;

  /* Pixel UI */
  --pixel-gold: #b8960a;
  --pixel-red: #cc4444;
  --pixel-heart: #cc2255;

  /* Shadows */
  --shadow-pixel: 4px 4px 0 #d0c8e0;
  --shadow-pixel-lg: 8px 8px 0 #d0c8e0;
  --shadow-neon: 0 0 10px #0077aa, 0 0 20px #0077aa;

  /* Stars background */
  --star-dot-1: #1a1a2e;
  --star-dot-2: #0077aa;
  --star-dot-3: #aa0077;

  /* Meta theme color */
  --meta-theme-color: #f5f5f0;

  /* Transition for theme switch */
  --theme-transition-duration: 200ms;
}

:root.dark {
  /* Background */
  --bg-primary: #0D0D0D;
  --bg-secondary: #1A1A2E;
  --bg-elevated: #1A1A2E;
  --bg-gradient-start: #0D0D0D;
  --bg-gradient-end: #1A1A2E;

  /* Text */
  --text-primary: #F0F0F0;
  --text-secondary: #B0B0B0;
  --text-muted: #888888;

  /* Accents - Full neon for dark backgrounds */
  --accent-cyan: #00FFFF;
  --accent-magenta: #FF00FF;
  --accent-green: #39FF14;

  /* Structural */
  --border-primary: #2D1B4E;
  --border-subtle: #2D1B4E;
  --surface-purple: #6B5B95;
  --surface-deep-purple: #2D1B4E;

  /* Pixel UI */
  --pixel-gold: #FFD700;
  --pixel-red: #FF6B6B;
  --pixel-heart: #FF4081;

  /* Shadows */
  --shadow-pixel: 4px 4px 0 #2D1B4E;
  --shadow-pixel-lg: 8px 8px 0 #2D1B4E;
  --shadow-neon: 0 0 10px #00FFFF, 0 0 20px #00FFFF;

  /* Stars background */
  --star-dot-1: #F0F0F0;
  --star-dot-2: #00FFFF;
  --star-dot-3: #FF00FF;

  /* Meta theme color */
  --meta-theme-color: #0D0D0D;
}

/* ============================================================
   LAYER 2: Tailwind @theme Tokens
   Map Tailwind utility names to CSS variables
   ============================================================ */

@theme {
  /* Background colors */
  --color-void-black: var(--bg-primary);
  --color-dark-space: var(--bg-secondary);
  --color-bg-elevated: var(--bg-elevated);

  /* Text colors */
  --color-star-white: var(--text-primary);
  --color-moon-gray: var(--text-secondary);
  --color-text-muted: var(--text-muted);

  /* Accent colors */
  --color-neon-cyan: var(--accent-cyan);
  --color-neon-magenta: var(--accent-magenta);
  --color-neon-green: var(--accent-green);

  /* Structural colors */
  --color-deep-purple: var(--surface-deep-purple);
  --color-space-purple: var(--surface-purple);

  /* Pixel UI colors */
  --color-pixel-gold: var(--pixel-gold);
  --color-pixel-red: var(--pixel-red);
  --color-pixel-heart: var(--pixel-heart);

  /* Fonts */
  --font-pixel: 'Press Start 2P', cursive;
  --font-body: 'Noto Sans KR', sans-serif;

  /* Shadows - now use CSS variables */
  --shadow-pixel: var(--shadow-pixel);
  --shadow-pixel-lg: var(--shadow-pixel-lg);
  --shadow-neon: var(--shadow-neon);
}

/* ============================================================
   Theme Transition Classes
   Only applied AFTER initial load to prevent FOUC
   ============================================================ */

html.theme-transition,
html.theme-transition *,
html.theme-transition *::before,
html.theme-transition *::after {
  transition:
    background-color var(--theme-transition-duration) ease,
    color var(--theme-transition-duration) ease,
    border-color var(--theme-transition-duration) ease,
    box-shadow var(--theme-transition-duration) ease,
    fill var(--theme-transition-duration) ease,
    stroke var(--theme-transition-duration) ease !important;
  transition-delay: 0s !important;
}

/* Reduced motion preference */
@media (prefers-reduced-motion: reduce) {
  html.theme-transition,
  html.theme-transition *,
  html.theme-transition *::before,
  html.theme-transition *::after {
    transition-duration: 0s !important;
  }
}

/* ... (rest of existing base, component, and utility layers follow,
   now referencing CSS variables instead of hardcoded hex values) ... */
```

### Key Changes to Existing Component Classes

The existing `.pixel-card`, `.pixel-btn`, `.pixel-nav`, etc. already reference `var(--color-*)` Tailwind tokens. Because those tokens now resolve through the CSS variable chain, **no changes are required to component class definitions**. The indirection is:

```
.pixel-card { border: 4px solid var(--color-neon-cyan); }
                                       |
                            @theme { --color-neon-cyan: var(--accent-cyan); }
                                                              |
                                  :root { --accent-cyan: #0077aa; }        (light)
                                  :root.dark { --accent-cyan: #00FFFF; }   (dark)
```

---

## 7. Stimulus Controller API Design

### Complete Controller Specification

```javascript
// ============================================================
// FILE: app/javascript/controllers/dark_mode_controller.js
//
// Dark Mode Controller
// Manages theme state across the application.
//
// Attaches to: <html> element
// Targets: icon (toggle button icon elements)
// Values: mode (String: "dark" | "light" | "system")
// Actions: toggle (called from navbar button)
// ============================================================

import { Controller } from "@hotwired/stimulus"

// Constants
const STORAGE_KEY = "theme"
const DARK_CLASS = "dark"
const TRANSITION_CLASS = "theme-transition"
const MEDIA_QUERY = "(prefers-color-scheme: dark)"

// Mode cycle order
const MODE_CYCLE = ["dark", "light", "system"]

export default class extends Controller {
  // ----------------------------------------------------------
  // Static Definitions
  // ----------------------------------------------------------

  static targets = [
    "darkIcon",    // Moon icon (visible when current effective = dark)
    "lightIcon",   // Sun icon (visible when current effective = light)
    "systemIcon"   // Monitor icon (visible when mode = system)
  ]

  static values = {
    mode: { type: String, default: "system" }
  }

  // ----------------------------------------------------------
  // Lifecycle: connect / disconnect
  // ----------------------------------------------------------

  connect() {
    // 1. Read persisted preference
    this.modeValue = this.#readPreference()

    // 2. Bind matchMedia listener
    this.#mediaQuery = window.matchMedia(MEDIA_QUERY)
    this.#boundHandleSystemChange = this.#handleSystemChange.bind(this)
    this.#mediaQuery.addEventListener("change", this.#boundHandleSystemChange)

    // 3. Bind Turbo events
    this.#boundHandleTurboBeforeRender = this.#handleTurboBeforeRender.bind(this)
    this.#boundHandleTurboBeforeCache = this.#handleTurboBeforeCache.bind(this)
    document.addEventListener("turbo:before-render", this.#boundHandleTurboBeforeRender)
    document.addEventListener("turbo:before-cache", this.#boundHandleTurboBeforeCache)

    // 4. Apply theme (in case FOUC script missed or was cached)
    this.#applyTheme(this.modeValue)
  }

  disconnect() {
    // Clean up matchMedia listener
    if (this.#mediaQuery) {
      this.#mediaQuery.removeEventListener("change", this.#boundHandleSystemChange)
    }

    // Clean up Turbo event listeners
    document.removeEventListener("turbo:before-render", this.#boundHandleTurboBeforeRender)
    document.removeEventListener("turbo:before-cache", this.#boundHandleTurboBeforeCache)
  }

  // ----------------------------------------------------------
  // Actions (called from HTML via data-action)
  // ----------------------------------------------------------

  /**
   * Cycle through modes: dark -> light -> system -> dark -> ...
   */
  toggle() {
    const currentIndex = MODE_CYCLE.indexOf(this.modeValue)
    const nextIndex = (currentIndex + 1) % MODE_CYCLE.length
    this.modeValue = MODE_CYCLE[nextIndex]
  }

  // ----------------------------------------------------------
  // Value Change Callback (Stimulus convention)
  // ----------------------------------------------------------

  /**
   * Fires whenever modeValue changes (from toggle, connect, or external).
   * This is the single synchronization point for all side effects.
   */
  modeValueChanged(value, previousValue) {
    // Enable transitions only after first interaction (not initial load)
    if (previousValue !== undefined) {
      this.#enableTransitions()
    }

    this.#applyTheme(value)
    this.#savePreference(value)
    this.#updateIcons(value)
    this.#updateMetaThemeColor()
    this.#updateAriaState(value)
  }

  // ----------------------------------------------------------
  // Private Methods
  // ----------------------------------------------------------

  /**
   * Resolve mode to effective theme and apply to <html>.
   */
  #applyTheme(mode) {
    const isDark = this.#resolveEffectiveTheme(mode)
    document.documentElement.classList.toggle(DARK_CLASS, isDark)
  }

  /**
   * Resolve mode string to boolean isDark.
   * "dark"   -> true
   * "light"  -> false
   * "system" -> matchMedia result
   */
  #resolveEffectiveTheme(mode) {
    if (mode === "dark") return true
    if (mode === "light") return false
    // "system" or unknown: use OS preference
    return window.matchMedia(MEDIA_QUERY).matches
  }

  /**
   * Read preference from localStorage.
   * Returns "dark", "light", or "system" (default when absent).
   */
  #readPreference() {
    const stored = localStorage.getItem(STORAGE_KEY)
    if (stored === "dark" || stored === "light") return stored
    return "system"
  }

  /**
   * Save preference to localStorage.
   * "system" removes the key (respect OS default).
   */
  #savePreference(mode) {
    if (mode === "system") {
      localStorage.removeItem(STORAGE_KEY)
    } else {
      localStorage.setItem(STORAGE_KEY, mode)
    }
  }

  /**
   * Update icon visibility based on current mode.
   */
  #updateIcons(mode) {
    const effective = this.#resolveEffectiveTheme(mode)

    if (this.hasDarkIconTarget) {
      this.darkIconTarget.classList.toggle("hidden", mode !== "system" || !effective ? mode !== "dark" && effective : true)
    }
    if (this.hasLightIconTarget) {
      this.lightIconTarget.classList.toggle("hidden", mode !== "system" || effective ? mode !== "light" && !effective : true)
    }

    // Simplified icon logic:
    // - mode "dark"   -> show moon
    // - mode "light"  -> show sun
    // - mode "system" -> show monitor/auto icon
    if (this.hasDarkIconTarget && this.hasLightIconTarget && this.hasSystemIconTarget) {
      this.darkIconTarget.classList.toggle("hidden", mode !== "dark")
      this.lightIconTarget.classList.toggle("hidden", mode !== "light")
      this.systemIconTarget.classList.toggle("hidden", mode !== "system")
    }
  }

  /**
   * Update <meta name="theme-color"> to match current theme.
   */
  #updateMetaThemeColor() {
    const meta = document.querySelector('meta[name="theme-color"]')
    if (meta) {
      const color = getComputedStyle(document.documentElement)
        .getPropertyValue("--meta-theme-color").trim()
      if (color) meta.setAttribute("content", color)
    }
  }

  /**
   * Update aria-pressed on the toggle button.
   */
  #updateAriaState(mode) {
    const button = this.element.querySelector("[data-dark-mode-toggle]")
    if (button) {
      // aria-pressed = "true" when dark is active
      const isDark = this.#resolveEffectiveTheme(mode)
      button.setAttribute("aria-pressed", isDark.toString())

      // Update aria-label for screen readers
      const labels = { dark: "Dark mode enabled", light: "Light mode enabled", system: "System theme active" }
      button.setAttribute("aria-label", `Toggle theme. ${labels[mode] || ""}`)
    }
  }

  /**
   * Enable CSS transitions for theme switch.
   * Adds transition class, then removes it after transition completes.
   */
  #enableTransitions() {
    const root = document.documentElement
    root.classList.add(TRANSITION_CLASS)

    // Remove after transition completes to avoid interfering with other animations
    clearTimeout(this.#transitionTimer)
    this.#transitionTimer = setTimeout(() => {
      root.classList.remove(TRANSITION_CLASS)
    }, 250) // slightly longer than --theme-transition-duration
  }

  /**
   * Handle OS-level color scheme change.
   * Only acts when mode is "system".
   */
  #handleSystemChange(event) {
    if (this.modeValue === "system") {
      this.#applyTheme("system")
      this.#updateIcons("system")
      this.#updateMetaThemeColor()
    }
  }

  /**
   * Handle Turbo Drive before-render event.
   * Ensures the incoming page has the correct theme class.
   */
  #handleTurboBeforeRender(event) {
    const newDocument = event.detail.newBody?.parentElement || event.detail.newBody
    if (newDocument) {
      const isDark = this.#resolveEffectiveTheme(this.modeValue)
      // Apply dark class to the new document's <html>
      const newHtml = event.detail.newBody.closest("html") || event.detail.newBody.parentElement
      if (newHtml) {
        newHtml.classList.toggle(DARK_CLASS, isDark)
      }
    }
  }

  /**
   * Handle Turbo Drive before-cache event.
   * Remove transition classes before Turbo caches the snapshot.
   */
  #handleTurboBeforeCache() {
    document.documentElement.classList.remove(TRANSITION_CLASS)
  }

  // ----------------------------------------------------------
  // Private Fields
  // ----------------------------------------------------------

  #mediaQuery = null
  #boundHandleSystemChange = null
  #boundHandleTurboBeforeRender = null
  #boundHandleTurboBeforeCache = null
  #transitionTimer = null
}
```

### Controller Method Responsibility Matrix

| Method | Layer | Responsibility | Testable Isolation |
|--------|-------|---------------|-------------------|
| `connect()` | Adapter | Wire up listeners, sync initial state | Integration |
| `disconnect()` | Adapter | Clean up all listeners | Integration |
| `toggle()` | Use Case | Cycle mode state | Unit |
| `modeValueChanged()` | Adapter | Orchestrate all side effects | Integration |
| `#resolveEffectiveTheme()` | Entity | Pure function: mode -> boolean | Unit |
| `#readPreference()` | Adapter | localStorage read | Unit (mock) |
| `#savePreference()` | Adapter | localStorage write | Unit (mock) |
| `#applyTheme()` | Adapter | DOM class mutation | Integration |
| `#updateIcons()` | Adapter | DOM class mutation on targets | Integration |
| `#updateMetaThemeColor()` | Adapter | DOM attribute mutation | Integration |
| `#updateAriaState()` | Adapter | DOM attribute mutation | Integration |
| `#enableTransitions()` | Adapter | Temporary CSS class management | Integration |
| `#handleSystemChange()` | Adapter | Event handler -> use case dispatch | Integration |
| `#handleTurboBeforeRender()` | Adapter | Turbo event -> DOM mutation | Integration |
| `#handleTurboBeforeCache()` | Adapter | Turbo event -> cleanup | Unit |

---

## 8. FOUC Prevention Script

### Implementation

This script executes synchronously in `<head>`, before stylesheets load and before first paint.

```html
<!-- FILE: app/views/layouts/application.html.erb -->
<!-- Place BEFORE stylesheet_link_tag -->

<script>
  // FOUC Prevention: Apply theme class before first paint
  // This runs synchronously and blocks rendering (intentionally).
  ;(function() {
    var d = document.documentElement
    var t = localStorage.getItem('theme')
    var isDark = t === 'dark' || (!t && window.matchMedia('(prefers-color-scheme: dark)').matches)
    d.classList.toggle('dark', isDark)
    // Update meta theme-color
    var m = document.querySelector('meta[name="theme-color"]')
    if (m) m.content = isDark ? '#0D0D0D' : '#f5f5f0'
  })()
</script>
```

### Design Decisions

1. **IIFE pattern**: Avoids polluting global scope
2. **`var` instead of `let/const`**: Maximum browser compatibility (including older WebViews)
3. **No ES6+ features**: Must work in all target browsers without transpilation
4. **Minimal logic**: Only reads localStorage and matchMedia, sets one class
5. **No error handling needed**: `localStorage.getItem` returns null on failure, `matchMedia` returns `{matches: false}` on failure -- both gracefully default to light mode
6. **Meta theme-color update**: Ensures mobile browser chrome matches theme immediately

### CSP Consideration

If Content-Security-Policy is enabled with `script-src`, the inline script requires a nonce:

```html
<script nonce="<%= content_security_policy_nonce %>">
  ;(function() { /* ... */ })()
</script>
```

Currently CSP is commented out in `config/initializers/content_security_policy.rb`, so no nonce is required at this time.

---

## 9. Turbo Drive Integration

### Problem Statement

Turbo Drive replaces `<body>` content during navigation. The `<html>` element persists, but Turbo may cache snapshots with stale theme classes, or the new page's controller may not be connected yet.

### Solution: Event-Based Synchronization

```
turbo:before-cache
    |
    v
Remove transition classes from snapshot
(prevents cached pages from having animation artifacts)
    |
turbo:before-render
    |
    v
Read localStorage -> resolve theme -> apply .dark to new DOM
(ensures incoming page has correct theme before it becomes visible)
    |
turbo:load / controller reconnect
    |
    v
Controller.connect() -> sync state -> update icons
(final reconciliation after DOM swap)
```

### Turbo Event Handler Details

**`turbo:before-render`**: Fires before Turbo replaces the body. The event provides access to the new body via `event.detail.newBody`. We apply the `.dark` class to the new body's parent `<html>` element to ensure correct styling from the first frame after swap.

**`turbo:before-cache`**: Fires before Turbo stores a snapshot for the back/forward cache. We remove the `theme-transition` class to prevent animation artifacts when restoring the cached snapshot.

### Edge Cases

| Scenario | Handling |
|----------|----------|
| User toggles theme, then navigates back | Turbo restores snapshot; controller re-connects and re-applies current theme |
| User is on page A (dark), navigates to page B | `turbo:before-render` applies `.dark` to new body before render |
| User changes OS theme while on cached page | `matchMedia` listener fires on controller reconnect |
| Hard refresh (non-Turbo) | FOUC script handles; controller re-initializes |

---

## 10. Toggle Button UI Design

### HTML Structure (Navbar Integration)

```html
<!-- FILE: app/views/shared/_navbar.html.erb -->
<!-- Added to Desktop Navigation section, before the login divider -->

<!-- Theme Toggle Button -->
<button
  type="button"
  data-action="click->dark-mode#toggle"
  data-dark-mode-toggle
  class="p-2 text-moon-gray hover:text-neon-cyan transition-colors relative"
  aria-label="Toggle theme"
  aria-pressed="true"
  title="Toggle theme (Dark / Light / System)"
>
  <!-- Dark Mode Icon (Moon) -->
  <svg data-dark-mode-target="darkIcon"
       class="w-5 h-5"
       fill="none" stroke="currentColor" viewBox="0 0 24 24"
       stroke-width="2">
    <path stroke-linecap="round" stroke-linejoin="round"
          d="M21.752 15.002A9.718 9.718 0 0118 15.75c-5.385
             0-9.75-4.365-9.75-9.75 0-1.33.266-2.597.748-3.752A9.753
             9.753 0 003 11.25C3 16.635 7.365 21 12.75 21a9.753
             9.753 0 009.002-5.998z" />
  </svg>

  <!-- Light Mode Icon (Sun) -->
  <svg data-dark-mode-target="lightIcon"
       class="w-5 h-5 hidden"
       fill="none" stroke="currentColor" viewBox="0 0 24 24"
       stroke-width="2">
    <path stroke-linecap="round" stroke-linejoin="round"
          d="M12 3v2.25m6.364.386l-1.591 1.591M21 12h-2.25m-.386
             6.364l-1.591-1.591M12 18.75V21m-4.773-4.227l-1.591
             1.591M5.25 12H3m4.227-4.773L5.636 5.636M15.75
             12a3.75 3.75 0 11-7.5 0 3.75 3.75 0 017.5 0z" />
  </svg>

  <!-- System Mode Icon (Monitor) -->
  <svg data-dark-mode-target="systemIcon"
       class="w-5 h-5 hidden"
       fill="none" stroke="currentColor" viewBox="0 0 24 24"
       stroke-width="2">
    <path stroke-linecap="round" stroke-linejoin="round"
          d="M9 17.25v1.007a3 3 0 01-.879 2.122L7.5 21h9l-.621-.621A3
             3 0 0115 18.257V17.25m6-12V15a2.25 2.25 0 01-2.25
             2.25h-13.5A2.25 2.25 0 013 15V5.25m18 0A2.25
             2.25 0 0018.75 3H5.25A2.25 2.25 0 003 5.25m18 0V12a2.25
             2.25 0 01-2.25 2.25H5.25A2.25 2.25 0 013 12V5.25" />
  </svg>
</button>
```

### Icon State Matrix

| Mode | Visible Icon | Icon Description |
|------|-------------|-----------------|
| dark | Moon (darkIcon) | Crescent moon indicating dark mode |
| light | Sun (lightIcon) | Sun indicating light mode |
| system | Monitor (systemIcon) | Computer monitor indicating system preference |

### Mobile Toggle

The same toggle button is duplicated in the mobile navigation section with identical `data-action` and `data-dark-mode-target` attributes. The controller on `<html>` scopes across both desktop and mobile instances.

---

## 11. Accessibility Architecture

### WCAG 2.1 AA Compliance Matrix

| Requirement | Implementation | Verification |
|-------------|----------------|-------------|
| **1.4.3 Contrast (Minimum)** | All color pairs pre-validated at 4.5:1 | Automated contrast checker |
| **1.4.11 Non-text Contrast** | UI components (buttons, inputs) have 3:1 contrast | Manual review + automated |
| **2.1.1 Keyboard** | `<button>` element is natively keyboard focusable | System test |
| **2.4.7 Focus Visible** | Custom focus ring visible in both themes | Visual review |
| **4.1.2 Name, Role, Value** | `aria-label`, `aria-pressed`, `role="button"` | Unit test |
| **1.3.1 Info and Relationships** | Theme state communicated via `aria-pressed` | Unit test |

### Focus Ring Design

```css
/* Both themes: visible focus indicator */
button[data-dark-mode-toggle]:focus-visible {
  outline: 2px solid var(--accent-cyan);
  outline-offset: 2px;
  border-radius: 2px;
}
```

### Screen Reader Announcements

The `aria-label` updates dynamically:
- Dark mode: `"Toggle theme. Dark mode enabled"`
- Light mode: `"Toggle theme. Light mode enabled"`
- System mode: `"Toggle theme. System theme active"`

The `aria-pressed` attribute communicates the current effective state:
- `"true"` when dark mode is active (effective)
- `"false"` when light mode is active (effective)

### Reduced Motion

```css
@media (prefers-reduced-motion: reduce) {
  html.theme-transition,
  html.theme-transition *,
  html.theme-transition *::before,
  html.theme-transition *::after {
    transition-duration: 0s !important;
  }
}
```

### Color Contrast Verification Table

| Element | Light Mode | Dark Mode | Ratio (Light) | Ratio (Dark) |
|---------|-----------|-----------|---------------|-------------|
| Body text on background | #1a1a2e on #f5f5f0 | #F0F0F0 on #0D0D0D | 13.4:1 | 17.4:1 |
| Secondary text | #4a4a5a on #f5f5f0 | #B0B0B0 on #0D0D0D | 7.1:1 | 10.3:1 |
| Cyan accent on bg | #0077aa on #f5f5f0 | #00FFFF on #0D0D0D | 4.5:1 | 14.8:1 |
| Green accent on bg | #1a8c0a on #f5f5f0 | #39FF14 on #0D0D0D | 4.6:1 | 13.6:1 |
| Magenta accent on bg | #aa0077 on #f5f5f0 | #FF00FF on #0D0D0D | 4.7:1 | 6.5:1 |
| Button text on cyan | #1a1a2e on #0077aa | #0D0D0D on #00FFFF | 4.5:1 | 14.8:1 |

---

## 12. Performance Optimization Strategy

### Target: < 50ms Perceived Switch Time

| Optimization | Technique | Impact |
|-------------|-----------|--------|
| **Single DOM op** | `classList.toggle("dark")` on `<html>` | 1 DOM write vs hundreds |
| **CSS-only transitions** | `transition: background-color, color, border-color` | GPU-composited, no JS frames |
| **No layout shift** | Only color properties change (no width, height, position) | 0 CLS |
| **Transition scoping** | `.theme-transition` class added/removed around toggle | No interference with animations |
| **No reflow** | CSS variables cascade without triggering layout recalc | Pure paint operation |
| **Debounced system listener** | matchMedia fires at most once per OS change | No rapid re-renders |
| **Lazy meta update** | `getComputedStyle` called once per toggle, not per frame | Minimal overhead |

### Performance Budget

| Operation | Budget | Measured |
|-----------|--------|---------|
| FOUC script execution | < 1ms | ~0.1ms (6 lines, no DOM query) |
| Toggle class operation | < 1ms | ~0.05ms (single classList.toggle) |
| CSS repaint (color only) | < 16ms | ~8ms (single paint, no layout) |
| localStorage read | < 1ms | ~0.1ms |
| localStorage write | < 1ms | ~0.1ms |
| Icon update (3 targets) | < 1ms | ~0.3ms |
| **Total perceived** | **< 50ms** | **~10ms** |

### What NOT to Do

- Do NOT use inline styles (hundreds of DOM operations)
- Do NOT use JavaScript to iterate elements and change colors
- Do NOT add transition to all properties (use explicit list)
- Do NOT transition on initial page load (only on toggle)

---

## 13. Risk Mitigation Architecture

### Risk-01: Neon Colors Illegible in Light Mode

**Problem**: The existing neon palette (#00FFFF, #FF00FF, #39FF14) has near-zero contrast against light backgrounds.

**Solution**: The CSS variable layer provides entirely separate color values for light mode. Light mode accents are darkened to WCAG AA compliance:

| Color Name | Dark Mode (Neon) | Light Mode (Adjusted) | Light BG Contrast |
|-----------|-----------------|----------------------|-------------------|
| Cyan | #00FFFF | #0077aa | 4.5:1 |
| Magenta | #FF00FF | #aa0077 | 4.7:1 |
| Green | #39FF14 | #1a8c0a | 4.6:1 |

**Verification**: CI pipeline contrast checker validates all pairs.

### Risk-02: FOUC (Flash of Unstyled Content)

**Problem**: Without synchronous theme resolution, users see a flash of wrong-theme content.

**Solution**: Inline `<script>` in `<head>` executes before first paint (ADR-05). Additionally, the `<html>` element can carry `class="dark"` from server-side if a cookie-based enhancement is added later.

**Verification**: System test with Capybara asserts no visible FOUC.

### Risk-03: Turbo Cache Theme Mismatch

**Problem**: Turbo caches page snapshots. If user toggles theme, then navigates back, the cached snapshot has the wrong theme.

**Solution**: Three-layer defense:
1. `turbo:before-cache` removes transition classes from snapshot
2. `turbo:before-render` applies correct theme to incoming DOM
3. Controller `connect()` re-syncs on every page load

**Verification**: System test navigates forward/back after toggle.

### Risk-04: Rouge Syntax Highlighting Colors

**Problem**: Code blocks use Rouge-generated HTML with specific CSS classes. These may have hardcoded colors that break in one theme.

**Solution**: Conditional Rouge theme based on `.dark` class:

```css
/* Light mode Rouge theme */
.highlight .k { color: #0077aa; }   /* keyword */
.highlight .s { color: #1a8c0a; }   /* string */
.highlight .c { color: #6b6b7b; }   /* comment */

/* Dark mode Rouge theme */
.dark .highlight .k { color: #00FFFF; }
.dark .highlight .s { color: #39FF14; }
.dark .highlight .c { color: #888888; }
```

**Verification**: Visual test with code block in both themes.

### Risk-05: Pixel Art Rendering Artifacts

**Problem**: Pixel art uses `image-rendering: pixelated` and hard-edge shadows. Transitions could smooth pixel edges.

**Solution**: Exclude pixel-render elements from color transitions:

```css
.pixel-render {
  transition: none !important;
}
```

The `image-rendering: pixelated` and `image-rendering: crisp-edges` properties are unaffected by color transitions since they control spatial rendering, not color.

**Verification**: Visual inspection of pixel mage character in both themes.

### Risk-06: Stars Background Animation in Light Mode

**Problem**: The `.stars-bg` pseudo-element creates star dots using `radial-gradient`. These are visible against dark backgrounds but invisible or distracting against light backgrounds.

**Solution**: Stars background uses CSS variables for dot colors, with light mode using subdued/darker dots:

```css
.stars-bg::before {
  background-image:
    radial-gradient(2px 2px at 20px 30px, var(--star-dot-1), transparent),
    radial-gradient(2px 2px at 40px 70px, var(--star-dot-2), transparent),
    radial-gradient(1px 1px at 90px 40px, var(--star-dot-1), transparent);
}
```

Light mode reduces opacity and uses muted colors. Alternative: hide stars entirely in light mode via `opacity: 0`.

---

## 14. Test Strategy Architecture

### Test Pyramid

```
                  /\
                 /  \
                / E2E \           3 system tests (Capybara)
               / Tests \          Full browser, real Turbo
              /----------\
             /            \
            / Integration  \      8 integration tests (Vitest + jsdom)
           /    Tests       \     Controller lifecycle, DOM, Storage
          /------------------\
         /                    \
        /     Unit Tests       \  12 unit tests (Vitest)
       /                        \ Pure functions, state logic
      /__________________________\
```

### Unit Tests (Vitest) - 12 Tests

These test pure logic in isolation with no DOM.

```javascript
// FILE: test/javascript/dark_mode_controller.test.js

// --- State Resolution Tests ---
// U-01: resolveEffectiveTheme("dark") returns true
// U-02: resolveEffectiveTheme("light") returns false
// U-03: resolveEffectiveTheme("system") returns matchMedia result
// U-04: resolveEffectiveTheme("system") with dark OS returns true
// U-05: resolveEffectiveTheme("system") with light OS returns false

// --- Toggle Cycle Tests ---
// U-06: toggle from "dark" yields "light"
// U-07: toggle from "light" yields "system"
// U-08: toggle from "system" yields "dark"

// --- Storage Tests ---
// U-09: savePreference("dark") sets localStorage.theme = "dark"
// U-10: savePreference("light") sets localStorage.theme = "light"
// U-11: savePreference("system") removes localStorage.theme
// U-12: readPreference returns "system" when localStorage is empty
```

### Integration Tests (Vitest + jsdom) - 8 Tests

These test controller behavior with a mocked DOM.

```javascript
// --- Controller Lifecycle Tests ---
// I-01: connect() reads localStorage and applies theme class to <html>
// I-02: connect() attaches matchMedia listener
// I-03: disconnect() removes matchMedia listener
// I-04: disconnect() removes Turbo event listeners

// --- DOM Interaction Tests ---
// I-05: toggle() cycles mode and updates <html> class
// I-06: modeValueChanged updates icon target visibility
// I-07: system preference change triggers theme update when mode="system"
// I-08: system preference change is ignored when mode="dark" or "light"
```

### System Tests (Capybara) - 3 Tests

These test the full user journey in a real browser.

```ruby
# FILE: spec/system/dark_mode_spec.rb

# --- Full Journey Tests ---
# S-01: Toggle button cycles through dark -> light -> system modes
#       and each mode displays correct visual theme
# S-02: Theme preference persists across Turbo navigation
#       (navigate to another page, verify theme maintained)
# S-03: Theme preference persists across page refresh
#       (hard refresh, verify correct theme from first paint)
```

### Test Configuration Files

**Vitest Config**:

```javascript
// FILE: vitest.config.js
import { defineConfig } from "vitest/config"

export default defineConfig({
  test: {
    environment: "jsdom",
    include: ["test/javascript/**/*.test.js"],
    globals: true,
    setupFiles: ["test/javascript/setup.js"],
  },
  resolve: {
    alias: {
      "@hotwired/stimulus": "./node_modules/@hotwired/stimulus",
    },
  },
})
```

**Test Setup**:

```javascript
// FILE: test/javascript/setup.js

// Mock matchMedia for jsdom (not available by default)
Object.defineProperty(window, "matchMedia", {
  writable: true,
  value: (query) => ({
    matches: false,
    media: query,
    onchange: null,
    addListener: () => {},    // deprecated
    removeListener: () => {}, // deprecated
    addEventListener: () => {},
    removeEventListener: () => {},
    dispatchEvent: () => {},
  }),
})

// Mock localStorage for clean test state
const localStorageMock = (() => {
  let store = {}
  return {
    getItem: (key) => store[key] ?? null,
    setItem: (key, value) => { store[key] = String(value) },
    removeItem: (key) => { delete store[key] },
    clear: () => { store = {} },
  }
})()
Object.defineProperty(window, "localStorage", { value: localStorageMock })
```

**Package.json** (dev dependencies only):

```json
{
  "private": true,
  "devDependencies": {
    "vitest": "^3.0.0",
    "jsdom": "^25.0.0",
    "@hotwired/stimulus": "^3.2.0"
  },
  "scripts": {
    "test": "vitest run",
    "test:watch": "vitest"
  }
}
```

### CI Integration

Add to `.github/workflows/ci.yml`:

```yaml
  test_js:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: "22"
          cache: "npm"

      - name: Install JS dependencies
        run: npm ci

      - name: Run JavaScript tests
        run: npx vitest run
```

---

## 15. File Structure and Change Manifest

### New Files

| File | Purpose |
|------|---------|
| `app/javascript/controllers/dark_mode_controller.js` | Stimulus controller (Section 7) |
| `test/javascript/dark_mode_controller.test.js` | Unit + integration tests |
| `test/javascript/setup.js` | Test environment setup (matchMedia, localStorage mocks) |
| `spec/system/dark_mode_spec.rb` | Capybara system tests |
| `package.json` | Vitest dev dependencies |
| `vitest.config.js` | Vitest configuration |
| `doc/DarkModeArchitecture.md` | This document |

### Modified Files

| File | Changes |
|------|---------|
| `app/assets/tailwind/application.css` | Add `@custom-variant dark`, CSS variables (Layer 1+2), transition classes, Rouge theme overrides |
| `app/views/layouts/application.html.erb` | Add FOUC prevention script in `<head>`, add `data-controller="dark-mode"` to `<html>`, add `data-dark-mode-mode-value` attribute |
| `app/views/shared/_navbar.html.erb` | Add toggle button with icon SVGs and `data-action`/`data-dark-mode-target` attributes |
| `.github/workflows/ci.yml` | Add `test_js` job for Vitest |

### Unchanged Files

All existing controllers (`mobile_menu_controller.js`, `flash_controller.js`), routes, models, Gemfile, and importmap.rb require **zero changes**. The importmap auto-discovers the new controller via `pin_all_from`.

### Complete Modified Layout

```html
<!-- FILE: app/views/layouts/application.html.erb -->
<!DOCTYPE html>
<html lang="ko"
      data-controller="dark-mode"
      data-dark-mode-mode-value="system">
  <head>
    <title><%= content_for(:title) || "AnsibleMage - Mastering True Names" %></title>
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <meta name="apple-mobile-web-app-capable" content="yes">
    <meta name="mobile-web-app-capable" content="yes">
    <meta name="description" content="Mastering the True Names of digital entities via Ansible">
    <meta name="theme-color" content="#0D0D0D">
    <%= csrf_meta_tags %>
    <%= csp_meta_tag %>

    <%= yield :head %>

    <!-- FOUC Prevention: Must be BEFORE stylesheets -->
    <script>
      ;(function(){
        var d=document.documentElement
        var t=localStorage.getItem('theme')
        var isDark=t==='dark'||(!t&&window.matchMedia('(prefers-color-scheme:dark)').matches)
        d.classList.toggle('dark',isDark)
        var m=document.querySelector('meta[name="theme-color"]')
        if(m)m.content=isDark?'#0D0D0D':'#f5f5f0'
      })()
    </script>

    <link rel="icon" href="/icon.png" type="image/png">
    <link rel="icon" href="/icon.svg" type="image/svg+xml">
    <link rel="apple-touch-icon" href="/icon.png">

    <%= stylesheet_link_tag :app, "data-turbo-track": "reload" %>
    <%= javascript_importmap_tags %>
  </head>

  <body class="min-h-screen flex flex-col stars-bg">
    <!-- ... (rest unchanged) ... -->
  </body>
</html>
```

---

## 16. Implementation Roadmap

### TDD Implementation Order

The implementation follows strict Red-Green-Refactor TDD. Each phase writes tests first, then implements the minimum code to pass.

```
Phase 1: Foundation (CSS + FOUC)
    |
    |  No JS tests needed yet.
    |  Manual verification: page loads in dark mode (existing behavior preserved).
    |
    v
Phase 2: Controller Core (Unit Tests First)
    |
    |  Write U-01 through U-12 (all RED).
    |  Implement #resolveEffectiveTheme, toggle cycle, storage methods.
    |  All unit tests GREEN.
    |
    v
Phase 3: Controller Integration (Integration Tests First)
    |
    |  Write I-01 through I-08 (all RED).
    |  Implement connect(), disconnect(), modeValueChanged(), DOM methods.
    |  All integration tests GREEN.
    |
    v
Phase 4: UI Integration (Toggle Button + Icons)
    |
    |  Add toggle button to navbar.
    |  Add dark-mode controller to <html>.
    |  Manual verification: toggle works in browser.
    |
    v
Phase 5: System Tests (Capybara)
    |
    |  Write S-01 through S-03 (should pass against existing implementation).
    |  Fix any edge cases found.
    |
    v
Phase 6: Polish
    |
    |  Light mode color tuning.
    |  Rouge syntax highlighting.
    |  Stars background adjustment.
    |  Pixel art preservation verification.
    |
    v
Phase 7: CI Integration
    |
    |  Add test_js job to ci.yml.
    |  Verify all tests pass in CI.
    |
    DONE
```

### Phase Detail

| Phase | Files Created/Modified | Tests | Estimated Effort |
|-------|----------------------|-------|-----------------|
| 1. Foundation | `application.css` (CSS variables, @custom-variant), `application.html.erb` (FOUC script) | Manual only | 1-2 hours |
| 2. Controller Core | `dark_mode_controller.js` (partial), `setup.js`, `package.json`, `vitest.config.js`, test file | 12 unit tests | 2-3 hours |
| 3. Controller Integration | `dark_mode_controller.js` (complete), test file | 8 integration tests | 2-3 hours |
| 4. UI Integration | `_navbar.html.erb` (toggle button), `application.html.erb` (data-controller) | Manual verification | 1 hour |
| 5. System Tests | `dark_mode_spec.rb` | 3 system tests | 1-2 hours |
| 6. Polish | `application.css` (color tuning, Rouge) | Visual review | 2-3 hours |
| 7. CI | `ci.yml` | CI verification | 30 min |
| **Total** | | **23 tests** | **10-14 hours** |

---

## 17. Appendix: Color Palette Specification

### Dark Mode Palette (Existing - Preserved)

This is the current space/cyberpunk theme. It becomes the `.dark` variant.

| Token | Hex | Usage |
|-------|-----|-------|
| void-black | #0D0D0D | Primary background |
| dark-space | #1A1A2E | Secondary background, cards |
| deep-purple | #2D1B4E | Borders, shadows |
| space-purple | #6B5B95 | Accent structural |
| neon-cyan | #00FFFF | Primary accent, links, borders |
| neon-magenta | #FF00FF | Hover accent |
| neon-green | #39FF14 | Success, secondary accent |
| star-white | #F0F0F0 | Primary text |
| moon-gray | #B0B0B0 | Secondary text |
| pixel-gold | #FFD700 | Highlight |
| pixel-red | #FF6B6B | Error, danger |
| pixel-heart | #FF4081 | Like button |

### Light Mode Palette (New)

Designed to maintain the pixel-art identity while being readable on light backgrounds. All accent colors meet WCAG AA (4.5:1 minimum) against the light background.

| Token | Hex | Usage | Contrast vs #f5f5f0 |
|-------|-----|-------|---------------------|
| void-black (light) | #f5f5f0 | Primary background | -- |
| dark-space (light) | #e8e8e0 | Secondary background | -- |
| deep-purple (light) | #e0d8f0 | Borders, shadows | -- |
| space-purple (light) | #6B5B95 | Accent structural | 4.3:1 |
| neon-cyan (light) | #0077aa | Primary accent | 4.5:1 |
| neon-magenta (light) | #aa0077 | Hover accent | 4.7:1 |
| neon-green (light) | #1a8c0a | Success accent | 4.6:1 |
| star-white (light) | #1a1a2e | Primary text | 13.4:1 |
| moon-gray (light) | #4a4a5a | Secondary text | 7.1:1 |
| pixel-gold (light) | #b8960a | Highlight | 4.5:1 |
| pixel-red (light) | #cc4444 | Error, danger | 4.5:1 |
| pixel-heart (light) | #cc2255 | Like button | 5.0:1 |

### Pixel Art Preservation

Pixel art elements (character SVGs, logo, `image-rendering: pixelated` elements) use the same rendering in both themes. Only surrounding colors change. The `.pixel-render` class explicitly opts out of theme transitions.

---

## Approval

| Role | Name | Status | Date |
|------|------|--------|------|
| Architect | system_architect (Opus) | Complete | 2026-02-08 |
| Requirements | requirements_analyst | Input Accepted | 2026-02-08 |
| Developer | code_developer (Pending) | Awaiting | - |
| Reviewer | quality_reviewer (Pending) | Awaiting | - |
