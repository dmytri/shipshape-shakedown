# Captain notes - shipshape-shakedown workstream

## Session close 2026-07-12 (restart-ready)

Doctrine 0.13.10 (c045b46) shipped, pushed, installed; doctor audit clean: one live
install (plugin channel, user scope), all six skills + templates hash-match upstream
main, all 10 hook scripts executable, no skills-channel copies, no shadowing; ~25
inert older plugin-cache dirs are CLI-managed cruft, harmless. Next session runs
installed-plugin mode at 0.13.10 by construction. First work item: the 0.13.11 queue
under Open items/candidates (plant-red timing, scope-out confirmation gate,
greenfield fast path, pilot.md template-fixture amendment) - all awaiting dk's word.
Sim trees (tidewatch1-5, todopilot, oracle-grading) die with this session's
scratchpad; all durable numbers are in METRICS.md. This session: 0.13.9 shipped and
validated 2-for-2, first TodoMVC pilot complete (oracle 0/29 -> 18/29), 0.13.10
shipped and probe-validated (notes custody FULL PASS transcript-verified,
seam-parallel Crew PASS, plank rules derive with plant-red timing residue).

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

- TOP (dk directive, 2026-07-12 post-pilot): economy. Pilot cost ~13x a bare session
  for first-build; must approach 2-3x for the maintenance-amortization case to hold.
  Levers ranked: QM parallel/batched Crew dispatch (~45m of the 92m build voyage),
  greenfield bootstrap collapse (~20m), harbour-gate deferral reading (~25m), model
  tiering (dk-owned, 20-30%), opening tax (bounded by resident-by-design). Fold into
  0.13.10 with the four blessed queue items; validate with tidewatch probes, not a
  pilot.

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
- First TodoMVC pilot COMPLETE (2026-07-12, 0.13.9, HEAD-text, sonnet): 27 legs,
  greenfield to working app, oracle 18/29 after one legal iteration (from 0/29 on the
  template gate). Numbers in METRICS.md; findings and doctrine queue in the Shakedown
  log. Residual: 9 oracle failures unfixed (next iteration is one Captain
  product-intent leg away, dk's call); ~39 nested subagent transcripts unmined.
- dk concern + doctrine candidate (2026-07-12, pilot; raised LOW->MEDIUM after
  discussion): plank-inventory derives to bare grep on plain-JS stacks, and grep
  cannot verify docblock FORM (tag inside /** */) beyond a crude regex, nor PLACEMENT
  (docblock attached to the seam declaration) at all - placement is parsing. The
  Planking agreement's "executable form check rather than a human-read judgment"
  degrades to exactly the human-read judgment it warns against (Article 6 failure
  mode). Key facts: the one-line-command constraint binds RIGGING values only, NOT
  verification support - a parser-backed checker under QM is legal today per the
  Scantling agreement's bespoke-checker clause; and the pilot's own derived
  verification-conformance rule set could have carried a form-lite regex rule
  (line-comment plank reddens) within all constraints, but the Planking agreement and
  the conformance rule-set mechanism are not cross-wired, so nothing prompts its
  derivation. Proposal for dk post-pilot: (1) cross-wire sentence in the Planking
  agreement routing plank-form into the derived conformance rule set, proven red by a
  planted line-comment plank; (2) named-engine catalog entry for docblock inventory
  (jsdoc -X; acorn-backed bespoke checker as QM verification support) for full
  placement checking. Do not change mid-pilot.
- QM leg still leaks ~1 wait invocation on nested Crew even with foreground order.

## Shakedown log

- 2026-07-12 TodoMVC pilot results (doctrine 0.13.9, HEAD-text). What held: 0.13.9
  strike arm 2-for-2 at sea (thin custody inherited record-corroborated greens and
  struck, zero reruns, legs 10 and 25); contamination bulkhead bit FOUR times
  correctly (2x QM-to-Crew interpretive dispatches, 1x operator's Boatswain-to-Crew
  shortcut, 1x narrative Captain-to-Boatswain dispatch flagged); parallel Crew
  shared-deck clean (2 mates, independent seams, leg 24); honest-red discipline held
  (all new targets proven red before fix); harbour caught 2 real spec-conformance
  defects the voyage's own verification missed and 27 missing planks via scripted
  cross-reference; watchbill/at-rest lifecycle exact throughout. Oracle: 0/29 on
  template gate (Captain's scope-out of Template/Structure/Code sections punished
  objectively), 18/29 after one product-language iteration; quarantine held - no role
  saw the oracle. Residual 9 failures (unauthored findings): missing template form
  wrapper around new-todo, edit-blur/empty-destroy path, create-trim, persistence
  format, filter-highlight semantics, others unanalysed.
- 2026-07-12 pilot doctrine queue for dk (consolidated, none shipped):
  1. MEDIUM plank conformance cross-wiring (one mechanism, three observed seams):
     grep-only form check degrades to human judgment (two Boatswains ruled opposite
     on identical index.html planks, legs 13/16); unplanked-seam remediation has no
     red target (foul->QM->Crew loop strained, legs 13-16); missing planks reached 27
     entries before a scripted harbour pass caught them (leg 21). Fix: plank
     form+coverage rule in the derived verification-conformance rule set, proven red
     by plant; named-engine catalog entry for docblock inventory (jsdoc -X; acorn
     checker as QM verification support).
  2. MEDIUM CAPTAIN.md custody: three Boatswains ruled leave/decline/stage-blind on
     the same file (legs 16/19/23); Captain self-commit worked as exit (leg 20); six
     CAPTAIN.md read-slips across HEAD-text legs, all self-caught, one costing a
     bounced harbour (leg 18). Fix: one explicit line (Captain commits own notes, or
     Boatswain MAY stage it content-blind); verify plugin-hook coverage blocks
     CAPTAIN.md reads on the plugin channel (HEAD-text mode has no hooks).
  3. LOW run-record line schema: roles appended structurally divergent entries
     (deckStateHash vs hash keys, leg 23 anomaly); hash rule voided safely. Fix:
     canonical line shape in the Wake policy, or an explicit no-strict-parse rule.
  4. LOW @captain third disposal observed (leg 22): supersede-into-existing-scenario
     (promote would bind a bug, discard would condemn a shared seam); lifecycle table
     names only promote/discard.
  5. Observational: greenfield bootstrap = 10 legs to first product spec; the
     harbour-resume-gate deferral (leg 7) is the largest avoidable serialization;
     Captain-owns-harness-setup resolved the toolchain gap cleanly with user word.
  6. Observational: whole-deck equality cost profile confirmed (comment-only fix
     voided full record; custody chose a defensible full rerun when hand-off
     freshness had decayed two hops) - accepted cost of the no-impact-analysis
     standing decision, working as designed.

- 2026-07-12 pilot finding (MEDIUM-HIGH, doctrine seam): unplanked-seam remediation
  has no clean legal path at sea. Live sequence: Boatswain custody correctly ruled
  deck foul on an unplanked touched seam (js/app.js loadTodos), correctly refused
  commit and strike; operator dispatched Crew directly with the foul; Crew correctly
  REFUSED (no scenario reference = literal "No target. Crew stop."; Boatswain-to-Crew
  is not a sanctioned dispatch vector). Underlying gaps: (1) a missing plank reddens
  nothing - not a failing verification target, so QM's only Crew-dispatch ground is
  strained (green target + custody foul as "failure evidence"); (2) "report foul deck
  to the caller for Crew redispatch" assumes a live QM caller; in subagent reality
  that context is gone; (3) Crew's contract cannot receive a hygiene foul. All three
  dissolve if plank coverage/form enters the derived verification-conformance rule
  set as a red-able rule (same fix as the plank-form item above - one mechanism, three
  seams). Also observed: any post-record byte change (comment-only plank fix) voids
  the whole run record by whole-deck equality; the caller-hand-off evidence arm is
  the designed rescue - cost profile of the no-impact-analysis standing decision
  observed live and workable.

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

## 0.13.11 candidates (dk decisions pending)

- Plant-red timing (UPGRADED to MEDIUM, three divergent observations): pilot leg 6
  Shipwright planted at fit-out; pilot leg 9 QM re-planted at promotion; 0.13.10
  fit-out probe planted NOT AT ALL (derived the plank rules correctly, deferred proof,
  report silent). Two rules name two owners; agents resolve the ambiguity three ways.
  Candidate resolution: QM-at-promotion owns the plant-red adoption proof (the rules
  are not executable until QM binds their steps); fitting out derives rules and
  skeletons only, and step 3's "every derived check has been red once" gate rewords
  accordingly. Side benefit: removes plant-red cycles from the fit-out leg, serving
  the bootstrap-time directive. Needs dk's word (0.13.11).
- Greenfield fast path (ARCHITECTURE, dk's directive on bootstrap time): first voyage
  needs only the five required RIGGING values; defer full fit-out derivation (weather,
  conformance scantling, plank rules, step-usage, coverage) to the first harbour.
  Sequence: one interactive Captain conversation (intent + stack + provision +
  minimal rigging + specs + watchbill) -> product voyage immediately -> fit-out
  completes at harbour. Cost: voyage 1 sails without methodology checks. Estimated
  empty-repo-to-product-spec: ~65m (pilot) -> ~20-25m (0.13.10 + interactive
  Captain) -> under ~10m (fast path).
- Note for economy accounting: pilot legs 2/3/5 were a harness artifact - headless
  Captain made each user exchange a full leg; interactive Captain absorbs them.
- Scope-out confirmation rule (MEDIUM, dk's template-iteration question): Captain
  downgraded asset-normative language (spec's "must include todomvc-app-css",
  template "should be used as the base") to out-of-scope by section classification,
  reported it, but nothing gated the build on user confirmation - cost the 0/29 first
  oracle grade. Candidate: excluded sections of a user-supplied spec asset are open
  questions, not decisions; they stand as pending intent (skeleton or named
  CAPTAIN.md question surfaced in every report) until the user rules. Compounding
  causes, recorded: spec mixes contribution-process and product registers; sim-user
  "keep it simple" pushed the trim; and a FIXTURE GAP - pilot.md vendors only
  app-spec.md while its Template section incorporates the todomvc-app-template repo
  by reference. Pilot #2: vendor the template index.html as a second asset (amend
  scenarios/pilot.md with dk's word).

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
