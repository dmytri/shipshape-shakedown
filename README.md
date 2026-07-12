# shipshape-shakedown

Live-fire validation harness for [Shipshape](https://github.com/dmytri/shipshape):
scaffold an instrumented toy project, run the real role agents through voyages,
harbours, and targeted probes, and mine exact per-invocation token/latency metrics
from the transcripts.

- `AGENTS.md` - the operator manual (an agent runs shakedowns; start there)
- `bin/` - scaffold, transcript miner, suite-execution counter, deck-state hash
- `fixtures/tidewatch/` - the standard green baseline project (cucumber-js, planted
  instrumentation hook)
- `prompts/` - role-agent preamble and dispatch rules learned live
- `scenarios/` - full lifecycle table and the targeted probe catalog
- `METRICS.md` - how to read the numbers, plus baselines

A shakedown answers four questions: does the doctrine hold end-to-end, did the change
under test land, what does every leg cost (invocations x prefill = both the token and
the latency bill), and did anything regress at the seams that moved.
