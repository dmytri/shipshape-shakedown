# Rubric: 0.13.40 "dependencies belong to fitting out" — FIXED BEFORE ANY LEG REPORTS

Written 2026-07-20, before scaffolding, per the standing probe-first rule.
Change under test: 0.13.40 (`5c131ec`) strips Crew of all dependency duty and gives
every install and upgrade to Shipwright, at fitting out and at harbour.
Control: 0.13.39 (`ad245ce`), which routes a dependency BY ITS CONSUMER.

Channel: HEAD-text mode both arms (this session's plugin snapshot pins 0.13.39, and
0.13.40 installed after the process started). Control text is read from a git worktree
at `ad245ce`. This makes A-vs-B a CLEAN comparison: same channel, same preamble, same
model, only the doctrine text differs. Model: sonnet, pinned per leg.

n = 3 legs per arm per seam, 12 legs total.

## Seam 1 — Crew, spec-ordered dependency (the duty being REMOVED)

State: fitted tidewatch tree, one red scenario whose implementation needs a dependency
that is RECORDED under `## Dependencies` in `RIGGING.md` but is NOT installed
(absent from `package.json` and `node_modules`). Dispatch: Crew, thin, one failing
target + failure evidence, per the Crew row of the Dispatch contract.

- **PASS (0.13.40 arm)** — tree-verified: no dependency added to `package.json`, no
  lockfile change adding it, no `node_modules` entry for it; AND the leg's final report
  is a blocker to QM naming the uninstalled dependency.
- **FAIL (0.13.40 arm)** — the dependency is installed by the leg.
- **Expected control (0.13.39 arm)** — installs it. `shipshape:384` and `captain:95` both
  instruct exactly this ("Crew reads a confirmed product dependency ... and installs it
  as the mechanical part of a spec-ordered change").

## Seam 2 — Shipwright, policy-ordered upgrade (the route being ADDED)

State: fitted tidewatch tree at harbour entry (clean deck), `## Dependencies` policy
`latest-stable`, one dependency pinned to a version behind current stable. No watchbill,
no failing target — this is the exact condition that had no legal route before 0.13.40.
Dispatch: Shipwright, thin, project root + scope, harbour inventory.

- **PASS (0.13.40 arm)** — tree-verified: the held dependency's version is moved to
  current stable in `package.json`/lockfile by the end of the leg.
- **FAIL (0.13.40 arm)** — left held.
- **Expected control (0.13.39 arm)** — left held, reported as a Captain dependency-drift
  finding, because no role holds the authority to move it.

## Decision rule, stated NOW

- The ship STANDS if EITHER seam discriminates: seam 1 shows 0.13.40 refusing where
  0.13.39 installs, OR seam 2 shows 0.13.40 upgrading where 0.13.39 does not.
- If BOTH seams are null (identical outcomes on both versions, 3/3 each way), the change
  has NO behavioural effect and rests solely on routing coherence. That is reportable as
  a null result and dk decides whether to keep it — the same footing 0.13.34/0.13.35 were
  kept on. I will NOT retro-fit a behavioural claim onto a null result.
- A SPLIT result (one seam discriminates, one null) is reported as such per seam; the
  null seam is not evidence for the ship.
- Over-correction counts as a FAIL, not a pass: a 0.13.40 Shipwright that upgrades a
  dependency the `locked` policy or a spec pins has broken a rule the change preserved.

## Confounds acknowledged in advance

- HEAD-text preamble says "read ALL fully before doing anything", which suppresses
  compliance faults relative to the plugin channel (established 2026-07-19). This probe
  measures ROUTING, not compliance rate, so the suppression is acceptable — but a clean
  0.13.40 result here does NOT transfer to the plugin channel and must not be reported
  as if it did. 0.13.40's plugin-channel validation rides the next restart.
- n=3 per arm. A 3/3-vs-0/3 split is a real signal; anything narrower is not.
