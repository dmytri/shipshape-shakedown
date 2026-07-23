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

## Eval tier: pi baseline agents on non-Claude models (built 2026-07-23)

A cheap, repeatable, control-armed instrument for measuring doctrine AFFORDANCE
on models that are NOT Claude - the portability claim this corpus had only ever
validated on sonnet/opus. A baseline `pi` agent (`@earendil-works/pi-coding-agent`,
`node_modules/.bin/pi`, isolated `$HOME`/XDG, `--approve` to kill the non-
interactive confirm-loop) reads the installed role skill(s) via `--skill` and
acts over a scaffolded sim; the run is captured raw and folded deterministically.

- `bin/eval-leg.sh` ATOM: one isolated pi session -> raw capture (session JSONL
  transcript + rendered stdout + FULL tree.diff of artifacts + tree.status + git.log).
- `bin/eval-map.py` FOLD (pure, no model call): role-phased affordance map -
  per-turn in/out/cache/cost, tool calls, role-skill loads, confirm/repeat flail
  signals. Sibling of doctrine-sections.py; tested on data/eval-fixture/.
- `bin/eval-bank.sh` bank a leg into data/<wave>/ with maximum durable detail.
- Pilot-capable by composition: eval-pilot.sh (to build) sequences legs
  (Captain -> /new -> QM-assumes-rest, x voyages, + oracle grade) over the atom.
  Skill-only pi IS the doctrine's "load role in place" branch natively - QM/
  Shipwright assume downstream roles by READING the next skill and following it.
- Batches are named model manifests (baseline/medium/premium); a batch is just a
  model list fed to the same atom. Baseline (2026-07-23): qwen3.6-27b,
  deepseek-v4-flash, devstral-2512, minimax-m2.7 - see data/eval-shipwright-01/.

**Iterating on candidate doctrine WITHOUT polluting real doctrine commits (dk asked,
2026-07-23; standing rule).** Three separate places, and only one ever takes a
doctrine commit:
1. `~/shipshape` = the real doctrine/plugin. The eval NEVER writes or commits here;
   it only READS skills. It gets a commit ONLY at the approved ship step
   (ship-first: edit -> bump -> tests green -> commit -> push -> reinstall), after
   a probe earns it AND dk approves. Structurally insulated.
2. installed plugin cache = read-only 0.13.64, the eval's CONTROL arm (`--skill`).
3. this cockpit = the instrument, data, and ALL iteration.
   To test a candidate doctrine edit: COPY the skills into a gitignored
   `experiments/<name>/skills`, edit the copy, and point the TREATMENT leg's
   `--skill` at it; the CONTROL leg points at the installed plugin. A/B the same
   models across both arms. `~/shipshape` is untouched until ship. Bank only the
   RESULT (maps, verdicts) plus the candidate's diff-vs-installed as a text
   artifact - never the candidate skill text as a cockpit commit that could read
   as a real change.

## Probe-first (dk ruled, 2026-07-19). Which findings owe a probe BEFORE a fix ships

Classify the finding, then route:

- **Behavioural** - "a role did the wrong thing." OWES A PROBE BEFORE ANY FIX SHIPS,
  with a control arm on the current text and a rubric fixed BEFORE the legs report.
  Reason, on 2026-07-19's record: probing changed or retired the finding EVERY time it
  was tried - pilot-#5 finding 3 (economy claim retired against a control), finding 1
  (did not reproduce on either version), the Captain opening (did not reproduce; no fix
  shipped, and the probe paid for itself), and the plank-routing finding, where 20 legs
  retired the proposed fix as a null result, killed the operator's own fixture
  hypothesis, corrected the stated mechanism, downgraded the severity, and only then
  found the real cause by probing THE ROLE THAT DOES NOT FAIL and asking what it does
  differently. Not one of those corrections came from re-reading the text.
- **Textual** - a list missing a member, a form no command can check, two lines
  contradicting, an example teaching against its own prose. Ships on a close read plus
  green `tests/*.sh`; no behavioural probe owed, because the defect is in the artifact
  and is visible in it. 0.13.34, 0.13.35 and 0.13.37 all rest on this footing.
- A behavioural OBSERVATION may motivate a textual finding, but it does not license
  skipping the probe when the fix is aimed at behaviour. State which footing a fix
  rests on in its commit message.

Two riders, both learned the same day:
- **Probe the role that does NOT fail, not only the one that does.** The plank-routing
  root cause was an asymmetry between QM and Boatswain, invisible until Boatswain was
  probed on the same state.
- **Ship one change per version where the seams are disjoint enough to attribute.**
  Bundling is what produced an efficiency battery "owed twice over".

## Invariants

- The shipshape repo stays clean during a shakedown except shipped fixes and
  CAPTAIN.md notes. Sim commits use "Sim Operator <sim@example.test>"; real doctrine
  commits use the repo's git user.
- Never install via any channel except `npx plugins add dmytri/shipshape`.
- One finding class per report line, with evidence (commit hash, transcript line,
  runs.log count).
- Findings > green runs. A shakedown that only confirms is a weak shakedown; probe
  the seams that changed.
