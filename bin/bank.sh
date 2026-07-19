#!/usr/bin/env bash
# Bank a leg's mined summary into the cockpit repo. Raw transcripts die with the
# VM (proven 2026-07-19: pilot #4's fold is unrecoverable), so the thin layer is
# banked SAME-SESSION and committed with the session record; BorgBase holds raw.
# Usage: bank.sh <wave> <transcript.jsonl> [legname]
# Writes data/<wave>/<legname>.<agentid8>.txt (meta header + mine.sh audit).
set -euo pipefail
HERE="$(cd "$(dirname "$0")/.." && pwd)"
WAVE="${1:?usage: bank.sh <wave> <transcript.jsonl> [legname]}"
F="${2:?usage: bank.sh <wave> <transcript.jsonl> [legname]}"
META="${F%.jsonl}.meta.json"
NAME="${3:-}"
if [ -z "$NAME" ] && [ -f "$META" ]; then
  NAME=$(jq -r '.description // empty' "$META" | tr -cs 'A-Za-z0-9.' '-' | sed 's/^-*//;s/-*$//' | cut -c1-60)
fi
AID="$(basename "$F" .jsonl)"; AID="${AID#agent-}"
[ -n "$NAME" ] || NAME="$AID"
OUT="$HERE/data/$WAVE/$NAME.${AID:0:8}.txt"
mkdir -p "$(dirname "$OUT")"
{
  [ -f "$META" ] && echo "# meta: $(cat "$META")"
  echo "# source: $F"
  echo "# banked: $(date -u +%FT%TZ)"
  "$HERE/bin/mine.sh" "$F" "$NAME"
} > "$OUT"
echo "$OUT"
