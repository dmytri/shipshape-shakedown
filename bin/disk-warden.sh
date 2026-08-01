#!/usr/bin/env bash
# Continuous disk warden. Replaces raw-reaper.sh, which only truncated pi.stdout above 1G and
# reaped M-*/sim build trees — it missed the two things that actually fill this box.
#
# MEASURED 2026-07-28, at 99% full with the pilot mid-run:
#   toolkit copies   1.6G   one 265M node_modules per arm, copied not shared
#   oracle clones    1.1G   one per arm
#   live waves       3.9G   and inside ONE wave: v11-qm.out=411M, v9-qm.out=196M, v1-qm.out=4M
# The per-leg spread is the tell. A leg's capture dir holds its isolated HOME, and that HOME
# carries XDG_CACHE_HOME — so every leg downloads and caches npm/npx packages PRIVATELY. We were
# storing a fresh package cache per leg, ~26 legs per wave, plus raw pi.stdout that json-mode
# streaming inflates without bound.
#
# What survives is the durable layer and nothing else: session.jsonl, the session/ dir, tree.diff,
# tree.status, leg.json, maps, driver.log, oracle grades. Raw stdout belongs on BorgBase; a leg's
# package cache belongs nowhere.
#
# usage: disk-warden.sh [--once]        (default: loop every 30s)
set -uo pipefail
SCRATCH=/home/exedev/shipshape-shakedown/.eval-scratch

# HARD RAILS. A cleanup script once deleted things it had no business touching (dk, and it cost
# real work). This one may only ever write inside .eval-scratch, and it refuses to start if that
# is not exactly what SCRATCH is. Everything below deletes via paths rooted at $SCRATCH; nothing
# here may reach ~/.claude (the installed plugin IS the control arm's doctrine), ~/shipshape (the
# real doctrine), data/ (the durable layer), experiments/, or any consumer repo.
FORBIDDEN=("$HOME/.claude" "$HOME/shipshape" "$HOME/shipshape-shakedown/data"
           "$HOME/shipshape-shakedown/experiments" "$HOME/yoink" "$HOME/jolly" "$HOME/swamp" "$HOME")
case "$SCRATCH" in
  /home/exedev/shipshape-shakedown/.eval-scratch) : ;;
  *) echo "disk-warden: SCRATCH is not the cockpit scratch dir — refusing to run" >&2; exit 2 ;;
esac
[ -d "$SCRATCH" ] || { echo "disk-warden: $SCRATCH missing — refusing to run" >&2; exit 2; }
for f in "${FORBIDDEN[@]}"; do
  case "$SCRATCH" in "$f"|"$f"/) echo "disk-warden: SCRATCH resolves to a protected path — refusing" >&2; exit 2;; esac
