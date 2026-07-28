# Generation B — fixed fixture (2026-07-28)

**The live comparison. Only cells within this generation may be compared to each other.**

| axis | value |
|---|---|
| harness | `67a682c` (world.js loads and RUNS the real app, window disposed) + `7746c15` (routing drivable) |
| playbook | fit-out BEFORE voyage 1; 3600s leg cap; full-file self-suite parse; a suite that cannot RUN is red |
| doctrine arms | candidate, control installed 0.13.65, midway (`P7-mid-*`, control + methods) |
| oracle | single clone under `flock` (`326ba85`) |

Each fixture fault was proven in both directions before the generation opened: missing page red,
empty app red, stub red against a behavioural scenario, real deferred app green (60 scenarios,
181MB flat); working router 3/3 green, broken router 2/3 red.

**Known limit carried into the results:** legs still hit a 4096-token per-response ceiling
(`stopReason=length`), 29 of 192 legs overall and 16 in `P6-cand-flash` alone. That ceiling is
not set by us — it is pi's fallback for a model its registry lacks — but heavier doctrine hits
it sooner, so it is measured, not masked. See `bin/noops.py`.
