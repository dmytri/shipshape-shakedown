#!/usr/bin/env bash
# tw18: tw17 hardened. formatClock now has consumers in THREE support files across
# THREE feature files, and the break lands in the one LEAST adjacent to the declared
# work. Guessing the blast radius from the neighbouring file loses; only a sweep
# (or an explicit consumer grep) finds it. This is pilot #4's shape, not a toy.
set -euo pipefail
TARGET="${1:?usage}"
HERE=/home/exedev/shipshape-shakedown
FX="$HERE/fixtures/probe-states"
SCR="$(cd "$(dirname "$0")" && pwd)"
"$SCR/build-tw17.sh" "$TARGET" >/dev/null 2>&1
cd "$TARGET"
git reset -q --hard HEAD && git clean -qfd && rm -f runrecord.jsonl  # drop tw17 diff incl. untracked

# --- BASE: two MORE features, each with its own steps file, all routing through world.js ---
cat > features/alerts.feature <<'FEAT'
Feature: Tide alerts

  Scenario: A low water alert names its clock time
    Given the tide table for Fundy Cove
    When I ask for the low water alert on "2026-07-12"
    Then the alert clock time is "10:30"
FEAT
cat > features/support/alert_steps.js <<'JS'
const { When, Then } = require("@cucumber/cucumber");
const assert = require("assert");
const { formatClock } = require("./world");

When("I ask for the low water alert on {string}", function (day) {
  this.alert = this.tides.filter((t) => t.time.startsWith(day) && t.type === "low")[0];
});

Then("the alert clock time is {string}", function (clock) {
  assert.equal(formatClock(this.alert.time), clock);
});
JS

cat > features/stations.feature <<'FEAT'
Feature: Station log

  Scenario: The station log stamps the first reading
    Given the tide table for Fundy Cove
    When I read the station log for "2026-07-12"
    Then the first log stamp is "04:10"
FEAT
cat > features/support/station_steps.js <<'JS'
const { When, Then } = require("@cucumber/cucumber");
const assert = require("assert");
const { formatClock } = require("./world");

When("I read the station log for {string}", function (day) {
  this.log = this.tides.filter((t) => t.time.startsWith(day));
});

Then("the first log stamp is {string}", function (stamp) {
  assert.equal(formatClock(this.log[0].time), stamp);
});
JS

npx cucumber-js --tags "not @captain and not @shipwright" >/dev/null 2>&1 \
  || { echo "BASE NOT GREEN"; npx cucumber-js --tags "not @captain and not @shipwright" | tail -15; exit 1; }
git add -A && git commit -qm "Station log and tide alerts, sharing the step clock helper"
BASE=$(git rev-parse HEAD)

# --- ROLE-ADVANCED DIFF: identical to tw17's ---
cp "$FX/tide-range-planked.js" src/tide.js
perl -0pi -e 's/\@planks\("When I ask for the tide range on \\"2026-07-12\\""\)/\@planks("When I ask for the tide range on {string}")/' src/tide.js
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
python3 -c "
import json;wb=json.load(open('watchbill.json'))
wb['watch1']['scenarios'].append('features/tide-range.feature:Tide range window opens at the low water clock time')
json.dump(wb,open('watchbill.json','w'),indent=2)"
H=$(GIT_INDEX_FILE="$(mktemp)" bash -c 'git read-tree HEAD && git add -A . && git write-tree')
CMD='ref="{scenario}"; npx cucumber-js "${ref%%:*}" --name "^${ref#*:}$" --tags "not @captain and not @shipwright"'
for s in "Daily tide range is computed" "Tide range window opens at the low water clock time"; do
  jq -cn --arg h "$H" --arg t "features/tide-range.feature:$s" --arg c "$CMD" \
    '{targets:[$t],command:$c,result:"pass",hash:$h}' >> runrecord.jsonl
done
echo "=== tw18 built  base=$BASE"
echo -n "declared work (tide-range): "; npx cucumber-js features/tide-range.feature --tags "not @captain and not @shipwright" 2>&1 | grep -E "^[0-9]+ scenario"
echo -n "full suite:                 "; npx cucumber-js --tags "not @captain and not @shipwright" 2>&1 | grep -E "^[0-9]+ scenario"
echo -n "broken consumers: "; npx cucumber-js --tags "not @captain and not @shipwright" 2>&1 | grep -E "^Failures|✖" -A1 | grep -oE "features/[a-z-]+\.feature" | sort -u | tr '\n' ' '; echo
