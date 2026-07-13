# Captain notes - shipshape-shakedown workstream

## 2026-07-13 afternoon: pre-approved 0.13.11 probes ran TWICE; channel-integrity finding (HIGH)

1. HIGH channel-integrity finding (harness + process): the plugin snapshot is
   PROCESS-level and /clear does not refresh it. This conversation's Claude Code
   process dates from Jul 12 12:42, so wave 1's `shipshape:*` agents silently loaded
   ~0.13.8/9 text AND hooks despite 0.13.12 installed on disk (proof: 0.13.10 and
   0.13.11 marker phrases absent from every loaded skill text; live hook behaviour
   matched the old hook exactly, incl. denying `git add CAPTAIN.md`, which the
   0.13.12 hook allows by synthetic replay). RE-DATING of prior evidence: yesterday
   evening's "0.13.10 seam probes" ALSO ran this stale snapshot - batching MISS x2
   happened with NO batching arm in context (not a weak-MAY observation); supersede
   MISS x2 happened with a tag table offering only promote/discard (supersede entered
   the table in 0.13.10), so that miss is explained and the 0.13.11 supersede
   preference is genuinely untested; the "0.13.9 strike arm FULL PASS" was
   model-native (corroboration wording absent from all 12 Boatswain legs) and wave
   1's stale Boatswain MISSED the same strike, so the arm's first real firing is wave
   2's (text present, fired correctly). The hooks-vs-text misalignment findings stand
   (hooks really were old). Harness fixes shipped in THIS repo: AGENTS.md channel
   rule (mandatory marker-phrase verification; timestamps lie), probes.md channel
   note, preamble.md nested-spawn paragraph (validated live).
