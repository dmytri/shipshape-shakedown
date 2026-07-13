#!/usr/bin/env bash
# Build the five 0.13.11-validation probe states on fresh trees (scenarios/probes.md):
#   tidewatch1 crew-batching: fitted + 3 red low-tide scenarios on ONE seam + watchbill (work in flight)
#   tidewatch2 captain notes-commit: fitted incl. committed CAPTAIN.md, clean deck
#   tidewatch3 boatswain notes arms: green role-advanced diff + CAPTAIN.md edit + record @ hash + watchbill
#   tidewatch4 QM plank-gap: same diff but seam UNPLANKED + record @ hash + watchbill
#   tidewatch5 no-plant fit-out: bare scaffold
#   tidewatch6 verification-boundary: fitted + planked station diff (one expensive
#              creation seam, instrumented) + 4 undefined scenarios + watchbill
# Self-contained from fixtures/probe-states (2026-07-13 wave states, deck hashes reproducible).
# Usage: probe-states.sh <target-dir>
set -euo pipefail
TARGET="${1:?usage: probe-states.sh <target-dir>}"
HERE="$(cd "$(dirname "$0")/.." && pwd)"
FX="$HERE/fixtures/probe-states"

for i in 1 2 3 4 5 6; do "$HERE/bin/scaffold.sh" "$TARGET/tidewatch$i"; done

for i in 1 2 3 4 6; do
  cp "$FX/RIGGING.md" "$FX/AGENTS.md" "$FX/README.md" "$TARGET/tidewatch$i/"
  cp "$FX/rgignore" "$TARGET/tidewatch$i/.rgignore"
  cp "$FX/tide-fitted.js" "$TARGET/tidewatch$i/src/tide.js"
done
for i in 2 3; do cp "$FX/CAPTAIN.md" "$TARGET/tidewatch$i/CAPTAIN.md"; done
for i in 1 2 3 4 6; do
  git -C "$TARGET/tidewatch$i" add -A
  git -C "$TARGET/tidewatch$i" commit -qm "Fit out for Shipshape: rigging, agent instructions, search exclusion, planked seam"
done

cp "$FX/low-tides.feature" "$TARGET/tidewatch1/features/low-tides.feature"
cp "$FX/watchbill-low.json" "$TARGET/tidewatch1/watchbill.json"

cp "$FX/tide-range.feature" "$TARGET/tidewatch3/features/tide-range.feature"
cp "$FX/range_steps.js" "$TARGET/tidewatch3/features/support/range_steps.js"
cp "$FX/tide-range-planked.js" "$TARGET/tidewatch3/src/tide.js"
cp "$FX/watchbill-range.json" "$TARGET/tidewatch3/watchbill.json"
echo '- Tide range asked for by the harbourmaster; daily range only, no weekly aggregate yet.' >> "$TARGET/tidewatch3/CAPTAIN.md"

cp "$FX/tide-range.feature" "$TARGET/tidewatch4/features/tide-range.feature"
cp "$FX/range_steps.js" "$TARGET/tidewatch4/features/support/range_steps.js"
cp "$FX/tide-range-unplanked.js" "$TARGET/tidewatch4/src/tide.js"
cp "$FX/watchbill-range.json" "$TARGET/tidewatch4/watchbill.json"

cp "$FX/station.js" "$TARGET/tidewatch6/src/station.js"
cp "$FX/station.feature" "$TARGET/tidewatch6/features/station.feature"
cp "$FX/watchbill-station.json" "$TARGET/tidewatch6/watchbill.json"

for i in 3 4; do
  cd "$TARGET/tidewatch$i"
  npx cucumber-js features/tide-range.feature --name "^Daily tide range is computed$" --tags "not @captain and not @shipwright" >/dev/null 2>&1 || { echo "tw$i NOT GREEN"; exit 1; }
  npx cucumber-js --tags "not @captain and not @shipwright" >/dev/null 2>&1 || { echo "tw$i SUITE NOT GREEN"; exit 1; }
  H=$(GIT_INDEX_FILE="$(mktemp)" bash -c 'git read-tree HEAD && git add -A . && git write-tree')
  mkdir -p logs
  jq -cn --arg h "$H" '{"targets":["features/tide-range.feature:Daily tide range is computed"],"command":"npx cucumber-js features/tide-range.feature --name \"^Daily tide range is computed$\" --tags \"not @captain and not @shipwright\"","result":"pass","hash":$h}' >> logs/runrecord.jsonl
  echo "tw$i green, hash=$H, operator runs in runs.log: $(wc -l < logs/runs.log)"
done

echo "=== dispatch bases (skip runs.log prefix per tree when mining: tw3=2 tw4=2) ==="
for i in 1 2 3 4 5 6; do
  echo "tw$i base=$(git -C "$TARGET/tidewatch$i" rev-parse --short HEAD) dirty=[$(git -C "$TARGET/tidewatch$i" status --porcelain | tr '\n' ' ')]"
done
