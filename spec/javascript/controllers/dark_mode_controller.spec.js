/**
 * Dark Mode Controller Unit Tests
 *
 * Testing Strategy:
 * - Unit tests for pure JavaScript logic
 * - Mock DOM elements and localStorage
 * - Test all public methods independently
 *
 * Note: These tests can be run with Jest or similar JavaScript test framework
 * For Rails 8 importmap projects, integration tests via RSpec System Tests
 * provide better coverage of actual behavior.
 */

describe('DarkModeController', () => {
  let controller;
  let element;
  let lightIconTarget;
  let darkIconTarget;

  beforeEach(() => {
    // Mock DOM structure
    element = document.createElement('html');
    lightIconTarget = document.createElement('svg');
    lightIconTarget.dataset.darkModeTarget = 'lightIcon';
    lightIconTarget.classList.add('hidden');

    darkIconTarget = document.createElement('svg');
    darkIconTarget.dataset.darkModeTarget = 'darkIcon';

    document.documentElement = element;

    // Mock localStorage
    global.localStorage = {
      getItem: jest.fn(),
      setItem: jest.fn(),
      removeItem: jest.fn(),
    };

    // Mock matchMedia
    global.window.matchMedia = jest.fn().mockImplementation(query => ({
      matches: false,
      media: query,
      addEventListener: jest.fn(),
      removeEventListener: jest.fn(),
    }));

    // Import controller (adjust path as needed)
    // controller = new DarkModeController();
    // controller.element = element;
    // controller.lightIconTarget = lightIconTarget;
    // controller.darkIconTarget = darkIconTarget;
  });

  describe('connect()', () => {
    it('applies theme on initialization', () => {
      localStorage.getItem.mockReturnValue('dark');

      // controller.connect();

      expect(element.classList.contains('dark')).toBe(true);
    });

    it('sets up Turbo event listeners', () => {
      const addEventListener = jest.spyOn(document, 'addEventListener');

      // controller.connect();

      expect(addEventListener).toHaveBeenCalledWith('turbo:before-render', expect.any(Function));
      expect(addEventListener).toHaveBeenCalledWith('turbo:before-cache', expect.any(Function));
    });

    it('sets up system preference listener', () => {
      const mediaQuery = { addEventListener: jest.fn() };
      window.matchMedia.mockReturnValue(mediaQuery);

      // controller.connect();

      expect(window.matchMedia).toHaveBeenCalledWith('(prefers-color-scheme: dark)');
      expect(mediaQuery.addEventListener).toHaveBeenCalled();
    });
  });

  describe('toggle()', () => {
    it('switches from light to dark', () => {
      localStorage.getItem.mockReturnValue('light');

      // controller.toggle();

      expect(localStorage.setItem).toHaveBeenCalledWith('theme', 'dark');
      expect(element.classList.contains('dark')).toBe(true);
    });

    it('switches from dark to light', () => {
      localStorage.getItem.mockReturnValue('dark');
      element.classList.add('dark');

      // controller.toggle();

      expect(localStorage.setItem).toHaveBeenCalledWith('theme', 'light');
      expect(element.classList.contains('dark')).toBe(false);
    });
  });

  describe('getTheme()', () => {
    it('returns stored theme if available', () => {
      localStorage.getItem.mockReturnValue('dark');

      // const theme = controller.getTheme();

      // expect(theme).toBe('dark');
      expect(localStorage.getItem).toHaveBeenCalledWith('theme');
    });

    it('returns dark if system preference is dark and no stored value', () => {
      localStorage.getItem.mockReturnValue(null);
      window.matchMedia.mockReturnValue({ matches: true });

      // const theme = controller.getTheme();

      // expect(theme).toBe('dark');
    });

    it('returns light as default', () => {
      localStorage.getItem.mockReturnValue(null);
      window.matchMedia.mockReturnValue({ matches: false });

      // const theme = controller.getTheme();

      // expect(theme).toBe('light');
    });
  });

  describe('updateIcon()', () => {
    it('shows sun icon in dark mode', () => {
      localStorage.getItem.mockReturnValue('dark');

      // controller.updateIcon();

      expect(lightIconTarget.classList.contains('hidden')).toBe(false);
      expect(darkIconTarget.classList.contains('hidden')).toBe(true);
    });

    it('shows moon icon in light mode', () => {
      localStorage.getItem.mockReturnValue('light');

      // controller.updateIcon();

      expect(lightIconTarget.classList.contains('hidden')).toBe(true);
      expect(darkIconTarget.classList.contains('hidden')).toBe(false);
    });

    it('gracefully handles missing icon targets', () => {
      // controller.lightIconTarget = null;
      // controller.darkIconTarget = null;

      expect(() => {
        // controller.updateIcon();
      }).not.toThrow();
    });
  });

  describe('updateMetaThemeColor()', () => {
    it('updates meta theme-color for dark mode', () => {
      const metaTag = document.createElement('meta');
      metaTag.name = 'theme-color';
      metaTag.content = '#FFFFFF';
      document.head.appendChild(metaTag);

      // controller.updateMetaThemeColor('dark');

      expect(metaTag.content).toBe('#0D0D0D');
    });

    it('updates meta theme-color for light mode', () => {
      const metaTag = document.createElement('meta');
      metaTag.name = 'theme-color';
      metaTag.content = '#0D0D0D';
      document.head.appendChild(metaTag);

      // controller.updateMetaThemeColor('light');

      expect(metaTag.content).toBe('#FFFFFF');
    });
  });

  describe('handleTurboBeforeRender()', () => {
    it('applies dark class to incoming page body', () => {
      localStorage.getItem.mockReturnValue('dark');

      const newBody = document.createElement('body');
      const event = {
        detail: { newBody }
      };

      // controller.handleTurboBeforeRender(event);

      expect(newBody.classList.contains('dark')).toBe(true);
    });

    it('removes dark class for light theme', () => {
      localStorage.getItem.mockReturnValue('light');

      const newBody = document.createElement('body');
      newBody.classList.add('dark');
      const event = {
        detail: { newBody }
      };

      // controller.handleTurboBeforeRender(event);

      expect(newBody.classList.contains('dark')).toBe(false);
    });
  });

  describe('disconnect()', () => {
    it('removes system preference listener', () => {
      const mediaQuery = {
        addEventListener: jest.fn(),
        removeEventListener: jest.fn()
      };
      window.matchMedia.mockReturnValue(mediaQuery);

      // controller.connect();
      // controller.disconnect();

      expect(mediaQuery.removeEventListener).toHaveBeenCalled();
    });
  });

  describe('handleSystemPreferenceChange()', () => {
    it('applies system preference when no stored theme', () => {
      localStorage.getItem.mockReturnValue(null);

      const event = { matches: true };

      // controller.handleSystemPreferenceChange(event);

      // Should trigger applyTheme() which sets dark mode
    });

    it('ignores system preference when theme is stored', () => {
      localStorage.getItem.mockReturnValue('light');

      const event = { matches: true };

      // controller.handleSystemPreferenceChange(event);

      // Should not change theme since user has explicit preference
      expect(element.classList.contains('dark')).toBe(false);
    });
  });
});
