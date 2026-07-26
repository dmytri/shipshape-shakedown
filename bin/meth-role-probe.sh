#!/usr/bin/env bash
# Probe ONE role against a seeded deck, and audit which METHODS it actually ran.
#
# dk's criteria for the methods candidate are (a) every role reliably USES the method for the job and
# (b) methods are reliably FITTED OUT. meth-fitout.sh answers (b). This answers (a), which a pilot
# cannot: in a pilot QM assumes Crew and Boatswain, so no leg is one role doing one job. Here the sim
# is fitted out with a known-good methods rigging, a role-advanced diff is seeded, and exactly one
# role is dispatched for one job. The audit then asks the only question that matters: for each job
# the role reached, did it run that job's method, or did it reach for an ad hoc invocation instead?
#
# usage: meth-role-probe.sh --wave <tag> --role boatswain --skills-dir <root> [--model M]
set -uo pipefail
HERE="$(cd "$(dirname "$0")/.." && pwd)"
SCRATCH="${EVAL_SCRATCH:-$HERE/.eval-scratch}"
WAVE=""; ROLE="boatswain"; MODEL="deepseek/deepseek-v4-flash"; SKILLS_DIR=""; TIMEOUT_S=900
RIGGING="$HERE/assets/rigging-tidewatch-methods.md"
while [ $# -gt 0 ]; do
  case "$1" in
    --wave) WAVE="$2"; shift 2;;
    --role) ROLE="$2"; shift 2;;
    --model) MODEL="$2"; shift 2;;
    --skills-dir) SKILLS_DIR="$2"; shift 2;;
    --rigging) RIGGING="$2"; shift 2;;
    --timeout-s) TIMEOUT_S="$2"; shift 2;;
    *) echo "meth-role-probe.sh: unknown arg '$1'" >&2; exit 2;;
  esac
done
[ -n "$WAVE" ] && [ -n "$SKILLS_DIR" ] || { echo "usage: meth-role-probe.sh --wave <tag> --role <role> --skills-dir <root>" >&2; exit 2; }
BASE="$SCRATCH/$WAVE"; SIM="$BASE/sim"; LOG="$BASE/probe.log"
rm -rf "$BASE"; mkdir -p "$BASE"
say(){ echo "[$(date -u +%FT%TZ)] $*" | tee -a "$LOG"; }

NM="$SCRATCH/.shared-nm-$WAVE"
[ -d "$NM/node_modules" ] || { mkdir -p "$NM"; cp -a "$SCRATCH/.shared-nm/node_modules" "$NM/"; }
export EVAL_SHARED_NM="$NM/node_modules"

say "PROBE START wave=$WAVE role=$ROLE model=$MODEL skills=$SKILLS_DIR"
"$HERE/bin/scaffold-stack.sh" js "$SIM" >"$BASE/scaffold.log" 2>&1 || { say "SCAFFOLD FAILED"; exit 4; }
cp "$RIGGING" "$SIM/RIGGING.md"
if grep -q 'npm run ss:' "$SIM/RIGGING.md"; then
  python3 - "$SIM/package.json" "$HERE/assets/tidewatch-method-scripts.json" <<'PYX'
import json,sys
pkg=json.load(open(sys.argv[1])); scripts=json.load(open(sys.argv[2]))
pkg.setdefault("scripts",{}).update(scripts)
json.dump(pkg,open(sys.argv[1],"w"),indent=2)
PYX
fi
printf '# Captain Notes\n\nNothing durable here. No role but Captain reads this file.\n' > "$SIM/CAPTAIN.md"
( cd "$SIM" && git add -A && git -c user.name="Sim Operator" -c user.email="sim@example.test" commit -qm "fitted out: methods rigging" )
BASE_COMMIT=$( cd "$SIM" && git rev-parse HEAD )

# The seeded deck: a role-advanced diff exactly as Crew leaves it. One production seam with a plank,
# its scenario, its step definitions, and a stale plank on the second seam so the join has something
# real to catch. Post-implementation custody is the job.
cat >> "$SIM/src/tide.js" <<'JS'

