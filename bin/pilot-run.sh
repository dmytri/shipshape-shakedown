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
#   the captain/qm leg SPLIT      2026-07-30, dk: "basic fixture, agent runs in bwrap with the
#                                 todomvc specs, runs autonomously until oracle, then the playbook
#                                 gives the clean exact error back until 28/29." Splitting each
#                                 voyage into two pi sessions with a git handoff between them was
#                                 an operator invention doctrine never asked for, and EVERY defect
#                                 of 2026-07-29/30 lived on that seam: the harness read BASE_COMMIT
#                                 before the Captain's work existed (16), so QM opened on a foul and
#                                 stashed the watchbill (15), so QM had no targets for ten voyages,
#                                 so the self-suite froze at 37/37 and the ceiling was unreachable;
#                                 and a fresh QM opening cold on a tree it never built blocked on a
#                                 missing RIGGING.md (B1). ONE session per voyage carries the whole
#                                 voyage — which is what the skills already do when no spawn tool
#                                 exists ("assume that role in place"), exactly as the old QM leg
#                                 already ran Crew and Boatswain inside itself.
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

fitout(){ # what the fit-out produced for spec linting — OBSERVED and recorded, never a gate
  # dk, 2026-07-29: gplint config belongs in fit-out grading. The harness does NOT seed .gplintrc
  # (that is role-authored fit-out output — arranging it would answer the question we are asking);
  # it measures what the wave produced. Deliberately VOCABULARY-NEUTRAL: rigging-conform.py keys on
  # `## Methods`, which is the candidate arm's word, so using it here would score every control
  # cell "no Methods section" and manufacture an arm difference out of naming. These three facts
  # read the same in both arms.
  local v="$1"
  local rc lintval="absent" cfg="no" gp="not-run" out="$BASE/$v-fitout.txt"
  [ -f "$SIM/.gplintrc" ] && cfg="yes"
  if [ -f "$SIM/RIGGING.md" ]; then
    lintval="$(grep -iE '^[[:space:]]*[-*]?[[:space:]]*(spec-)?lint[[:space:]]*:' "$SIM/RIGGING.md" \
      | head -1 | sed 's/^[^:]*:[[:space:]]*//' | tr -d '`' | cut -c1-60)"
    [ -n "$lintval" ] || lintval="absent"
  fi
  # Run the linter the way the project would: shared toolkit mounted, spec surface only. Globs stay
  # QUOTED so gplint expands them (bash without globstar drops features/*.feature from `**`).
  if [ "$cfg" = no ]; then
    # gplint with no .gplintrc REFUSES TO START ("Could not find config file"). That is a different
    # fact from a clean spec surface, and scoring it as red(0 problems) would read as the opposite
    # of what happened. Name it for what it is.
    gp="no-config"
    echo "gplint not run: no .gplintrc in the tree" >"$out"
  else
    rm -rf "$SIM/node_modules"; ln -s "$EVAL_SHARED_NM" "$SIM/node_modules"
    ( cd "$SIM" && npx gplint 'features/**/*.feature' 'specs/**/*.feature' ) >"$out" 2>&1
    rc=$?
    rm -f "$SIM/node_modules"; mkdir -p "$SIM/node_modules"
    if [ "$rc" -eq 0 ]; then gp="green"
    else gp="red($(grep -cE '^ *[0-9]+ +[0-9]+ +(error|warn)' "$out" 2>/dev/null || echo '?') problems)"; fi
  fi
  echo ".gplintrc: $cfg | rigging lint: $lintval | gplint: $gp"
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
  # `local a=$1 b=$a` does NOT work: local expands ALL its assignment words before assigning any
  # of them, so $vg is still unset here and `set -u` aborts the whole command substitution. That
  # left $task empty, `cp ''` failed, and every voyage 2 died with no session (defect 14,
  # 2026-07-29 — the reason pilot-run.sh had never completed a full wave). Keep these separate.
  local vg="$1"
  local cyp="$BASE/$vg-oracle.cypress.log" task="$BASE/correct-after-$vg.task" block=""
  [ -f "$cyp" ] && block="$(awk '/^  [0-9]+\)/{f=1} f{print} /^\s*[0-9]+ passing|\(Results\)/{if(f)exit}' "$cyp")"
  [ -n "$block" ] || block="$(titles "$vg" | sed 's/^/  - /')"
  # dk, 2026-07-31: the original header, with the suite RUN BY A USER. No paraphrasing and no
  # filtering of the block -- it is passed through exactly as the runner emitted it.
  { printf 'You are the Shipshape Captain. Project root: %s.\n\nAn external browser acceptance suite is run by a user against the build. It is FIXED and\nCORRECT — you cannot and must not change it. You have no access to these tests, as they are\nrun by the user. Your own verification suite passes, yet the\nacceptance suite still reports the failures below, because a real browser exercises behaviour\nyour in-harness DOM does not. These are real PRODUCT defects; fix the product so a real\nbrowser passes.\n\nVerbatim acceptance-suite failure output:\n----------------------------------------------------------------------\n' "$SIM"
    printf '%s\n' "$block"
    printf -- '----------------------------------------------------------------------\n\nCarry this voyage to completion without waiting for confirmation. You have no subagent\nspawn tool: where your role would dispatch another role, assume that role in place by\nreading its skill and following it. Do not push.\n'
  } > "$task"
  echo "$task"
}

