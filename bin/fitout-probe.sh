#!/usr/bin/env bash
# THE fit-out probe. One leg, nothing else:
#
#   clean fixture -> sandbox -> Captain+Shipwright -> custody -> stop
#
#   bin/fitout-probe.sh <arm> <model-key> [tag]
#     arm        control | candidate | midway
#     model-key  flash | mimo | hy3
#
# Why this exists (dk, 2026-08-02): the full wave measures completion, and the oracle cannot see
# the goal. Fitting out is upstream of everything -- the rigging, the spec surface, the watchbill
# -- and it happens ONCE, in the first Captain/Shipwright session, before any cold start. So it
# can be probed on its own for an eighth of a wave's cost.
#
# Settings live here, once, as in pilot.sh. No options.
set -uo pipefail
HERE="$(cd "$(dirname "$0")/.." && pwd)"
SCRATCH="$HERE/.eval-scratch"

ARM="${1:-}"; MODEL_KEY="${2:-}"; TAG="${3:-F}"
case "$ARM" in
  control)   SKILLS=/home/exedev/.claude/plugins/cache/dmytri-shipshape/shipshape/596fbf17be06/skills ;;
  candidate) SKILLS="$HERE/experiments/methods-candidate/skills" ;;
  midway)    SKILLS="$HERE/experiments/methods-midway/skills" ;;
  floor)     SKILLS="$HERE/experiments/fitout-floor/skills" ;;
  lean)      SKILLS="$HERE/experiments/fitout-lean/skills" ;;
  leanplus)  SKILLS="$HERE/experiments/fitout-lean-plus/skills" ;;
  *) echo "usage: fitout-probe.sh <control|candidate|midway|floor> <flash|mimo|hy3> [tag]" >&2; exit 2 ;;
esac
case "$MODEL_KEY" in
  flash) MODEL=deepseek/deepseek-v4-flash ;;
  mimo)  MODEL=xiaomi/mimo-v2.5 ;;
  hy3)   MODEL=tencent/hy3 ;;
  *) echo "usage: fitout-probe.sh <control|candidate|midway|floor> <flash|mimo|hy3> [tag]" >&2; exit 2 ;;
esac

WAVE="$TAG-$ARM-$MODEL_KEY"
BASE="$SCRATCH/$WAVE"; SIM="$BASE/sim"; LOG="$BASE/probe.log"
[ -d "$SKILLS/shipshape" ] || { echo "fitout-probe: no skills at $SKILLS" >&2; exit 3; }
if [ "$ARM" = midway ]; then
  python3 "$HERE/bin/build-midway.py" --check >/dev/null 2>&1 || {
    echo "fitout-probe: midway build is not clean" >&2; exit 3; }
fi

rm -rf "$BASE"; mkdir -p "$BASE"
say(){ echo "[$(date -u +%FT%TZ)] $*" | tee -a "$LOG"; }
export EVAL_SHARED_NM="$SCRATCH/.shared-nm/node_modules"

say "FITOUT PROBE $WAVE model=$MODEL skills=$SKILLS"
"$HERE/bin/scaffold-todomvc.sh" "$SIM" >"$BASE/scaffold.log" 2>&1 || { say "SCAFFOLD FAILED"; exit 4; }

sed "s#PROJECT_ROOT_PLACEHOLDER#$SIM#g" "$HERE/tasks/pilot/captain-todomvc.task.md" > "$BASE/fitout.task"
"$HERE/bin/eval-leg.sh" --model "$MODEL" --workspace "$SIM" --out "$BASE/fitout.out" \
  --skill "$SKILLS/shipshape" --skill "$SKILLS/captain" --skill "$SKILLS/shipwright" \
  --skill "$HOME/yoink/skills/yoink" \
  --task-file "$BASE/fitout.task" --name fitout --timeout-s 3600 \
  >"$BASE/fitout.leg.log" 2>&1
rc=$?

[ -s "$BASE/fitout.out/session.jsonl" ] || {
  say "LEG PRODUCED NO SESSION — infrastructure, not a result"; exit 9; }

# custody is a RESULT, never arranged: report it, do not repair it
if [ -z "$(git -C "$SIM" status --porcelain 2>/dev/null)" ]; then
  say "CUSTODY | captain committed | HEAD $(git -C "$SIM" rev-parse --short HEAD)"
else
  say "CUSTODY | WARN uncommitted: $(git -C "$SIM" status --porcelain | awk '{print $2}' | tr '\n' ' ')"
fi
say "PROBE END $WAVE (leg rc=$rc)"
echo PROBE-DONE
