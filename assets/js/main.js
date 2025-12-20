// Harbour Tiling — Minimal site JS (no frameworks)
// Mobile nav toggle + accessibility

(function () {
  'use strict';

  function ready(fn) {
    if (document.readyState === 'loading') {
      document.addEventListener('DOMContentLoaded', fn);
    } else {
      fn();
    }
  }

  ready(function () {
    var toggle = document.getElementById('nav-toggle');
    var navList = document.getElementById('nav-list');

    if (!toggle || !navList) return;

    function setOpen(isOpen) {
      navList.classList.toggle('is-open', isOpen);
      toggle.classList.toggle('is-active', isOpen);
      toggle.setAttribute('aria-expanded', isOpen ? 'true' : 'false');
      toggle.setAttribute('aria-label', isOpen ? 'Close menu' : 'Open menu');
    }

    function isOpen() {
      return navList.classList.contains('is-open');
    }

    function toggleMenu(e) {
      if (e) {
        e.preventDefault();
        e.stopPropagation();
      }
      setOpen(!isOpen());
    }

    function closeMenu() {
      setOpen(false);
    }

    // Click/tap
    toggle.addEventListener('click', toggleMenu);

    // Some Android browsers can be finicky with delayed click events
    toggle.addEventListener(
      'touchstart',
      function (e) {
        toggleMenu(e);
      },
      { passive: false }
    );

    // Close on link activation
    navList.addEventListener('click', function (e) {
      if (e.target && e.target.tagName === 'A') closeMenu();
    });

    // Close on ESC
    document.addEventListener('keydown', function (e) {
      if (e.key === 'Escape' && isOpen()) {
        closeMenu();
        toggle.focus();
      }
    });

    // Close when switching to desktop
    window.addEventListener('resize', function () {
      if (window.innerWidth >= 1024) closeMenu();
    });

    // Close if clicking outside
    document.addEventListener('click', function (e) {
      if (!isOpen()) return;
      if (toggle.contains(e.target) || navList.contains(e.target)) return;
      closeMenu();
    });

    // Initialise
    closeMenu();
  });
})();
