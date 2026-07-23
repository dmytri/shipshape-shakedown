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

# Fixture-integrity guard: an escaped leg that wanders into ~/shipshape-shakedown
# can run a Shipwright inspection ON THE SOURCE FIXTURE (writes error-messages.feature,
# RIGGING.md, edits tide.js), which then breaks EVERY subsequent scaffold. Restore the
# fixture pristine before the run so a prior escape can't poison this one.
fixture_guard() {
  if [ -n "$(git -C "$HERE" status --porcelain fixtures/ 2>/dev/null)" ]; then
    echo "eval-batch[$WAVE]: $1 fixtures/ dirty (escape pollution) — restoring pristine" >&2
    git -C "$HERE" checkout -- fixtures/ 2>/dev/null || true
    git -C "$HERE" clean -fdx fixtures/ >/dev/null 2>&1 || true
  fi
}
fixture_guard "pre-run:"

# Build ONE shared node_modules the scaffolds symlink (disk-robust: a 20-leg run
# otherwise npm-installs ~1GB and exhausts a tight tmpfs). scaffold.sh reads
# EVAL_SHARED_NM and symlinks it instead of installing per leg. Carries cucumber
# (the runner) AND @dk/yoink (batch context retrieval) — the latter so a leg can
# run `npx @dk/yoink`/`node_modules/.bin/yoink` OFFLINE under bwrap (empty fake
# HOME kills the npx cache, so it must resolve from node_modules), which future
# yoink-using doctrine requires the eval to be able to exercise. Verified under
# containment 2026-07-23. Registry install, falling back to the local ~/yoink checkout.
# Preinstall the EXPECTED fitting-out toolkit into the shared store (install latency
# is not what the eval measures, dk 2026-07-23): the runner (cucumber), batch retrieval
# (@dk/yoink), coverage (c8), plank-inventory (jsdoc), dead-code (knip), lint (biome).
# scaffold.sh cp -a's this into each sim (a REAL copy, not hardlinks — a leg is free to
# `npm install` anything else it wants without corrupting the shared store; proven 07-23).
# `biome` present = toolkit complete (the gate). yoink falls back to the local ~/yoink checkout.
SHARED_NM="$SCRATCH/.shared-nm"
if [ ! -e "$SHARED_NM/node_modules/.bin/biome" ]; then
  mkdir -p "$SHARED_NM"
  ( cd "$SHARED_NM" && [ -f package.json ] || npm init -y >/dev/null 2>&1
    npm install --no-fund --no-audit --save-dev \
      @cucumber/cucumber @dk/yoink c8 jsdoc knip @biomejs/biome >/dev/null 2>&1 \
    || npm install --no-fund --no-audit \
      @cucumber/cucumber "$HOME/yoink" c8 jsdoc knip @biomejs/biome >/dev/null 2>&1 )
fi
export EVAL_SHARED_NM="$SHARED_NM/node_modules"
KIT=""; for t in cucumber-js yoink c8 jsdoc knip biome; do [ -e "$EVAL_SHARED_NM/.bin/$t" ] && KIT="$KIT+$t" || KIT="$KIT-$t"; done
[ -d "$EVAL_SHARED_NM/@cucumber" ] && echo "eval-batch[$WAVE]: shared toolkit ready ($EVAL_SHARED_NM) [$KIT]" || echo "eval-batch[$WAVE]: WARN shared node_modules missing, legs will install per-leg"

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
    # Bound disk: the banked session.jsonl + tree.diff hold everything analysis
    # needs, so drop the heavy scratch (node_modules ~30-50MB/leg, fake home, raw
    # session dir). Keeps sim src/features + out/session.jsonl for convenience.
    rm -rf "$ws/node_modules" "$out/home" "$out/session" 2>/dev/null || true
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
fixture_guard "POST-RUN (a leg ESCAPED!):"
echo "eval-batch[$WAVE]: complete. Banked under data/$WAVE/ ; fold: bin/eval-map.py data/$WAVE/*.session.jsonl"
