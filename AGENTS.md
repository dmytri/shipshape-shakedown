# Shipshape Shakedown - operator manual

Repeatable live-fire validation of the Shipshape doctrine (~/shipshape) using real
role agents on instrumented toy projects. Built from the 0.13.x audit sessions.

## Session bootstrap

Fresh session, FIRST `git fetch` THIS repo and confirm the local clone is level
with origin/main before reading anything - a stale clone reads as a false state
gap and mis-bases the whole session (2026-07-18: a 38-commit-stale clone cost a
wave a wrong number, a stale queue, and a rejected push). Then read in this order:
this file, CAPTAIN.md (state, standing decisions, open items), METRICS.md. Then
check the deck: ~/shipshape clean and level with origin, installed plugin version
vs .plugin/plugin.json. Development and testing
happen HERE; ~/shipshape is doctrine/plugin only - it gets doctrine commits and
nothing else (no notes, no fixtures, no scratch).

## Standing procedure (order matters)

1. **Ship first.** Doctrine changes under test must be committed, pushed, and
   installed: `yes | npx plugins add dmytri/shipshape`. Bump `.plugin/plugin.json`
   version for ANY doctrine change. Run all `tests/*.sh` (must be green) before push.
2. **Know your text channel.** Plugin resolution is snapshotted at PROCESS start,
   not conversation start: /clear does NOT re-snapshot, so a long-lived Claude Code
   process serves stale `shipshape:*` text and hooks no matter what
   installed_plugins.json says (2026-07-13: two whole waves ran ~0.13.8 text
   undetected). Never trust timestamps; verify empirically: after dispatching the
   first installed-plugin leg, grep its transcript for a marker phrase unique to the
   version under test (pick one from the newest doctrine diff, e.g. `git -C
   ~/shipshape diff <prev>..<cur> -- skills | grep '^+'`). Zero hits = stale
   snapshot = this session can only run HEAD-text mode (generic agents +
   prompts/preamble.md); the installed-plugin validation waits for a real restart.
3. **Scaffold**: `bin/scaffold.sh /tmp/<scratch>/tidewatchN` (never inside a real
   repo; keep sim trees in the session scratchpad).
4. **Run legs** per scenarios/lifecycle.md, or scenarios/probes.md for single-rule
   changes. Thin dispatches; verify tree facts between legs yourself. Pin `model`
   explicitly on every dispatched leg; nested spawns inherit the parent's model only
   for the parent's first spawn, then fall to the session model (2026-07-12).
   Slow-suite dispatch rules (pilot #2 deadlock, 2026-07-13): every dispatch
   carries the background-task lines from prompts/preamble.md - never end a turn
   with a live background task; commands that may exceed ~90s run backgrounded and
   their output file is Read to the summary line within the same turn; wait on
   output files, never process names (a pgrep condition matched a concurrent
   session's suite). Pilot and lifecycle legs are OPERATOR-DRIVEN: stop Captain
   after specs+watchbill with an explicit stop-line and dispatch QM yourself; never
   auto-chain nested async voyages on a slow-suite project - the runtime
   auto-backgrounds foreground commands at ~2m, and a background completion cannot
   resume a finished nested agent chain (silent deadlock).
5. **Mine**: `bin/mine.sh <task-transcript.output> <legname>` per leg;
   `bin/runs.sh <project>` for suite executions; `bin/deckstate.sh` to check wake
   run-record equality. Compare against METRICS.md baselines. Mine the transcript
   on EVERY task-notification immediately - tree-diff alone missed a stalled QM
   for ~25m (pilot #2).
   Transcripts live at `~/.claude/projects/<proj>/<session>/subagents/agent-*.jsonl`
   but the old "DURABLE, nothing needs harvesting" claim is FALSE (2026-07-18/19:
   pilot #4, the GOAL-2 14-leg session, and waves 1-5 raw transcripts are all
   gone; cause CONFIRMED 07-19 as VM mortality, not pruning - this home dir was
   born 07-14 17:36, both repo clones 07-15, so that work ran on a previous
   exe.dev VM whose disk is gone; no cleanupPeriodDays configured. gitignored
   or otherwise uncommitted local copies die the same way - only content pushed
   to origin survives). Mine every leg SAME-SESSION and BANK it: `bin/bank.sh
   <wave> <transcript.jsonl>` writes the per-invocation audit to
   data/<wave>/<leg>.txt - commit data/ with the session record (KBs; this is
   the layer that survives, dk-approved 2026-07-19). BorgBase covers raw jsonl
   for ~6 months on the vykar cron (see CAPTAIN.md 2026-07-19 + ~/swamp
   AGENTS.md Visitors recipes); raw-transcript re-analysis (P/N/Neg fold,
   inbound.py, plan.py, retrieval graph) is only possible while raw survives -
   fold same-session, bank the numbers.
6. **IEPE**: analyse the instruction as the execution trajectory it produces, per
   `scenarios/iepe.md`. `bin/inbound.py` and `bin/inbound-fleet.py` decompose inbound
   context weight (exact; the ledger identity closes at drift +0 or the numbers are
   unsound). `bin/plan.py` derives the retrieval plan an instruction implies and reports
   its compilable waste. `bin/doctrine-sections.py` prices each doctrine section.
   `bin/make-ballast.py` + `bin/ballast-compare.py` are the controlled context-latency
   probe. Apply this to ANY instruction under test, not just role skills. The framework's
   own limits are binding and stated in that file: cost is not worth, the matrix nominates
   and never condemns, and IEPE is a shakedown lens that never ships as doctrine text.
7. **Judge**: markers from the scenario tables; every invocation through the audit
   lens in METRICS.md, scored 0-100 for worth, with leg worth density in the report. A finding is real only with tree evidence, never report prose
   alone. Route findings to dk; do not fix doctrine without routing, except when dk
   pre-approved the cycle.
8. **Record**: update METRICS.md baselines on doctrine version changes; log findings
   and state in CAPTAIN.md here (notes migrated from ~/shipshape at the 2026-07-12
   handover; the shipshape repo gets doctrine commits only).

## Invariants

- The shipshape repo stays clean during a shakedown except shipped fixes and
  CAPTAIN.md notes. Sim commits use "Sim Operator <sim@example.test>"; real doctrine
  commits use the repo's git user.
- Never install via any channel except `npx plugins add dmytri/shipshape`.
- One finding class per report line, with evidence (commit hash, transcript line,
  runs.log count).
- Findings > green runs. A shakedown that only confirms is a weak shakedown; probe
  the seams that changed.
