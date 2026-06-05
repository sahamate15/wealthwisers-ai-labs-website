/* WealthWisers AI Labs, shared contact-form behaviour.
   Loaded on every page that carries the inline "contact" form.
   1. Any "Request a conversation" link (href="#contact-form") smooth-scrolls
      to the form on the current page and focuses the Name field. If the form
      is already in view it simply focuses, no jump.
   2. Name is the only required field; on an empty submit we show a gentle
      inline message instead of the browser's default bubble. */
(function () {
  function init() {
    var form = document.getElementById('contact-form');

    // 1. Scroll-to-form for every in-page "Request a conversation" trigger.
    var links = document.querySelectorAll('a[href="#contact-form"]');
    Array.prototype.forEach.call(links, function (a) {
      a.addEventListener('click', function (e) {
        if (!form) return;
        e.preventDefault();
        var first = form.querySelector('input[name="name"]');
        var rect = form.getBoundingClientRect();
        var inView = rect.top >= 0 && rect.bottom <= (window.innerHeight || document.documentElement.clientHeight);
        if (!inView) {
          form.scrollIntoView({ behavior: 'smooth', block: 'center' });
        }
        if (first) {
          setTimeout(function () {
            try { first.focus({ preventScroll: true }); } catch (_) { first.focus(); }
          }, inView ? 0 : 450);
        }
        if (window.history && history.replaceState) history.replaceState(null, '', '#contact-form');
      });
    });

    if (!form) return;

    // 2. Gentle inline validation for the only required field (Name).
    var nameField = form.querySelector('input[name="name"]');
    var err = form.querySelector('.cf-err');
    if (nameField) {
      nameField.addEventListener('invalid', function (e) {
        e.preventDefault();
        nameField.classList.add('is-invalid');
        if (err) err.hidden = false;
        nameField.focus();
      });
      nameField.addEventListener('input', function () {
        nameField.classList.remove('is-invalid');
        if (err) err.hidden = true;
      });
    }
  }

  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', init);
  else init();
})();