done
# every deletion goes through this, so a bad glob cannot escape the scratch dir
safe_rm(){
  local p="$1"
  case "$p" in
    "$SCRATCH"/*) : ;;
    *) echo "disk-warden: REFUSED to delete outside scratch: $p" >&2; return 1 ;;
  esac
  for f in "${FORBIDDEN[@]}"; do
    case "$p" in "$f"|"$f"/*) echo "disk-warden: REFUSED protected path: $p" >&2; return 1 ;; esac
  done
  rm -rf -- "$p"
}
IDLE_MIN="${IDLE_MIN:-3}"        # a file untouched this long belongs to a leg that has moved on
STDOUT_CAP_MB="${STDOUT_CAP_MB:-200}"
LOW_G="${LOW_G:-10}"             # below this, escalate
CRIT_G="${CRIT_G:-5}"            # below this, take everything expendable

say(){ echo "[$(date -u +%FT%TZ)] warden: $*"; }
free_g(){ df -Pk / | awk 'NR==2{printf "%.1f",$4/1048576}'; }

sweep() {
  # 1. raw stdout: cap while live, delete once the leg has ACTUALLY FINISHED.
  #
  # Defect 17 (2026-08-01). This used `-mmin +$IDLE_MIN -delete`, reading "file not written for
  # a while" as "the leg has moved on". It is not: a leg thinking, or waiting on the provider,
  # writes nothing for many minutes. The warden then unlinked the stdout of a LIVE leg and pi
  # went on writing into a deleted inode -- caught red-handed on R14, where
  #   /proc/<pi>/fd/1 -> .../v1-captain.out/pi.stdout (deleted)
  # Three costs: no live window into a running leg (every stall so far took a 3600s timeout to
  # discover instead of a glance); the raw capture destroyed for precisely the slow legs worth
  # inspecting; and eval-leg.sh's 429-retry check greps pi.stdout, so with the file gone a
  # rate-limited leg silently never retries.
  #
  # eval-leg.sh writes $OUT/exit when the leg returns, so that file -- not mtime -- says whether
  # a leg is done. Truncation stays unconditional: it reclaims the bytes without unlinking, so a
  # live leg keeps its fd and simply continues.
  find "$SCRATCH" -name 'pi.stdout' -size +${STDOUT_CAP_MB}M -exec sh -c ': > "$1"' _ {} \; 2>/dev/null
  find "$SCRATCH" -name 'pi.stdout' -mmin +"$IDLE_MIN" -print0 2>/dev/null | while IFS= read -r -d '' f; do
    [ -e "$(dirname "$f")/exit" ] || continue   # leg still running: never unlink a live capture
    rm -f -- "$f" "$(dirname "$f")/pi.stderr"
  done

  # 2. THE BIG ONE: per-leg package caches inside each leg's isolated HOME. Nothing downstream
  #    reads them; they exist only because each leg gets a private XDG_CACHE_HOME.
  find "$SCRATCH" -type d -path '*.out/home/.cache' -mmin +"$IDLE_MIN" -prune -exec rm -rf {} + 2>/dev/null
  find "$SCRATCH" -type d -path '*.out/home/.npm' -mmin +"$IDLE_MIN" -prune -exec rm -rf {} + 2>/dev/null
  find "$SCRATCH" -type d -path '*.out/home/tmp' -mmin +"$IDLE_MIN" -prune -exec rm -rf {} + 2>/dev/null

  # 3. build trees under a sim whose wave has ended: node_modules, target, .venv, coverage.
  for w in "$SCRATCH"/*/; do
    log="$w/driver.log"
    [ -f "$log" ] || continue
    grep -q 'PILOT END' "$log" 2>/dev/null || continue
    for d in "$w"sim/node_modules "$w"sim/target "$w"sim/.venv "$w"sim/coverage; do
      [ -d "$d" ] && [ ! -L "$d" ] && rm -rf "$d" 2>/dev/null
    done
  done

  # 4. oracle clones keep screenshots/videos even with both disabled; drop them unconditionally.
  rm -rf "$SCRATCH"/oracle-clone*/cypress/screenshots "$SCRATCH"/oracle-clone*/cypress/videos 2>/dev/null
}

escalate() {
  say "LOW ($(free_g)G) — dropping raw stdout and leg homes wholesale"
  find "$SCRATCH" -name 'pi.stdout' -delete 2>/dev/null
  find "$SCRATCH" -type d -path '*.out/home' -mmin +"$IDLE_MIN" -prune -exec rm -rf {} + 2>/dev/null
}

critical() {
  say "CRITICAL ($(free_g)G) — reclaiming ENDED waves already banked under data/"
  for w in "$SCRATCH"/*/; do
    name=$(basename "$w")
    [ -f "$w/driver.log" ] || continue
    grep -q 'PILOT END' "$w/driver.log" 2>/dev/null || continue
    [ -d "/home/exedev/shipshape-shakedown/data/$name" ] || continue
    rm -rf "$w" && say "reclaimed $name (banked in data/)"
  done
}

run_once() {
  sweep
  f=$(free_g)
  awk -v f="$f" -v l="$LOW_G" 'BEGIN{exit !(f+0 < l+0)}' && escalate
  f=$(free_g)
  awk -v f="$f" -v c="$CRIT_G" 'BEGIN{exit !(f+0 < c+0)}' && critical
}

if [ "${1:-}" = "--once" ]; then
  before=$(free_g); run_once; say "one-shot: ${before}G -> $(free_g)G free"; exit 0
fi

say "start (cap ${STDOUT_CAP_MB}M, idle ${IDLE_MIN}min, low ${LOW_G}G, crit ${CRIT_G}G) — free $(free_g)G"
while :; do
  before=$(free_g)
  run_once
  after=$(free_g)
  awk -v a="$before" -v b="$after" 'BEGIN{exit !(b-a > 0.5)}' && say "reclaimed $(awk -v a="$before" -v b="$after" 'BEGIN{printf "%.1f", b-a}')G — free ${after}G"
  sleep 30
done
