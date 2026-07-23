#!/usr/bin/env bash
# Bank one eval leg into the cockpit repo with MAXIMUM durable detail.
#
# The scratchpad workspace and the leg's capture dir are both scratch that dies
# with the VM (proven mortality, AGENTS.md). This copies the full evidence into
# data/<wave>/ so a later evaluator has everything: the structured transcript
# (session JSONL — thinking, tool calls, results, per-turn usage), the agent's
# rendered stdout, the FULL artifact patch (what @planks/@captain it wrote), the
# tree status, the leg meta, and the folded affordance map.
#
# Usage:
#   eval-bank.sh --wave <dir> --name <leg> --out <capture-dir> \
#     [--workspace <sim>] [--verdict <text>]
set -euo pipefail
HERE="$(cd "$(dirname "$0")/.." && pwd)"
WAVE=""; NAME=""; OUT=""; WS=""; VERDICT=""
while [ $# -gt 0 ]; do
  case "$1" in
    --wave) WAVE="$2"; shift 2;;
    --name) NAME="$2"; shift 2;;
    --out) OUT="$2"; shift 2;;
    --workspace) WS="$2"; shift 2;;
    --verdict) VERDICT="$2"; shift 2;;
    *) echo "eval-bank.sh: unknown arg '$1'" >&2; exit 2;;
  esac
done
[ -n "$WAVE" ] && [ -n "$NAME" ] && [ -n "$OUT" ] || { echo "usage: eval-bank.sh --wave <d> --name <n> --out <dir> [--workspace <sim>] [--verdict <t>]" >&2; exit 2; }
[ -d "$OUT" ] || { echo "eval-bank.sh: capture dir '$OUT' missing" >&2; exit 2; }

DEST="$HERE/data/$WAVE"; mkdir -p "$DEST"
P="$DEST/$NAME"

# Structured transcript (full fidelity) + rendered stdout + meta + status.
[ -f "$OUT/session.jsonl" ] && cp "$OUT/session.jsonl" "$P.session.jsonl"
[ -f "$OUT/pi.stdout" ]     && cp "$OUT/pi.stdout"     "$P.stdout.json"
[ -f "$OUT/pi.stderr" ] && [ -s "$OUT/pi.stderr" ] && cp "$OUT/pi.stderr" "$P.stderr.txt"
[ -f "$OUT/leg.json" ]      && cp "$OUT/leg.json"      "$P.leg.json"
[ -f "$OUT/tree.status" ]   && cp "$OUT/tree.status"   "$P.tree.status"
[ -f "$OUT/exit" ]          && cp "$OUT/exit"          "$P.exit"

# Full artifact patch: prefer the leg's own capture; else regenerate from the
# still-present workspace (a leg run under the pre-diff atom left it unstaged).
if [ -f "$OUT/tree.diff" ] && [ -s "$OUT/tree.diff" ]; then
  cp "$OUT/tree.diff" "$P.tree.diff"
elif [ -n "$WS" ] && [ -d "$WS/.git" ]; then
  git -C "$WS" add -A >/dev/null 2>&1 || true
  git -C "$WS" -c core.pager=cat diff --cached > "$P.tree.diff" 2>/dev/null || true
  git -C "$WS" reset -q >/dev/null 2>&1 || true
fi

# Folded affordance map (with a verdict header if given).
{
  echo "# banked: $(date -u +%FT%TZ)"
  [ -n "$VERDICT" ] && echo "# verdict: $VERDICT"
  [ -f "$OUT/leg.json" ] && echo "# leg: $(cat "$OUT/leg.json" | tr -d '\n')"
  echo
  "$HERE/bin/eval-map.py" "$P.session.jsonl" 2>/dev/null || echo "(no session to fold)"
} > "$P.map.txt"

echo "banked $NAME -> $DEST/ ($(ls "$P".* | wc -l) files)"
ls -1 "$P".* | sed 's#.*/#  #'
