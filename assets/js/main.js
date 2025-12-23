// Harbour Tiling — Minimal site JS (no frameworks)
// Mobile nav toggle + dropdown menus + accessibility

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
    // -------------------------------------------------------------------------
    // Mobile nav toggle
    // -------------------------------------------------------------------------
    var toggle = document.getElementById('nav-toggle');
    var navList = document.getElementById('nav-list');

    if (toggle && navList) {
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
        if (e.target && e.target.tagName === 'A' && !e.target.closest('.nav-item-dropdown')) {
          closeMenu();
        }
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
    }

    // -------------------------------------------------------------------------
    // Dropdown menus
    // -------------------------------------------------------------------------
    var dropdownToggles = document.querySelectorAll('.nav-dropdown-toggle');

    dropdownToggles.forEach(function (dropdownToggle) {
      var dropdown = dropdownToggle.nextElementSibling;
      if (!dropdown) return;

      function openDropdown() {
        dropdownToggle.setAttribute('aria-expanded', 'true');
        dropdown.classList.add('is-open');
      }

      function closeDropdown() {
        dropdownToggle.setAttribute('aria-expanded', 'false');
        dropdown.classList.remove('is-open');
      }

      function toggleDropdown(e) {
        e.preventDefault();
        e.stopPropagation();
        var isExpanded = dropdownToggle.getAttribute('aria-expanded') === 'true';
        
        // Close all other dropdowns first
        dropdownToggles.forEach(function (otherToggle) {
          if (otherToggle !== dropdownToggle) {
            otherToggle.setAttribute('aria-expanded', 'false');
            var otherDropdown = otherToggle.nextElementSibling;
            if (otherDropdown) otherDropdown.classList.remove('is-open');
          }
        });

        if (isExpanded) {
          closeDropdown();
        } else {
          openDropdown();
        }
      }

      // Click to toggle
      dropdownToggle.addEventListener('click', toggleDropdown);

      // Desktop hover behavior (only on larger screens)
      var parent = dropdownToggle.parentElement;
      
      parent.addEventListener('mouseenter', function () {
        if (window.innerWidth >= 1024) {
          openDropdown();
        }
      });

      parent.addEventListener('mouseleave', function () {
        if (window.innerWidth >= 1024) {
          closeDropdown();
        }
      });

      // Close dropdown when clicking a link inside it
      dropdown.addEventListener('click', function (e) {
        if (e.target && e.target.tagName === 'A') {
          closeDropdown();
          // Also close mobile menu if open
          if (navList && navList.classList.contains('is-open')) {
            navList.classList.remove('is-open');
            if (toggle) {
              toggle.classList.remove('is-active');
              toggle.setAttribute('aria-expanded', 'false');
            }
          }
        }
      });

      // Keyboard navigation
      dropdownToggle.addEventListener('keydown', function (e) {
        if (e.key === 'Enter' || e.key === ' ') {
          toggleDropdown(e);
        }
        if (e.key === 'Escape') {
          closeDropdown();
          dropdownToggle.focus();
        }
      });
    });

    // Close dropdowns when clicking outside
    document.addEventListener('click', function (e) {
      dropdownToggles.forEach(function (dropdownToggle) {
        var parent = dropdownToggle.parentElement;
        if (!parent.contains(e.target)) {
          dropdownToggle.setAttribute('aria-expanded', 'false');
          var dropdown = dropdownToggle.nextElementSibling;
          if (dropdown) dropdown.classList.remove('is-open');
        }
      });
    });

    // Close dropdowns on ESC
    document.addEventListener('keydown', function (e) {
      if (e.key === 'Escape') {
        dropdownToggles.forEach(function (dropdownToggle) {
          dropdownToggle.setAttribute('aria-expanded', 'false');
          var dropdown = dropdownToggle.nextElementSibling;
          if (dropdown) dropdown.classList.remove('is-open');
        });
      }
    });

    // -------------------------------------------------------------------------
    // Web3Forms AJAX submission
    // -------------------------------------------------------------------------
    var contactForms = document.querySelectorAll('.contact-form');

    contactForms.forEach(function (form) {
      form.addEventListener('submit', function (e) {
        e.preventDefault();

        var statusEl = form.querySelector('.form-status');
        var submitBtn = form.querySelector('button[type="submit"]');
        var originalBtnText = submitBtn ? submitBtn.textContent : 'Submit';

        // Show loading state
        if (statusEl) {
          statusEl.className = 'form-status is-loading';
          statusEl.textContent = 'Sending...';
        }
        if (submitBtn) {
          submitBtn.disabled = true;
          submitBtn.textContent = 'Sending...';
        }

        var formData = new FormData(form);

        fetch(form.action, {
          method: 'POST',
          body: formData
        })
          .then(function (response) {
            return response.json();
          })
          .then(function (data) {
            if (data.success) {
              // Success
              form.classList.add('is-submitted');
              if (statusEl) {
                statusEl.className = 'form-status is-success';
                statusEl.innerHTML = '<strong>Thank you!</strong> Your message has been sent. I\'ll get back to you within one business day.';
              }
              form.reset();
            } else {
              // API returned error
              throw new Error(data.message || 'Form submission failed');
            }
          })
          .catch(function (error) {
            // Error
            if (statusEl) {
              statusEl.className = 'form-status is-error';
              statusEl.innerHTML = '<strong>Sorry, something went wrong.</strong> Please try again or email <a href="mailto:info@harbourtiling.com.au">info@harbourtiling.com.au</a> directly.';
            }
            if (submitBtn) {
              submitBtn.disabled = false;
              submitBtn.textContent = originalBtnText;
            }
            console.error('Form error:', error);
          });
      });
    });
  });
})();
