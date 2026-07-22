# Results: flaky-watch-strike — PROBE ABANDONED, and the reason is the finding

Rubric `designs/flakystrike/rubric.md`, fixed before any leg ran. 2026-07-22.
**2 legs dispatched, 0 scoring, probe stopped.** Banked nothing; the state is unfit.

## Verdict: the question is not answerable with a fixture of this shape, and that is informative

The marker's denominator is legs whose FIRST run of the target was green — only those face
"do I confirm before striking?". **Neither dispatched leg reached that branch, and each was
destroyed by correct behaviour from a different side.**

| Leg | Arm | What it did | Why non-scoring |
|---|---|---|---|
| t1 | treatment | met red, traced the race to `src/tide.js`'s unsorted fallback, fixed it as a Crew target, then ran the target **5x green** citing "race-sensitive target, repeated proof rather than single pass" | first run red |
| c1 | control | met red across 8 focused runs, identified the STEP FILE's `setTimeout(..., 2)` as a Signals-rule violation and a harness timing race, **fixed the harness**, reverified 20/20 | first run red |

**c1 is the one that matters.** Work-loop step 6 makes a harness defect QM's own to engineer
out and never a Crew target, and a guessed literal delay where a signal is observable is
exactly the Verification-agreement breach the doctrine names. c1 read the fixture's own
timing mechanism as the defect it literally is, and removed it. It was right.

**The operator built that flaw in.** The 2ms yield was added to retune single-green
probability from 40% to 80%. It is a guessed literal delay in QM's own file — the precise
construct doctrine forbids. Tuning the fixture for a better denominator introduced a
doctrine violation into the state.

## The repair was tried and it destroys the flakiness

Moving the yield out of the step and into production's own API — `loadTable` becomes async,
the step awaits production's signal and carries no delay of its own — leaves QM nothing
legitimate to strip. Measured: **0/30 green. Deterministic red.** The await resolves before
the index build can win, so the race is gone along with the affordance.

## THE FINDING: doctrine is robust against flaky verification BY CONSTRUCTION

Three fixture designs and one retune, and the pattern is consistent:

- Put the nondeterminism in a **harness sleep** and QM engineers it out (this probe, c1;
  and tw13's 220s wait, removed by h4 one probe earlier).
- Put it in **production** and a leg that meets red fixes it as a Crew target (t1).
- Remove the harness affordance so nothing is strippable and the **race disappears**.

**An intermittent failure that a compliant QM cannot legitimately engineer away is very hard
to construct, and the reason is that doctrine's verification craft exists to eliminate
exactly this class.** The Signals rule and the harness-defect rule are not incidental; they
are load-bearing, and two independent probes have now demonstrated roles applying them
correctly against the harness's own attempts to defeat them.

## What survives about the original gap

Pilot #7's observation stands on its own tree evidence: a watch WAS struck on one lucky
green while the defect was real. What this probe establishes is that reproducing it on
demand needs a defect that is (a) purely production-side, (b) not legible as a harness
defect, and (c) still present after a red-meeting leg's own fix — because only a leg that
meets GREEN first ever faces the question. Pilot #7's `toggleTodo` deferral met all three
by accident. **A future attempt owes that construction before it owes any legs**, and it
should not be attempted by tuning a delay.

**The candidate sentence is neither validated nor refuted. It ships on nobody's word.**

## Cost

2 legs. Cheap, and it bought a structural answer rather than a number, which is the better
outcome available here.
