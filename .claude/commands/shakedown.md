---
description: Run a Shipshape shakedown - lifecycle, probes, or pilot - per the operator manual
---

Run a shakedown of the Shipshape doctrine. Arguments: $ARGUMENTS

1. Bootstrap if not already done this session: read AGENTS.md, CAPTAIN.md, METRICS.md
   in this repo. Check the deck: ~/shipshape clean and level with origin; installed
   plugin version vs ~/shipshape/.plugin/plugin.json; note whether this session
   predates the last install (session-snapshot rule decides HEAD-text vs
   installed-plugin mode).
2. Interpret the arguments:
   - empty: do NOT run yet. Report the deck in two lines (doctrine version vs the
     last METRICS.md baseline, open items from CAPTAIN.md), then: if doctrine moved
     since the last baseline, propose the cheapest scenario covering the changed
     seams and ask one question - "run this?"; if nothing moved, ask what to test.
     Named arguments below run autonomously without asking.
   - "lifecycle": full lifecycle per scenarios/lifecycle.md
   - "probes" or a probe name: the matching probes from scenarios/probes.md
   - "pilot": the TodoMVC pilot per scenarios/pilot.md (expensive - confirm with the
     user before starting, and honour the oracle quarantine absolutely)
   - anything else: treat as the change under test; pick the cheapest scenario that
     exercises the seams that moved (verification economy applies to shakedowns)
3. If doctrine changes are part of the task: edit ~/shipshape skills, bump the plugin
   version, run tests/*.sh green, commit, push, reinstall - BEFORE simulating.
4. Scaffold sim trees with bin/scaffold.sh into the session scratchpad. Dispatch role
   agents per prompts/preamble.md, thin dispatches, verifying tree facts between legs.
5. Mine every leg with bin/mine.sh, count suite executions with bin/runs.sh, classify
   every invocation P/N/Neg per METRICS.md, and report: markers hit or missed,
   findings with evidence, per-leg invocations/tokens/wall, worth densities, class
   tally updates.
6. Record: update METRICS.md baselines and the class tally, log findings and state in
   CAPTAIN.md, commit this repo. Route doctrine findings to the user; do not ship
   doctrine fixes without their word unless they pre-approved the cycle.
