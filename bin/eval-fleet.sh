#!/usr/bin/env bash
# Staggered frontier-cohort runner with a disk governor. Runs a QUEUE of models one at a time
# (concurrency 1 by default) so total in-flight pilots stay bounded and the disk never fills
# (the 2026-07-25 ENOSPC that faked a "shipwright regression"). A background pruner drops raw
# pi.stdout/stderr of COMPLETED legs (>3 min idle) — session.jsonl is the durable layer, so the
# raw transcript is disposable once a leg has banked and its provider-error guard has run.
#
# usage: eval-fleet.sh "tag:model:port" "tag:model:port" ...
set -uo pipefail
HERE="$(cd "$(dirname "$0")/.." && pwd)"
SCRATCH="$HERE/.eval-scratch"
SK="$HERE/experiments/yoink-settle/skills"
BASECLONE="$SCRATCH/oracle-clone"
FLOG="$SCRATCH/fleet.log"
say(){ echo "[$(date -u +%FT%TZ)] fleet: $*" | tee -a "$FLOG"; }
free_g(){ df -Pk / | awk 'NR==2{printf "%.2f",$4/1048576}'; }

# --- background disk pruner: raw stdout of legs idle >3min, plus a hard sweep under 2.5G ---
pruner(){
  while :; do
    find "$SCRATCH"/todomvc-* -name 'pi.stdout' -mmin +3 -delete 2>/dev/null
    find "$SCRATCH"/todomvc-* -name 'pi.stderr' -mmin +3 -delete 2>/dev/null
    local f; f=$(df -Pk / | awk 'NR==2{print $4}')
    if [ "${f:-0}" -lt 2621440 ]; then   # <2.5G: emergency — drop ALL raw stdout + screenshots/videos
      find "$SCRATCH"/todomvc-* -name 'pi.stdout' -delete 2>/dev/null
      rm -rf "$SCRATCH"/oracle-clone*/cypress/screenshots "$SCRATCH"/oracle-clone*/cypress/videos 2>/dev/null
      say "PRUNER emergency sweep (<2.5G) — free now $(free_g)G"
    fi
    sleep 45
  done
}
pruner & PRUNER_PID=$!
trap 'kill $PRUNER_PID 2>/dev/null' EXIT
say "START queue=[$*] free=$(free_g)G pruner=$PRUNER_PID"

for spec in "$@"; do
  tag="${spec%%:*}"; rest="${spec#*:}"; model="${rest%:*}"; port="${rest##*:}"
  clone="$SCRATCH/oracle-clone-$tag"; nm="$SCRATCH/.shared-nm-$tag"
  say "=== $tag ($model) port=$port — free=$(free_g)G ==="
  # cheap dedicated oracle clone (181M; shares the global Cypress binary cache in ~/.cache)
  [ -d "$clone/cypress" ] || cp -a "$BASECLONE" "$clone"
  # dedicated app node_modules to dodge the concurrent overlay-mount race
  [ -e "$nm/node_modules/.bin/skills" ] || { mkdir -p "$nm"; cp -a "$SCRATCH/.shared-nm/node_modules" "$nm/"; cp -a "$SCRATCH/.shared-nm/package.json" "$nm/" 2>/dev/null; }
  DRIVER_SHARED_NM="$nm" "$HERE/bin/eval-drive-todomvc.sh" --wave "todomvc-$tag" --model "$model" \
    --skills-dir "$SK" --clone "$clone" --port "$port" --max-voyages 14 \
    >"$SCRATCH/todomvc-$tag.nohup" 2>&1
  say "=== $tag DONE ($(tail -1 "$SCRATCH/todomvc-$tag/driver.log" 2>/dev/null | cut -c1-70)) free=$(free_g)G ==="
  # reclaim this model's raw transcripts immediately; keep the committed sim + driver.log
  find "$SCRATCH/todomvc-$tag" -name 'pi.stdout' -delete 2>/dev/null
done
say "QUEUE COMPLETE free=$(free_g)G"
