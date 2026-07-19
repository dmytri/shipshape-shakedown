# plank-routing A/B: judging rubric, fixed BEFORE the legs reported

State (identical both arms, 8 fresh clones of the tw4 probe state, base `0a557ee`):

- `tideRange` — **in the role-advanced diff** (`M src/tide.js`), carries **no** `@planks(...)`.
  Correct routing: **Crew**, this voyage, while the seam is in hand.
- `nextHighTide` — **beyond the diff** (untouched since the fit-out commit), carries a
  **malformed** plank (`@planks("When I ask …")`, the leading keyword the pattern does not carry).
  Correct routing: **harbour**.

The state discriminates in both directions, so a fix that over-corrects — routing everything to
Crew — fails as surely as one that under-routes. That is the point of scoring both.

## Per-leg score, both axes required

| Axis | PASS | FAIL |
|---|---|---|
| **P1 in-diff** | `tideRange` routes to Crew (named as next role / dispatch target) | deferred to harbour, or to Shipwright, or unreported |
| **P2 beyond-diff** | `nextHighTide` deferred to harbour | routed to Crew (over-correction) |

Leg verdict: **PASS** only if P1 and P2 both pass. P1-fail is the tw4 fault reproducing.
P2-fail is the candidate's own new risk.

## Arm verdict

- Control (A) is expected to reproduce the tw4 fault at some rate. If A passes 4/4, the tw4
  observation was a one-off and **the fix has no demonstrated fault to fix** — report that and
  ship nothing.
- Candidate (B) must beat A on P1 without losing P2.
- Both arms at 4/4 or both at 0/4 = **null result**, no ship.

## Integrity checks, every leg

1. **Doctrine served per arm** — grep the transcript for the arm-unique marker:
   - A only: `a plank that is missing, stale, or malformed is the same fault`
   - B only: `route by LOCATION, never by kind`
   Zero hits = that leg read the wrong text and is **void**, not a data point.
2. **Model** — every invocation `claude-sonnet-5`. Any escalation voids the leg (dk's rule; this
   session is opus, which is why the dispatch forbids subagents).
3. **No nested spawns** — zero `Agent:` invocations. A spawn means the stop line failed and the
   leg could have escalated.
4. **Tree unchanged** — no commit, no writes: `git status --porcelain` still 4 entries, base
   still `0a557ee`. A leg that mutated its tree is reporting on a state it changed.

## Stated limits

- n=4 per arm on a judgment call; this sizes an effect, it does not close one.
- HEAD-text mode both arms, so the numbers are not comparable to the installed-plugin battery
  legs and no economy claim rides on them.
- The stop-before-dispatch instruction is itself a deviation from a live voyage: the routing
  decision is read from the report, not from an actual dispatch.
