#!/usr/bin/env bash
# Run the doctrine matrix ONE MODEL AT A TIME: the three arms of a model together, nothing else.
#
# Why batched by model (2026-07-28): nine concurrent waves put nine happy-dom suites on a 16G
# box and the kernel OOM-killed them mid-run (two kills at ~12G within 34 seconds, R4). Batching
# by MODEL is better than batching arbitrarily: the three arms of a model then run under
# IDENTICAL contention, and arm-vs-arm within a model is the comparison the matrix exists to
# make. Cross-model numbers were never comparable anyway (see data/BUDGET-NOTE.md).
set -uo pipefail
HERE=/home/exedev/shipshape-shakedown
TAG="${1:-R5}"
CTRL=/home/exedev/.claude/plugins/cache/dmytri-shipshape/shipshape/596fbf17be06/skills
CAND=$HERE/experiments/methods-candidate/skills
MID=$HERE/experiments/methods-midway/skills
port=8940
for m in flash:deepseek/deepseek-v4-flash mimo:xiaomi/mimo-v2.5 hy3:tencent/hy3; do
  mm=${m%%:*}; id=${m#*:}
  echo "[$(date -u +%FT%TZ)] === batch $mm: ctrl, cand, mid together ==="
  for arm in ctrl cand mid; do
    case $arm in ctrl) SK=$CTRL;; cand) SK=$CAND;; mid) SK=$MID;; esac
    port=$((port+1))
    # NOT setsid: setsid forks and exits immediately, so `wait` below returns at once and every
    # batch launches on top of the last — which is how R5 put all nine waves live again despite
    # being "batched". Plain background children are what `wait` can actually wait for.
    DRIVER_SHARED_NM="$HERE/.eval-scratch/.shared-nm" bash "$HERE/bin/eval-drive-todomvc.sh" \
      --wave "$TAG-$arm-$mm" --model "$id" --skills-dir "$SK" --yoink-skill "$HOME/yoink/skills/yoink" \
      --clone "$HERE/.eval-scratch/oracle-clone" --port "$port" --max-voyages 12 --oracle-correct \
      --timeout-s 3600 > "$HERE/.eval-scratch/$TAG-$arm-$mm.log" 2>&1 &
  done
  wait
  echo "[$(date -u +%FT%TZ)] === batch $mm complete ==="
done
echo "MATRIX-COMPLETE"
