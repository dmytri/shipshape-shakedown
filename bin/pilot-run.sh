#!/usr/bin/env bash
# THE pilot run. Nothing but:
#
#   clean fixture -> sandbox -> initial prompt -> oracle-response prompts -> grading
#
# Called by bin/pilot.sh, which supplies the arm and model. No options here either.
#
# What was deleted from the old driver, and why (dk, 2026-07-29):
#   voyage-0 Shipwright fit-out   an operator-dispatched role the doctrine says never happens at
#                                 a greenfield repo. It was my workaround for the candidate's
#                                 greenfield contradiction (B1) — i.e. the playbook papering over
#                                 a doctrine fault, which is exactly what must not happen.
#   post-ceiling Shipwright pass  another dispatch nobody asked for, after the result was in.
#   revert-on-red                 the harness undoing role work. It destroyed RIGGING.md all
#                                 session and once deleted a measured 26/29 improvement.
#   operator custody commits      committing FOR the roles hid whether Boatswain took custody.
#   the intent library            page/domidentity/editreentrancy prompt selection. Every voyage
#                                 pastes the exact oracle failure; picking a canned intent instead
#                                 was operator craft dressed as playbook.
#   resume / infra-retry paths    state to get wrong, for a run that should just be rerun.
#
# The harness now READS this repo and never writes it. Custody, rigging and specs are the roles'
# business; whether they happen is a RESULT, not something to arrange.
set -uo pipefail
HERE="$(cd "$(dirname "$0")/.." && pwd)"
SCRATCH="$HERE/.eval-scratch"

WAVE="${1:?wave}"; MODEL="${2:?model}"; SKILLS="${3:?skills-dir}"; PORT="${4:?port}"
MAXV=12
TIMEOUT_S=3600
CLONE="$SCRATCH/oracle-clone"
BASE="$SCRATCH/$WAVE"; SIM="$BASE/sim"; LOG="$BASE/driver.log"

rm -rf "$BASE"; mkdir -p "$BASE"
say(){ echo "[$(date -u +%FT%TZ)] $*" | tee -a "$LOG"; }
export EVAL_SHARED_NM="$SCRATCH/.shared-nm/node_modules"

