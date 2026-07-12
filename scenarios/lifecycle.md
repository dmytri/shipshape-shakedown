# Full lifecycle shakedown

The standard end-to-end run. Legs in order, each a fresh subagent with the preamble.
Between legs, verify tree facts yourself (git log, git status, grep) - never trust the
report alone.

| Leg | Role | Dispatch | Expected markers |
|---|---|---|---|
| 1 | Shipwright | fit out + inventory, base = baseline commit, scope full | RIGGING/AGENTS/README/.rgignore written; required checks (watchbill-shape with absence-conforms, perturbation quiescence) each proven red once; verification-conformance scantling derived (rule file + one @invariant scenario, never `none` on a runnable stack); focused command accepts `<spec>.feature:<Scenario Name>` verbatim; runrecord path derived git-ignored; NO script files authored; tree left uncommitted |
| 2 | Captain | product intent + promotions in prompt as user discovery | @captain tags removed on promote; new scenarios use real fixture data; valid fixed-shape watchbill written with the edit; thin next-dispatches named |
| 3 | Boatswain | job post-implementation (harbour custody), thin | Commits over undefined promoted steps (never a custody failure); unspent watchbill staged, NOT struck, NOT used as recheck selector; per-hunk decision-table rows reported |
| 4 | QM | role + base commit only | Watchbill is sole channel; undefined steps made executable honestly; Crew dispatched foreground with thin evidence-only dispatch; fresh green per target; run record appended with deck-state hash; watchbill reported spent |
| 5 | Boatswain | post-implementation; EITHER paste QM report (hand-off path) OR thin-only (fresh-session path, wake evidence) | Inherits caller/run-record greens (row 1, run nothing); reruns only unevidenced executable hunks by trace; strikes spent watchbill with zero strike-runs; commit references scenario in canonical form |

Then mine every leg (bin/mine.sh) and the project (bin/runs.sh) and compare against
METRICS.md baselines. Deltas in invocations and suite executions are the doctrine
signal; wall-clock is the harness signal.

Perturbation extension (optional leg 6+): Captain plants perturb statement + watchbill
at a behaviour-stable seam; QM treats red as normal target; Crew rebuilds and removes
statement with seam audit in its report; Boatswain accepts statement-only removal on
that evidence.
