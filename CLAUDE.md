# WealthWisers AI Labs website

Static marketing site for WealthWisers AI Labs. Plain HTML, one CSS token
system, a little vanilla JavaScript. No framework, no build step. Deployed on
Netlify by Git auto-deploy.

## Hard rules
- Secrets never enter this repo. Tokens (GitHub, Netlify) live in files OUTSIDE
  the repo. `.gitignore` and `scripts/secret-scan.sh` are the guardrails, and
  the git pre-commit hook runs the scan automatically.
- No long dashes anywhere (no em dash, no en dash, no horizontal bar). Use
  commas, semicolons, colons, periods. The pre-commit hook enforces this.
- No emoji and no hype vocabulary. The voice is rigorous, plain, and specific.
- Decision support, not advice. Keep the site-wide disclaimer intact.

## Layout
- `index.html`, `site.css`, `colors_and_type.css`: the home page and its styles.
- `assets/`: logos, hero image, partner logos, team photos (web optimised).
- `deck/samriddhi-ai-labs-deck.pdf`: the downloadable event deck.
- `thanks/`: the contact-form success page.
- `scripts/`: `secret-scan.sh` and `build-deck-pdf.sh`, plus `git-hooks/pre-commit`.
- `.claude/`: project hooks and the `site-hygiene-audit` subagent.

## Common tasks
- Preview locally: open `index.html`, or run `python3 -m http.server 8000`.
- Regenerate the deck PDF: `bash scripts/build-deck-pdf.sh /path/to/deck-print.html`.
- Scan for secrets: `bash scripts/secret-scan.sh --tree` (also `--history`).
- Enable git hooks after cloning: `git config core.hooksPath scripts/git-hooks`.

## Not in this repo
- The Samriddhi demo is a separate live application (phase 2). This site will
  link to and embed that deployment; the demo code is never vendored here.
- The open-source demo at samriddhi-ai-demo.vercel.app is a different project.
  This commercial site does not depend on it.
