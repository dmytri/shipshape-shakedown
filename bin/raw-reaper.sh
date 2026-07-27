#!/usr/bin/env bash
# Cap raw pi.stdout while legs run. pi's json-mode stream re-emits accumulated state per event, so
# one leg reached 18G from 27 shell calls (FIT-py-mimo, 2026-07-26) and took the disk to 98% with
# three other legs live. The DURABLE layer is session.jsonl (328K for that same leg), tree.diff and
# the maps; raw is for BorgBase and is expendable in place.
CAP_MB="${CAP_MB:-1024}"
SCRATCH=/home/exedev/shipshape-shakedown/.eval-scratch
while :; do
  find "$SCRATCH" -name pi.stdout -size +${CAP_MB}M 2>/dev/null | while read -r f; do
    : > "$f"   # truncate in place: the writer keeps its fd, the leg continues, the disk is returned
    echo "[$(date -u +%FT%TZ)] reaped $f (>${CAP_MB}M)"
  done

  # BUILD TREES, the bigger leak (2026-07-27): a sim's target/, node_modules/ and .venv/ survive the
  # leg that made them, and one cargo target is 1.6-1.8G. Twenty waves of that reached 41G, none of
  # it durable and none of it in the scoring path - scores read RIGGING.md and the recorded
  # method-*.out. Only reap a wave whose leg has ENDED, so a live leg keeps its toolchain.
  for w in "$SCRATCH"/M-*/; do
    grep -q "FITOUT END" "$w/fitout.log" 2>/dev/null || continue
    for d in "$w"sim/target "$w"sim/node_modules "$w"sim/.venv; do
      [ -d "$d" ] && [ ! -L "$d" ] || continue
      rm -rf "$d" && echo "[$(date -u +%FT%TZ)] reaped $d (build tree, leg ended)"
    done
  done
  free=$(df -Pk / | awk 'NR==2{print $4}')
  [ "${free:-0}" -lt 5242880 ] && find /home/exedev/shipshape-shakedown/.eval-scratch -name pi.stdout -size +200M -exec sh -c ': > "$1"' _ {} \; 2>/dev/null
  sleep 30
done
