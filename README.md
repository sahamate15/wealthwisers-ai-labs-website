# WealthWisers AI Labs website

The public marketing site for WealthWisers AI Labs: governed AI for India's
financial markets. A static site (plain HTML, one CSS token system, a little
vanilla JavaScript), deployed on Netlify.

## Status
- Phase 1 (this repo): the home page, live on Netlify, plus the downloadable
  event deck as a PDF.
- Phase 2 (after the event): a Samriddhi landing page as the front door to the
  Samriddhi demo, with the demo embedded from its own separate deployment.

## Develop
No build step. Edit the files and preview in a browser:

    python3 -m http.server 8000
    # open http://localhost:8000

Key files: `index.html`, `site.css`, `colors_and_type.css` (design tokens),
`assets/` (optimised imagery), `deck/` (the PDF), `thanks/` (form success page).

## Deploy (Netlify, Git auto-deploy)
Connect this repo in the Netlify UI:
- Build command: none.
- Publish directory: the repository root.

The contact form uses Netlify Forms. The form in `index.html` carries
`data-netlify="true"`, so Netlify detects it on deploy. Add an email
notification to connect@wealthwisers.in in the Netlify dashboard.

## Secrets hygiene (hard rule)
This is a public repo, so no token belongs in it.
- Tokens live in files OUTSIDE the repo and are matched by `.gitignore`.
- `scripts/secret-scan.sh` scans staged content, the working tree, or history.
- The git pre-commit hook runs the scan and a no-long-dash check on each commit.
  Enable hooks after cloning: `git config core.hooksPath scripts/git-hooks`.

## Regenerate the deck PDF

    bash scripts/build-deck-pdf.sh /absolute/path/to/deck-print.html

This renders the print-optimised HTML deck to `deck/samriddhi-ai-labs-deck.pdf`
with headless Chrome.
