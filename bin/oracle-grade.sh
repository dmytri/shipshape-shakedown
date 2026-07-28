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
# Disk preflight — grading on a full disk parses ENOSPC noise as a bogus low score (see the
# ENOSPC guard below). Refuse up front rather than emit a lie. Exit 6 = infra fault, not a grade.
_free=$(df -Pk / | awk 'NR==2{print $4}'); if [ "${_free:-0}" -lt "${ORACLE_DISK_MIN_KB:-1048576}" ]; then
  echo "oracle-grade.sh: only $((_free/1024))M free — refusing to grade (ENOSPC risk), exit 6" >&2; exit 6; fi
[ -n "$CLONE" ] || CLONE="${ORACLE_CLONE:-$HERE/.eval-scratch/oracle-clone}"
[ -d "$CLONE/cypress" ] || { echo "oracle-grade.sh: oracle clone '$CLONE' not found — clone tastejs/todomvc at the pinned commit and apply fixtures/oracle/*.patch first" >&2; exit 3; }

# Mandatory patch check — an unpatched oracle manufactures phantom failures (pilot #7).
grep -q "^  ${FRAMEWORK}: true," "$CLONE/cypress/e2e/spec.cy.js" || {
  echo "oracle-grade.sh: '$FRAMEWORK' NOT in the exempt map — apply fixtures/oracle/shakedown-localstorage-exempt.patch" >&2; exit 4; }
grep -q "invoke('resetHistory')" "$CLONE/cypress/e2e/spec.cy.js" || {
  echo "oracle-grade.sh: spy-reset.patch NOT applied — apply fixtures/oracle/spy-reset.patch" >&2; exit 4; }

# Mandatory RUNNABILITY check — the patches can be perfect while the clone cannot serve at all.
# 2026-07-27: a broad node_modules sweep of .eval-scratch took the clone's own root deps with it,
# so tests/server.js died on `Cannot find package 'express'` and EVERY grade came back
# "GRADE: UNPARSEABLE" — which the driver's intent selector reads as "no servable page" and then
# chases with page voyages forever. Three parallel pilots spent ~40 minutes and real credits
# scoring 0/29 against a dead server; the same builds regraded 24/29 once the deps were back.
# A grader that cannot run must exit as an infra fault (6), never emit a score-shaped lie.
[ -d "$CLONE/node_modules" ] || {
  echo "oracle-grade.sh: '$CLONE/node_modules' missing — run 'npm install' in the clone; refusing to grade, exit 6" >&2; exit 6; }
( cd "$CLONE" && node -e "require.resolve('express')" >/dev/null 2>&1 ) || {
  echo "oracle-grade.sh: the clone cannot resolve 'express' (tests/server.js would die) — run 'npm install' in the clone; refusing to grade, exit 6" >&2; exit 6; }
git -C "$CLONE" diff --name-only --diff-filter=D -- examples | head -1 | grep -q . && {
  echo "oracle-grade.sh: the clone has DELETED vendored files under examples/ — run 'git checkout -- examples/' in the clone; refusing to grade, exit 6" >&2; exit 6; }

# ONE FIXTURE (dk, 2026-07-28). Per-arm oracle clones existed only so parallel waves could not
# collide in examples/<framework>/ — six copies cost 1.1G and were a standing disk hazard that
# twice took this box to 99% and voided a cell mid-run. One clone plus a lock is the same
# guarantee for a sixth of the disk: a grade holds the clone for the ~35s it runs, and a
# concurrent wave waits rather than overwriting the build under it.
# The lock is keyed on the clone, so a run that still passes its own --clone is unaffected.
exec 9>"$CLONE/.grade.lock"
flock 9 || { echo "oracle-grade.sh: could not lock $CLONE — refusing to grade, exit 6" >&2; exit 6; }

# Drop the build at examples/<framework>/ (served at :PORT/examples/<framework>/index.html).
# Copy the runnable app only — never features/steps/assets/.git.
DEST="$CLONE/examples/$FRAMEWORK"
rm -rf "$DEST"; mkdir -p "$DEST"
( cd "$BUILD" && tar --exclude=node_modules --exclude=.git --exclude=features \
    --exclude=assets --exclude='*.feature' -cf - . ) | ( cd "$DEST" && tar -xf - )

# SERVE WHAT THE PAGE LINKS (2026-07-28). Excluding node_modules wholesale stripped the very
# stylesheets index.html references: the standard TodoMVC template links
# node_modules/todomvc-app-css/index.css, which carries `li.editing .view { display: none }` —
# the rule the oracle's "should hide other controls when editing" test checks. The served page
# therefore had NO css at all, so that test could never pass however correct the app was, and
# the roles could not see why: happy-dom does not compute stylesheet visibility, so their tier
# reads green while a real browser fails. P6-ctrl-cmimo sat at 27/29 on exactly this, on
# doctrine byte-identical to a run that had passed the day before — the difference was ours.
# Copy ONLY the packages the built page actually links, never the whole tree.
for pkg in $(grep -ohE 'node_modules/[A-Za-z0-9._@/-]+' "$BUILD/index.html" 2>/dev/null \
             | sed -E 's#(node_modules/(@[^/]+/)?[^/]+)/.*#\1#' | sort -u); do
  # The sim's own node_modules is an EMPTY mountpoint outside bwrap — the packages live in the
  # shared toolkit, which is the overlay's lower dir. So resolve from the build first, then the
  # toolkit. Without the fallback the copy silently finds nothing and the page is still styleless.
  src=""
  [ -d "$BUILD/$pkg" ] && src="$BUILD/$pkg"
  for cand in "${EVAL_SHARED_NM:-}" /home/exedev/shipshape-shakedown/.eval-scratch/.shared-nm/node_modules; do
    [ -n "$src" ] && break
    [ -n "$cand" ] && [ -d "$cand/${pkg#node_modules/}" ] && src="$cand/${pkg#node_modules/}"
  done
  if [ -n "$src" ]; then
    mkdir -p "$DEST/$(dirname "$pkg")"
    cp -a "$src" "$DEST/$(dirname "$pkg")/" 2>/dev/null \
      && echo "oracle-grade: served linked dependency $pkg (from $(dirname "$src"))" >&2
  else
    echo "oracle-grade: WARNING index.html links $pkg but neither the build nor the toolkit has it" >&2
  fi
