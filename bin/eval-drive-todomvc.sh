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
# Default model for all single-model runs/draws = xiaomi/mimo-v2.5 (dk, 2026-07-26; see CAPTAIN.md):
# the all-round cheap/fast good outlier, 28/29 reproduced at ~$0.15. Override with --model.
WAVE=""; MODEL="xiaomi/mimo-v2.5"; SKILLS_DIR=""; YOINK=""; CLONE=""; PORT=8873; MAXV=14; TIMEOUT_S=1500; RESUME_FROM=0; ORACLE_CORRECT=0
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
    --oracle-correct) ORACLE_CORRECT=1; shift;;  # every voyage pastes the EXACT oracle failure; never give up on no-change
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
# yoink CAPABILITY check, not mere presence (2026-07-26): a toolkit copy carrying @dk/yoink
# 0.1.17 accepts only a JSON plan and dies "unknown option: --run" on the flag form that
# composite rigging methods are written in — a silent per-command failure inside a leg, not a
# launch error. Assert the flag form works, upgrading in place when it does not.
if ! ( cd "$SHARED_NM" && node node_modules/@dk/yoink/dist/cli.js --run 'true' >/dev/null 2>&1 ); then
  say_pre(){ echo "eval-drive: toolkit yoink lacks the --run flag form; upgrading" >&2; }; say_pre
  ( cd "$SHARED_NM" && npm install --no-fund --no-audit @dk/yoink@latest >/dev/null 2>&1 ) || true
  ( cd "$SHARED_NM" && node node_modules/@dk/yoink/dist/cli.js --run 'true' >/dev/null 2>&1 ) \
    || { echo "eval-drive: yoink still cannot run a flag-form plan — composite methods would fail silently" >&2; exit 3; }
fi

# Disk preflight: a full disk (ENOSPC) silently corrupts everything downstream — legs die at
# 0s, git commits fail, and oracle grades parse ENOSPC noise as a bogus low score (glm-5.2's
# phantom "28->12 shipwright regression" on 2026-07-25 was ENOSPC, not a real regression).
# Abort the voyage BEFORE it can produce garbage rather than mislabel a disk fault as a finding.
DISK_MIN_KB="${DISK_MIN_KB:-2097152}"   # 2G
disk_ok(){
  local free; free=$(df -Pk / | awk 'NR==2{print $4}')
  if [ "${free:-0}" -lt "$DISK_MIN_KB" ]; then
    say "DISK GUARD: only $((free/1024))M free (< $((DISK_MIN_KB/1024))M) — ABORTING to avoid ENOSPC-corrupted results"
    return 1
  fi
  return 0
}

say "PILOT START wave=$WAVE model=$MODEL clone=$CLONE port=$PORT max=$MAXV resume=$RESUME_FROM"
if [ "$RESUME_FROM" -eq 0 ]; then
  if ! "$HERE/bin/scaffold-todomvc.sh" "$SIM" >"$BASE/scaffold.log" 2>&1; then say "SCAFFOLD FAILED"; echo PILOT-DONE; exit 4; fi
else
  [ -d "$SIM/.git" ] || { say "RESUME: sim missing at $SIM"; echo PILOT-DONE; exit 4; }
fi

grade(){ # -> writes $BASE/vN-oracle.txt ; echoes "passing tests"
  local v="$1"
  disk_ok || { echo "0 29"; return; }   # never grade on a full disk — the number would be a lie
  "$HERE/bin/oracle-grade.sh" --build "$SIM" --out "$BASE/$v-oracle.txt" --clone "$CLONE" --port "$PORT" >"$BASE/$v-oraclerun.log" 2>&1 || true
  local p t; p=$(grep -oE 'passing=[0-9]+' "$BASE/$v-oracle.txt" 2>/dev/null | head -1 | cut -d= -f2)
  t=$(grep -oE 'tests=[0-9]+' "$BASE/$v-oracle.txt" 2>/dev/null | head -1 | cut -d= -f2)
  echo "${p:-0} ${t:-29}"
}
titles(){ sed -n '/## failing tests/,/## /p' "$BASE/$1-oracle.txt" 2>/dev/null | grep '^  - ' | sed 's/^  - //'; }

