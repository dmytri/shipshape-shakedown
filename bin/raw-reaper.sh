#!/usr/bin/env bash
# Cap raw pi.stdout while legs run. pi's json-mode stream re-emits accumulated state per event, so
# one leg reached 18G from 27 shell calls (FIT-py-mimo, 2026-07-26) and took the disk to 98% with
# three other legs live. The DURABLE layer is session.jsonl (328K for that same leg), tree.diff and
# the maps; raw is for BorgBase and is expendable in place.
CAP_MB="${CAP_MB:-1024}"
while :; do
  find /home/exedev/shipshape-shakedown/.eval-scratch -name pi.stdout -size +${CAP_MB}M 2>/dev/null | while read -r f; do
    : > "$f"   # truncate in place: the writer keeps its fd, the leg continues, the disk is returned
    echo "[$(date -u +%FT%TZ)] reaped $f (>${CAP_MB}M)"
  done
  free=$(df -Pk / | awk 'NR==2{print $4}')
  [ "${free:-0}" -lt 5242880 ] && find /home/exedev/shipshape-shakedown/.eval-scratch -name pi.stdout -size +200M -exec sh -c ': > "$1"' _ {} \; 2>/dev/null
  sleep 30
done
