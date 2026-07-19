# plank-routing probe — 16 legs, four arms. Candidate fix RETIRED; fault CONFIRMED and its mechanism isolated.

Rubric fixed before results (`rubric.md`). Legs banked `data/plankroute-0.13.35/`. State: fresh
clones of the tw4 probe state, discriminating both ways (`tideRange` in-diff + unplanked → Crew;
`nextHighTide` beyond-diff + malformed → harbour). All 16: sonnet, zero nested spawns, zero
commits, doctrine marker verified per arm.

| Arm | Channel | Text | Dispatch | P1 in-diff→Crew | P2 no over-correction |
|---|---|---|---|---|---|
| A control | HEAD-text | current 0.13.35 | thin, no base | **4/4** | 4/4 |
| B candidate | HEAD-text | reorganized on location | thin, no base | **4/4** | 4/4 |
| C control | installed | current 0.13.35 | thin, no base | **3/4** | 4/4 |
| D control | installed | current 0.13.35 | **base commit named** | **3/4** | 4/4 |

## 1. The candidate fix is a null result — RETIRED

A 4/4 vs B 4/4, same channel, cost flat (9.25 vs 8.75 inv). Per the rubric's pre-stated rule,
both arms clean = no ship. The four-site reorganization dk flagged as "big" buys nothing
measurable. **Do not ship it.**

## 2. My fixture hypothesis was WRONG — naming the base commit changes nothing

I proposed that both observations came from dispatches missing the base commit the Dispatch
contract requires, making this a tw17-class fixture defect. Arm D tested it: **C 3/4 vs D 3/4,
identical.** D2 failed *with* the base named, and more cleanly than C4 did:

> "This seam is untouched by any current-voyage diff (**HEAD equals base commit; no role has
> edited yet**), so it is plank drift beyond the current diff — defers to harbour."

It had the base, confirmed HEAD matched it, and concluded no role-advanced work existed — while
`git status` showed `M src/tide.js` and three untracked files. The dispatch was a real defect and
is worth fixing in the harness, but it is **not** the cause.

## 3. The fault is real, ~25% on the installed channel, and has teeth

2 failures in 8 installed-channel legs. Both declared the watch **spent**; C4 also appended a
green line to `runrecord.jsonl` (tree-verified, 2 lines vs 1 elsewhere). The unplanked seam
leaves Crew's hands with a recorded green behind it — the escape this rule exists to prevent.

Zero failures in 8 HEAD-text legs. Channel is the apparent discriminator, but that comparison is
confounded: the HEAD-text preamble says "read ALL fully before doing anything," which plausibly
suppresses the fault on its own. Only A-vs-B and C-vs-D are clean comparisons.

## 4. The mechanism, isolated

| Ran a working-tree command? | Legs | Correct |
|---|---|---|
| Yes (1–3 calls) | C1, C3, D1, D3, D4 | **5/5** |
| **Zero** | C2, C4, D2 | **1/3** |

Every failure ran zero working-tree commands and stated the HEAD-vs-base inference explicitly.
Every leg that ran one routed correctly. C2 is the instructive near-miss: it also ran zero, and
reached the right answer by a different route entirely ("every production seam is planked") —
right conclusion, unbacked claim.

Statistical honesty: at n=8 this is Fisher p ≈ 0.11, **suggestive, not established**. What lifts
it above correlation is that both failures *state the faulty reasoning in their own reports*, so
mechanism and correlation agree.

**Doctrine already forbids this.** Hand-off custody: a tree claim is "the output of a command the
role ran, never a recollection and **never an inference**." The failing legs asserted a tree fact
they never ran a command for. This is a compliance gap on a stated rule, not a missing rule —
which is exactly why new prose is the wrong instrument.

## Recommendation — REVISED from "drop it"

I recommended dropping this when I believed it was ~8% and possibly a fixture artifact. At ~25%,
with the fixture explanation dead and real escape consequences, that recommendation was wrong.

1. **Ship nothing textual.** Confirmed twice over: the reorganization is null, and the rule the
   roles are breaking is already written.
2. **The fix, if any, is mechanical — and it is the same shape as the orphan guard.** At QM
   `SubagentStop`: if the working tree is dirty *and* the transcript contains no working-tree
   command, block once — "you reported on the role-advanced diff without running a command that
   establishes it." Stack-agnostic, no plank parsing, no command denied. On this sample it fires
   on exactly the 3 zero-command legs: both true faults, plus C2, whose claim was equally
   unbacked and merely lucky. That is correct enforcement of the stated rule, not a false
   positive.
3. **Fix the harness dispatch too**, independently: probe dispatches must carry the base commit.
   Mine did not, in all 12 of the first legs. Real fault, just not this one.
4. **Not `planks-check.sh`.** It is file-level — `src/tide.js` carries a plank on `nextHighTide`,
   so it passes C4's tree. Seam-level needs the plank join in a hook: stack-specific, wide blast
   radius, already declined once.

## Limits

- n=4/arm; 2 failures total. The ~25% rate is a point estimate on 8 legs, not a measurement.
- The discriminator table is p ≈ 0.11 — suggestive.
- A/B-vs-C/D confounded by channel and preamble strength.
- Stop-before-dispatch reads routing from the report, not an executed dispatch.
