# Method audit: every job of every role, and the method it uses (2026-07-26)

Written after reading all five role skills end to end, not by grep. Supersedes the earlier version,
which was restricted by a wrong premise (that a method composes `## Commands` values) and therefore
answered "none" wherever a job ran `cat`/`git` or a single command.

## The rules this audit applies (dk, 2026-07-26)

1. **Commands are gone.** `RIGGING.md` carries methods, not commands. A method is **the named way a role does a
   job**, and its plan spells out whatever the stack needs for that job. The word is always
   *method*: not a tool, not a command, because a runtime's tools and a shell's commands are other
   things and the name exists to keep them apart.
2. **Methods are the execution jobs.** A job that needs project tooling — the runner, the linter,
   the type checker, coverage, the plank inventory, step usage, static discovery, the package
   manager, the ship and its live check — is a method.
3. **Ad hoc tool use is fine**, so long as (a) it needs no project tooling of its own, and (b) it is
   never reached for *instead of* the method for that job. Reading files, `git
   status`, a one-off grep for a token: ad hoc. Grepping for planks instead of running the plank
   join: forbidden, and the existing check-precedence rule already says so.
4. **Reuse is positive.** Where several roles do the same job, they call the same method. Reuse
   means one method per job, not plans nested inside plans: each method's plan is self-contained, so
   a stack's runner invocation appears in every plan that runs it.

## CAPTAIN

| # | Job, in order | Needs in hand (ad hoc) | Must run (method) |
|---|---|---|---|
| 1 | Opening: retrieve the standing state, one pass | `AGENTS.md`, `RIGGING.md`, `CAPTAIN.md`, `watchbill.json`, tree cleanliness, and a token search for `@captain`, `@shipwright`, `PERTURBATION` | — reads and git only; no project tooling |
| 2 | Settle preceding blockers, classify the situation | that same output | — |
| 3 | Read the specs and assets classification made relevant | those files | — |
| 4 | Discovery with the user | conversation | — |
| 5 | Author or maintain specs and assets | writes | — |
| 6 | **Lint authored specs and assets at write time** | — | **`spec-lint`** |
| 7 | Write `watchbill.json` | writes | — |
| 8 | Plant a perturbation (narrow exception) | the seam, the `perturb` value | — writes a statement |
| 9 | Dispatch Boatswain / QM, resolve blockers | — | — |
| 10 | **Greenfield fast path: install the harness and the rigging's dependencies** | user conversation, registry checks | **`install`** |
| 11 | **Greenfield fast path: confirm the runner executes before writing `RIGGING.md`** | — | **runs each method it just derived** (the proving act, not a method of its own) |
| 12 | Greenfield fast path: write minimal `RIGGING.md`, including every method | writes | — |
| 13 | **Outbound: ship the release artifact** | user approval | **`ship`**, per outbound target |
| 14 | **Outbound: verify the live artifact a user consumes** | — | **`ship-verify`**, per outbound target |
| 15 | Harbour review 1-6 | Shipwright's report | — |

## QUARTERMASTER

| # | Work-loop step | Needs in hand (ad hoc) | Must run (method) |
|---|---|---|---|
| 1 | Enforce the context bulkhead | the dispatch | — |
| 2 | Retrieve rigging, watchbill, base, one pass | `RIGGING.md`, `watchbill.json`, `git rev-parse HEAD`, `git status --porcelain` | — reads and git only |
| 3 | Settle rigging, HEAD, watchbill from that output | — | — |
| 4 | **A tier-tag watch: one enumeration sweep of that tier** | — | **`sweep`**, or its tier-suffixed variant |
| 5 | **Verify the watch's whole target set, and join its planks** | the targets' features, step definitions, seam surfaces | **`verify`** |
| 6 | Dispatch Crew on a production failure | the failure evidence | — |
| 7 | Consume parallel Crew reports | reports | — |
| 8 | Repeat the cycle until the watch is spent | — | **`verify`** again, per cycle |
| 9 | Append the run record after a fresh green | writes a line | — |
| 10 | End in the final report naming Boatswain | — | — |
| 11 | Return a product-intent blocker to Captain | — | — |

QM also makes undefined steps executable and reverifies: that reverification is `verify` again.
A harness defect QM engineers out is a write, then `verify`.

## CREW

