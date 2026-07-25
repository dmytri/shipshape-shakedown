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
WAVE=""; MODEL=""; SKILLS_DIR=""; YOINK=""; CLONE=""; PORT=8873; MAXV=14; TIMEOUT_S=1500; RESUME_FROM=0
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
    --resume-from) RESUME_FROM="$2"; shift 2;;   # keep existing sim, skip build, start at voyage N
    *) echo "eval-drive-todomvc.sh: unknown arg '$1'" >&2; exit 2;;
  esac
done
[ -n "$WAVE" ] && [ -n "$MODEL" ] && [ -n "$SKILLS_DIR" ] && [ -n "$CLONE" ] || {
  echo "usage: eval-drive-todomvc.sh --wave <d> --model <id> --skills-dir <root> --yoink-skill <dir> --clone <oracle-clone> [--port N] [--max-voyages N]" >&2; exit 2; }

BASE="$SCRATCH/$WAVE"; SIM="$BASE/sim"; LOG="$BASE/driver.log"
[ "$RESUME_FROM" -gt 0 ] || rm -rf "$BASE"
mkdir -p "$BASE"
I="$HERE/tasks/pilot/intents"
say(){ echo "[$(date -u +%FT%TZ)] $*" | tee -a "$LOG"; }

# Toolkit (cucumber + happy-dom + yoink + skills). DRIVER_SHARED_NM overrides the store so
# parallel pilots can use DEDICATED node_modules copies — concurrent bwrap --tmp-overlay on a
# single shared lowerdir intermittently fails "Can't make overlay mount" (glm, 2026-07-25).
SHARED_NM="${DRIVER_SHARED_NM:-$SCRATCH/.shared-nm}"
if [ ! -e "$SHARED_NM/node_modules/@cucumber" ] || [ ! -e "$SHARED_NM/node_modules/happy-dom" ] || [ ! -e "$SHARED_NM/node_modules/.bin/skills" ]; then
  ( cd "$SHARED_NM" && [ -f package.json ] || npm init -y >/dev/null 2>&1
    npm install --no-fund --no-audit --save-dev @cucumber/cucumber @dk/yoink happy-dom skills c8 jsdoc knip @biomejs/biome >/dev/null 2>&1 \
    || npm install --no-fund --no-audit @cucumber/cucumber "$HOME/yoink" happy-dom skills c8 jsdoc knip @biomejs/biome >/dev/null 2>&1 )
fi
export EVAL_SHARED_NM="$SHARED_NM/node_modules"
[ -x "$EVAL_SHARED_NM/.bin/skills" ] || { echo "eval-drive: 'skills' CLI missing from toolkit" >&2; exit 3; }

say "PILOT START wave=$WAVE model=$MODEL clone=$CLONE port=$PORT max=$MAXV resume=$RESUME_FROM"
if [ "$RESUME_FROM" -eq 0 ]; then
  if ! "$HERE/bin/scaffold-todomvc.sh" "$SIM" >"$BASE/scaffold.log" 2>&1; then say "SCAFFOLD FAILED"; echo PILOT-DONE; exit 4; fi
else
  [ -d "$SIM/.git" ] || { say "RESUME: sim missing at $SIM"; echo PILOT-DONE; exit 4; }
fi

grade(){ # -> writes $BASE/vN-oracle.txt ; echoes "passing tests"
  local v="$1"
  "$HERE/bin/oracle-grade.sh" --build "$SIM" --out "$BASE/$v-oracle.txt" --clone "$CLONE" --port "$PORT" >"$BASE/$v-oraclerun.log" 2>&1 || true
  local p t; p=$(grep -oE 'passing=[0-9]+' "$BASE/$v-oracle.txt" 2>/dev/null | head -1 | cut -d= -f2)
  t=$(grep -oE 'tests=[0-9]+' "$BASE/$v-oracle.txt" 2>/dev/null | head -1 | cut -d= -f2)
  echo "${p:-0} ${t:-29}"
}
titles(){ sed -n '/## failing tests/,/## /p' "$BASE/$1-oracle.txt" 2>/dev/null | grep '^  - ' | sed 's/^  - //'; }