/** @planks("I ask for the next low tide after {string}") */
function nextLowTide(tides, after) {
  const next = tides.find((t) => new Date(t.time) > new Date(after) && t.type === "low");
  if (!next) throw new Error("no upcoming low tide in data");
  return next;
}
JS
python3 - "$SIM/src/tide.js" <<'PY'
import sys
p=sys.argv[1]; s=open(p).read()
s=s.replace("module.exports = { nextHighTide };","module.exports = { nextHighTide, nextLowTide };")
open(p,"w").write(s)
PY
cat >> "$SIM/features/tides.feature" <<'FEAT'

  Scenario: Next low tide after a given time
    Given the tide table for Fundy Cove
    When I ask for the next low tide after "2026-07-12T05:00:00Z"
    Then the predicted low tide is at "2026-07-12T10:30:00Z" with height 0.8
FEAT
cat >> "$SIM/features/support/steps.js" <<'JS'

const { nextLowTide } = require("../../src/tide");

When("I ask for the next low tide after {string}", function (after) {
  try {
    this.result = nextLowTide(this.tides, after);
  } catch (e) {
    this.error = e;
  }
});

Then("the predicted low tide is at {string} with height {float}", function (time, height) {
  assert.equal(this.result.time, time);
  assert.equal(this.result.height, height);
});
JS

case "$ROLE" in
  boatswain)
    cat > "$BASE/task.md" <<EOF
You are the Shipshape Boatswain. Project root: $SIM.

Job: post-implementation. Base commit: $BASE_COMMIT.

Proceed now without waiting for confirmation. Do not push or tag.
EOF
    ;;
  qm)
    # QM's deck is the OTHER shape: the spec and the watchbill exist, the production seam does not,
    # so the target is genuinely red and QM must verify, make steps executable, and reach Crew.
    ( cd "$SIM" && git checkout -- src/tide.js features/support/steps.js 2>/dev/null )
    python3 - "$SIM/src/tide.js" <<'PYX'
import sys
p=sys.argv[1]; s=open(p).read()
s=s.replace("module.exports = { nextHighTide, nextLowTide };","module.exports = { nextHighTide };")
i=s.find('/** @planks("I ask for the next low tide')
if i>0: s=s[:i].rstrip()+"\n"
open(p,"w").write(s)
PYX
    cat > "$SIM/watchbill.json" <<'JSON'
{ "watch1": { "scenarios": ["features/tides.feature:Next low tide after a given time"] } }
JSON
    ( cd "$SIM" && git add -A && git -c user.name="Sim Operator" -c user.email="sim@example.test" commit -qm "captain: low tide spec + watchbill" )
    BASE_COMMIT=$( cd "$SIM" && git rev-parse HEAD )
    cat > "$BASE/task.md" <<EOF
You are the Shipshape Quartermaster. Project root: $SIM. Base commit: $BASE_COMMIT.

Proceed now without waiting for confirmation. Do not push or tag.
EOF
    ;;
  crew)
    ( cd "$SIM" && git checkout -- src/tide.js 2>/dev/null )
    python3 - "$SIM/src/tide.js" <<'PYX'
import sys
p=sys.argv[1]; s=open(p).read()
s=s.replace("module.exports = { nextHighTide, nextLowTide };","module.exports = { nextHighTide };")
i=s.find('/** @planks("I ask for the next low tide')
if i>0: s=s[:i].rstrip()+"\n"
open(p,"w").write(s)
PYX
    ( cd "$SIM" && git add -A && git -c user.name="Sim Operator" -c user.email="sim@example.test" commit -qm "qm: low tide step definitions" )
    BASE_COMMIT=$( cd "$SIM" && git rev-parse HEAD )
    cat > "$BASE/task.md" <<EOF
You are a Shipshape Crew Mate. Project root: $SIM. Base commit: $BASE_COMMIT.

Target: features/tides.feature:Next low tide after a given time
Failure evidence: the scenario fails with "TypeError: nextLowTide is not a function" from
features/support/steps.js, because src/tide.js exports no nextLowTide.
Solo dispatch.

Proceed now without waiting for confirmation. Do not push or tag.
EOF
    ;;
esac

t0=$(date +%s)
"$HERE/bin/eval-leg.sh" --model "$MODEL" --workspace "$SIM" --out "$BASE/probe.out" \
  --skill "$SKILLS_DIR/shipshape" --skill "$SKILLS_DIR/$ROLE" \
  --task-file "$BASE/task.md" --name "$ROLE" --timeout-s "$TIMEOUT_S" >"$BASE/probe.leg.log" 2>&1
rc=$?; t1=$(date +%s)
say "PROBE LEG $((t1-t0))s rc=$rc base=$BASE_COMMIT"
"$HERE/bin/meth-use-audit.py" "$BASE" 2>&1 | tee -a "$LOG"
say "PROBE END wave=$WAVE"
echo PROBE-DONE
