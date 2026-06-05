/* WealthWisers AI Labs, shared contact-form behaviour.
   Loaded on every page that carries the inline "contact" form
   (home, /demo/, both walkthroughs, and /contact).

   1. Submits the form to the Google Apps Script web app, which writes a row
      to a Google Sheet. Apps Script does not return a CORS-readable response,
      so the request is sent with mode:'no-cors' and success is shown
      optimistically once the fetch resolves.
   2. Any "Request a conversation" link (href="#contact-form") smooth-scrolls
      to the form on the current page and focuses the Name field.
   3. Name is the only required field; an empty submit shows a gentle inline
      message instead of the browser's default bubble. */
(function () {
  var ENDPOINT = 'https://script.google.com/macros/s/AKfycbwat3l0oMxDGPcrSycyIyjbbNusJi_dGuEdrgK5DFhwPxd3heryPvhV-G2aX3BKeolS/exec';

  function init() {
    var form = document.getElementById('contact-form');

    // 2. Scroll-to-form for every in-page "Request a conversation" trigger.
    var links = document.querySelectorAll('a[href="#contact-form"]');
    Array.prototype.forEach.call(links, function (a) {
      a.addEventListener('click', function (e) {
        if (!form) return;
        e.preventDefault();
        var first = form.querySelector('input[name="name"]');
        var rect = form.getBoundingClientRect();
        var inView = rect.top >= 0 && rect.bottom <= (window.innerHeight || document.documentElement.clientHeight);
        if (!inView) form.scrollIntoView({ behavior: 'smooth', block: 'center' });
        if (first) setTimeout(function () {
          try { first.focus({ preventScroll: true }); } catch (_) { first.focus(); }
        }, inView ? 0 : 450);
        if (window.history && history.replaceState) history.replaceState(null, '', '#contact-form');
      });
    });

    if (!form) return;

    // 3. Gentle inline validation for the only required field (Name).
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

    // 1. Submit to Google Sheets. Native "required" on Name gates empty
    //    submits (the submit event does not fire when Name is blank).
    form.addEventListener('submit', function (e) {
      e.preventDefault();
      var btn = form.querySelector('button[type="submit"]');
      if (btn) { btn.disabled = true; btn.textContent = 'Sending...'; }

      var val = function (n) { var el = form.querySelector('[name="' + n + '"]'); return el ? el.value : ''; };
      var payload = {
        name: val('name'),
        firm: val('firm'),
        email: val('email'),
        phone: val('phone'),
        message: val('message'),
        page: val('page')
      };

      fetch(ENDPOINT, {
        method: 'POST',
        mode: 'no-cors',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload)
      }).then(function () {
        form.innerHTML = '<p class="form-success">Thank you. We will be in touch shortly.</p>';
      }).catch(function () {
        if (btn) { btn.disabled = false; btn.textContent = 'Request a conversation'; }
        var e2 = form.querySelector('.form-error');
        if (!e2) { e2 = document.createElement('p'); e2.className = 'form-error'; form.appendChild(e2); }
        e2.textContent = 'Something went wrong. Please try again in a moment.';
      });
    });
  }

  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', init);
  else init();
})();
