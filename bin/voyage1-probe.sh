#!/usr/bin/env bash
# THE voyage-1 probe. The whole first voyage, and nothing after it:
#
#   clean fixture -> Captain+Shipwright (fit out, author, stop)
#                 -> FRESH QM+Crew+Boatswain (prove red, build, take custody)
#                 -> the roles' own suite, observed
#   and STOP. No oracle, no correction prompts, no grading.
#
#   bin/voyage1-probe.sh <arm> <model-key> [tag]
#
# Why (dk, 2026-08-02): the oracle measures completion, not the goal. Fitting out is now settled
# on candidate, so the next question is what ONE voyage produces on its own -- the rigging, the
# spec surface, the step definitions, the planks, and whether custody happens -- without a grade
# in the loop to chase. Everything the oracle would tell us is downstream of this.
#
# Settings live here, once, as in pilot.sh. No options.
set -uo pipefail
HERE="$(cd "$(dirname "$0")/.." && pwd)"
SCRATCH="$HERE/.eval-scratch"

ARM="${1:-}"; MODEL_KEY="${2:-}"; TAG="${3:-V}"
case "$ARM" in
  control)   SKILLS=/home/exedev/.claude/plugins/cache/dmytri-shipshape/shipshape/596fbf17be06/skills ;;
  candidate) SKILLS="$HERE/experiments/methods-candidate/skills" ;;
  midway)    SKILLS="$HERE/experiments/methods-midway/skills" ;;
  fitout)    SKILLS="$HERE/experiments/fitout/skills" ;;
  *) echo "usage: voyage1-probe.sh <control|candidate|midway|fitout> <flash|mimo|hy3> [tag]" >&2; exit 2 ;;
esac
case "$MODEL_KEY" in
  flash) MODEL=deepseek/deepseek-v4-flash ;;
  mimo)  MODEL=xiaomi/mimo-v2.5 ;;
  hy3)   MODEL=tencent/hy3 ;;
  *) echo "usage: voyage1-probe.sh <arm> <flash|mimo|hy3> [tag]" >&2; exit 2 ;;
esac

WAVE="$TAG-$ARM-$MODEL_KEY"
BASE="$SCRATCH/$WAVE"; SIM="$BASE/sim"; LOG="$BASE/probe.log"
[ -d "$SKILLS/shipshape" ] || { echo "voyage1-probe: no skills at $SKILLS" >&2; exit 3; }

rm -rf "$BASE"; mkdir -p "$BASE"
say(){ echo "[$(date -u +%FT%TZ)] $*" | tee -a "$LOG"; }
export EVAL_SHARED_NM="$SCRATCH/.shared-nm/node_modules"

leg(){ # leg <name> <task-file> <skill>...
  local name="$1" task="$2"; shift 2
  local args=(); for s in "$@"; do args+=(--skill "$s"); done
  "$HERE/bin/eval-leg.sh" --model "$MODEL" --workspace "$SIM" --out "$BASE/$name.out" \
    "${args[@]}" --task-file "$task" --name "$name" --timeout-s 3600 \
    >"$BASE/$name.leg.log" 2>&1
  local rc=$?
  [ -s "$BASE/$name.out/session.jsonl" ] || {
    say "LEG $name PRODUCED NO SESSION — infrastructure, not a result"; return 9; }
  return $rc
}

say "VOYAGE-1 PROBE $WAVE model=$MODEL skills=$SKILLS"
"$HERE/bin/scaffold-todomvc.sh" "$SIM" >"$BASE/scaffold.log" 2>&1 || { say "SCAFFOLD FAILED"; exit 4; }

# --- Captain + Shipwright: fit out, author, stop ---
sed "s#PROJECT_ROOT_PLACEHOLDER#$SIM#g" "$HERE/tasks/pilot/captain-todomvc.task.md" > "$BASE/v1-captain.task"
leg v1-captain "$BASE/v1-captain.task" "$SKILLS/shipshape" "$SKILLS/captain" "$SKILLS/shipwright" \
  "$HOME/yoink/skills/yoink" || { say "STOP: captain leg failed"; exit 5; }
BASE_COMMIT="$(git -C "$SIM" rev-parse HEAD)"
dirty="$(git -C "$SIM" status --porcelain 2>/dev/null)"
[ -n "$dirty" ] && say "HANDOFF | captain work in flight: $(printf '%s' "$dirty" | awk '{print $2}' | tr '\n' ' ')" \
                || say "HANDOFF | captain committed | HEAD $(git -C "$SIM" rev-parse --short HEAD)"

# --- fresh QM + Crew + Boatswain: prove red, build, take custody ---
sed -e "s#PROJECT_ROOT_PLACEHOLDER#$SIM#g" -e "s#BASE_COMMIT_PLACEHOLDER#$BASE_COMMIT#g" \
  "$HERE/tasks/pilot/qm.task.md" > "$BASE/v1-qm.task"
leg v1-qm "$BASE/v1-qm.task" "$SKILLS/shipshape" "$SKILLS/qm" "$SKILLS/crew" \
  "$SKILLS/boatswain" "$HOME/yoink/skills/yoink" || { say "STOP: qm leg failed"; exit 5; }

# --- the roles' own suite, OBSERVED (never a gate). No oracle: the probe ends here. ---
rm -rf "$SIM/node_modules"; ln -s "$EVAL_SHARED_NM" "$SIM/node_modules"
( cd "$SIM" && NODE_OPTIONS="--max-old-space-size=2048" npx cucumber-js features specs 2>&1 ) \
  > "$BASE/selfsuite.txt" 2>&1
rm -f "$SIM/node_modules"; mkdir -p "$SIM/node_modules"
say "SELF-SUITE | $(grep -oE '[0-9]+ scenarios( \([^)]*\))?' "$BASE/selfsuite.txt" | head -1 || echo none)"
[ -n "$(git -C "$SIM" status --porcelain 2>/dev/null)" ] \
  && say "CUSTODY | work left uncommitted: $(git -C "$SIM" status --porcelain | awk '{print $2}' | tr '\n' ' ')" \
  || say "CUSTODY | deck clean | HEAD $(git -C "$SIM" rev-parse --short HEAD)"
say "PROBE END $WAVE (no oracle, by design)"
echo PROBE-DONE
