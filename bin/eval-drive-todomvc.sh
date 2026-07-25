#!/usr/bin/env bash
# Autonomously drive ONE new-way TodoMVC pilot to 28/29 using the operator playbook
# (tasks/pilot/operator-presets.md) encoded as an intent selector over prepared intents
# (tasks/pilot/intents/). Build voyage 1, then loop: grade -> pick the intent matching the
# current oracle failures -> run the voyage -> regrade, until 28/29 or a safety breaker.
#
# Breakers (each STOPS and flags for the operator, never spins): voyage cap; no-improvement
# (score AND failing-set unchanged 2x); an unknown failure pattern the intent library does
# not cover. Everything is logged to $BASE/driver.log for the detailed cross-model compare.
set -uo pipefail
HERE="$(cd "$(dirname "$0")/.." && pwd)"
SCRATCH="${EVAL_SCRATCH:-$HERE/.eval-scratch}"
WAVE=""; MODEL=""; SKILLS_DIR=""; YOINK=""; CLONE=""; PORT=8873; MAXV=14; TIMEOUT_S=1500
while [ $# -gt 0 ]; do
  case "$1" in
    --wave) WAVE="$2"; shift 2;;
    --model) MODEL="$2"; shift 2;;
    --skills-dir) SKILLS_DIR="$2"; shift 2;;
    --yoink-skill) YOINK="$2"; shift 2;;
    --clone) CLONE="$2"; shift 2;;
    --port) PORT="$2"; shift 2;;
    --max-voyages) MAXV="$2"; shift 2;;
    --timeout-s) TIMEOUT_S="$2"; shift 2;;
    *) echo "eval-drive-todomvc.sh: unknown arg '$1'" >&2; exit 2;;
  esac
done
[ -n "$WAVE" ] && [ -n "$MODEL" ] && [ -n "$SKILLS_DIR" ] && [ -n "$YOINK" ] && [ -n "$CLONE" ] || {
  echo "usage: eval-drive-todomvc.sh --wave <d> --model <id> --skills-dir <root> --yoink-skill <dir> --clone <oracle-clone> [--port N] [--max-voyages N]" >&2; exit 2; }

BASE="$SCRATCH/$WAVE"; SIM="$BASE/sim"; LOG="$BASE/driver.log"
rm -rf "$BASE"; mkdir -p "$BASE"
I="$HERE/tasks/pilot/intents"
say(){ echo "[$(date -u +%FT%TZ)] $*" | tee -a "$LOG"; }

# Toolkit (cucumber + happy-dom + yoink) — same store the other pilots use.
SHARED_NM="$SCRATCH/.shared-nm"
if [ ! -e "$SHARED_NM/node_modules/@cucumber" ] || [ ! -e "$SHARED_NM/node_modules/happy-dom" ]; then
  ( cd "$SHARED_NM" && [ -f package.json ] || npm init -y >/dev/null 2>&1
    npm install --no-fund --no-audit --save-dev @cucumber/cucumber @dk/yoink happy-dom c8 jsdoc knip @biomejs/biome >/dev/null 2>&1 \
    || npm install --no-fund --no-audit @cucumber/cucumber "$HOME/yoink" happy-dom c8 jsdoc knip @biomejs/biome >/dev/null 2>&1 )
fi
export EVAL_SHARED_NM="$SHARED_NM/node_modules"

say "PILOT START wave=$WAVE model=$MODEL clone=$CLONE port=$PORT max=$MAXV"
if ! "$HERE/bin/scaffold-todomvc.sh" "$SIM" >"$BASE/scaffold.log" 2>&1; then say "SCAFFOLD FAILED"; echo PILOT-DONE; exit 4; fi

grade(){ # -> writes $BASE/vN-oracle.txt ; echoes "passing tests"
  local v="$1"
  "$HERE/bin/oracle-grade.sh" --build "$SIM" --out "$BASE/$v-oracle.txt" --clone "$CLONE" --port "$PORT" >"$BASE/$v-oraclerun.log" 2>&1 || true
  local p t; p=$(grep -oE 'passing=[0-9]+' "$BASE/$v-oracle.txt" 2>/dev/null | head -1 | cut -d= -f2)
  t=$(grep -oE 'tests=[0-9]+' "$BASE/$v-oracle.txt" 2>/dev/null | head -1 | cut -d= -f2)
  echo "${p:-0} ${t:-29}"
}
titles(){ sed -n '/## failing tests/,/## /p' "$BASE/$1-oracle.txt" 2>/dev/null | grep '^  - ' | sed 's/^  - //'; }

