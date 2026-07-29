# Five defects of OURS, and the playbook ordering that made them bite (2026-07-27)

Framing (dk, standing): nobody is testing whether a model can clear a bar. THE BAR IS OURS —
doctrine, playbook, harness, fixture. Attributing a broken run to model capability is a hard fail.
The one historical exception is gpt-oss (cannot call tools). r23's 15/15 and the 0.13.65 pilots'
28/29 both stand; they exercised parts of the corpus today's failures do not live in.

| # | layer | our artifact | what we wrote | why a capable agent could not do better |
|---|---|---|---|---|
| 1 | doctrine (candidate) | `captain/SKILL.md:36` vs `:54`/`:60` | `:54` Shipwright fits out; `:60` author "on Shipwright's return"; `:36` "Shipwright is never dispatched at a greenfield repository" | Cannot both be obeyed. We deleted `0.13.65 captain:59` (Captain writes minimal RIGGING.md under the write-scope exception) and put nothing in its place. At voyage 1 no rigging exists and no role may create it. |
| 2 | doctrine (candidate) | `qm/SKILL.md:78` | "a missing required value is a configuration blocker to Captain" | Given #1 our own text ORDERS QM to block. P4-cand-mimo's QM obeyed in 7 turns with a clean two-blocker report: a correct execution of a defective instruction. |
| 3 | fixture/doctrine boundary | `shipshape/SKILL.md:151` (both arms) + `bin/scaffold-todomvc.sh:32` | doctrine: specs live "under the specs directory from RIGGING.md"; scaffold documents `features/` | With no RIGGING.md the pointer dangles and has no default. Candidate methods lint `specs/`; our scaffold says `features/`. We made the directory unknowable, then required watchbill paths to include it. |
| 4 | doctrine (shared, pre-existing) | `qm/SKILL.md:78`, `shipshape` Watchbill policy, `captain/SKILL.md:49` | form stated where it is READ and REJECTED; `grep watch1` = ZERO hits in captain/SKILL.md in BOTH arms | We ask Captain to author a form we never show it, then reject non-matches. `captain:49` is byte-identical across arms: a standing gap in shared text, not a candidate regression. |
| 5 | harness | `eval-leg.sh` `--tmp-overlay`; old `eval-voyage.sh` guard | node_modules discarded at leg end; revert guard grepped only "N failed" | A normal `require('chai')` was correct work our overlay deleted; our guard could not see an ERROR, so we logged VOYAGE-COMPLETE over an unrunnable suite. |

PLAYBOOK, the ordering that made #1 unavoidable: we ran the Shipwright fit-out pass AFTER voyage 1
while doctrine says Captain authors on Shipwright's return. `run_shipwright fitout` now precedes the
build (`eval-drive-todomvc.sh:274`).

## Cost of OUR doctrine (a measurement, not a ranking)

Output per turn, QM legs, same model, same thinkingLevel medium, same provider:
0.13.65: 241 and 326 out/turn (mimo run1, run2). Candidate: 493 and 537 (P2, P3).
=> the candidate text costs ~1.7-2.2x the output per turn of 0.13.65. Against the 1500s wall cap WE
chose, that truncated builds. At 3600s it is a cost figure, not a failure.

## Excluded as causes, with evidence
candidate Captain text for the watchbill (`captain:49` diff IDENTICAL); the yoink skill we injected
(no separation across cells); "form buried deeper" (85.7% vs 86.1% by bytes - withdrawn); toolkit
drift (versions predate the champion run); CPU contention (load <1.3); thinking level and provider
(identical in session metadata).

## Watchbill form, honest status
Across 8 pre-stop Captain legs the form matched in 2; the CHAMPION configuration matched 0 of 2. Our
form is unreliable in every configuration tested, including the one that produced 28/29 - the
champion's conforming watch1/watch2/watch3 was a draw, not a property of 0.13.65. 2 draws/cell is
below our own 5-draw bar, so NO RATE IS CLAIMED. The directory split did separate cleanly by arm
(candidate -> specs/ 4/4, 0.13.65 -> features/ 4/4).