| # | Step, in order | Needs in hand (ad hoc) | Must run (method) |
|---|---|---|---|
| 1 | Opening: verify the dispatch against the contract | the dispatch | — |
| 2 | Opening: first pass, one retrieval | `RIGGING.md`, every target's feature file with its `Background` and `Rule:`, `AGENTS.md` for a perturbation target | — reads only |
| 3 | Opening: second pass, one retrieval | the step definitions and support the first pass named, the referenced spec or asset, the directly related production files | — reads only, and genuinely depends on pass 2 |
| 4 | State target and durable source | — | — |
| 5 | **Reproduce or inspect the failure** | the evidence | **`prove`** over the dispatched target set |
| 6 | Edit minimum production code, add or update planks | writes | — |
| 7 | **Run focused verification** | — | **`prove`** |
| 8 | Report the pass, or the blocker | — | — |

Crew's green is what QM and Boatswain inherit, so `prove`'s output is the hand-off's evidence.

## BOATSWAIN

| # | Job / step, in order | Needs in hand (ad hoc) | Must run (method) |
|---|---|---|---|
| 1 | Opening: verify the dispatch | the dispatch | — |
| 2 | Opening: retrieve the rigging and the deck, one pass | `RIGGING.md`, `AGENTS.md`, `git status`, `git diff <base> -- . ':!CAPTAIN.md'`, `git log -n 5` | — reads and git only; **the `:!CAPTAIN.md` exclusion is part of the retrieval and stays mandatory** |
| 3 | Settle job, touched seams, deck-state hash | — | — |
| 4 | **Hygiene checks: one evidence run answers every check** | the deck from step 2 | **`hygiene`** |
| 5 | Judge each hygiene check against that output | — | — a check judged by reading the diff is an opinion, not a check |
| 6 | Recheck, verification-support hunk | the staged hunks | **`sweep`** of the tier it serves |
| 7 | Recheck, executable hunk with no carried evidence | its planks, from step 4's output | **`prove`** over the planked scenario set |
| 8 | Recheck, non-executable hunk, deletion, or configuration | — | **`static`** |
| 9 | Recheck, hunk with a carried fresh green at this deck-state hash | the hand-off or run record | — inherits it; runs nothing |
| 10 | Strike a spent watchbill with no carried evidence | the watchbill's entries | **`prove`** over those entries |
| 11 | Stage intended changes, commit locally | `git` | — |
| 12 | Confirm the tree clean, report to Captain | `git status` | — |

## SHIPWRIGHT

| # | Job / step, in order | Needs in hand (ad hoc) | Must run (method) |
|---|---|---|---|
| A | Harbour-entry guard | `git status` | — |
| B | **Fitting out: derive `RIGGING.md` and `AGENTS.md`** | the repository | **derives every method** |
| C | **Fitting out: install the runner and confirmed tooling** | the package manifest | **`install`** |
| D | **Fitting out: prove the tooling is runnable** | — | **runs each derived method once** (the proving act) |
| E | Fitting out: write the methodology-check skeletons and the search-exclusion artifact | writes | — |
| 1 | Work loop: load the core skill | — | — |
| 2 | Work loop: retrieve the rigging and the deck, one pass | `RIGGING.md`, `AGENTS.md`, `git status` | — reads and git only |
| 3 | Identify scope | `RIGGING.md` directories | — |
| 4 | **Harbour's one full regression, every tier, cheapest first** | — | **`regression`** |
| 5 | **Map covered code to step definitions** | step 4's coverage output | **`plank-join`** |
| 6 | Find uncovered modules | step 4's coverage output | — reads step 4 |
| 7 | Judge each seam; reference analysis for unreachable code | AST inspection, text search | — ad hoc, no project tooling |
| 8 | Write the two `@conformance` skeletons | writes | — |
| 9 | **Annotate every production seam** | the plank mapping | **`plank-join`** output already in hand |
| 10 | **Process condemned scenarios: prove each removal batch** | the planks | **`condemnation`**, or **`discovery`** twice for dry-run parity where the touched scenarios have no executable steps |
| 11 | Refresh the golden captures | the real dependency | — not project tooling |
| 12 | Verification-economy audit | the weather record, step 4's output | — |
| 13 | Confirm nothing unproven; do not rerun step 4 | — | — |
| 14 | Report to Captain, leave edits uncommitted | — | — |
| F | **Refit: verify every method slot and prove they still execute** | `RIGGING.md` | **runs each method once** |

## What the roles ACTUALLY invoke: 190 banked legs, 4,940 shell invocations

dk's steer: run a role and see what it reaches for. Mined from banked legs rather than fresh spend
(`captain` = 34 legs, `qm`-assumes-crew-and-Boatswain = 140, `shipwright` fitting out = 16):

