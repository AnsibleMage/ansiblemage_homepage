require 'rails_helper'

RSpec.describe "Dark Mode Toggle", type: :system do
  before do
    driven_by(:rack_test)
  end

  describe "Basic Toggle Functionality" do
    it "renders dark mode toggle button in navbar" do
      visit root_path

      # Check toggle button exists
      expect(page).to have_css('[data-action="click->dark-mode#toggle"]')
    end

    it "has correct data attributes for Stimulus controller" do
      visit root_path

      # HTML should have dark-mode controller
      expect(page).to have_css('html[data-controller="dark-mode"]')
    end
  end

  describe "Icon Structure" do
    it "renders both light and dark icons with correct targets" do
      visit root_path

      # Light icon (sun) for showing in dark mode
      expect(page).to have_css('[data-dark-mode-target="lightIcon"]', count: 2) # Desktop + Mobile

      # Dark icon (moon) for showing in light mode
      expect(page).to have_css('[data-dark-mode-target="darkIcon"]', count: 2) # Desktop + Mobile
    end

    it "has moon icon visible by default (light mode)" do
      visit root_path

      # Moon icons should be visible, sun icons hidden
      dark_icons = all('[data-dark-mode-target="darkIcon"]')
      light_icons = all('[data-dark-mode-target="lightIcon"]')

      # Check first instance (desktop)
      expect(light_icons.first[:class]).to include('hidden')
      expect(dark_icons.first[:class]).not_to include('hidden')
    end
  end

  describe "FOUC Prevention Script" do
    it "includes inline script in head for FOUC prevention" do
      visit root_path

      html_content = page.html

      # Check for localStorage theme reading
      expect(html_content).to include("localStorage.getItem('theme')")

      # Check for matchMedia system preference detection
      expect(html_content).to include("prefers-color-scheme: dark")

      # Check for dark class application
      expect(html_content).to include("classList.add('dark')")
    end
  end

  describe "CSS Variables" do
    it "loads CSS stylesheet correctly" do
      visit root_path

      # Verify CSS file is loaded (check head for stylesheet link)
      expect(page.html).to include('stylesheet')
    end
  end

  describe "Turbo Integration" do
    it "persists data-controller across page navigation" do
      visit root_path

      expect(page).to have_css('html[data-controller="dark-mode"]')

      # Navigate to another page
      visit about_path

      # Controller should still be present
      expect(page).to have_css('html[data-controller="dark-mode"]')
    end
  end

  describe "Mobile and Desktop Toggle" do
    it "renders toggle button in both desktop and mobile navigation" do
      visit root_path

      # Should have 2 toggle buttons (desktop + mobile)
      buttons = all('[data-action="click->dark-mode#toggle"]')
      expect(buttons.count).to eq(2)
    end
  end

  describe "Accessibility" do
    it "includes aria-label on toggle button" do
      visit root_path

      toggle_buttons = all('[data-action="click->dark-mode#toggle"]')

      toggle_buttons.each do |button|
        expect(button['aria-label']).to eq('Toggle dark mode')
      end
    end
  end

  describe "Meta Theme Color" do
    it "includes theme-color meta tag" do
      visit root_path

      expect(page).to have_css('meta[name="theme-color"]', visible: false)
    end
  end
end
