#!/usr/bin/env bash
# THE pilot. One fixture, one harness, one playbook. Two arguments, no options.
#
#   bin/pilot.sh <arm> <model-key> [wave-tag]
#     arm        control | candidate | midway
#     model-key  flash | mimo | hy3
#
# Why this exists (dk, 2026-07-29): the driver had ten flags — clone, port, toolkit, voyage cap,
# leg timeout, oracle-correct, resume, skills dir, yoink skill — and every one of them had
# exactly ONE correct value by the end of the day. Options that are never varied are not
# flexibility, they are places for two runs to differ silently, and this session lost several
# matrices to precisely that: a toolkit copy per arm, a budget that applied to one model,
# a midway build assembled by hand a different way each time.
#
# So the settings live HERE, once, and a run cannot disagree with another run:
#
#   fixture     ONE oracle clone (flock-serialised) + ONE shared toolkit with a persistent
#               per-wave node_modules upper, so a role's own install survives its leg
#   budget      32768 output tokens for every model, via models.json modelOverrides — the only
#               mechanism pi honours (proven: 4096 -> 30284)
#   playbook    fit-out (voyage 0, exempt from revert-on-red — it is where RIGGING.md is born)
#               -> build -> oracle-correction voyages, exact failure pasted, 12-voyage cap
#   legs        3600s
#
# Ports are derived from arm+model so two arms never collide, and nothing else is tunable.
set -uo pipefail
HERE="$(cd "$(dirname "$0")/.." && pwd)"

ARM="${1:-}"; MODEL_KEY="${2:-}"; TAG="${3:-P}"
case "$ARM" in
  control)   SKILLS=/home/exedev/.claude/plugins/cache/dmytri-shipshape/shipshape/596fbf17be06/skills ;;
  candidate) SKILLS="$HERE/experiments/methods-candidate/skills" ;;
  midway)    SKILLS="$HERE/experiments/methods-midway/skills" ;;
  *) echo "usage: pilot.sh <control|candidate|midway> <flash|mimo|hy3> [tag]" >&2; exit 2 ;;
esac
case "$MODEL_KEY" in
  flash) MODEL=deepseek/deepseek-v4-flash; P0=1 ;;
  mimo)  MODEL=xiaomi/mimo-v2.5;           P0=2 ;;
  hy3)   MODEL=tencent/hy3;                P0=3 ;;
  *) echo "usage: pilot.sh <control|candidate|midway> <flash|mimo|hy3> [tag]" >&2; exit 2 ;;
esac
case "$ARM" in control) A0=0;; candidate) A0=3;; midway) A0=6;; esac
PORT=$((8970 + A0 + P0))
WAVE="$TAG-$ARM-$MODEL_KEY"

[ -d "$SKILLS/shipshape" ] || { echo "pilot.sh: no skills at $SKILLS" >&2; exit 3; }
if [ "$ARM" = midway ]; then
  python3 "$HERE/bin/build-midway.py" --check >/dev/null 2>&1 || {
    echo "pilot.sh: midway build is not clean — run bin/build-midway.py first" >&2; exit 3; }
fi

exec env DRIVER_SHARED_NM="$HERE/.eval-scratch/.shared-nm" \
  "$HERE/bin/pilot-run.sh" "$WAVE" "$MODEL" "$SKILLS" "$PORT"