# oracle-correction intent: paste the EXACT acceptance-suite failure to the Captain, verbatim,
# no rephrase (dk). The roles' own happy-dom suite can pass while a real browser still fails
# (blur/visibility the tier can't fire) — so the operator hands over the raw browser failure the
# roles cannot see from inside their harness. $1 = voyage tag whose grade to correct (e.g. v4).
correction_intent(){
  # NB: each local that references a prior one MUST be its own line — `local a=$1 b=$a` expands
  # $a before it is assigned (empty), and under `set -u` exits on the unbound ref (the 0s-voyage
  # bug, 2026-07-25; same class as the run_shipwright `local label=$1 out=..$label` crash).
  local vg="$1"
  local cyp="$BASE/$vg-oracle.cypress.log"
  local task="$BASE/correct-after-$vg.task"
  # exact failing blocks: from the first "  N) " line through the run-summary, verbatim.
  local block=""
  if [ -f "$cyp" ]; then
    block="$(awk '/^  [0-9]+\)/{f=1} f{print} /^\s*[0-9]+ passing|\(Results\)|Run Finished/{if(f){exit}}' "$cyp")"
  fi
  [ -n "$block" ] || block="$(titles "$vg" | sed 's/^/  - /')"   # fall back to titles if no raw block
  # Class-aware operator diagnosis. A verbatim cypress error can MISLEAD: its own remediation text
  # ("break up the chain", "rewrite cy.get(...)") is advice to a TEST author, and a detached-DOM
  # error reads like a test bug when the real fix is app-side. We keep the error verbatim (evidence)
  # but add the operator's read of the CAUSE so the role fixes the product, not the (fixed) test.
  # This is the qmax lesson, 2026-07-26: paste-exact is necessary but not sufficient for errors
  # whose surface text points at the harness.
  local hint=""
  if printf '%s' "$block" | grep -qiE 'no longer attached|detached from the DOM|removed the element|requery the page'; then
    hint="This is a DOM-identity defect. \"detached from the DOM / element was removed\" means your app
REPLACES DOM nodes on this interaction — it re-renders (rebuilds) the list when an item's state
changes, so a reference the browser took before the click is invalidated. Your own suite does not
catch it because its DOM re-queries differently. The fix is app-side: PRESERVE element identity —
mutate the existing node in place (toggle its class/checkbox) instead of re-rendering the list, so
the node stays attached across the interaction."
  fi
  {
    echo "You are the Shipshape Captain. Project root: $SIM."
    echo
    echo "An external browser acceptance suite runs against the build. It is FIXED and CORRECT — you"
    echo "cannot and must not change it. Your own verification suite passes, yet the acceptance suite"
    echo "still reports the failures below, because a real browser exercises behaviour your in-harness"
    echo "DOM does not. These are real PRODUCT defects; fix the product so a real browser passes."
    echo
    echo "Verbatim acceptance-suite failure output:"
    echo "----------------------------------------------------------------------"
    printf '%s\n' "$block"
    echo "----------------------------------------------------------------------"
    echo
    echo "How to read it:"
    echo "- The error's own advice may suggest changing the TEST (e.g. \"break up the chain\", rewrite"
    echo "  a cy.get(...) call). Ignore that — the test is fixed and correct. Take only the CAUSE it names."
    if [ -n "$hint" ]; then echo "- $hint"; fi
    echo "- If your in-harness suite genuinely cannot reproduce the failure, that is EXPECTED for a"
    echo "  browser-only defect — do not force an impossible failing scenario. Guard the behaviour with"
    echo "  a source-level conformance check instead."
    echo
    # The operator is the user here, and a user's "just fix it" does NOT license Captain to write
    # production code: doctrine's one absolute boundary routes it through a durable spec to QM and
    # Crew. The old closing line ("make the smallest product change") did license it, and an
    # 86-voyage tree audit found Captain writing js/index.html/css on ~every correction voyage
    # under it, after which QM opened to an empty watchbill and reported "deck at rest" in three
    # calls — so those voyages measured one model in one role, not the role chain (2026-07-26).
    echo "Proceed now without waiting for confirmation. This is product intent, not a work order:"
    echo "author or correct the durable specs and \`watchbill.json\` that pin the behaviour, so a"
    echo "scenario fails on the current code, then STOP and report. Do not write production code"
    echo "yourself and do not edit anything under the implementation directories — the Quartermaster"
    echo "and Crew implement it from your specs on the next leg. Do not commit, push, or tag."
  } > "$task"
  echo "$task"
}

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
  disk_ok || { echo "DISK-ABORT"; return; }
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
  local label="$1"
  disk_ok || { say "SHIPWRIGHT[$label] SKIPPED — disk guard"; return; }
  local out="$BASE/sw-$label.out" t0 t1 committed=no prehead
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
  say "RESUME: Shipwright harbour pass #1 (before oracle), then grade baseline (voyage $((RESUME_FROM-1)))"
  run_shipwright prebuild
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
  if [ "$ORACLE_CORRECT" = "1" ]; then
    # An UNSERVED page grades UNPARSEABLE: no cypress failing blocks and no titles exist, so the
    # correction intent would paste an EMPTY failure block between its rulers and the voyage is a
    # guaranteed no-op (caught in flight, methflash-c1 v2, 2026-07-26). A build with no index.html
    # has one cause and the intent library already names it; route there instead of pasting nothing.
    if grep -q 'GRADE: UNPARSEABLE' "$BASE/v$((v-1))-oracle.txt" 2>/dev/null || [ ! -f "$SIM/index.html" ]; then
      intent="page"; task="$I/page.md"
      say "VOYAGE $v (intent=page — prior grade unparseable/no servable page, nothing to paste)"
    else
    intent="oracle-correction"
    task=$(correction_intent "v$((v-1))")
    say "VOYAGE $v (oracle-correction — exact failure pasted verbatim)"
    fi
  else
    intent=$(pick_intent "$p" "$tl")
    if [ "$intent" = "unknown" ]; then say "UNKNOWN failure pattern at ${p}/${t} — STOP for operator:"; titles v$((v-1)) | sed 's/^/    /' | tee -a "$LOG" >/dev/null; break; fi
    task="$I/$intent.md"
    say "VOYAGE $v (intent=$intent)"
  fi
  # infra-retry: a voyage aborted by a void/overlay leg (eval-voyage exit 6) is NOT progress —
  # retry the SAME voyage number rather than count a silent no-op (qmax V6-V20, 2026-07-26). Bounded
  # and disk-gated so a persistently full disk stops loudly instead of grinding the cap to zero.
  infra=0
  while :; do
    w=$(run_voyage "$v" "$task")
    grep -qE 'INFRA/VOID' "$BASE/v$v.log" 2>/dev/null || break
    infra=$((infra+1)); say "V$v INFRA/VOID (overlay-mount/void leg) — not counted; infra-retry $infra/4 (free=$(df -Pk / | awk 'NR==2{printf "%.1fG",$4/1048576}'))"
    if [ "$infra" -ge 4 ]; then say "INFRA FAILURE 4x at voyage $v — STOP (disk/overlay); free disk then --resume-from $v"; break 2; fi
    disk_ok || true; sleep 20
  done
  if grep -q 'PROVIDER ERROR' "$BASE/v$v.log" 2>/dev/null; then say "PROVIDER ERROR — STOP"; break; fi
  outcome=$(grep -oE 'VOYAGE-(COMPLETE|REGRESSED)' "$BASE/v$v.log" | tail -1)
  ss=$(tail -3 "$BASE/v$v-selfsuite.txt" 2>/dev/null | grep -oE '[0-9]+ scenarios \([^)]*\)' | head -1)
  read -r p t <<<"$(grade v$v)"
  cur_titles=$(titles v$v)
  say "V$v $intent ${w}s | $outcome | self-suite: ${ss:-?} | oracle ${p}/${t} | failing:"; echo "$cur_titles" | sed 's/^/    /' | tee -a "$LOG" >/dev/null
  LAST_INTENT="$intent"
  # no-improvement breaker — DISABLED in oracle-correct mode (dk: keep going until convergence;
  # each correction voyage re-pastes the exact live failure, so repetition is progress, not a loop)
  if [ "${p:-0}" = "$prev_p" ] && [ "$cur_titles" = "$prev_titles" ]; then
    stuck=$((stuck+1)); say "  (no change vs prior voyage: stuck=$stuck)"
    if [ "$ORACLE_CORRECT" != "1" ] && [ "$stuck" -ge 2 ]; then say "NO IMPROVEMENT 2x at ${p}/${t} — STOP for operator"; break; fi
  else stuck=0; fi
  prev_p="$p"; prev_titles="$cur_titles"
done

say "PILOT END wave=$WAVE final=${p}/${t}"
echo "PILOT-DONE"
