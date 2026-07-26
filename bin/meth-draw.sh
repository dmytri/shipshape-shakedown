#!/usr/bin/env bash
# ONE build-voyage draw for the composite-METHODS A/B, with no oracle involved.
#
# The methods candidate's question is mechanistic and per-checkpoint: at the QM verify checkpoint
# and the Boatswain hygiene checkpoint, does a composite method specified in RIGGING.md collapse
# the command set into ONE invocation, and is it run at all? Both checkpoints live in the
# QM-assumes-rest BUILD leg, and correction voyages barely reach them (2026-07-26: under the
# oracle-correction playbook Captain fixes the app itself and QM reports "deck at rest" in three
# shell calls). So the cheap, high-n instrument is the build voyage alone: scaffold, Captain, QM,
# audit. No oracle clone, no port, no grade — a draw costs a few cents and runs in parallel.
#
# usage: meth-draw.sh --wave <tag> --model <id> --skills-dir <root> --rigging <file> [--timeout-s N]
set -uo pipefail
HERE="$(cd "$(dirname "$0")/.." && pwd)"
SCRATCH="${EVAL_SCRATCH:-$HERE/.eval-scratch}"
WAVE=""; MODEL="xiaomi/mimo-v2.5"; SKILLS_DIR=""; RIGGING=""; TIMEOUT_S=1200
while [ $# -gt 0 ]; do
  case "$1" in
    --wave) WAVE="$2"; shift 2;;
    --model) MODEL="$2"; shift 2;;
    --skills-dir) SKILLS_DIR="$2"; shift 2;;
    --rigging) RIGGING="$2"; shift 2;;
    --timeout-s) TIMEOUT_S="$2"; shift 2;;
    *) echo "meth-draw.sh: unknown arg '$1'" >&2; exit 2;;
  esac
done
[ -n "$WAVE" ] && [ -n "$SKILLS_DIR" ] && [ -n "$RIGGING" ] || {
  echo "usage: meth-draw.sh --wave <tag> --model <id> --skills-dir <root> --rigging <file>" >&2; exit 2; }

BASE="$SCRATCH/$WAVE"; SIM="$BASE/sim"; LOG="$BASE/draw.log"
rm -rf "$BASE"; mkdir -p "$BASE"
say(){ echo "[$(date -u +%FT%TZ)] $*" | tee -a "$LOG"; }

# Dedicated toolkit copy per draw: concurrent bwrap --tmp-overlay on one shared lowerdir
# intermittently fails "Can't make overlay mount" (documented, glm 2026-07-25).
NM="$SCRATCH/.shared-nm-$WAVE"
if [ ! -d "$NM/node_modules" ]; then
  mkdir -p "$NM"; cp -a "$SCRATCH/.shared-nm/node_modules" "$NM/" || { say "toolkit copy failed"; exit 3; }
fi
export EVAL_SHARED_NM="$NM/node_modules"
node "$EVAL_SHARED_NM/@dk/yoink/dist/cli.js" --run 'true' >/dev/null 2>&1 \
  || { say "toolkit yoink cannot run a flag-form plan — a composite method would fail per command"; exit 3; }

say "DRAW START wave=$WAVE model=$MODEL rigging=$(basename "$RIGGING") skills=$(basename "$(dirname "$SKILLS_DIR")")/$(basename "$SKILLS_DIR")"
RIGGING_TEMPLATE="$RIGGING" "$HERE/bin/scaffold-todomvc.sh" "$SIM" >"$BASE/scaffold.log" 2>&1 \
  || { say "SCAFFOLD FAILED"; exit 4; }

t0=$(date +%s)
"$HERE/bin/eval-voyage.sh" --wave "$WAVE" --sim "$SIM" --model "$MODEL" --skills-dir "$SKILLS_DIR" \
  --voyage 1 --captain-task "$HERE/tasks/pilot/captain-todomvc.task.md" \
  --timeout-s "$TIMEOUT_S" --no-revert >"$BASE/v1.log" 2>&1
rc=$?
t1=$(date +%s)
ss=$(grep -oE '[0-9]+ scenarios \([^)]*\)' "$BASE/v1-selfsuite.txt" 2>/dev/null | head -1)
say "DRAW BUILT $((t1-t0))s rc=$rc | self-suite: ${ss:-?}"
if grep -q 'PROVIDER ERROR' "$BASE/v1.log" 2>/dev/null; then say "PROVIDER ERROR — draw void"; echo DRAW-DONE; exit 5; fi
if grep -qE 'INFRA/VOID' "$BASE/v1.log" 2>/dev/null; then say "INFRA/VOID — draw void"; echo DRAW-DONE; exit 6; fi

for leg in v1-captain v1-qm; do
  f=$(ls "$BASE/$leg.out/session"/*.jsonl 2>/dev/null | head -1)
  [ -n "$f" ] || { say "$leg: NO SESSION"; continue; }
  say "$leg $(python3 "$HERE/bin/cluster-audit.py" --leg "$f" | sed -n '3p')"
done
say "DRAW END wave=$WAVE"
echo DRAW-DONE