LAST_INTENT=""
pick_intent(){ # $1=passing  $2=titles(lowercased, newline). MAJORITY-based: the group with
  # the most failing tests wins (a single residual must not hijack the whole voyage, e.g. one
  # "Routing -- back button" fail stealing a voyage from 5 checkbox fails — the v1 selector bug).
  local passing="$1" t="$2"
  # page/crash override
  if [ "${passing:-0}" -le 1 ] || echo "$t" | grep -qE 'before each|initially opened|focus on the todo'; then echo page; return; fi
  [ -f "$SIM/index.html" ] || { echo page; return; }
  local c_dom c_edithide c_edit c_route c_back
  c_dom=$(echo "$t"     | grep -cE 'mark items as complete|un-mark items|mark all items|clear the complete state')
  c_edithide=$(echo "$t"| grep -cE 'hide other controls when editing')
  c_edit=$(echo "$t"    | grep -cE 'edit an item|save edits on blur|trim entered text|empty text string')
  c_route=$(echo "$t"   | grep -cE 'active filter|completed filter|active route|completed route|selected class|preserved on reload|persist|hides it in the (active|completed)|display active|display completed|highlight the currently')
  c_back=$(echo "$t"    | grep -cE 'back button|forward button|history')
  # winner = the group with the most failures; on a TIE, CYCLE (prefer a group != last intent)
  # so a 1-1-1 residual split doesn't repeat one intent forever (deepseek stuck at 25/29).
  local best="" bestn=0 g n grp intent
  # map group -> the intent it dispatches (editing resolves reentrancy-then-order below)
  for pair in "dom:$c_dom" "edithide:$c_edithide" "edit:$c_edit" "route:$c_route" "back:$c_back"; do
    n="${pair##*:}"; [ "$n" -gt "$bestn" ] && bestn="$n"
  done
  [ "$bestn" -eq 0 ] && { echo unknown; return; }
  # collect tied groups (count==bestn), in priority order, mapped to their intent
  local tied=()
  for pair in "dom:domidentity:$c_dom" "edithide:edithide:$c_edithide" "edit:EDIT:$c_edit" "route:routing:$c_route" "back:backbutton:$c_back"; do
    grp="${pair%%:*}"; intent="$(echo "$pair"|cut -d: -f2)"; n="${pair##*:}"
    [ "$n" -eq "$bestn" ] && tied+=("$intent")
  done
  # editing intent resolves to reentrancy first, then order
  resolve(){ if [ "$1" = "EDIT" ]; then if [ "$LAST_INTENT" = "editreentrancy" ]; then echo editorder; else echo editreentrancy; fi; else echo "$1"; fi; }
  # pick the first tied intent whose resolved value != LAST_INTENT; else the first
  local pick=""
  for intent in "${tied[@]}"; do local r; r="$(resolve "$intent")"; if [ "$r" != "$LAST_INTENT" ]; then pick="$r"; break; fi; done
  [ -n "$pick" ] || pick="$(resolve "${tied[0]}")"
  echo "$pick"
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

# --- Shipwright harbour pass + planking evaluation (dk: evaluate the role, don't grade the
# artifact myself). Runs a Shipwright leg over the current sim, commits its harbour output,
# and audits WHERE its @planks landed: on the nearest seam (correct) vs hoisted to the file
# top (the observed non-conformance). Reverts if it breaks the self-suite. ---
YSK=(); [ -n "$YOINK" ] && YSK=(--skill "$YOINK")
audit_planks(){ # -> "planks=N on-seam=X hoisted=Y | @captain=C @conformance=K"
  python3 - "$SIM" <<'PY'
import sys,re,glob,os
sim=sys.argv[1]; app=os.path.join(sim,"js","app.js")
try: lines=open(app).read().splitlines()
except Exception: print("planks=NO-APP.JS"); raise SystemExit
fn=[i for i,l in enumerate(lines) if re.search(r'\bfunction\b|=>|^\s*[A-Za-z_$][\w$]*\s*\(',l)]
firstfn=fn[0] if fn else None
fnset=set(fn)
planks=[i for i,l in enumerate(lines) if '@planks' in l]
onseam=hoisted=0
for p in planks:
    if firstfn is not None and p<firstfn: hoisted+=1; continue
    onseam += 1 if any((p+d) in fnset for d in range(0,4)) else 0
    if not any((p+d) in fnset for d in range(0,4)): hoisted+=1
cap=con=0
for f in glob.glob(os.path.join(sim,"features","**","*.feature"),recursive=True):
    t=open(f).read(); cap+=t.count("@captain"); con+=t.count("@conformance")
print(f"planks={len(planks)} on-seam={onseam} hoisted={hoisted} | @captain={cap} @conformance={con}")
PY
}
run_shipwright(){ # $1=label
  local label="$1" out="$BASE/sw-$label.out" t0 t1 committed=no prehead
  prehead="$(git -C "$SIM" rev-parse HEAD 2>/dev/null)"
  t0=$(date +%s)
  sed "s#PROJECT_ROOT_PLACEHOLDER#$SIM#g" "$HERE/tasks/pilot/shipwright.task.md" > "$BASE/sw-$label.task"
  "$HERE/bin/eval-leg.sh" --model "$MODEL" --workspace "$SIM" --out "$out" \
    --skill "$SKILLS_DIR/shipshape" --skill "$SKILLS_DIR/shipwright" "${YSK[@]}" \
    --task-file "$BASE/sw-$label.task" --name "sw-$label" --timeout-s "$TIMEOUT_S" >"$BASE/sw-$label.leg.log" 2>&1 || true
  t1=$(date +%s)
  git -C "$SIM" add -A >/dev/null 2>&1 || true
  [ -n "$(git -C "$SIM" status --porcelain)" ] && { git -C "$SIM" -c user.name="Sim Operator" -c user.email="sim@example.test" commit -qm "shipwright harbour ($label)" >/dev/null 2>&1 && committed=yes; }
  local audit; audit="$(audit_planks)"
  # keep the sim GREEN — a harbour pass that breaks the self-suite is reverted (measured, not merged)
  rm -rf "$SIM/node_modules"; ln -s "$EVAL_SHARED_NM" "$SIM/node_modules"
  local ss; ss=$( ( cd "$SIM" && npx cucumber-js 2>&1 | tail -3 ) | grep -oE '[0-9]+ scenarios \([^)]*\)' | head -1 )
  rm -f "$SIM/node_modules"; mkdir -p "$SIM/node_modules"
  if echo "$ss" | grep -qE 'failed'; then git -C "$SIM" reset --hard "$prehead" >/dev/null 2>&1 || true; committed="reverted(self-suite red)"; fi
  say "SHIPWRIGHT[$label] $((t1-t0))s | committed=$committed | self-suite:${ss:-?} | $audit"
}

# ---- Voyage 1: build (skipped on resume) ----
if [ "$RESUME_FROM" -eq 0 ]; then
  say "VOYAGE 1 (build)"
  w=$(run_voyage 1 "$HERE/tasks/pilot/captain-todomvc.task.md" "--no-revert")
  if grep -q 'PROVIDER ERROR' "$BASE/v1.log" 2>/dev/null; then say "PROVIDER ERROR on build — STOP"; echo PILOT-DONE; exit 5; fi
  ss=$(tail -3 "$BASE/v1-selfsuite.txt" 2>/dev/null | grep -oE '[0-9]+ scenarios \([^)]*\)' | head -1)
  say "V1 build ${w}s | self-suite: ${ss:-?} — Shipwright harbour pass #1 (before first oracle)"
  run_shipwright prebuild
  read -r p t <<<"$(grade v1)"
  say "V1 (post-shipwright) | oracle ${p}/${t} | failing:"; titles v1 | sed 's/^/    /' | tee -a "$LOG" >/dev/null
  START=2
else
  # discard any dirty tree left by an interrupted voyage — grade only the last committed state
  git -C "$SIM" reset --hard HEAD >/dev/null 2>&1 || true
  git -C "$SIM" clean -fd >/dev/null 2>&1 || true
  say "RESUME: grading current sim as baseline (voyage $((RESUME_FROM-1)), HEAD=$(git -C "$SIM" rev-parse --short HEAD 2>/dev/null))"
  read -r p t <<<"$(grade v$((RESUME_FROM-1)))"
  say "resume baseline oracle ${p}/${t} | failing:"; titles v$((RESUME_FROM-1)) | sed 's/^/    /' | tee -a "$LOG" >/dev/null
  START=$RESUME_FROM
fi

# ---- Iterate ----
prev_p=-1; prev_titles=""; stuck=0
for v in $(seq "$START" "$MAXV"); do
  if [ "${p:-0}" -ge 28 ]; then
    say "REACHED ${p}/${t} — Shipwright harbour pass #2 (after 28/29)"
    run_shipwright final
    read -r pp tt <<<"$(grade post-shipwright)"
    if [ "${pp:-0}" -ge 28 ]; then say "POST-SHIPWRIGHT oracle ${pp}/${tt} — STILL 28/29 (shipwright did not regress) — DONE";
    else say "POST-SHIPWRIGHT oracle ${pp}/${tt} — REGRESSED from ${p}/${t}!! shipwright broke function — DONE(flagged)"; fi
    break
  fi
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
