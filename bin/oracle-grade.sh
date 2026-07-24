#!/usr/bin/env bash
# Grade a TodoMVC build against the upstream tastejs/todomvc Cypress oracle.
# OPERATOR-SIDE ONLY — the role agents MUST NEVER see this, the clone, or its output
# (oracle quarantine, scenarios/pilot.md). Runs out-of-band from a dir the pilot sim
# never sees; the only thing that crosses back is a re-phrased product-language intent.
#
# Usage:
#   oracle-grade.sh --build <app-dir> --out <grade-file> [--clone <oracle-clone>]
#     [--port 8873] [--framework shakedown]
#
# Serves the oracle clone (with the build dropped at examples/<framework>/) and runs
# the parameterised spec, then parses Tests/Passing/Failing into a stable grade line.
set -euo pipefail
HERE="$(cd "$(dirname "$0")/.." && pwd)"
BUILD=""; OUT=""; CLONE=""; PORT=8873; FRAMEWORK="shakedown"
while [ $# -gt 0 ]; do
  case "$1" in
    --build) BUILD="$2"; shift 2;;
    --out) OUT="$2"; shift 2;;
    --clone) CLONE="$2"; shift 2;;
    --port) PORT="$2"; shift 2;;
    --framework) FRAMEWORK="$2"; shift 2;;
    *) echo "oracle-grade.sh: unknown arg '$1'" >&2; exit 2;;
  esac
done
[ -n "$BUILD" ] && [ -n "$OUT" ] || { echo "usage: oracle-grade.sh --build <dir> --out <file> [--clone <d>] [--port N]" >&2; exit 2; }
[ -d "$BUILD" ] || { echo "oracle-grade.sh: build dir '$BUILD' missing" >&2; exit 2; }
[ -n "$CLONE" ] || CLONE="${ORACLE_CLONE:-$HERE/.eval-scratch/oracle-clone}"
[ -d "$CLONE/cypress" ] || { echo "oracle-grade.sh: oracle clone '$CLONE' not found — clone tastejs/todomvc at the pinned commit and apply fixtures/oracle/*.patch first" >&2; exit 3; }

# Mandatory patch check — an unpatched oracle manufactures phantom failures (pilot #7).
grep -q "^  ${FRAMEWORK}: true," "$CLONE/cypress/e2e/spec.cy.js" || {
  echo "oracle-grade.sh: '$FRAMEWORK' NOT in the exempt map — apply fixtures/oracle/shakedown-localstorage-exempt.patch" >&2; exit 4; }
grep -q "invoke('resetHistory')" "$CLONE/cypress/e2e/spec.cy.js" || {
  echo "oracle-grade.sh: spy-reset.patch NOT applied — apply fixtures/oracle/spy-reset.patch" >&2; exit 4; }

# Drop the build at examples/<framework>/ (served at :PORT/examples/<framework>/index.html).
# Copy the runnable app only — never features/steps/assets/node_modules/.git.
DEST="$CLONE/examples/$FRAMEWORK"
rm -rf "$DEST"; mkdir -p "$DEST"
( cd "$BUILD" && tar --exclude=node_modules --exclude=.git --exclude=features \
    --exclude=assets --exclude='*.feature' -cf - . ) | ( cd "$DEST" && tar -xf - )
echo "oracle-grade: build -> $DEST ($(find "$DEST" -type f | wc -l) files)" >&2

# Serve + run. Override baseUrl/port off 8000 to dodge orphaned sibling servers (a
# recurring cross-session hazard, METRICS). start-server-and-test waits on the URL.
mkdir -p "$(dirname "$OUT")"
RUNLOG="$(mktemp)"
set +e
# Wait on the BUILD's entry (a 200), not on /examples/ (a dir → 404, times out).
( cd "$CLONE" && PORT="$PORT" npx --yes start-server-and-test \
    "node tests/server.js" "http://localhost:$PORT/examples/$FRAMEWORK/index.html" \
    "npx cypress run --env framework=$FRAMEWORK --spec cypress/e2e/spec.cy.js --config baseUrl=http://localhost:$PORT/examples/" \
  ) >"$RUNLOG" 2>&1
GEXIT=$?
set -e

# Parse the cypress summary. It prints "Tests:", "Passing:", "Failing:", "Pending:".
python3 - "$RUNLOG" "$OUT" "$FRAMEWORK" "$GEXIT" <<'PY'
import re, sys
runlog, out, fw, gexit = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4]
txt = open(runlog, encoding="utf-8", errors="replace").read()
def last(pat):
    m = re.findall(pat, txt)
    return int(m[-1]) if m else None
tests   = last(r'Tests:\s+(\d+)')
passing = last(r'Passing:\s+(\d+)')
failing = last(r'Failing:\s+(\d+)')
pending = last(r'Pending:\s+(\d+)')
allpass = "All specs passed!" in txt
lines = [
  f"# oracle grade: framework={fw}  runner_exit={gexit}",
  f"tests={tests} passing={passing} failing={failing} pending={pending}",
  f"all_specs_passed={allpass}",
  f"GRADE: {passing}/{tests}" if tests else "GRADE: UNPARSEABLE (see tail below)",
  "",
  "## cypress summary tail",
]
tail = txt.splitlines()[-40:]
open(out, "w").write("\n".join(lines) + "\n" + "\n".join(tail) + "\n")
print("\n".join(lines[:4]))
PY
rm -f "$RUNLOG"
echo "oracle-grade: grade written -> $OUT" >&2
