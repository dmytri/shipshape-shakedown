# Method audit: every job of every role, in order, and the method it uses (2026-07-26)

dk asked whether the set is complete for **any** stack. This is the exhaustive pass: every job and
step in all five role skills, what it runs, and which method answers it. A step earns a method only
where it runs two or more `## Commands` values whose parts are independent of one another's output.

## Why the set is CLOSED, and closed independently of the stack

Three facts together bound it:

1. **A method belongs to a STEP, not to a stack.** The steps are doctrine's own and finite.
2. **The command vocabulary is closed by the Rigging read contract**: `discover`, `focused`,
   `broad`, `coverage`, `step-usage`, `plank-inventory`, `typecheck`, `lint`, plus `conformance`
   and tier-suffixed variants. A stack cannot invent a new command key, so it cannot invent a new
   composition.
3. **A method never adds an act.** It composes only what its step already runs.

So a new stack changes the *parts* of a method and whether the counting rule collapses it to
`none`. It never adds a method. The six below are therefore the whole set, and a project on any
stack is fully fitted out when all six values are present.

## CAPTAIN

| # | Job / step | Runs | Method |
|---|---|---|---|
| 1 | Opening: retrieve standing state, one pass | `AGENTS.md`, `RIGGING.md`, specs, `git` | none — reads, not `## Commands` values |
| 2 | Route on `RIGGING.md` absence | nothing | none |
| 3 | Discovery and spec authoring | nothing executable | none |
| 4 | Feature lint at write time on Captain-authored specs | `lint` (feature lint rides the one `lint` value, feature lint first) | none — one command |
| 5 | **Greenfield fast path bootstrap** | installs the harness, confirms the runner executes, writes minimal `RIGGING.md` | **derives all six method values** (no fitting-out session will), then `rigging-proof` proves them |
| 6 | Perturbation planting | writes the `perturb` statement | none |
| 7 | Harbour review 1-3 (review skeletons, retag, route economy findings) | nothing executable | none |
| 8 | Harbour review 4-6 (dispatch custody, outbound, resume) | nothing executable | none |

## QUARTERMASTER

| # | Work-loop step | Runs | Method |
|---|---|---|---|
| 1 | Enforce context bulkhead | nothing | none |
| 2 | Retrieve rigging, watchbill, base, one pass | `cat`/`git` | none — composes no `## Commands` values; doctrine already batches it |
| 3 | Settle rigging, HEAD, watchbill from that output | nothing | none |
| 4 | Process watches in order; a tier-tag watch is one enumeration sweep | `broad` or its tier variant | none — one command per tier, and **across** tiers it is reactive: a red cheaper tier's dispatches complete before a costlier tier runs |
| 5 | **Verify the watch's whole target set** | `focused` over the set + `plank-inventory` + `step-usage` | **`verify`** |
| 6 | Dispatch Crew on production failure | nothing | none |
| 7 | Consume parallel Crew reports | nothing | none |
| 8 | Repeat the cycle until the watch is spent | re-runs step 5 | **`verify`** again |
| 9 | Append the run record after a fresh green | writes a line | none |
| 10 | End in the final report naming Boatswain | nothing | none |
| 11 | Blocker return to Captain | nothing | none |

## CREW

| # | Step | Runs | Method |
|---|---|---|---|
| 1-3 | Opening: verify dispatch, two retrieval passes | reads | none |
| 1 | Reproduce or inspect the failure | `focused` on its target | none — one command |
| 2 | Edit minimum production code, update planks | nothing | none |
| 3 | Run focused verification | `focused` | none — one command, and a method must not **add** an act (giving Crew typecheck/lint would be a new obligation, not a composition) |
| 4-5 | Report pass, or report blocker | nothing | none |

## BOATSWAIN

