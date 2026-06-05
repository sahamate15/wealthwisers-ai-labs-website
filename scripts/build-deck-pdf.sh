#!/usr/bin/env bash
# Render the print-optimised HTML deck to a clean PDF with headless Chrome.
# The deck source lives OUTSIDE this repo (in the design deliverable folder),
# so pass its absolute path, or set DECK_PRINT_HTML.
# Output: deck/samriddhi-ai-labs-deck.pdf
#
# Two workarounds are baked in:
#  - The deck path contains spaces, which Chrome's file:// loader mishandles, so
#    we render through a space-free symlink under a temp dir.
#  - Headless Chrome can fail to EXIT after it has written the PDF, so we poll
#    for the finished file and stop Chrome ourselves, capped by DECK_TIMEOUT.
set -uo pipefail
ROOT="$(git rev-parse --show-toplevel)"
OUT="$ROOT/deck/samriddhi-ai-labs-deck.pdf"
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
TIMEOUT="${DECK_TIMEOUT:-60}"

SRC="${1:-${DECK_PRINT_HTML:-}}"
if [ -z "$SRC" ] || [ ! -f "$SRC" ]; then
  echo "Usage: scripts/build-deck-pdf.sh /absolute/path/to/deck-print.html" >&2
  echo "(or set DECK_PRINT_HTML). The deck source is kept outside this repo." >&2
  exit 1
fi

SRC_DIR="$(cd "$(dirname "$SRC")" && pwd)"
SRC_FILE="$(basename "$SRC")"
LINK_DIR="$(mktemp -d)"; LINK="$LINK_DIR/src"; ln -s "$SRC_DIR" "$LINK"
PROFILE="$(mktemp -d)"
TMP_PDF="$(mktemp -d)/deck.pdf"

"$CHROME" --headless=new --disable-gpu --no-sandbox --no-pdf-header-footer \
  --no-first-run --no-default-browser-check \
  --user-data-dir="$PROFILE" \
  --virtual-time-budget=15000 \
  --print-to-pdf="$TMP_PDF" \
  "file://$LINK/$SRC_FILE" >/dev/null 2>&1 &
CPID=$!

# Poll for a stable (finished) PDF, then stop Chrome. Bounded by TIMEOUT.
ok=0
for _ in $(seq 1 "$TIMEOUT"); do
  if [ -s "$TMP_PDF" ]; then
    a=$(stat -f%z "$TMP_PDF" 2>/dev/null || echo 0); sleep 1
    b=$(stat -f%z "$TMP_PDF" 2>/dev/null || echo 0)
    if [ "$a" = "$b" ] && [ "$a" -gt 1000 ]; then ok=1; break; fi
  else
    kill -0 "$CPID" 2>/dev/null || break
    sleep 1
  fi
done

kill -9 "$CPID" >/dev/null 2>&1 || true
pkill -9 -f "$PROFILE" >/dev/null 2>&1 || true
wait "$CPID" 2>/dev/null || true

mkdir -p "$ROOT/deck"
if [ "$ok" = "1" ] && [ -s "$TMP_PDF" ]; then
  cp "$TMP_PDF" "$OUT"
  echo "Wrote $OUT"
else
  echo "Deck render failed: no stable PDF within ${TIMEOUT}s." >&2
  exit 1
fi
