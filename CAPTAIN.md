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

- 0.13.9 strike-guard wording: SHIPPED 2026-07-12 (33b8e38) on dk's word after the
  probe pair upgraded it to MEDIUM (three observations, divergent: obs#1 struck on
  inference; obs#2 legA and obs#3 legC refused, committed watchbill.json into the
  voyage commit, named it for Captain; over-strike arm clean in legC). Strike guard
  now accepts run-record corroboration of every watchbill entry green at the current
  deck-state hash as spent evidence. Validation rides the TodoMVC pilot; a dedicated
  custody-fresh-session probe on 0.13.9 text is the cheap follow-up if the pilot
  never hits the fresh-session strike seam.
- dk owns: jolly validation (real project, slow suite - where evidence-or-rerun and
  the run record pay off in minutes), model-tiering defaults (haiku custody
  outcome-safe but economy-leaky; sonnet economy-conformant), remote for this repo.
- `npx plugins doctor` prints "No plugins found" from any cwd while
  installed_plugins.json and cache are correct - upstream CLI quirk, unreported.
- First TodoMVC pilot (scenarios/pilot.md) not yet run.
- QM leg still leaks ~1 wait invocation on nested Crew even with foreground order.

## Shakedown log

- 2026-07-12 probe pair (strike + custody-fresh-session + stale-record arm), doctrine
  0.13.8 installed-plugin channel, sonnet, three parallel fresh Boatswain legs on
  duplicated tidewatch trees (cp -r probe-state duplication per the probe catalog).
  Markers: legA row-1 inherit clean (hash byte-equal, 0 suite executions, commit
  03d2feb) but strike MISSED per the wording gap above; legB hand-off strike full PASS
  (0 strike-runs, watchbill removed, commit 6948022); legC stale-record full PASS
  (mismatch caught, record voided, exactly 1 focused rerun, fresh record line appended
  at the new hash, commit c8a69f6). No redundant confirmation runs anywhere; no
  contamination refusals on legal hand-off content; no mid-leg doctrine re-reads.
  Bonus positives: legA raised the unpinned-error-branch Captain blocker on
  nextLowTide (spec-ambiguity check bites); legC flagged the data-bound plank for
  harbour per the Planking agreement caution. Per-leg numbers in METRICS.md.
- 2026-07-12: harness repo published to https://github.com/dmytri/shipshape-shakedown
  (private) at dk's request; main tracks origin.

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

- Jolly and Estelle re-derive at next refit: everything 0.13.0-0.13.9, notably
  watchbill as sole QM channel, thin dispatch, broad/coverage without fail-fast,
  @invariant rename, planted-red vocabulary, trace-selected recheck, decision-table
  custody, runrecord slot in RIGGING, no-pre-check credentials.
- Pilots owe live-fire evidence: weather record, behaviour-identity duplication
  check, @eval tier, verification-economy audit at scale (TodoMVC pilot covers most).
- Open infra fork: automated live-agent bulkhead conformance harness vs the
  fixture-matrix proof in shipshape tests/bulkhead.sh - the probe catalog's
  contamination/bulkhead probes are the current answer; build more or accept.