## What r23 could not have covered
`bin/meth-fitout.sh:58` gives fit-out legs only `--skill shipshape --skill shipwright`;
`data/methods-candidate/r23/` holds only `<stack>-<model>-RIGGING.md` - no watchbill, Captain or QM
artifacts; `fixtures/tidewatch-spec/` ships a bare `tides.feature` with NO RIGGING.md, because
deriving it IS the fit-out task. The absence that deadlocks the pilot is r23's premise. Untested by
r23: Captain's greenfield route, watchbill authorship and form, QM's validate-and-reject path, the
Captain->QM hand-off, assume-in-place to custody, the specs-directory pointer against a real project.

## CAVEAT that must not be lost
Fit-out-first means THE OPERATOR now dispatches Shipwright at a greenfield repository, which
`candidate captain:36` says never happens. It unblocks everything downstream and is the right
operational call, but the pilot therefore no longer exercises the candidate's own greenfield route -
it exercises a route the candidate denies exists. B1 stays fully open. Do NOT read a green P5 as
evidence that the greenfield route works; that route needs its own probe once dk rules on B1.

## Routed to dk, nothing shipped
B1: repair the candidate's greenfield contradiction - restore `0.13.65 captain:59`, or permit
    Shipwright at greenfield. Highest-value item; textual footing.
B2: put the watchbill form in Captain's work-loop as a literal 3-line example, and give the specs
    directory a stated default when RIGGING.md is absent. Textual footing.
Neither owes a behavioural probe (probe-first rule: the defect is visible in the artifact).

## Still ours, open
Per-wave persistent node_modules instead of the discarded overlay; the containment check should read
tool RESULTS not arguments (third false positive this session); the pilot Captain task should name
the specs directory only if doctrine gains a default, else it masks #3.

## Unattributable from the record (experiments named, none run)
watchbill-form match rate per configuration (>=5 draws x 4 cells, frozen rubric); whether QM's
reject clause fires by draw (QM-only legs, conforming vs free-form watchbill); whether #3 alone
deadlocks independently of #1 (confounded today); whether restoring `captain:59` fixes the cell
(one-clause treatment arm).

## DEFECT 6 (ours: fixture + doctrine) — a green self-suite with NO application at all

P5-cand-flash, tree-verified 2026-07-27 15:44Z:
- `sim/js/` is EMPTY. There is no `app.js`. No production code exists in the project.
- The roles' own suite reports **21 scenarios, 19 passed, 2 undefined** — green.
- The oracle reports **0/29** (`tests=29 passing=0 failing=1`): the real page cannot run.
- `index.html` (1211 bytes) is correct and carries `<script src="js/app.js">` pointing at nothing.

Mechanism, and it is ours: nothing in the fixture or in doctrine requires the executable tier to
load the production artifact. `features/support/steps.js:402-405` builds its own DOM
(`new Window(...)`, `document.body.innerHTML = html`) and asserts against that. The suite is a
mirror of itself, so it stays green with an empty `js/`.

The sharpest single line of evidence, `features/todos.feature:113`:
    And it has a script element with src "js/app.js"
The role wrote a scenario asserting the STRING presence of a script tag, not behaviour driven
through it. A structural check standing in for the behaviour it is supposed to prove — and it
passes while the file it names does not exist.

This is the documented "a scenario that passes on buggy code is a no-op" class in its most extreme
form: passing on NO code. The pilot fixture ships no world/harness that loads `index.html` +
`js/app.js`, so the app-loading contract is left to the roles, and a role can satisfy every
scenario without ever loading the app. The oracle was the only witness.

Candidate fixes (NOT applied; the fixture change is ours, the doctrine one needs dk):
- ours: the pilot scaffold should ship the harness that loads the real `index.html` and `js/app.js`
  (the sonnet-era pilots had a `world.js` doing exactly this), so the executable tier is wired to
  the production artifact by construction rather than by a role's choice.
- dk's call: whether the Verification agreement should state that an executing scenario must
  exercise the production artifact, so a self-built-DOM step is a dishonest step by the text and
  not merely by taste.
