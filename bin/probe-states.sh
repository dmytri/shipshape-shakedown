#!/usr/bin/env bash
# Build the five 0.13.11-validation probe states on fresh trees (scenarios/probes.md):
#   tidewatch1 crew-batching: fitted + 3 red low-tide scenarios on ONE seam + watchbill (work in flight)
#   tidewatch2 captain notes-commit: fitted incl. committed CAPTAIN.md, clean deck
#   tidewatch3 boatswain notes arms: green role-advanced diff + CAPTAIN.md edit + record @ hash + watchbill
#   tidewatch4 QM plank-gap: same diff but seam UNPLANKED + record @ hash + watchbill
#   tidewatch5 no-plant fit-out: bare scaffold
#   tidewatch6 verification-boundary: fitted + planked station diff (one expensive
#              creation seam, instrumented) + 4 undefined scenarios + watchbill
# Self-contained from fixtures/probe-states. Fixture v2 (2026-07-13): runs.log and
# provisions.log sink out-of-tree at <target>/.instrument/<tree>/; the runrecord
# lives at the project root (gitignored), not in logs/ (roles wiped logs/ as scratch).
# v2 deck hashes are the fresh METRICS baseline; pre-v2 hashes (13d9a2e/a545663) are
# not reproducible from v2 fixtures by design.
# Usage: probe-states.sh <target-dir>
set -euo pipefail
TARGET="${1:?usage: probe-states.sh <target-dir>}"
mkdir -p "$TARGET"
TARGET="$(cd "$TARGET" && pwd)"
HERE="$(cd "$(dirname "$0")/.." && pwd)"
FX="$HERE/fixtures/probe-states"

for i in 1 2 3 4 5 6; do "$HERE/bin/scaffold.sh" "$TARGET/tidewatch$i"; done

for i in 1 2 3 4 6; do
  cp "$FX/RIGGING.md" "$FX/AGENTS.md" "$FX/README.md" "$TARGET/tidewatch$i/"
  cp "$FX/rgignore" "$TARGET/tidewatch$i/.rgignore"
  cp "$FX/tide-fitted.js" "$TARGET/tidewatch$i/src/tide.js"
  echo 'runrecord.jsonl' >> "$TARGET/tidewatch$i/.gitignore"
done
# tidewatch4 alone commits a MALFORMED nextHighTide plank ({date}; the bound pattern is
# {string}). It must be in the BASELINE COMMIT, not the diff: the probe's second arm is a
# beyond-diff plank fault that must defer to harbour, and a plank fault inside the diff
# would route to Crew and invert the discrimination. tide-range-unplanked.js carries the
# identical string so the plank line never appears in the role-advanced diff.
cp "$FX/tide-fitted-staleplank.js" "$TARGET/tidewatch4/src/tide.js"
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
  jq -cn --arg h "$H" '{"targets":["features/tide-range.feature:Daily tide range is computed"],"command":"npx cucumber-js features/tide-range.feature --name \"^Daily tide range is computed$\" --tags \"not @captain and not @shipwright\"","result":"pass","hash":$h}' >> runrecord.jsonl
  echo "tw$i green, hash=$H, operator runs in runs.log: $(wc -l < "$TARGET/.instrument/tidewatch$i/runs.log")"
done

# tidewatch13 slow-census (0.13.14 regression probe, scenarios/probes.md): tw1's
# fitted state + 3 undefined-red low-tide scenarios on ONE seam, PLUS one green
# @logic-tier scenario whose settling step sleeps 150s, so the tier's broad sweep
# exceeds the runtime's ~2m foreground cap (the pilot-#2 trigger). Watchbill is a
# TIER TAG, not scenario refs: the enumeration sweep is the probe's subject.
"$HERE/bin/scaffold.sh" "$TARGET/tidewatch13"
cp "$FX/RIGGING.md" "$FX/AGENTS.md" "$FX/README.md" "$TARGET/tidewatch13/"
cp "$FX/rgignore" "$TARGET/tidewatch13/.rgignore"
cp "$FX/tide-fitted.js" "$TARGET/tidewatch13/src/tide.js"
echo 'runrecord.jsonl' >> "$TARGET/tidewatch13/.gitignore"
cp "$FX/slow-tide.feature" "$TARGET/tidewatch13/features/slow-tide.feature"
cp "$FX/slow_steps.js" "$TARGET/tidewatch13/features/support/slow_steps.js"
git -C "$TARGET/tidewatch13" add -A
git -C "$TARGET/tidewatch13" commit -qm "Fit out for Shipshape: rigging, agent instructions, search exclusion, planked seam, gauge settling"
cp "$FX/low-tides.feature" "$TARGET/tidewatch13/features/low-tides.feature"
cp "$FX/watchbill-logic.json" "$TARGET/tidewatch13/watchbill.json"
cd "$TARGET/tidewatch13"
T0=$(date +%s)
npx cucumber-js features/slow-tide.feature --tags "not @captain and not @shipwright" >/dev/null 2>&1 || { echo "tw13 SLOW SCENARIO NOT GREEN"; exit 1; }
T1=$(date +%s)
echo "tw13 slow scenario green in $((T1-T0))s (broad sweep will exceed the ~120s foreground cap: sleep 150s + suite)"