leg(){ # leg <name> <task-file> <skill>...
  local name="$1" task="$2"; shift 2
  local args=(); for s in "$@"; do args+=(--skill "$s"); done
  "$HERE/bin/eval-leg.sh" --model "$MODEL" --workspace "$SIM" --out "$BASE/$name.out" \
    "${args[@]}" --task-file "$task" --name "$name" --timeout-s "$TIMEOUT_S" \
    >"$BASE/$name.leg.log" 2>&1
  local rc=$?
  "$HERE/bin/eval-bank.sh" --wave "$WAVE" --name "$name" --out "$BASE/$name.out" \
    --workspace "$SIM" --verdict PENDING >/dev/null 2>&1 || true
  # a leg that produced no session is infrastructure, not a result: stop, do not score it
  [ -s "$BASE/$name.out/session.jsonl" ] || ls "$BASE/$name.out"/session/*.jsonl >/dev/null 2>&1 || {
    say "LEG $name PRODUCED NO SESSION — stopping (infrastructure, not a result)"; return 9; }
  return $rc
}

selfsuite(){ # the roles' own suite, observed only — never a gate
  local v="$1" paths=""
  [ -f "$SIM/cucumber.js" ] || [ -f "$SIM/cucumber.cjs" ] || for r in features specs; do
    [ -d "$SIM/$r" ] && paths="$paths $r"; done
  rm -rf "$SIM/node_modules"; ln -s "$EVAL_SHARED_NM" "$SIM/node_modules"
  ( cd "$SIM" && NODE_OPTIONS="--max-old-space-size=2048" npx cucumber-js $paths 2>&1 ) > "$BASE/$v-selfsuite.txt" 2>&1
  rm -f "$SIM/node_modules"; mkdir -p "$SIM/node_modules"
  grep -oE '[0-9]+ scenarios( \([^)]*\))?' "$BASE/$v-selfsuite.txt" | head -1
}

grade(){ # echoes "passing total", or "ERR ERR" when UNMEASURED — never a fake zero
  local v="$1"
  "$HERE/bin/oracle-grade.sh" --build "$SIM" --out "$BASE/$v-oracle.txt" --clone "$CLONE" \
    --port "$PORT" >"$BASE/$v-oraclerun.log" 2>&1 || true
  grep -q '^GRADE:' "$BASE/$v-oracle.txt" 2>/dev/null || { echo "ERR ERR"; return; }
  local p t
  p=$(grep -oE 'passing=[0-9]+' "$BASE/$v-oracle.txt" | head -1 | cut -d= -f2)
  t=$(grep -oE 'tests=[0-9]+' "$BASE/$v-oracle.txt" | head -1 | cut -d= -f2)
  { [ -n "$p" ] && [ -n "$t" ]; } || { echo "ERR ERR"; return; }
  echo "$p $t"
}

titles(){ sed -n '/## failing tests/,/## /p' "$BASE/$1-oracle.txt" 2>/dev/null | grep '^  - ' | sed 's/^  - //'; }

# the oracle-response prompt: the exact browser failure, verbatim, no rephrase
correction(){ # correction <prev-voyage-tag> -> writes a task file, echoes its path
  local vg="$1" cyp="$BASE/$vg-oracle.cypress.log" task="$BASE/correct-after-$vg.task" block=""
  [ -f "$cyp" ] && block="$(awk '/^  [0-9]+\)/{f=1} f{print} /^\s*[0-9]+ passing|\(Results\)/{if(f)exit}' "$cyp")"
  [ -n "$block" ] || block="$(titles "$vg" | sed 's/^/  - /')"
  { sed "s#PROJECT_ROOT_PLACEHOLDER#$SIM#g" "$HERE/tasks/pilot/correction-header.md" 2>/dev/null \
      || printf 'You are the Shipshape Captain. Project root: %s.\n\nAn external browser acceptance suite runs against the build. It is FIXED and CORRECT — you\ncannot and must not change it. Your own verification suite passes, yet the acceptance suite\nstill reports the failures below, because a real browser exercises behaviour your in-harness\nDOM does not. These are real PRODUCT defects; fix the product so a real browser passes.\n\nVerbatim acceptance-suite failure output:\n----------------------------------------------------------------------\n' "$SIM"
    printf '%s\n' "$block"
    printf -- '----------------------------------------------------------------------\n\nProceed now without waiting for confirmation: author or correct the durable specs and\nwatchbill your role calls for, then stop. Do not commit, push, or dispatch.\n'
  } > "$task"
  echo "$task"
}

say "PILOT START wave=$WAVE model=$MODEL skills=$SKILLS port=$PORT"

# --- clean fixture -> sandbox ---
"$HERE/bin/scaffold-todomvc.sh" "$SIM" >"$BASE/scaffold.log" 2>&1 || { say "SCAFFOLD FAILED"; exit 4; }

# --- initial prompt ---
say "VOYAGE 1 (initial prompt)"
sed "s#PROJECT_ROOT_PLACEHOLDER#$SIM#g" "$HERE/tasks/pilot/captain-todomvc.task.md" > "$BASE/v1-captain.task"
leg v1-captain "$BASE/v1-captain.task" "$SKILLS/shipshape" "$SKILLS/captain" "$HOME/yoink/skills/yoink" || { say "STOP: captain leg failed"; exit 5; }
BASE_COMMIT="$(git -C "$SIM" rev-parse HEAD)"
sed -e "s#PROJECT_ROOT_PLACEHOLDER#$SIM#g" -e "s#BASE_COMMIT_PLACEHOLDER#$BASE_COMMIT#g" "$HERE/tasks/pilot/qm.task.md" > "$BASE/v1-qm.task"
leg v1-qm "$BASE/v1-qm.task" "$SKILLS/shipshape" "$SKILLS/qm" "$SKILLS/crew" "$SKILLS/boatswain" "$HOME/yoink/skills/yoink" || { say "STOP: qm leg failed"; exit 5; }
ss=$(selfsuite v1)
read -r p t <<<"$(grade v1)"
[ "$p" = ERR ] && { say "GRADE UNMEASURED after the initial prompt — STOP, nothing is scored"; exit 7; }
[ -n "$(git -C "$SIM" status --porcelain 2>/dev/null)" ] && custody="roles left work UNCOMMITTED" || custody="roles committed"
say "V1 | self-suite: ${ss:-none} | $custody | oracle ${p}/${t}"
titles v1 | sed 's/^/    /' | tee -a "$LOG" >/dev/null

# --- oracle-response prompts -> grading, until the ceiling or the cap ---
for v in $(seq 2 "$MAXV"); do
  [ "${p:-0}" -ge 28 ] && { say "REACHED ${p}/${t}"; break; }
  task="$(correction "v$((v-1))")"
  say "VOYAGE $v (oracle response: exact failure, verbatim)"
  cp "$task" "$BASE/v$v-captain.task"
  leg "v$v-captain" "$BASE/v$v-captain.task" "$SKILLS/shipshape" "$SKILLS/captain" "$HOME/yoink/skills/yoink" || { say "STOP: captain leg failed at v$v"; break; }
  BASE_COMMIT="$(git -C "$SIM" rev-parse HEAD)"
  sed -e "s#PROJECT_ROOT_PLACEHOLDER#$SIM#g" -e "s#BASE_COMMIT_PLACEHOLDER#$BASE_COMMIT#g" "$HERE/tasks/pilot/qm.task.md" > "$BASE/v$v-qm.task"
  leg "v$v-qm" "$BASE/v$v-qm.task" "$SKILLS/shipshape" "$SKILLS/qm" "$SKILLS/crew" "$SKILLS/boatswain" "$HOME/yoink/skills/yoink" || { say "STOP: qm leg failed at v$v"; break; }
  ss=$(selfsuite "v$v")
  read -r p t <<<"$(grade "v$v")"
  [ "$p" = ERR ] && { say "GRADE UNMEASURED at voyage $v — STOP rather than record a number"; break; }
  [ -n "$(git -C "$SIM" status --porcelain 2>/dev/null)" ] && custody="roles left work UNCOMMITTED" || custody="roles committed"
  say "V$v | self-suite: ${ss:-none} | $custody | oracle ${p}/${t}"
  titles "v$v" | sed 's/^/    /' | tee -a "$LOG" >/dev/null
done

say "PILOT END wave=$WAVE final=${p}/${t}"
echo PILOT-DONE
