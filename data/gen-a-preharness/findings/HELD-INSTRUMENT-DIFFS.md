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

## 5. NO memory bound is available on this box — the fixture harness is the only remedy

Three OOM kills on 2026-07-28, each ~13.5G RSS on a 16G swapless VM:
- P5-ctrl-cmimo v1 suite: killed, output ended "Killed", no summary line -> self-suite "?"
- P5-ctrl-cmimo v3: killed MID-VOYAGE. eval-voyage.sh died after "leg v3-qm banked", so the
  self-suite file is EMPTY, the revert gate never ran, and the driver logged a blank outcome.
  A voyage's gate was LOST to a memory kill — this is data loss, not just noise.
- a python3 at 13.6G (a leg's own command; legs may run python freely inside bwrap).

What does NOT work, each checked:
- `NODE_OPTIONS=--max-old-space-size=2048` DOES reach the suite (verified 2240MB limit through
  npx) but bounds only V8's old space; ~13.5G of the growth is outside it, so the process still
  takes the box down. My earlier "cap verified" claim was overstated and is corrected here.
- `systemd-run --user --scope -p MemoryMax=` — "Failed to connect to bus": no systemd user bus.
- cgroup v2 — /sys/fs/cgroup not writable.
- `ulimit -v` — unusable for node, which reserves tens of GB of virtual address space; a VA cap
  kills it outright rather than bounding it.

So there is no operator-side hard bound available. The remedy is to remove the CAUSE, which the
fixture harness now does: an undisposed happy-dom Window per scenario was the growth, and the
shipped world.js closes it in an After hook (measured: 60 scenarios, peak RSS 181MB, flat).
That only protects waves scaffolded after the harness landed (07:42Z), so every wave in the
running control arm remains exposed and may lose a voyage gate the same way.

Operational rule until a bound exists: keep concurrency at 3 waves, and treat a blank voyage
outcome or an empty selfsuite file as a possible memory kill — check `dmesg` before reading
either as a doctrine or model signal.

## 6. DISK GUARD must STOP the pilot, not fail every remaining voyage

2026-07-28, P6-ctrl-cmimo: disk hit 1912M (<2048M guard). The guard correctly refused to grade —
but the driver then ran voyages 8,9,10,11,12 back-to-back, each aborting instantly on the same
guard, and logged PILOT END with a garbage final score built from the guard's own message. Five
voyages of the cap were consumed in one second and the cell read as "finished" at a corrupt value.

The sim itself was untouched (clean tree, last real commit intact), so the cell was resumable —
but only because I looked. A cap consumed by aborts is indistinguishable in the log from a cap
consumed by work.

Proposed: on a disk-guard abort, STOP the pilot immediately (as PROVIDER ERROR does) with a
distinct DISK-ABORT marker and a non-scoring exit, so the operator frees space and resumes rather
than watching the cap evaporate. Same rule for any guard that aborts a voyage before it runs.
