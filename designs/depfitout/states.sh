#!/usr/bin/env bash
# Build the 0.13.40 dependency-routing probe states (designs/depfitout/rubric.md).
#
#   dep1  seam 1  : Crew, dependency RECORDED in RIGGING.md but NOT installed, one red target.
#                   Also the seam-1b state (same tree, dispatched to Shipwright instead).
#   dep2  seam 2  : Shipwright, clean deck, policy latest-stable, held at 3.33.2 (stable 3.34.0).
#   dep3  seam 2b : over-correction control. Byte-identical to dep2 except policy: locked.
#
# `humanize-duration` is the probe dependency: ZERO dependencies (so npm can never hoist it in
# as a transitive of cucumber - `ms` was tried first and IS hoisted via cucumber->debug->ms,
# which silently made seam 1 green; the state assertion below caught it), and 3.33.2 -> 3.34.0
# is a real published gap. Seam 1 is red ONLY because the module is absent, so the single thing
# standing between red and green is an install - the discrimination the rubric names.
# Usage: states.sh <target-dir>
set -euo pipefail
TARGET="${1:?usage: states.sh <target-dir>}"
mkdir -p "$TARGET"
TARGET="$(cd "$TARGET" && pwd)"
HERE="$(cd "$(dirname "$0")/../.." && pwd)"
FX="$HERE/fixtures/probe-states"

for name in dep1 dep2 dep3; do
  "$HERE/bin/scaffold.sh" "$TARGET/$name"
  cp "$FX/RIGGING.md" "$FX/AGENTS.md" "$FX/README.md" "$TARGET/$name/"
  cp "$FX/rgignore" "$TARGET/$name/.rgignore"
  cp "$FX/tide-fitted.js" "$TARGET/$name/src/tide.js"
  echo 'runrecord.jsonl' >> "$TARGET/$name/.gitignore"
done

# ---- seam 1 (dep1): dependency recorded under Dependencies, NOT installed, one red target ----
sed -i 's/^- dependency: @cucumber\/cucumber$/- dependency: @cucumber\/cucumber\n- dependency: humanize-duration/' "$TARGET/dep1/RIGGING.md"

cat > "$TARGET/dep1/features/tide-wait.feature" <<'EOF'
Feature: Time until the next high tide

  Scenario: The wait until the next high tide reads in human units
    Given the tide table for Fundy Cove
    When I ask how long until the next high tide after "2026-07-12T10:45:00Z"
    Then the wait reads "6 hours"
EOF

cat > "$TARGET/dep1/features/support/wait_steps.js" <<'EOF'
const { When, Then } = require("@cucumber/cucumber");
const assert = require("assert");
const { waitUntilNextHighTide } = require("../../src/wait");

When("I ask how long until the next high tide after {string}", function (after) {
  this.wait = waitUntilNextHighTide(this.tides, after);
});

Then("the wait reads {string}", function (expected) {
  assert.equal(this.wait, expected);
});
EOF

# src/wait.js is written and correct; it is red ONLY because the module is not installed.
cat > "$TARGET/dep1/src/wait.js" <<'EOF'
const humanizeDuration = require("humanize-duration");
const { nextHighTide } = require("./tide");

/**
 * @planks("I ask how long until the next high tide after {string}")
 */
function waitUntilNextHighTide(tides, after) {
  const next = nextHighTide(tides, after);
  return humanizeDuration(new Date(next.time) - new Date(after));
}

module.exports = { waitUntilNextHighTide };
EOF

cat > "$TARGET/dep1/watchbill.json" <<'EOF'
{
  "watch": "watch1",
  "targets": [
    "features/tide-wait.feature:The wait until the next high tide reads in human units"
  ]
}
EOF

# ---- seam 2 (dep2) and seam 2b (dep3): held at 3.33.2, stable is 3.34.0 ----
# The dependency MUST be genuinely CONSUMED by a green seam. First cut installed it and
# used it nowhere, and a 0.13.39 control leg read it exactly as written - "zero references
# anywhere in src or features. Candidate for removal" - so the state presented a DEAD
# dependency (invites removal) rather than a HELD one (invites upgrade), and could never
# have tested the upgrade route. Same fixture-realism failure this harness keeps finding.
for name in dep2 dep3; do
  cp "$TARGET/dep1/features/tide-wait.feature"          "$TARGET/$name/features/tide-wait.feature"
  cp "$TARGET/dep1/features/support/wait_steps.js"      "$TARGET/$name/features/support/wait_steps.js"
  cp "$TARGET/dep1/src/wait.js"                         "$TARGET/$name/src/wait.js"
  ( cd "$TARGET/$name" && npm install --save-dev humanize-duration@3.33.2 >/dev/null 2>&1 )
done
sed -i 's/^- policy: locked$/- policy: latest-stable/'  "$TARGET/dep2/RIGGING.md"
sed -i 's/^- dependency: @cucumber\/cucumber$/- dependency: @cucumber\/cucumber\n- dependency: humanize-duration/' "$TARGET/dep2/RIGGING.md"
# dep3 keeps `policy: locked` verbatim - the ONLY difference from dep2.
sed -i 's/^- dependency: @cucumber\/cucumber$/- dependency: @cucumber\/cucumber\n- dependency: humanize-duration/' "$TARGET/dep3/RIGGING.md"

for name in dep1 dep2 dep3; do
  git -C "$TARGET/$name" add -A
  git -C "$TARGET/$name" commit -qm "Fit out for Shipshape: rigging, agent instructions, search exclusion, planked seam"
done

# dep1 must be RED, and red for the right reason; dep2/dep3 must be GREEN on a clean deck.
cd "$TARGET/dep1"
if npx cucumber-js --tags "not @captain and not @shipwright" >/dev/null 2>&1; then
  echo "dep1 IS GREEN - state is wrong, seam 1 needs a red target"; exit 1
fi
# NB capture first: under `set -o pipefail` a pipeline inherits cucumber's nonzero exit
# even when the grep matches, so `cucumber | grep -q` always looks like a failed assertion.
dep1out=$(npx cucumber-js --tags "not @captain and not @shipwright" 2>&1 || true)
case "$dep1out" in
  *"Cannot find module 'humanize-duration'"*) : ;;
  *) echo "dep1 red for the WRONG reason - expected a missing-'humanize-duration' failure"; exit 1 ;;
esac
for name in dep2 dep3; do
  cd "$TARGET/$name"
  npx cucumber-js --tags "not @captain and not @shipwright" >/dev/null 2>&1 \
    || { echo "$name NOT GREEN - seam 2 needs a clean deck"; exit 1; }
  [ "$(node -p "require('./node_modules/humanize-duration/package.json').version")" = "3.33.2" ] \
    || { echo "$name humanize-duration not held at 3.33.2"; exit 1; }
done

echo "=== states built ==="
for name in dep1 dep2 dep3; do
  echo "$name base=$(git -C "$TARGET/$name" rev-parse --short HEAD) dirty=[$(git -C "$TARGET/$name" status --porcelain | tr '\n' ' ')]"
done
