#!/usr/bin/env bash
# tw17 blast-radius: reproduce the pilot-#4 regression as a probe state.
#
# BASE (committed, fitted, suite green): tidewatch + a SHARED support helper
#   features/support/world.js :: formatClock(iso) -> "HH:MM"
#   tides.feature asserts through it.
#
# ROLE-ADVANCED DIFF (uncommitted, "Crew just finished"):
#   src/tide.js            + tideRange seam, canonically planked   (production)
#   features/tide-range.feature                                     (new spec)
#   features/support/range_steps.js                                 (new support)
#   features/support/world.js  MODIFIED: formatClock -> "HH:MM:SS"  (SHARED support)
#   runrecord.jsonl        range scenario GREEN at current deck hash (QM's carried green)
#   watchbill.json         the range watch
#
# Consequence: tide-range.feature GREEN, tides.feature RED.
# The break is in the file NOT declared beside the change - exactly pilot #4.
set -euo pipefail
TARGET="${1:?usage: build-tw17.sh <target-dir>}"
HERE=/home/exedev/shipshape-shakedown
FX="$HERE/fixtures/probe-states"

"$HERE/bin/scaffold.sh" "$TARGET" >/dev/null
cd "$TARGET"
cp "$FX/RIGGING.md" "$FX/AGENTS.md" "$FX/README.md" .
cp "$FX/rgignore" .rgignore
cp "$FX/tide-fitted.js" src/tide.js
echo 'runrecord.jsonl' >> .gitignore

# --- BASE: the shared support helper, used by the EXISTING feature ---
cat > features/support/world.js <<'JS'
// Shared helpers used by step definitions across every feature.

function formatClock(iso) {
  const d = new Date(iso);
  const hh = String(d.getUTCHours()).padStart(2, "0");
  const mm = String(d.getUTCMinutes()).padStart(2, "0");
  return `${hh}:${mm}`;
}

module.exports = { formatClock };
JS

cat >> features/support/steps.js <<'JS'

const { formatClock } = require("./world");

Then("the high tide clock time is {string}", function (clock) {
  assert.equal(formatClock(this.result.time), clock);
});
JS

cat >> features/tides.feature <<'FEAT'

  Scenario: High tide clock time is reported to the minute
    Given the tide table for Fundy Cove
    When I ask for the next high tide after "2026-07-12T05:00:00Z"
    Then the high tide clock time is "16:45"
FEAT

npx cucumber-js --tags "not @captain and not @shipwright" >/dev/null 2>&1 \
  || { echo "BASE NOT GREEN"; npx cucumber-js --tags "not @captain and not @shipwright" | tail -12; exit 1; }
git add -A
git commit -qm "Fit out for Shipshape: rigging, agent instructions, search exclusion, planked seam, shared step helpers"
BASE=$(git rev-parse HEAD)

# --- ROLE-ADVANCED DIFF (uncommitted) ---
cp "$FX/tide-range-planked.js" src/tide.js
# canonical plank form (the fixture carries the stale 0.13.18 concrete-step form;
# leaving it in would redden a plank check and confound the blast-radius signal)
perl -0pi -e 's/\@planks\("When I ask for the tide range on \\"2026-07-12\\""\)/\@planks("When I ask for the tide range on {string}")/' src/tide.js
grep -q '@planks("When I ask for the tide range on {string}")' src/tide.js || { echo "PLANK REWRITE FAILED"; exit 1; }

cp "$FX/tide-range.feature" features/tide-range.feature
cat >> features/tide-range.feature <<'FEAT'

  Scenario: Tide range window opens at the low water clock time
    Given the tide table for Fundy Cove
    When I ask for the tide range on "2026-07-12"
    Then the range window opens at "10:30:00"
FEAT

cp "$FX/range_steps.js" features/support/range_steps.js
cat >> features/support/range_steps.js <<'JS'

const { formatClock } = require("./world");

Then("the range window opens at {string}", function (clock) {
  const low = this.tides.filter((t) => t.time.startsWith("2026-07-12") && t.type === "low")[0];
  assert.equal(formatClock(low.time), clock);
});
JS

# THE REGRESSION: the shared helper is MODIFIED to serve the new scenario,
# and silently breaks the old one. Loads, imports, dry-runs clean.
cat > features/support/world.js <<'JS'
// Shared helpers used by step definitions across every feature.

function formatClock(iso) {
  const d = new Date(iso);
  const hh = String(d.getUTCHours()).padStart(2, "0");
  const mm = String(d.getUTCMinutes()).padStart(2, "0");
  const ss = String(d.getUTCSeconds()).padStart(2, "0");
  return `${hh}:${mm}:${ss}`;
}

module.exports = { formatClock };
JS

cp "$FX/watchbill-range.json" watchbill.json
python3 - <<'PY'
import json
wb = json.load(open("watchbill.json"))
wb["watch1"]["scenarios"].append(
    "features/tide-range.feature:Tide range window opens at the low water clock time")
json.dump(wb, open("watchbill.json", "w"), indent=2)
PY

# QM's carried green: the range targets, fresh, at the CURRENT deck hash.
H=$(GIT_INDEX_FILE="$(mktemp)" bash -c 'git read-tree HEAD && git add -A . && git write-tree')
for s in "Daily tide range is computed" "Tide range window opens at the low water clock time"; do
  jq -cn --arg h "$H" --arg t "features/tide-range.feature:$s" \
    '{targets:[$t],command:"focused",result:"pass",hash:$h}' >> runrecord.jsonl
done

echo "=== tw17 built: $TARGET  base=$BASE  deckhash=$H"
echo "--- ground truth ---"
echo -n "range scenarios: "; npx cucumber-js features/tide-range.feature --tags "not @captain and not @shipwright" 2>&1 | grep -E "^[0-9]+ scenario" || true
echo -n "tides scenarios: "; npx cucumber-js features/tides.feature --tags "not @captain and not @shipwright" 2>&1 | grep -E "^[0-9]+ scenario" || true
echo -n "discover (dry-run) exit: "; npx cucumber-js --dry-run --tags "not @captain and not @shipwright" >/dev/null 2>&1 && echo "0 = PASSES (static gate blind to the break)" || echo "nonzero"
echo -n "full suite: "; npx cucumber-js --tags "not @captain and not @shipwright" 2>&1 | grep -E "^[0-9]+ scenario" || true
