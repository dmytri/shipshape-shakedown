#!/usr/bin/env bash
# Run a whole model batch through one eval leg each, on fresh isolated trees,
# with bounded concurrency, and bank every result. The composable batch layer
# over eval-leg.sh + eval-bank.sh; medium/premium tiers reuse it unchanged.
#
# For each model id in the manifest: scaffold a fresh sim, materialise the task
# (PROJECT_ROOT_PLACEHOLDER -> the sim), run the leg, bank it. Models run up to
# --concurrency at a time (legs are API-bound; isolated homes/trees, no shared
# state). Progress is written to stdout so a background caller can Read it.
#
# Usage:
#   eval-batch.sh --wave <dir> --models <manifest> --task <template> \
#     --skill <path> [--skill <path>...] [--model-list "id id ..."] \
#     [--concurrency 4] [--timeout-s 900]
set -euo pipefail
HERE="$(cd "$(dirname "$0")/.." && pwd)"
SCRATCH="${EVAL_SCRATCH:-$(pwd)/.eval-scratch}"
WAVE=""; MODELS_FILE=""; TASK=""; CONC=4; TIMEOUT_S=900; INLINE=""; DRAWS=1
SKILLS=()
while [ $# -gt 0 ]; do
  case "$1" in
    --wave) WAVE="$2"; shift 2;;
    --models) MODELS_FILE="$2"; shift 2;;
    --model-list) INLINE="$2"; shift 2;;
    --task) TASK="$2"; shift 2;;
    --skill) SKILLS+=("$2"); shift 2;;
    --concurrency) CONC="$2"; shift 2;;
    --draws) DRAWS="$2"; shift 2;;
    --timeout-s) TIMEOUT_S="$2"; shift 2;;
    --scratch) SCRATCH="$2"; shift 2;;
    *) echo "eval-batch.sh: unknown arg '$1'" >&2; exit 2;;
  esac
done
[ -n "$WAVE" ] && [ -n "$TASK" ] || { echo "usage: eval-batch.sh --wave <d> --models <f> --task <tmpl> --skill <p>..." >&2; exit 2; }
[ -f "$TASK" ] || { echo "eval-batch.sh: task template '$TASK' missing" >&2; exit 2; }
[ "${#SKILLS[@]}" -gt 0 ] || { echo "eval-batch.sh: at least one --skill required" >&2; exit 2; }

# Model list: manifest (skip # comments and inline # trailers) and/or --model-list.
MODELS=()
if [ -n "$MODELS_FILE" ]; then
  [ -f "$MODELS_FILE" ] || { echo "eval-batch.sh: manifest '$MODELS_FILE' missing" >&2; exit 2; }
  while IFS= read -r line; do
    line="${line%%#*}"; line="$(echo "$line" | xargs)"
    [ -n "$line" ] && MODELS+=("$line")
  done < "$MODELS_FILE"
fi
for m in $INLINE; do MODELS+=("$m"); done
[ "${#MODELS[@]}" -gt 0 ] || { echo "eval-batch.sh: no models to run" >&2; exit 2; }

mkdir -p "$SCRATCH/$WAVE"
SKILL_FLAGS=(); for s in "${SKILLS[@]}"; do SKILL_FLAGS+=(--skill "$s"); done
echo "eval-batch[$WAVE]: ${#MODELS[@]} models, concurrency $CONC"

run_one() {
  local model="$1" draw="${2:-1}"
  local name; name="$(echo "$model" | tr '/:' '--')"
  [ "$DRAWS" -gt 1 ] && name="${name}-d${draw}"
  local base="$SCRATCH/$WAVE/$name"
  local ws="$base/sim" out="$base/out"
  rm -rf "$base"; mkdir -p "$base"
  if ! "$HERE/bin/scaffold.sh" "$ws" >"$base/scaffold.log" 2>&1; then
    echo "  [$name] SCAFFOLD FAILED (see $base/scaffold.log)"; return
  fi
  sed "s#PROJECT_ROOT_PLACEHOLDER#$ws#" "$TASK" > "$base/task"
  if "$HERE/bin/eval-leg.sh" --model "$model" --workspace "$ws" --out "$out" \
       "${SKILL_FLAGS[@]}" --task-file "$base/task" --name "$name" \
       --timeout-s "$TIMEOUT_S" >"$base/leg.log" 2>&1; then
    "$HERE/bin/eval-bank.sh" --wave "$WAVE" --name "$name" --out "$out" \
       --workspace "$ws" --verdict PENDING >/dev/null 2>&1 || true
    echo "  [$name] done -> banked"
  else
    echo "  [$name] LEG FAILED (see $base/leg.log)"
  fi
}

# Bounded-concurrency scheduler over (model x draw).
echo "eval-batch[$WAVE]: draws=$DRAWS"
running=0
for model in "${MODELS[@]}"; do
  for draw in $(seq 1 "$DRAWS"); do
    run_one "$model" "$draw" &
    running=$((running+1))
    if [ "$running" -ge "$CONC" ]; then wait -n; running=$((running-1)); fi
  done
done
wait
echo "eval-batch[$WAVE]: complete. Banked under data/$WAVE/ ; fold: bin/eval-map.py data/$WAVE/*.session.jsonl"