| What was invoked | captain | qm (+crew+bosun) | shipwright | The method that covers it |
|---|---|---|---|---|
| runner, executing | 202 | 1,137 | 94 | `prove`, `sweep`, `regression` |
| dry-run discovery and step usage | 31 | 374 | 63 | `discovery`, `plank-join` |
| plank inventory | 2 | 85 | 37 | `plank-join` |
| lint | 6 | 9 | 34 | `spec-lint`, and parts of `hygiene`, `static`, `condemnation` |
| typecheck | 0 | 0 | 5 | parts of `hygiene`, `static`, `condemnation` |
| coverage | 1 | 7 | 41 | `regression` |
| install | 7 | 8 | 1 | `install` |
| file reads | 443 | 597 | 82 | ad hoc, correctly |
| git reads | 116 | 533 | 37 | ad hoc, correctly |
| search, not for planks | 42 | 176 | 22 | ad hoc, correctly |
| ad hoc scripting (`node -e`, `python -c`) | 43 | 340 | 7 | ad hoc: investigation, mostly happy-dom probes |
| git writes | 0 | 47 | 0 | ad hoc, custody |

**Only 8 invocations in 4,940 (7 distinct) match no known family**, and every one is an environment
probe: `whoami`, `ulimit -v`, `free -m`, `rustup component list`. So the method set is closed
empirically as well as by argument: no observed project-tooling invocation lacks a method.

Two things the numbers say that the reading alone did not:

1. **`rustup component add llvm-tools-preview` appears in a Shipwright leg** — a role installing
   toolchain components on the fly. That is `install`, and it is evidence for making it a method
   rather than leaving it to improvisation.
2. **Retrieval dwarfs execution**: 1,122 file reads and 686 git reads against 1,433 executing runs.
   Retrieval stays ad hoc by rule, but that is where the round trips actually are, so the retrieval
   batches doctrine already states as one pass are worth keeping stated that way.

## The method set this audit yields

| Method | The job it is the method for | Invoked by | Takes |
|---|---|---|---|
| `prove` | prove a named scenario set | Crew, Boatswain, QM (inside `verify`) | `{scenario}` |
| `verify` | verify a watch's whole target set and join its planks | QM | `{scenario}` |
| `sweep` | enumerate a whole tier, unfiltered, no fail-fast | QM, Boatswain | tier suffix |
| `plank-join` | join every plank to a current step-definition pattern | Shipwright, and inside `hygiene` and `verify` | — |
| `hygiene` | judge deck hygiene in one evidence run | Boatswain | — |
| `static` | prove a non-executable hunk, a deletion, or configuration | Boatswain | — |
| `discovery` | list undefined and unimplemented steps, executing nothing | Shipwright | — |
| `regression` | harbour's one full regression over every tier | Shipwright | — |
| `condemnation` | prove a condemnation removal batch | Shipwright | `{scenario}` |
| `spec-lint` | lint Captain-authored specs and assets at write time | Captain | — |
| `install` | install or upgrade a dependency | Shipwright, Captain on the fast path | `{dependency}` |
| `ship` | ship an outbound target | Captain | per target |
| `ship-verify` | verify the live artifact a user consumes | Captain | per target |

Parameters: `{scenario}` for a target set, `{dependency}` for an install, tier suffixes such as
`sweep-sandbox`. No `{paths}` parameter is owed: every retrieval job turned out to be ad hoc.

**Proving is an act, not a method.** Fitting out, the fast path, and every refit prove the rigging by
running each derived method once. A `rigging-proof` method would be a plan that re-embeds every
other plan, which is duplication for no gain.

**Crew invokes exactly one method** (`prove`) and it is right that it invokes no more: a method is
the tool for a job, and Crew's job is one target's fix and its focused proof. Giving Crew the gates
would add an act, which no method may do.

## What changes in the skills

123 command-value mentions and 9 `## Commands` references across six skills. The substitution map:

| Old command value | Becomes |
|---|---|
| `focused` | `prove`, or `verify` where the plank join belongs to the same step |
| `broad` | `sweep` |
| `coverage` | `regression` |
| `step-usage` + `plank-inventory` | `plank-join` |
| `discover` | `discovery`, or a part inside `static` |
| `typecheck`, `lint` | parts inside `hygiene`, `static`, `condemnation`; Captain's own lint is `spec-lint` |
| `conformance` | the part that replaces the plank inventory inside `plank-join` where the project derives its plank rules |
| `## Outbound` `ship` / `verify` lines | `ship` / `ship-verify` methods |

## Open judgments for dk

1. **`## Outbound` currently carries command values** (`ship`, `verify` per target). Under rule 2
   they are execution jobs and become methods. That is the reading this audit takes.
2. **`install` as a method** makes the package manager's invocation a fitted value rather than a
   role's improvisation, and gives fitting out a proven install path. It takes `{dependency}`.
3. **A tier-tag sweep across several tiers stays several `sweep` invocations**, not one method: a
   red cheaper tier's dispatches complete before a costlier tier runs, so the sequence is reactive
   even though each sweep is a method.
