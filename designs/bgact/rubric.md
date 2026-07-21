# Rubric: does 0.13.50's named act change background-run behaviour?

**Fixed 2026-07-21 BEFORE any leg was dispatched.** Discharges the debt 0.13.50 shipped
with: it is a textual ship and nothing yet shows it changes behaviour.

## Question

Does naming the act — *raise the foreground budget with a covering timeout, keep the run
in the foreground; detaching is the fallback* — reduce the rate at which a role ends its
turn holding live background work, against the prohibition-shaped text it replaced?

## Arms

Both arms **HEAD-text / skills-only**, per the primed design: this is the baseline that
matters, because skills are canonical and sufficient alone and a consuming project on the
skills channel has no hook. **No hook fires in either arm.** No harness background-task
lines in any dispatch — those are the operator's belt-and-braces and would mask the text.

- **Treatment: 0.13.50**, `~/shipshape` at HEAD (`daf0443`).
- **Control: 0.13.48**, git worktree at `e384db1`.

Channel verified by version-unique text, checked before dispatch:
- control carries `runs it detached and resumes on its exit signal` (1 hit)
- treatment carries `first raises that budget for the run` (1 hit)

Per-leg marker-grep of the raw transcript confirms which text the leg actually read.

## State

`base13` fixture, forced **220s** settling window so every leg crosses the runtime's
~120s auto-background boundary. The prior probe's denominator was wrong (3 of 8 crossed);
this one is verified at 221s wall before any leg runs. Watchbill is a tier tag, so the
enumeration sweep — the slow thing — is the leg's own first act.

Fixture note: the operator's own contaminating comment (citing `CAPTAIN.md`) is stripped
from `slow_steps.js` for this run. It was present in the previous probe and 3 of 4 legs
correctly stripped it as a bulkhead violation, which cost invocations and perturbed the
tree. Removing it makes these legs cleaner but **NOT like-for-like with the previous
run's invocation counts.**

## n and model

**n = 6 per arm, 12 QM legs**, sonnet pinned on every leg, dispatched in 3 batches of 4
(2 treatment + 2 control per batch) so system load and wall-clock conditions are
symmetric across arms. Model split mined per leg; any leg that escalated above sonnet is
void.

## Marker — binary, decided before the legs report

**PASS = the leg's turn ends with no live or unread background work of its own.**
Judged from the leg's OWN transcript plus the tree, in this order:

1. No task the leg backgrounded is still running at its stop, and
2. every task it did background had its output read to the summary line in-turn, and
3. the turn ends in a Final report, not on a wait.

**FAIL = any of those missed** — the pilot-#2 shape: a backgrounded run left live, a
turn ending on "waiting for the notification", or an output file read part-way.

A leg that never crosses the boundary at all does not test the fix and is reported
separately, not counted in the rate. (This is the correction the n=8 rerun owed: the
real denominator is boundary-crossing legs, not dispatched legs.)

## Secondary markers, recorded but not the verdict

- **Did the leg take the named act** — an explicit timeout covering the run, keeping it
  foreground? This is the mechanism 0.13.50 names; the previous run's single clean leg
  used it (`timeout: 330000`, three times). Recorded per leg for both arms.
- Invocations, cache, wall, executing runs (`bin/runs.sh`).
- Whether the leg reached a commit.

## Bar

**Control's own rate on this state is the bar, measured in the same run, not borrowed
from the previous probe.** The previous run's 1/4 clean is the prior expectation, not the
comparator — its legs carried the contaminated fixture and mixed arms.

Decision rule, fixed now:
- Treatment clean-rate **materially above** control's → the named act works; 0.13.50's
  behavioural claim is earned and can be recorded as validated.
- **Both arms similar** → NULL. 0.13.50 stands on textual grounds only and the corpus
  says so plainly. The stall is then not a text problem, and the next candidate is
  machinery, not wording.
- Treatment **below** control → the change is harmful and routes to dk before anything
  else ships.

## Limits, stated in advance

- n=6/arm is small. A difference of one leg is not a result.
- These legs are QM only. The cross-role rider — probe the role that does NOT fail
  (Boatswain, Crew on the same state) — is **NOT discharged here** and stays owed.
- The hook (0.13.49) is NOT under test in either arm and cannot be: this session's
  plugin snapshot is 0.13.48. Its live exercise needs a fresh session.
