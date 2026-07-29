#!/usr/bin/env bash
# THE matrix: three arms x three models, one model at a time.
#
#   bin/run-matrix.sh [tag]
#
# One model per batch, its three arms together, so the arms being compared run under IDENTICAL
# contention — the only comparison that was ever valid (cross-model numbers are not comparable;
# see data/BUDGET-NOTE.md). Nine concurrent waves OOM-killed this box; three do not.
#
# Every setting lives in bin/pilot.sh. There are no options here either, on purpose.
set -uo pipefail
HERE="$(cd "$(dirname "$0")/.." && pwd)"
TAG="${1:-P}"
for model in flash mimo hy3; do
  echo "[$(date -u +%FT%TZ)] === batch $model: control, candidate, midway ==="
  for arm in control candidate midway; do
    # plain background children: `wait` cannot wait for a setsid'd process, and that defeated
    # batching once already (R5 launched all nine at once while claiming to be batched).
    bash "$HERE/bin/pilot.sh" "$arm" "$model" "$TAG" > "$HERE/.eval-scratch/$TAG-$arm-$model.log" 2>&1 &
  done
  wait
  echo "[$(date -u +%FT%TZ)] === batch $model complete ==="
done
echo MATRIX-COMPLETE
