# Shipshape Shakedown - operator manual

Repeatable live-fire validation of the Shipshape doctrine (~/shipshape) using real
role agents on instrumented toy projects. Built from the 0.13.x audit sessions.

## Session bootstrap

Fresh session, read in this order: this file, CAPTAIN.md (state, standing decisions,
open items), METRICS.md. Then check the deck: ~/shipshape clean and level with
origin, installed plugin version vs .plugin/plugin.json. Development and testing
happen HERE; ~/shipshape is doctrine/plugin only - it gets doctrine commits and
nothing else (no notes, no fixtures, no scratch).

## Standing procedure (order matters)

1. **Ship first.** Doctrine changes under test must be committed, pushed, and
   installed: `yes | npx plugins add dmytri/shipshape`. Bump `.plugin/plugin.json`
   version for ANY doctrine change. Run all `tests/*.sh` (must be green) before push.
2. **Know your text channel.** Plugin resolution is snapshotted at session start:
   installed `shipshape:*` agents in a session predating the install run OLD text.
   Same session -> HEAD-text mode (generic agents + prompts/preamble.md).
   After a restart -> installed-plugin mode validates the plugin channel itself.
3. **Scaffold**: `bin/scaffold.sh /tmp/<scratch>/tidewatchN` (never inside a real
   repo; keep sim trees in the session scratchpad).
4. **Run legs** per scenarios/lifecycle.md, or scenarios/probes.md for single-rule
   changes. Thin dispatches; verify tree facts between legs yourself.
5. **Mine**: `bin/mine.sh <task-transcript.output> <legname>` per leg;
   `bin/runs.sh <project>` for suite executions; `bin/deckstate.sh` to check wake
   run-record equality. Compare against METRICS.md baselines.
6. **Judge**: markers from the scenario tables; every invocation through the audit
   lens in METRICS.md, scored 0-100 for worth, with leg worth density in the report. A finding is real only with tree evidence, never report prose
   alone. Route findings to dk; do not fix doctrine without routing, except when dk
   pre-approved the cycle.
7. **Record**: update METRICS.md baselines on doctrine version changes; log findings
   in ~/shipshape/CAPTAIN.md per Captain notes custody.

## Invariants

- The shipshape repo stays clean during a shakedown except shipped fixes and
  CAPTAIN.md notes. Sim commits use "Sim Operator <sim@example.test>"; real doctrine
  commits use the repo's git user.
- Never install via any channel except `npx plugins add dmytri/shipshape`.
- One finding class per report line, with evidence (commit hash, transcript line,
  runs.log count).
- Findings > green runs. A shakedown that only confirms is a weak shakedown; probe
  the seams that changed.