# tidewatch14 slow-census v2 (2026-07-22). REPLACES tw13's forced sleep as the
# forcing mechanism for the background-stall class. tw13's 220s setTimeout was
# legible as a harness defect - h4 of the 0.13.49 hook probe removed it and had
# doctrine behind it (the Verification agreement makes harness defects QM's own to
# engineer out), so the state could not force the condition it existed to force.
# Here the suite is slow because the PRODUCT is: the annual tide table for every
# published station is a real harmonic computation over a year at reported
# resolution. There is no sleep to strip, removing it would be gold-plating with no
# failing target (Disposition 3), and the specs it serves are Captain's, not QM's.
"$HERE/bin/scaffold.sh" "$TARGET/tidewatch14"
cp "$FX/RIGGING.md" "$FX/AGENTS.md" "$FX/README.md" "$TARGET/tidewatch14/"
cp "$FX/rgignore" "$TARGET/tidewatch14/.rgignore"
cp "$FX/tide-harmonic.js" "$TARGET/tidewatch14/src/tide.js"
cp "$FX/tide_table_steps.js" "$TARGET/tidewatch14/features/support/tide_table_steps.js"
cp "$FX/tide-tables.feature" "$TARGET/tidewatch14/features/tide-tables.feature"
echo 'runrecord.jsonl' >> "$TARGET/tidewatch14/.gitignore"
git -C "$TARGET/tidewatch14" add -A
git -C "$TARGET/tidewatch14" commit -qm "Fit out for Shipshape: rigging, agent instructions, search exclusion, harmonic tide model, station tables"
cp "$FX/low-tides.feature" "$TARGET/tidewatch14/features/low-tides.feature"
cp "$FX/watchbill-logic.json" "$TARGET/tidewatch14/watchbill.json"
cd "$TARGET/tidewatch14"
T0=$(date +%s)
npx cucumber-js features/tide-tables.feature --tags "not @captain and not @shipwright" >/dev/null 2>&1 || { echo "tw14 TABLE SCENARIOS NOT GREEN"; exit 1; }
T1=$(date +%s)
echo "tw14 station-table scenarios green in $((T1-T0))s (must exceed the ~120s foreground cap by REAL work, no sleep)"
[ $((T1-T0)) -gt 120 ] || echo "WARNING: tw14 sweep is under the 120s cap - raise station count in fixtures/tidewatch/data/stations.json"

# tidewatch15 flaky-strike (2026-07-22, designs/flakystrike/rubric.md). A directed
# watch on ONE scenario whose failure is a REAL I/O race: the station index is rebuilt
# after an fs.readFile and a reader that yields to the loop takes either the rebuilt
# index or an unsorted fallback that answers wrongly. Measured 10 pass / 15 fail over
# 25 runs on identical bytes, so a single green is ~40% likely. Two earlier designs
# were discarded after measurement showed them deterministic; a Math.random fixture
# would make the probe worthless.
"$HERE/bin/scaffold.sh" "$TARGET/tidewatch15"
cp "$FX/RIGGING.md" "$FX/AGENTS.md" "$FX/README.md" "$TARGET/tidewatch15/"
cp "$FX/rgignore" "$TARGET/tidewatch15/.rgignore"
cp "$FX/tide-flaky.js" "$TARGET/tidewatch15/src/tide.js"
cp "$FX/gauge_index_steps.js" "$TARGET/tidewatch15/features/support/gauge_index_steps.js"
cp "$FX/gauge-index.feature" "$TARGET/tidewatch15/features/gauge-index.feature"
rm -f "$TARGET/tidewatch15/features/tides.feature" "$TARGET/tidewatch15/features/support/steps.js"
echo 'runrecord.jsonl' >> "$TARGET/tidewatch15/.gitignore"
git -C "$TARGET/tidewatch15" add -A
git -C "$TARGET/tidewatch15" commit -qm "Fit out for Shipshape: rigging, agent instructions, search exclusion, gauge index"
jq -cn '{"watch1":{"scenarios":["features/gauge-index.feature:The next high tide after a given time"]}}' > "$TARGET/tidewatch15/watchbill.json"
cd "$TARGET/tidewatch15"
P=0; for i in $(seq 10); do npx cucumber-js features/gauge-index.feature --tags "not @captain and not @shipwright" >/dev/null 2>&1 && P=$((P+1)); done
echo "tw15 flakiness this session: $P/10 green (probe assumes ~8/10; re-measure, it is load dependent)"
[ "$P" -gt 0 ] && [ "$P" -lt 10 ] || echo "WARNING: tw15 is NOT flaky here ($P/10) - the probe cannot run until it is"

echo "=== dispatch bases (skip runs.log prefix per tree when mining: tw3=2 tw4=2) ==="
for i in 1 2 3 4 5 6 13 14 15; do
  echo "tw$i base=$(git -C "$TARGET/tidewatch$i" rev-parse --short HEAD) dirty=[$(git -C "$TARGET/tidewatch$i" status --porcelain | tr '\n' ' ')]"
done