done
echo "oracle-grade: build -> $DEST ($(find "$DEST" -type f | wc -l) files)" >&2

# Serve + run. Override baseUrl/port off 8000 to dodge orphaned sibling servers (a
# recurring cross-session hazard, METRICS). start-server-and-test waits on the URL.
mkdir -p "$(dirname "$OUT")"
RUNLOG="$(mktemp)"
set +e
# Wait on the BUILD's entry (a 200), not on /examples/ (a dir → 404, times out).
# WAIT_ON_TIMEOUT caps the wait: a build with no servable index.html (a real finding —
# roles that test a synthesized DOM but ship no deployable page, pilot #6's gap) would
# otherwise spin forever, since start-server-and-test waits indefinitely by default.
# The outer `timeout` is the backstop covering the whole serve+run.
# screenshots + video OFF (dk 2026-07-24): the failing test TITLES come from cypress's
# own spec-reporter output (parsed below), so per-failure screenshots were only disk
# noise. `screenshotOnRunFailure=false,video=false` disables both.
( cd "$CLONE" && WAIT_ON_TIMEOUT="${WAIT_ON_TIMEOUT:-90000}" PORT="$PORT" \
    timeout "${ORACLE_TIMEOUT_S:-420}" npx --yes start-server-and-test \
    "node tests/server.js" "http://localhost:$PORT/examples/$FRAMEWORK/index.html" \
    "xvfb-run -a npx cypress run --env framework=$FRAMEWORK --spec cypress/e2e/spec.cy.js --config baseUrl=http://localhost:$PORT/examples/,screenshotOnRunFailure=false,video=false" \
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
# ENOSPC guard: a full disk makes cypress/the server emit garbage that parses as a bogus low
# score (glm-5.2's phantom 12/29 on 2026-07-25). If the run couldn't parse a Tests: line AND
# the log shows a disk error, this is an INFRASTRUCTURE fault, not a grade — fail loudly (exit 6)
# so the caller never records the number as a real regression.
disk_err = bool(re.search(r'ENOSPC|no space left on device', txt, re.I))
if tests is None and disk_err:
    open(out, "w").write("# oracle grade: DISK ERROR (ENOSPC) — result is NOT a valid grade\nGRADE: DISK-ERROR\n")
    sys.stderr.write("oracle-grade: ENOSPC in runner output — refusing to emit a grade (exit 6)\n")
    sys.exit(6)
# Failing test titles from the spec reporter's FINAL failures section (replaces the
# screenshot filenames, dk 2026-07-24). Restrict to the tail after the "N failing" summary
# so interleaved ✓-passing run lines aren't captured. Each failure is a `  N) ` block whose
# indented, checkmark-free lines are the describe path + leaf title (ending ':'); error follows.
m = list(re.finditer(r'\n\s*\d+\s+failing', txt))
section = txt[m[-1].end():] if m else ""
fails, cur = [], None
for line in section.splitlines():
    if re.match(r'^\s+\d+\)\s', line):
        if cur: fails.append(cur)
        rest = line.strip().split(') ', 1)[-1].strip()
        cur = [rest] if rest else []
    elif cur is not None:
        s = line.strip()
        if not s or '✓' in s or re.match(r'(Assertion|Error|TypeError|NotFound|CypressError|\+ expected|- |at |\d+\))', s):
            fails.append(cur); cur = None
        else:
            cur.append(s.rstrip(':'))
if cur: fails.append(cur)
failing_titles = [" -- ".join(dict.fromkeys(p for p in blk if p and '✓' not in p)) for blk in fails if blk]
lines = [
  f"# oracle grade: framework={fw}  runner_exit={gexit}",
  f"tests={tests} passing={passing} failing={failing} pending={pending}",
  f"all_specs_passed={allpass}",
  f"GRADE: {passing}/{tests}" if tests else "GRADE: UNPARSEABLE (see tail below)",
  "",
  "## failing tests",
] + ([f"  - {t}" for t in failing_titles] or ["  (none parsed)"]) + [
  "",
  "## cypress summary tail",
]
tail = txt.splitlines()[-40:]
open(out, "w").write("\n".join(lines) + "\n" + "\n".join(tail) + "\n")
print("\n".join(lines[:4]))
print("failing:", "; ".join(failing_titles) if failing_titles else "(none parsed)")
PY
# Persist the raw cypress output next to the grade so operator oracle-correction voyages can
# paste the EXACT failure (assertion text) to the roles verbatim — the parsed summary drops it.
cp "$RUNLOG" "${OUT%.txt}.cypress.log" 2>/dev/null || true
rm -f "$RUNLOG"
echo "oracle-grade: grade written -> $OUT" >&2