2. Wave 2 = the five pre-approved 0.13.11 validation probes on 0.13.12 TEXT
   (HEAD-text mode; identical reconstructed states, deck hashes byte-equal to wave
   1's): ALL FIVE PASS. (1) batching: ONE batched Crew dispatch carrying all 3
   refs+evidence, batched red census, commit 15b2f65; (2) Captain composed
   `git commit -m <msg> -- CAPTAIN.md` first try, notes-only commit 75833ab, 73s leg;
   (3) Boatswain: `:!CAPTAIN.md` deck diff, `git add -- CAPTAIN.md` content-blind,
   row-1 inherit zero runs, record-corroboration strike, commit 2dd9382; (4) QM
   re-derived the unplanked-seam foul itself per the 0.13.11 clause (one fewer leg
   than wave 1's nested-custody route), commit c930df1; (5) run-record lines
   canonical x4 incl. empty-record appends (the example line binds where key lists
   did not), and fit-out with ZERO plants, 3 skeletons + 5-rule conformance
   scantling, tree uncommitted, 26 inv vs 40 stale. Validation is TEXT-layer; the
   0.13.12 hook layer is synthetically ground-truthed; the integrated plugin-channel
   re-run is owed after a REAL process restart. States rebuild with ONE command:
   `bin/probe-states.sh <scratch-dir>` (self-contained from fixtures/probe-states,
   reproduces the wave deck hashes 13d9a2e/a545663 exactly; tested green 2026-07-13).
3. Economics on like-for-like states (dk's lens quantified): stale/incoherent wave 1
   = 11 legs, 180 inv, 4 hook denials, 1 doomed dispatch + SendMessage resume, 2/5
   failed outcomes. Coherent wave 2 = 9 legs, 115 inv (-36%), zero mistake/fix
   cycles, 5/5 outcomes landed. Coherence, not token thrift, was the whole lever.
4. NEW findings routed to dk, none shipped: (a) hook gap - `git -C <root> add --
   CAPTAIN.md` denied (strip patterns cover only bare `git add` forms); (b) hook gap -
   any prose mention of CAPTAIN.md in a compound command denied, incl. echo section
   labels that wave 2's textbook Boatswain naturally composed, so the best-behaved
   agent eats a spurious denial on the plugin channel; (c) commit-custody denial
   message leads with "Boatswain holds local commit custody" and steered wave 1's
   Captain into the doomed Boatswain route - put the pathspec form first; (d)
   record-append economy seam: both wave-2 QMs re-ran Crew-proven greens solely to
   append record lines (4 redundant runs) - either a Crew hand-off green is
   recordable or the re-proof is the record's standing price; (e) model-tier leak
   unchanged in HEAD-text mode (first spawn inherits, later spawns fall to session
   model) - dk owns tiering.
5. dk directive recorded (mid-run, 2026-07-13): outcome quality > latency measured in
   invocations and mistake/fix cycles > raw token volume. More-tokens-less-often for
   the same quality is a win. Folded into the METRICS audit lens.
6. Owed next session (after a real restart): integrated plugin-channel re-run of the
   five probes (wave-2 verdicts predict PASS; hook-shape gaps (a)/(b) may bite the
   Boatswain leg there - that is the point); supersede probe against text that
   actually lists it; the two 0.13.12 probes (scope-out gate, fast-path bootstrap)
   still await dk's nod.
7. NEW PROBE on dk's word (2026-07-13, mid-session ask): verification-boundary -
   verifies the Verification agreement's containment shape live: real creation of an
   expensive resource at ONE seam, tested for real at ONE step, never more than one
   provision per executing run (ambient reuse), dependent seams asserted through a
   spy tagged @exceptional-double, normal paths never faked. Spec in
   scenarios/probes.md; state = tidewatch6 from bin/probe-states.sh (instrumented
   provisionStation writes logs/provisions.log + 1.5s cost; markers are objective
   log-join counts, not report prose). Queued for the post-restart wave alongside
   the plugin-channel re-run.

## 2026-07-13: 0.13.11 SHIPPED on dk's word ("resolve all findings")

Doctrine 0.13.11 (26ca239) committed, pushed, installed (tests 186 green incl. 9 new
hook checks). This session's subagents stay snapshotted on 0.13.10; next session runs
installed-plugin 0.13.11 by construction. Per-finding resolution:
1. Notes custody -> hooks + text aligned: Captain commits notes pathspec-limited
   (`git commit -m <msg> -- CAPTAIN.md`, hook-allowed; the pathspec itself enforces
   notes-only whatever is staged); Boatswain gets exactly two content-blind forms
   (`git add -- CAPTAIN.md`, `:!CAPTAIN.md` exclusion), every other naming still denied.
2. Foul-to-fresh-QM -> resolved in text, not hooks: a foul is re-derivable (touched
   seam + missing plank is the same observed evidence), QM and Boatswain skills now
   say so; the dispatch-guard cap stands (it IS the bulkhead; hand-off-vs-discovery is
   string-indistinguishable). 2b proved the re-derivation path live.
3. Run-record schema -> canonical example line embedded in the Wake policy (the tw2
   imitation evidence says examples bind where key lists do not).
4. Batching -> SHOULD on one seam cluster; solos only when evidence cannot place the
   cluster; "solos on a seam the evidence already names shared are the expensive
   fallback, never the default."
5. Disposals -> promote-with-correction named in the tag table AND in the Captain
   skill's harbour-review step (root cause: Captain skill never listed supersede);
   preference rule added: supersede when an existing scenario already pins the seam.
6. Plant-red timing -> ONE owner: QM at adoption (promoted check made executable
   plants, reddens, removes, greens); fit-out derives without planting (bootstrap-time
   win); harbour plant exception survives only for production-only scantling reds.
7. Command fidelity -> Rigging read contract: run derived commands verbatim; only
   {scenario} and ## Tiers tags compose; invented tags are drift.
8. Model inheritance -> harness-level, documented: AGENTS.md + preamble now order
   explicit model pinning per dispatched leg (first-spawn-only inheritance recorded).
Harness: pilot.md now vendors app-template.index.html as a second Captain asset
(fixture gap from pilot #1 closed); lifecycle leg-1 markers updated to no-plant
fit-out.
## 2026-07-13: dk ruled the two design decisions; 0.13.12 SHIPPED

dk's rulings (2026-07-13): scope-out = BLOCKING GATE (an unconfirmed exclusion of a
user-supplied asset section blocks QM dispatch for that asset's work; pending
exclusions recorded as named questions in report + CAPTAIN.md); greenfield fast path =
ADOPTED (first voyage sails on the five required values from one interactive Captain
conversation, no methodology checks on voyage 1, first harbour completes fitting out
before its inventory); next-session validation = PRE-APPROVED.
Doctrine 0.13.12 (de24fa7) committed, pushed, installed; tests 186 green. Homes:
gate principle in the Asset policy + gate mechanics in Captain's before-QM bullet;
fast path in Shipwright Fitting out + Captain workflow + entry routing + write-scope
exception.

PRE-APPROVED by dk (2026-07-13): next session runs the five 0.13.11 validation probes
autonomously on the installed plugin channel - (1) crew-batching regression (expect
ONE batched dispatch now), (2) captain pathspec notes-commit arm, (3) boatswain
staging + :!exclusion arms under the new hook, (4) QM plank-gap re-derivation thin,
(5) record-line shape on an empty record + no-plant fit-out leg. Mine, classify,
update tally, commit. PROPOSED IN ADDITION (needs dk's nod, not yet covered by the
pre-approval): two 0.13.12 probes - scope-out blocking gate (Captain with an asset
whose section it would exclude; expect held dispatch + named question), and fast-path
bootstrap (empty repo + product intent; expect minimal RIGGING + specs + watchbill in
one Captain pass, voyage sails, timed against the ~40m baseline).

## 2026-07-12 evening: five pre-approved 0.13.10 seam probes COMPLETE (plugin channel)

Discharges the pre-approval below. Verdicts (full numbers and per-leg accounting in
METRICS.md "0.13.10 seam probes"): batching MISS (twice - tw1 sonnet QM ran 3 solo Crew
sequential on a seam it itself named shared; tw4 fable QM ran 2 solos on one new seam),
unplanked-foul PASS (Boatswain foul clean: no commit/strike/runs; thin-QM redispatch
detected the plank gap itself, Crew ACCEPTED the plank-only target, route closed with
commit 39e5639), supersede MISS (Captain chose promote-with-correction - rewrote the
skeleton's assertion to intended behaviour and promoted; supersede still never observed
live; fixture caveat: self-contained skeleton data invited a standalone scenario),
harbour-gate PASS (specs+watchbill authored in the review pass, zero deferral, zero
redundant regression, bonus full voyage to clean deck), one-blocker bootstrap PASS
(one blocker; one Captain cycle installed toolchain AND wrote values; full fit-out to
methodology-green in 5a 3.7m + 5b 36.1m; caught the npm `cucumber-js` squat).

Findings routed to dk, NONE shipped (doctrine untouched):
1. MEDIUM notes-custody hooks contradict 0.13.10 text: bash-custody.sh denies every
   internal-role command containing "CAPTAIN.md" (blocks Boatswain content-blind
   staging AND the validated `':!CAPTAIN.md'` diff-exclusion composition) and denies
   `git commit` to all but Boatswain (blocks Captain's sanctioned notes-only
   self-commit, observed denied live at tw5 20:20). Net: notes have NO legal path into
   a commit on the plugin channel; 5b's Captain diagnosed it and left notes untracked.
   Both 0.13.10 arms shipped in skills; hooks never updated. Meanwhile `git add -A`
   would sweep notes in silently - hooks block the careful forms, miss the careless one.
2. MEDIUM dispatch-guard thin cap (2500 chars, captain-seat dispatches to any
   shipshape:* target; QM exempt only as dispatcher) closes the verbatim-report
   hand-off INTO a fresh QM - the unplanked-foul redispatch vector. A foul is not a
   durable artifact, so a fresh QM cannot legally receive one; only the live-QM loop
   works (and did). Decide: intended (fresh QM re-derives; plank foul then only
   reachable once plank rules ride the conformance rule set) or add a role-report
   hand-off allowance for QM like Boatswain's.
3. MEDIUM (upgraded from LOW) run-record line schema: three shapes in three trees on
   one doctrine text (tw1 `target`/`deckState`; tw2 canonical - imitating the seeded
   example line; tw4 `targets`/`deckStateHash`). The Wake policy names exact keys and
   demonstrably does not bind; a written example DOES. Cheap fix: canonical example
   line in the Wake policy or a template in RIGGING.
4. Batching arm never fires (0.13.11 candidate): "MAY batch ... serial solo dispatches
   are the fallback where neither applies, not the default" reads as optional; both QMs
   defaulted to solos even after naming the shared seam. Candidate: SHOULD-strength or
   an explicit decision rule at dispatch time. This is dk's top economy lever (tw1 paid
   16 suite runs and 3 Crew spawns where a batch takes ~8 and 1).
5. @captain disposal table incomplete: observed a fourth shape, promote-with-correction
   (rewrite assertion at promotion). Supersede remains unobserved after two designed
   invitations. Candidate: name the fourth disposal, or fold it into supersede wording.
6. Plant-red timing: FOURTH divergent observation (tw5 fit-out Shipwright planted at
   fit-out: setTimeout plant in verification + PERTURBATION plant in src, both proven
   red then removed; tw5 QM ALSO planted nock( during verification). Strengthens the
   existing 0.13.11 MEDIUM candidate.
7. LOW derived-command fidelity: tw4 role hand-composed `--tags "not @captain and not
   @shipshape and not @shipwright"` (nonexistent tag) instead of running `focused`
   verbatim; harmless here.
8. Model inheritance (harness, dk owns tiering): nested UNSET spawns inherit the
   parent's model only for the parent's FIRST spawn; later spawns silently fall to the
   session model. 145/409 invocations (35%) escalated to fable-5 despite sonnet
   dispatch. Explicit `model` pin works (tw3 proof). Fable nested legs ran leaner in
   invocations (Crew 7-9 vs sonnet 11-12).
Positives: 0.13.9 strike corroboration arm FULL PASS live (10-inv leg, zero
strike-runs); contamination enforcement caught real breaches at three layers (agent
refusal x2, hook block x2) at falling cost (hook = 0 tokens); custody-foul Boatswain
9-inv/100% new best; QM inherited run-record greens twice (zero redundant
classification); polling ~7 waits/31 legs, structural to async spawns.

Harness fixes shipped in THIS repo (operator-owned): fixture gitignores coverage/
(operator error had committed c8 wake into all probe bases; three Boatswains handled it
three defensible ways), scaffold.sh sets repo-local Sim Operator git author (the
dispatch author line caused one QM contamination refusal - drop it from dispatches),
probes.md gains the five seam probes.

## Session close 2026-07-12 (restart-ready)

Doctrine 0.13.10 (c045b46) shipped, pushed, installed; doctor audit clean: one live
install (plugin channel, user scope), all six skills + templates hash-match upstream
main, all 10 hook scripts executable, no skills-channel copies, no shadowing; ~25
inert older plugin-cache dirs are CLI-managed cruft, harmless. Next session runs
installed-plugin mode at 0.13.10 by construction.

PRE-APPROVED by dk (2026-07-12, "probe all in next session"): probe every unprobed
0.13.10 seam autonomously, no focus question needed. Five probes, cheapest-first:
1. Crew batching arm: one watch, 2-3 targets red on ONE seam cluster -> QM ->
   expect one batched Crew dispatch carrying all refs+evidence (not serial solos).
2. Unplanked-foul route: voyage state with one touched seam missing its plank ->
   Boatswain foul -> QM with foul hand-off -> expect Crew dispatch with
   step-usage-derived scenario ref + foul as evidence, and Crew ACCEPTS.
3. @captain supersede: harbour state, skeleton documenting a defect an existing
   scenario should pin -> Captain review -> expect supersede recognized as legal.
4. Harbour-gate: complete inventory, uncommitted harbour output, product intent in
   dispatch -> Captain -> expect specs+watchbill authored in the same review pass.
5. One-blocker bootstrap: empty repo (README only) -> Shipwright fit-out -> expect
   ONE blocker naming stack values AND toolchain together; one Captain cycle
   resolves both.
Mine, classify, update tally, commit. THEN surface the 0.13.11 queue (plant-red
timing, scope-out gate, greenfield fast path, pilot.md fixture amendment) - those
still await dk's word; probing does not ship them.
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

## 0.13.11 candidates (superseded 2026-07-13: plant-red SHIPPED in 0.13.11 per the
resolution above; pilot.md fixture amendment DONE; scope-out gate and greenfield fast
path remain open below)

- Plant-red timing (RESOLVED 0.13.11; kept for history - three divergent observations): pilot leg 6
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
