# Captain notes - shipshape-shakedown workstream

Migrated from ~/shipshape/CAPTAIN.md at handover (2026-07-12, doctrine 0.13.8).
The shipshape repo is doctrine/plugin only; all development, testing, and notes live
here. Binding behaviour lives in the doctrine skills; procedure lives in AGENTS.md and
scenarios/; numbers live in METRICS.md. These notes carry decisions and open items.

## State at handover

- Doctrine 0.13.8 (425c642) shipped, pushed, installed, sim-validated: wake voyage
  run record with deck-state equality (fresh-session custody ran zero verification),
  round economy, decision-table custody, no-pre-check credentials with CLI custody,
  verification-conformance scantling, evidence-or-rerun. Voyage: 15.7m/14 runs
  (0.13.3) -> 5.6m/3 runs (0.13.8). Full history in shipshape git log 0.13.0-0.13.8.
- This harness v0 is self-tested; first class tally seeded in METRICS.md.

## Open items

- 0.13.9 candidate (LOW): strike guard wording - fresh-session Boatswain has no
  hand-off saying "spent"; add "or the run record corroborates every watchbill entry
  green at the current deck-state hash". Observed inferred correctly and flagged.
- dk owns: jolly validation (real project, slow suite - where evidence-or-rerun and
  the run record pay off in minutes), model-tiering defaults (haiku custody
  outcome-safe but economy-leaky; sonnet economy-conformant), remote for this repo.
- `npx plugins doctor` prints "No plugins found" from any cwd while
  installed_plugins.json and cache are correct - upstream CLI quirk, unreported.
- First TodoMVC pilot (scenarios/pilot.md) not yet run.
- QM leg still leaks ~1 wait invocation on nested Crew even with foreground order.

## Standing decisions (dk's; do not revisit without the named change)

- Parallel Crew stays shared-deck: no worktrees, no disjoint-files guards.
  Verification is the detector. Revisit only on live-fire evidence the ladder missed.
- No reference-file splits in doctrine skills; resident-by-design. Revisit only on a
  change to the clear or isolation model.
- Green ledger (durable green cache with change-impact selection) dropped whole. The
  0.13.8 run record is NOT it and must not grow toward it: whole-deck equality is the
  entire invalidation rule; no impact analysis may be added.
- No self-enforcement claims for methodology checks until a downstream fitting-out
  proves them red once, live. (Partially discharged: tidewatch fitting-outs prove
  derived checks red; the claim stays modest.)
- Blocking Captain-reset gate not built: no reliable boundary signal for a stateless hook.
- hooks: bash -lc "git push" left fail-open deliberately; revisit on live-fire evidence.
- Seam vs Feathers' test seam: accept and watch (dependency-injection-doubles prior).
- Anchor adoption form: name plus concrete rule, never a bare anchor.
- Credentials: fitted, never pre-checked; CLI-custodied stores are opaque and never
  searched (jolly's saleor/vercel case drove 0.13.4/0.13.5).

## Standing procedures

- Install: `yes | npx plugins add dmytri/shipshape`, nothing else. Never `claude
  plugin` commands; `.claude-plugin/*` are generated downstream artifacts.
- Plugin resolution snapshots at session start; mid-session reinstall does not reach
  subagents. Restart, or use HEAD-text mode (prompts/preamble.md).
- Any doctrine change bumps .plugin/plugin.json version; tests/*.sh green before push.
- ~/shipshape stays clean: doctrine commits (repo git user) only; no notes, no sim
  artifacts. Sim trees live in the session scratchpad and die with it - durable
  numbers go to METRICS.md before session end.

## Downstream carry

- Jolly and Estelle re-derive at next refit: everything 0.13.0-0.13.8, notably
  watchbill as sole QM channel, thin dispatch, broad/coverage without fail-fast,
  @invariant rename, planted-red vocabulary, trace-selected recheck, decision-table
  custody, runrecord slot in RIGGING, no-pre-check credentials.
- Pilots owe live-fire evidence: weather record, behaviour-identity duplication
  check, @eval tier, verification-economy audit at scale (TodoMVC pilot covers most).
- Open infra fork: automated live-agent bulkhead conformance harness vs the
  fixture-matrix proof in shipshape tests/bulkhead.sh - the probe catalog's
  contamination/bulkhead probes are the current answer; build more or accept.
