#!/usr/bin/env bash
# Secret scanner for the WealthWisers AI Labs website repo.
# Usage:
#   scripts/secret-scan.sh --staged    scan staged changes (pre-commit default)
#   scripts/secret-scan.sh --tree      scan all tracked files
#   scripts/secret-scan.sh --history   scan the entire commit history
# Exit code: 0 clean, 1 a token-shaped string was found.
set -uo pipefail

MODE="${1:---staged}"

# Specific token shapes, kept tight to avoid false positives:
#   GitHub classic PAT   ghp_/gho_/ghu_/ghs_/ghr_ + 36 or more chars
#   GitHub fine-grained  github_pat_ + body
#   Netlify token        nfp_ + 32 to 64 chars
#   AWS access key id    AKIA + 16
#   Private key header   -----BEGIN ... PRIVATE KEY-----
PAT='gh[pousr]_[A-Za-z0-9]{36,255}|github_pat_[A-Za-z0-9_]{22,255}|nfp_[A-Za-z0-9]{32,64}|AKIA[0-9A-Z]{16}|-----BEGIN [A-Z ]*PRIVATE KEY-----'

found=""
case "$MODE" in
  --staged)
    found=$(git diff --cached -U0 --diff-filter=ACMR 2>/dev/null \
      | grep -E '^\+' | grep -vE '^\+\+\+' \
      | grep -nE "$PAT" || true)
    ;;
  --tree)
    while IFS= read -r f; do
      [ -z "$f" ] && continue
      m=$(grep -nIE "$PAT" "$f" 2>/dev/null || true)
      [ -n "$m" ] && found="${found}${f}:\n${m}\n"
    done < <(git ls-files)
    ;;
  --history)
    found=$(git log -p --all 2>/dev/null | grep -nE "$PAT" || true)
    ;;
  *)
    echo "unknown mode: $MODE (use --staged, --tree, or --history)" >&2
    exit 2
    ;;
esac

if [ -n "$found" ]; then
  echo "SECRET SCAN ($MODE): POTENTIAL TOKEN FOUND"
  printf '%b\n' "$found"
  echo ""
  echo "Do not commit or push. Remove the value, and rotate the token if it was real."
  exit 1
fi
echo "secret-scan ($MODE): clean"
exit 0
