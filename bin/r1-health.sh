#!/usr/bin/env bash
# Health watch for a full matrix run. dk's rule (2026-07-28): START OVER ON ANY HICCUP — a
# suspicious table is worth less than the credits a rerun costs. So this reports harness faults
# loudly and distinctly from doctrine signals, and never cries wolf.
#
# A wave is only checked for progress once it is OLD ENOUGH to have produced a session; the
# first version of this fired NO-PROGRESS on all nine waves sixty seconds after launch, before
# any session file existed, which is exactly the false alarm that erodes trust in a monitor.
set -uo pipefail
S=/home/exedev/shipshape-shakedown/.eval-scratch
PREFIX="${1:-R1-}"; IDLE_MIN="${2:-15}"; SEEN=$(mktemp); trap 'rm -f "$SEEN"' EXIT
fire(){ grep -qxF "$1" "$SEEN" || { echo "$2"; echo "$1" >> "$SEEN"; }; }
while :; do
  for log in "$S/$PREFIX"*/driver.log; do
    [ -f "$log" ] || continue
    d=$(dirname "$log"); w=$(basename "$d")
    # harness faults: any of these means the RUN is untrustworthy, not the doctrine
    for sig in 'DISK GUARD' 'PROVIDER ERROR' 'INFRA/VOID' 'self-suite: ?' 'DID NOT RUN' 'UNPARSEABLE'; do
      n=$(grep -c "$sig" "$log" 2>/dev/null | head -1); n=${n:-0}
      [ "${n:-0}" -gt 0 ] && fire "$w|$sig|$n" "HARNESS-FAULT $w: $sig x$n"
    done
    # A leg cut off at the output ceiling. deepseek-v4-flash runs in a 4096 window that pi
    # applies from provider metadata and will not let us override, so truncation there is an
    # expected, tracked property of the model (see .eval-scratch/R2-BUDGET-NOTE.md and
    # bin/peaks.py) and firing on each one is noise. On mimo/hy3, which have 131072, hitting the
    # ceiling means a role ruminated past 131k without acting — that is pathological and loud.
    case "$w" in
      *flash*) : ;;
      *) for s in "$d"/*.out/session/*.jsonl; do
           [ -f "$s" ] || continue
           grep -q '"stopReason":"length"' "$s" 2>/dev/null && fire "$w|trunc|$(basename "$(dirname "$(dirname "$s")")")" \
             "BUDGET-BINDING $w: $(basename "$(dirname "$(dirname "$s")")") hit the output cap"
         done ;;
    esac
    # progress: only once the wave has had time, and only while it is still meant to be running
    started=$(stat -c %Y "$log" 2>/dev/null || echo 0); now=$(date +%s)
    age=$(( (now - started) / 60 ))
    if ! grep -q 'PILOT END' "$log" 2>/dev/null && [ "$age" -ge "$IDLE_MIN" ]; then
      fresh=$(find "$d" -name '*.jsonl' -newermt "-${IDLE_MIN} minutes" 2>/dev/null | head -1)
      [ -z "$fresh" ] && fire "$w|noprogress|$age" "NO-PROGRESS $w: no session writes in ${IDLE_MIN}min"
    fi
  done
  sleep 120
done