| # | Job / step | Runs | Method |
|---|---|---|---|
| 1 | Opening: verify dispatch | nothing | none |
| 2 | Retrieve rigging and deck, one pass | `cat`/`git status`/`git diff`/`git log` | none — no `## Commands` values |
| 3 | Settle job, touched seams, deck-state hash | nothing | none |
| 4 | **Hygiene checks (both jobs)** | `plank-inventory` + `step-usage` + `typecheck` + `lint` | **`hygiene`** |
| 5 | Recheck, executable hunk with no carried evidence | `focused` over the planked scenario set | none — one command, and doctrine calls the recheck "the one run that depends on what came before", i.e. reactive |
| 6 | Recheck, verification-support hunk | that tier's `broad` | none — one command |
| 7 | **Recheck, non-executable hunk / deletion / configuration** | `discover` + `typecheck` + `lint` | **`static`** |
| 8 | Recheck, hunk with carried green evidence | nothing — inherits it | none |
| 9 | Strike a spent watchbill without carried evidence | `focused` over the watchbill's entries | none — one command |
| 10 | Stage and commit locally | `git` | none |
| 11 | Report to Captain | nothing | none |

## SHIPWRIGHT

| # | Job / step | Runs | Method |
|---|---|---|---|
| A | Harbour-entry guard | `git status` | none |
| B | **Fitting out: derive `RIGGING.md`** | derives every command value | **writes all six methods** |
| C | **Fitting out: prove the tooling runnable** | every derived command, once each | **`rigging-proof`** |
| D | Fitting out: methodology-check skeletons, search-exclusion artifact | writes files | none |
| 1-2 | Work loop: load core skill; retrieve rigging and deck, one pass | `cat`/`git` | none |
| 3 | Identify scope | reads | none |
| 4 | **Harbour's one full regression** | `coverage` + each tier-suffixed variant, cheapest first | **`regression`** |
| 5 | Map covered code to step definitions | reads step definitions (`step-usage` output already in hand) | none |
| 6 | Find uncovered modules | reads step 4's coverage output | none — reactive on step 4 |
| 7 | Judge each seam, reference analysis | static analysis / text search, not `## Commands` | none |
| 8 | Write the two `@conformance` skeletons | writes files | none |
| 9 | Annotate every seam with planks | writes annotations | none |
| 10 | **Process condemned scenarios: scoped proof after each removal batch** | `typecheck` + `lint` + `focused` over the touched seams' scenarios | **`condemnation`** |
| 11 | Refresh golden captures | re-records from the real dependency | none — not `## Commands` |
| 12-13 | Confirm nothing unproven (step 4 is the one full run; do not rerun) | nothing new | none |
| 14 | Report to Captain, leave edits uncommitted | nothing | none |
| E | **Refit: verify every command and method slot, prove they still execute** | every derived command | **`rigging-proof`** |

## The six, and where each is used

| Method | Used by | At |
|---|---|---|
| `verify` | QM | work-loop steps 5 and 8 (every cycle of every watch) |
| `hygiene` | Boatswain | hygiene checks, in both jobs, every custody run |
| `static` | Boatswain | recheck of a non-executable hunk, a deletion, or configuration |
| `regression` | Shipwright | work-loop step 4, harbour's one full regression |
| `condemnation` | Shipwright | work-loop step 10, after each condemnation removal batch |
| `rigging-proof` | Shipwright, and Captain on the greenfield fast path | fitting out, and every refit |

Crew uses no method by design: its one command is one command, and a method never adds an act.
Captain uses no method at sea; it derives them on the fast path so the roles downstream have them.

## Deliberate exclusions, each with its reason

| Step | Why it is not a method |
|---|---|
| QM step 2, Boatswain step 2, Shipwright step 2 openings | They compose `cat` and `git`, not `## Commands` values, and doctrine already states each as one run |
| QM step 4 tier sweep across several tiers | Reactive: a red cheaper tier's dispatches complete before a costlier tier runs |
| Boatswain's executable-hunk recheck | Doctrine's own words: the one run that depends on what came before |
| Shipwright step 6 uncovered-module search | Reads step 4's output |
| Crew step 3 | One command; composing more would add an act |
| Captain's feature lint | One command |