say "PILOT START wave=$WAVE model=$MODEL skills=$SKILLS port=$PORT"

# --- clean fixture -> sandbox ---
"$HERE/bin/scaffold-todomvc.sh" "$SIM" >"$BASE/scaffold.log" 2>&1 || { say "SCAFFOLD FAILED"; exit 4; }

# --- initial prompt ---
# ONE session carries the whole voyage. Every role skill is loaded; the agent assumes each role in
# place as its own doctrine tells it to when no spawn tool exists. No inter-leg git handoff exists
# to get wrong, because there is no inter-leg.
say "VOYAGE 1 (initial prompt)"
sed "s#PROJECT_ROOT_PLACEHOLDER#$SIM#g" "$HERE/tasks/pilot/captain-todomvc.task.md" > "$BASE/v1.task"
leg v1 "$BASE/v1.task" "$SKILLS/shipshape" "$SKILLS/captain" "$SKILLS/qm" "$SKILLS/crew" \
  "$SKILLS/boatswain" "$HOME/yoink/skills/yoink" || { say "STOP: voyage leg failed"; exit 5; }
ss=$(selfsuite v1)
read -r p t <<<"$(grade v1)"
[ "$p" = ERR ] && { say "GRADE UNMEASURED after the initial prompt — STOP, nothing is scored"; exit 7; }
[ -n "$(git -C "$SIM" status --porcelain 2>/dev/null)" ] && custody="roles left work UNCOMMITTED" || custody="roles committed"
say "V1 | self-suite: ${ss:-none} | $custody | oracle ${p}/${t}"
say "V1 FIT-OUT | $(fitout v1)"
titles v1 | sed 's/^/    /' | tee -a "$LOG" >/dev/null

# --- oracle-response prompts -> grading, until the ceiling or the cap ---
for v in $(seq 2 "$MAXV"); do
  [ "${p:-0}" -ge 28 ] && { say "REACHED ${p}/${t}"; break; }
  task="$(correction "v$((v-1))")"
  say "VOYAGE $v (oracle response: exact failure, verbatim)"
  cp "$task" "$BASE/v$v.task"
  leg "v$v" "$BASE/v$v.task" "$SKILLS/shipshape" "$SKILLS/captain" "$SKILLS/qm" "$SKILLS/crew" \
    "$SKILLS/boatswain" "$HOME/yoink/skills/yoink" || { say "STOP: voyage leg failed at v$v"; break; }
  ss=$(selfsuite "v$v")
  read -r p t <<<"$(grade "v$v")"
  [ "$p" = ERR ] && { say "GRADE UNMEASURED at voyage $v — STOP rather than record a number"; break; }
  [ -n "$(git -C "$SIM" status --porcelain 2>/dev/null)" ] && custody="roles left work UNCOMMITTED" || custody="roles committed"
  say "V$v | self-suite: ${ss:-none} | $custody | oracle ${p}/${t}"
  say "V$v FIT-OUT | $(fitout "v$v")"
  titles "v$v" | sed 's/^/    /' | tee -a "$LOG" >/dev/null
done

say "PILOT END wave=$WAVE final=${p}/${t}"
echo PILOT-DONE
