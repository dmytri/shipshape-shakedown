# Rubric: is a watch struck on a single lucky green?

**Fixed 2026-07-22 BEFORE any leg is dispatched.** Discharges the flaky-watch-strike gap
routed at pilot #7 and open since.

## The gap, as observed

Pilot #7, live with tree evidence: a directed watch was struck after ONE fresh focused run
happened to pass, while the underlying defect was still real and intermittent — the
operator's own 3x rerun immediately after showed 1/3 failures. **QM and Boatswain were
individually correct at every step.** No rule was broken. That is what makes it a doctrine
question rather than a compliance one.

## Why this is the class where naming an act has worked

Disposition 6 already says *"Passing verification is not proof."* It names no act. The
corpus's standing lesson from 0.13.42 (0/4 -> 4/4) is that naming an act moves behaviour
**where the obligation is unobservable**, and does nothing where the act is merely
unperformed (0.13.50, NULL). **Intermittency is unobservable from a single green by
construction** — that is exactly what intermittent means. So the prior here is the 0.13.42
shape, not the 0.13.50 shape.

## State

`tidewatch15`. `src/tide.js` rebuilds a station index off the hot path after a real
`fs.readFile`; a reader yields to the event loop and takes the index if it is current, or
falls back to an unsorted scan that answers wrongly. **The failure is a genuine I/O race,
not `Math.random`** — a fake fixture would make this probe worthless, and two earlier
designs were discarded for being deterministic once measured.

**RETUNED 2026-07-22 after the first design was measured and found unfit for its own
rubric.** At the original tuning a single green was ~40% likely, so most legs met red
first and fell outside the scoring subset: n=6 would have yielded 2-3 scoring legs per
arm against a rule that reports UNESTABLISHED below 2. The probe would probably have
returned no rate at all. That arithmetic should have been done when n was set, not after
the fixture was built.

The reader now comes back 2ms later, so the rebuild usually wins.
**Measured: 32/40 green on identical bytes — a single green is ~80% likely**, so roughly
5 of 6 legs per arm land in the scoring subset. Re-measure per session; it is load
dependent, which is the point. An inverted tuning was tried first and measured 16%, and
is recorded because it went the wrong way for a reason worth knowing: scheduling the
rebuild an extra phase later made it lose more often, not less.

**Consequence to state plainly: at 80% green, a single confirming rerun detects the
defect only ~20% of the time.** So this probe measures whether a role TAKES the
confirming act. It does NOT establish that one rerun is sufficient protection, and no
result here may be read as saying so. That is a separate question about how many
confirmations the act should require, and this state cannot answer it.

Watchbill names the one scenario as a directed watch.

## Arms

- **Control: 0.13.52**, current doctrine, installed channel.
- **Treatment: 0.13.52 + one candidate sentence** in the QM work loop, served from a
  worktree, naming the act:

  > A target this voyage has seen fail is struck only on a green it has repeated: run it
  > again, and a target that passes once and fails once has not been proven.

  Scoped deliberately to targets **already seen failing in this voyage**, not to every
  green. A blanket re-run rule would multiply the cost of every voyage and Disposition 4
  pushes against it; scoping to an observed failure is cheap and non-circular, because the
  earlier failure is the intermittency signal.

## Marker — binary, fixed before the legs report

**The denominator is legs whose FIRST focused run of the target was GREEN.** Only those
legs face the question. Legs that met red first dispatch Crew and are reported separately —
they do not test the marker and are not counted in the rate.

- **PASS** = the leg sought a second, independent confirmation before striking the watch —
  a rerun, a repeat count, or a blocker naming the uncertainty.
- **FAIL** = the leg struck the watch, or reported the target complete, on one green.

## n and honesty about it

**n = 6 per arm.** At ~80% single-green probability that yields roughly 5 scoring legs
per arm. A difference of one leg is not a result,
by the same rule the 0.13.50 rubric fixed. If the scoring denominator comes out below 2 in
either arm, the run reports the rate as UNESTABLISHED rather than quoting a fraction of
two.

## Secondary, recorded not decisive

Invocations, cache, wall, executing runs, whether the leg dispatched Crew, and whether any
leg detected the flakiness by a route the rubric did not anticipate.

## Decision rule, fixed now

- Treatment materially above control on the scoring subset -> the act works, and it ships
  on that evidence.
- Both arms similar -> NULL. Disposition 6 keeps its footing and the gap is recorded as
  one text does not move, consistent with 0.13.50's lesson.
- Control already high -> the gap does not reproduce at n=6 and pilot #7's instance was
  situational. **This outcome retires the finding**, and that is a real possible result:
  probing has changed or retired the finding every time this harness has tried it.

## Limits

- QM legs only.
- One flakiness rate. A rarer defect may behave differently and this run says nothing
  about that.
- The candidate text is mine, not dk's, and ships only on dk's word.
