---
description: Run a Shipshape shakedown - lifecycle, probes, or pilot - per the operator manual
---

Run a shakedown of the Shipshape doctrine. Arguments: $ARGUMENTS

1. Bootstrap if not already done this session: read AGENTS.md, CAPTAIN.md, METRICS.md
   in this repo. Check the deck: ~/shipshape clean and level with origin; installed
   plugin version vs ~/shipshape/.plugin/plugin.json; note whether this session
   predates the last install (session-snapshot rule decides HEAD-text vs
   installed-plugin mode).
2. The standard entry is bare /shakedown. Do NOT run yet. Report the deck in two
   lines (doctrine version vs the last METRICS.md baseline, open items from
   CAPTAIN.md) and propose a scope: the cheapest scenario covering seams that moved
   since the last baseline, or the top open item when nothing moved. Then ask ONE
   question before spending anything: "Any particular focus this run - token economy,
   a failure mode, feedback from a consuming agent, a doctrine worry - or shall I
   proceed as proposed?" Fold whatever the user answers into scenario choice, leg
   prompts where legal (user intent is a legal Captain channel; never contaminate
   role dispatches with it), the audit lens, and the report's emphasis. "Proceed" or
   silence-equivalent means run the proposal autonomously to completion.
   Arguments, when given, skip the question: "lifecycle" (scenarios/lifecycle.md),
   "probes" or a probe name (scenarios/probes.md), "pilot" (scenarios/pilot.md -
   still confirm cost first, and honour the oracle quarantine absolutely), anything
   else = the change under test, cheapest covering scenario.
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
