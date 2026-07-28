#!/usr/bin/env bash
# Standing attention trigger (dk, 2026-07-28): a STALL or a REGRESSION in any wave's trajectory
# must pull the operator's attention immediately — not when someone thinks to ask why a cell is
# stuck. Every stall this session had a cause in OUR harness, and each one cost voyages while it
# went unexamined:
#   - 27/29 x4      the grader stripped the stylesheet the page links (oracle-grade.sh)
#   - 26 -> 23 x2   custody was committed after a guard that OOM-killed the script
#   - 23/29 x4      Captain legs truncated at 4096 output tokens, exit 0, logged VOYAGE-COMPLETE
#   - 0/29 x12      the fixture let a suite pass over an empty js/
# None of those were the doctrine's. All were visible in the trajectory the moment they began.
#
# Emits one line per NEW event, so it is safe to leave running:
#   STALL <wave> at <score> repeated <n>x
#   REGRESSION <wave> <prev> -> <now>
#   ENDED <wave> <final>
#
# usage: watch-waves.sh [interval-seconds]   (default 90; scans every wave under .eval-scratch)
set -uo pipefail
SCRATCH=/home/exedev/shipshape-shakedown/.eval-scratch
INTERVAL="${1:-90}"
STATE=$(mktemp)
trap 'rm -f "$STATE"' EXIT

seen(){ grep -qxF "$1" "$STATE" 2>/dev/null; }
mark(){ echo "$1" >> "$STATE"; }

while :; do
  for log in "$SCRATCH"/*/driver.log; do
    [ -f "$log" ] || continue
    wave=$(basename "$(dirname "$log")")
    scores=$(grep -oE 'oracle [0-9]+/29' "$log" 2>/dev/null | awk '{print $2}' | cut -d/ -f1)
    [ -n "$scores" ] || continue
    last=$(echo "$scores" | tail -1)
    prev=$(echo "$scores" | tail -2 | head -1)
    n=$(echo "$scores" | grep -cx "$last")

    # REGRESSION: the score went down. Always worth attention — it is either the roles breaking
    # their own build, or (every instance so far) us losing their work.
    if [ -n "$prev" ] && [ "$prev" -gt "$last" ] 2>/dev/null; then
      key="REG:$wave:$prev:$last:$(echo "$scores" | wc -l)"
      seen "$key" || { echo "REGRESSION $wave $prev -> $last"; mark "$key"; }
    fi

    # STALL: the same score twice or more in a row, and not yet at the ceiling.
    if [ "$n" -ge 2 ] && [ "$last" -lt 28 ] 2>/dev/null; then
      key="STALL:$wave:$last:$n"
      seen "$key" || { echo "STALL $wave at $last repeated ${n}x"; mark "$key"; }
    fi

    if grep -q 'PILOT END' "$log" 2>/dev/null; then
      key="END:$wave:$(grep -c 'PILOT END' "$log")"
      seen "$key" || { echo "ENDED $wave $(grep -oE 'PILOT END.*' "$log" | tail -1 | cut -c1-80)"; mark "$key"; }
    fi
  done
  sleep "$INTERVAL"
done