LAST_INTENT=""
pick_intent(){ # $1=passing  $2=titles(lowercased, newline)
  local passing="$1" t="$2"
  if [ "${passing:-0}" -le 1 ] || echo "$t" | grep -qE 'before each|initially opened|focus on the todo'; then echo page; return; fi
  [ -f "$SIM/index.html" ] || { echo page; return; }
  if echo "$t" | grep -qE 'rout|filter|active route|completed route|selected|preserved on reload|persist|hides it in the'; then echo routing; return; fi
  if echo "$t" | grep -qE 'mark items as complete|un-mark|mark all|clear the complete state|hide other controls when editing'; then echo domidentity; return; fi
  if echo "$t" | grep -qE 'edit an item|save edits on blur|trim entered text|empty text string|editing'; then
    if [ "$LAST_INTENT" != "editreentrancy" ] && [ "$LAST_INTENT" != "editorder" ]; then echo editreentrancy; return; fi
    if [ "$LAST_INTENT" = "editreentrancy" ]; then echo editorder; return; fi
    echo unknown; return
  fi
  echo unknown
}

run_voyage(){ # $1=voyage#  $2=captain-task-file  $3=extra(eg --no-revert)
  local v="$1" task="$2" extra="${3:-}"; local t0 t1
  t0=$(date +%s)
  # shellcheck disable=SC2086
  "$HERE/bin/eval-voyage.sh" --wave "$WAVE" --sim "$SIM" --model "$MODEL" \
    --skills-dir "$SKILLS_DIR" --yoink-skill "$YOINK" --voyage "$v" \
    --captain-task "$task" --timeout-s "$TIMEOUT_S" $extra >"$BASE/v$v.log" 2>&1
  t1=$(date +%s); echo $((t1-t0))
}

# ---- Voyage 1: build ----
say "VOYAGE 1 (build)"
w=$(run_voyage 1 "$HERE/tasks/pilot/captain-todomvc.task.md" "--no-revert")
if grep -q 'PROVIDER ERROR' "$BASE/v1.log" 2>/dev/null; then say "PROVIDER ERROR on build — STOP"; echo PILOT-DONE; exit 5; fi
ss=$(tail -3 "$BASE/v1-selfsuite.txt" 2>/dev/null | grep -oE '[0-9]+ scenarios \([^)]*\)' | head -1)
read -r p t <<<"$(grade v1)"
say "V1 build ${w}s | self-suite: ${ss:-?} | oracle ${p}/${t} | failing:"; titles v1 | sed 's/^/    /' | tee -a "$LOG" >/dev/null

# ---- Iterate ----
prev_p=-1; prev_titles=""; stuck=0
for v in $(seq 2 "$MAXV"); do
  if [ "${p:-0}" -ge 28 ]; then say "REACHED ${p}/${t} — DONE"; break; fi
  tl=$(titles v$((v-1)) | tr 'A-Z' 'a-z')
  intent=$(pick_intent "$p" "$tl")
  if [ "$intent" = "unknown" ]; then say "UNKNOWN failure pattern at ${p}/${t} — STOP for operator:"; titles v$((v-1)) | sed 's/^/    /' | tee -a "$LOG" >/dev/null; break; fi
  say "VOYAGE $v (intent=$intent)"
  w=$(run_voyage "$v" "$I/$intent.md")
  if grep -q 'PROVIDER ERROR' "$BASE/v$v.log" 2>/dev/null; then say "PROVIDER ERROR — STOP"; break; fi
  outcome=$(grep -oE 'VOYAGE-(COMPLETE|REGRESSED)' "$BASE/v$v.log" | tail -1)
  ss=$(tail -3 "$BASE/v$v-selfsuite.txt" 2>/dev/null | grep -oE '[0-9]+ scenarios \([^)]*\)' | head -1)
  read -r p t <<<"$(grade v$v)"
  cur_titles=$(titles v$v)
  say "V$v $intent ${w}s | $outcome | self-suite: ${ss:-?} | oracle ${p}/${t} | failing:"; echo "$cur_titles" | sed 's/^/    /' | tee -a "$LOG" >/dev/null
  LAST_INTENT="$intent"
  # no-improvement breaker
  if [ "${p:-0}" = "$prev_p" ] && [ "$cur_titles" = "$prev_titles" ]; then
    stuck=$((stuck+1)); say "  (no change vs prior voyage: stuck=$stuck)"
    if [ "$stuck" -ge 2 ]; then say "NO IMPROVEMENT 2x at ${p}/${t} — STOP for operator"; break; fi
  else stuck=0; fi
  prev_p="$p"; prev_titles="$cur_titles"
done

say "PILOT END wave=$WAVE final=${p}/${t}"
echo "PILOT-DONE"
