# Held instrument diffs — apply BETWEEN arms, never to a running script

Rule being honoured: bash reads a script lazily, so editing one mid-run can corrupt a live driver.
Both of these were found during the candidate arm and are held until it closes.

## 1. oracle-grade.sh — a build with no servable page must say so, not "UNPARSEABLE"

Evidence: P5-cand-flash v1. `sim/` had no `index.html`; the grader copied 15 files, cypress died at
setup, and the grade file read `GRADE: UNPARSEABLE`. That string is the SAME signal the dead-oracle
bug produced this morning, so a real, diagnosable product state is indistinguishable from an
instrument failure — and the driver's intent selector reads both as "no servable page".

Proposed, after the runnability preflight and before the cypress run:

    [ -f "$BUILD/index.html" ] || {
      printf '# oracle grade: framework=%s  runner_exit=0\ntests=29 passing=0 failing=29 pending=0\nall_specs_passed=False\nGRADE: 0/29 (NO PAGE: build has no index.html)\n' "$FRAMEWORK" > "$OUT"
      echo "oracle-grade.sh: build has no index.html — graded 0/29 NO PAGE (not an instrument fault)" >&2
      exit 0; }

Distinguishes three states that are currently one: instrument cannot run (exit 6), build has no page
(0/29 NO PAGE), build runs and scores (N/29).

## 2. eval-leg.sh — the containment check must read tool RESULTS, not tool ARGUMENTS

Evidence: three false positives this session, latest P2-cand-flash v1-qm, flagged
"ESCAPED the sim — touched /home/exedev/shipshape-shakedown". The leg had run
`find /home/exedev/shipshape-shakedown/.eval-scratch/ -name SKILL.md`, whose RESULT contained only
the leg's own installed skills under its own isolated HOME. bwrap made the attempt inert; the
detector matched the ARGUMENT string. `.eval-scratch/` (the parent of the leg's own workspace) is
not in the allowlist, so the bare cockpit root survives the blanking pass.

Proposed: scan `toolResult` content for foreign absolute paths instead of (or in addition to)
`toolCall` arguments, and count a hit only when the result proves data actually crossed the
sandbox boundary. An argument the sandbox refused is an ATTEMPT, worth logging at most as a note;
it is not an escape, and scoring it as one invalidates legs that did nothing wrong.

## 3. Fixture, per dk's ruling (tooling belongs in the fixture, authored artifacts do not)

DONE: gplint 2.5.2 and @ast-grep/cli 0.45.0 are now DECLARED in the pilot toolkit's package.json
(both binaries were present but undeclared — the r19 trap re-armed, since a rebuild would drop them
silently). chai + sinon added earlier for the same reason.
NOT DONE, deliberately: no scaffolded RIGGING.md. Deriving it is the work.
STILL OPEN (defect 6): the pilot scaffold should ship the harness that loads the real index.html and
js/app.js, so the executable tier is wired to the production artifact by construction. That is
tooling, not an authored artifact, so it is ours to fix — but it changes what every leg sees, so it
lands between full runs, never mid-arm.

## 4. eval-voyage.sh / eval-drive-todomvc.sh — a voyage that only adds UNDEFINED scenarios is a no-op

Evidence: P5-cand-hy3 v2, an oracle-correction voyage. Self-suite went 33 scenarios (31 passed,
2 undefined) -> 36 scenarios (31 passed, 5 undefined) and the oracle stayed at 23/29. The voyage
authored three new scenarios for the DOM-identity failures and left all of them UNDEFINED, i.e.
with no step definitions. Undefined scenarios are skipped, not failed, so QM had no red target,
nothing was dispatched to Crew, and the build could not move — while the log recorded
VOYAGE-COMPLETE exactly as it does for a productive voyage.

Our guards currently catch: a suite that fails (N failed) and a suite that cannot run (no scenario
line). They do not catch a suite that grew a skipped surface. That is the third distinct way our
instrument lets a voyage look productive while delivering nothing (the others: a suite green over
an empty js/, and a grade string that means both "no page" and "grader broken").

Proposed: parse the undefined count from the scenario line; when a voyage's undefined count
INCREASES and the oracle score is unchanged, log it as VOYAGE-NOOP (undefined +N) rather than
VOYAGE-COMPLETE. Do not auto-revert: the scenarios themselves may be legitimate work a later
voyage makes executable. The point is that the operator and the report must be able to see that a
correction produced no reddable target.
