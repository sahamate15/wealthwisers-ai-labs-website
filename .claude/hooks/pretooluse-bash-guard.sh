#!/usr/bin/env bash
# Defense in depth: before a git commit or push, run the secret scan over the
# tracked files. Blocks (exit 2) only on a definite hit. Reads hook JSON on stdin.
set -uo pipefail
input="$(cat)"
cmd="$(printf '%s' "$input" | python3 -c 'import sys,json; print(json.load(sys.stdin).get("tool_input",{}).get("command",""))' 2>/dev/null || true)"
root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
[ -z "$root" ] && exit 0
case "$cmd" in
  *"git commit"*|*"git push"*)
    bash "$root/scripts/secret-scan.sh" --tree >/dev/null 2>&1
    rc=$?
    if [ "$rc" -eq 1 ]; then
      echo "Blocked: secret-scan found a token-shaped string in tracked files." >&2
      echo "Run: bash scripts/secret-scan.sh --tree" >&2
      exit 2
    fi
    ;;
esac
exit 0
