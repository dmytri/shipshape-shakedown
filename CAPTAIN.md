# Captain notes - shipshape-shakedown workstream

## 2026-07-18 (fable session): PILOT #4 RETROSPECTIVE EVAL (dk's ask: "eval last pilot") - zero legs dispatched; one HIGH harness finding (transcript durability is FALSE), AGENTS.md corrected

Entry: /shakedown, deck reported (0.13.32 = last baseline, nothing moved), dk's
focus answer: "eval last pilot" = pilot #4. Cheapest covering scenario = analysis
over the banked record, no simulation. Deck housekeeping: pushed the stranded
efficiency-battery commit 651766f (cockpit was ahead-1; last session recorded but
never pushed).

**HIGH HARNESS FINDING, and it reshaped the eval: the transcript-durability
assumption is FALSE.** Evidence: nothing before 2026-07-15 survives anywhere under
`~/.claude/projects` (oldest survivor is a jolly session dir dated Jul 15; the
shakedown project holds ONLY Jul-18 sessions); `~/.claude/backups` empty,
file-history trivial; the todopilot5 sim tree lived in a since-wiped /tmp
scratchpad. Gone forever: pilot #4's raw transcripts (Jul 14), GOAL-2's 14-leg
session 6bdcdbf3, waves 1-5 raw legs. Observed retention ~3-4 days (or a VM
lifecycle event - indistinguishable from here; either way durability cannot be
assumed). Consequences: (a) pilot #4's P/N/Neg fold and worth densities are
PERMANENTLY unrecoverable (METRICS.md pilot-#4 section now says so - the fold was
never done, only "held for the eventual fold" like the pilot-#2 fragment); (b)
GOAL-2 instrument 2 ("retrieval graph over the task transcripts already banked")
is DEAD as a retrospective - it can only run same-window or on fresh legs; (c) the
mine-on-every-notification rule is not just a stall-detector, it is the ONLY
moment the data exists. Harness fix APPLIED operator-side (same class as the
wave-6 fetch-first fix): AGENTS.md durability text corrected to mine-same-session
+ bank-derived-numbers. ROUTED, not done: whether to bank raw leg jsonl into the
cockpit repo (MBs/wave) or accept METRICS-only survival - dk's call.

**The eval itself, four axes per scenarios/pilot.md, from the durable record:**

1. OUTCOME: effectively FULL PASS - best of the four pilots. First grade 24/29 is
   the best cold open ever (#1: 0/29, #2: 21/29, #3: 23/29); 28/29 at iteration 2;
   the residual resolved as an upstream-mislabeled check (every framework in the
   oracle's last real update wave already exempt) -> dk-ruled exemption fixture ->
   "All specs passed!" Pilot #4 is the only pilot that CLOSED its residual rather
   than parking it.
2. INVOCATIONS: ~232 inv to 28/29 - the generation trend is 717 (#2) -> 440 (#3)
   -> 232 (#4), roughly halving per doctrine generation on the like-for-like
   reach-28/29 metric. Full run ~454, of which the iteration-3 regression detour
   cost 185 inv (41% of the run); the pure detection+repair chain AFTER the broken
   commit landed is 142 inv. That is the measured price of ONE custody escape, vs
   the 0.13.28 fix's standing price of +5 inv per support-touching custody leg:
   the fix breaks even if it prevents one escape per ~28 such legs. Hindsight also
   prices iteration 4's plateau confirmation at 38 inv - not waste under the
   quarantine rule (mid-run oracle forensics are banned), and the exemption
   fixture means no future pilot pays it again.
3. TOKENS: ~12.5M cache / 90k out to 28/29 (-55% cache vs #3's 27.9M); full run
   ~25.2M / 204k. Worth densities: unrecoverable, see above.
4. FIDELITY: hits - 0.13.23 plank-join disposition fired live in a real voyage
   (malformed plank -> Crew redispatch, not harbour parking); the planted-red
   adoption proof owed since 0.13.19 closed; first real scantlings in a pilot;
   quarantine held every leg; QM refused a contaminated dispatch; 100% sonnet;
   content-blind CAPTAIN.md hook live under real conditions. Misses - custody
   recheck-selection missed the same shared-support regression TWICE (the harbour
   net caught it, custody did not); QM's Monitor instinct x2 (self-caught); Captain
   declared-not-provisioned rigging deps (structural, every greenfield); runner
   narration decayed without an external check (2nd instance of the stated-once
   class). 0.13.25's own headline change (Crew approach-cap) was NEVER exercised -
   Crew converged on every fix; still unexercised anywhere as of today.

**Finding afterlife - every pilot #4 finding reached a terminal state; the yield
was 3 routed findings -> 2 doctrine ships + 1 standing watch, 3 weak findings ->
evidence-based do-nothing dispositions, 1 oracle fixture, 1 runner-architecture
hardening (pilot.md timer wakes):** finding 1 (custody blast radius) -> 0.13.27/28,
and the tw17/tw18 probes could NOT reproduce the miss even hardened to three
broken consumers - pilot #4 remains the ONLY live evidence of the defect class it
fixed, which is exactly why losing its transcripts stings; finding 3 (rigging
deps) -> 0.13.28 consumer-routing, downstream-validated in wave 6 + the battery
(deriving roles install toolchains, zero rigging-blocker round-trips observed
since); finding 2 (Monitor instinct) -> watch, deny-the-class-never-Monitor-alone
rider stands.

**The ONE pilot #4 number still open: the +5 inv/leg custody price of 0.13.27/28
("watch across the next pilot") has no post-fix pilot-scale measurement - it waits
on the owed 0.13.26-0.13.32 TodoMVC pilot (#5), which would also be the first
possible exercise of the Crew approach-cap.** Queue otherwise unchanged: dk's
ruling owed on the two RIGGING.md findings (Dependencies slot, gplint lint-slot);
wave-7 A/B/C on dk's nod; pilot #5 owed at integration scale. NEW routed question:
raw-transcript banking policy (above).

QUEUE RE-ORDER (dk ruled, 2026-07-19): **wave-7 A/B/C is DEFERRED until yoink is
ready** - arm C needs a seaworthy yoink and the wave-6 record already said
"yoink seaworthiness is ours to finish first"; the wave folds the yoink gate,
the architecture.md gate and the economy target, so it waits as one unit rather
than running crippled. Resulting order: (1) thin banking layer into standing
procedure - awaiting dk's word; (2) dk's ruling on the two RIGGING.md findings
-> ship 0.13.33 -> cheap spot-validation; (3) PILOT #5 moves AHEAD of wave-7
(runs on 0.13.32/0.13.33 text; closes the +5 inv/leg custody-price watch and
first-exercises the Crew approach-cap); (4) wave-7 when yoink is ready; (5)
instrument-3 matrix rides on banked pilot-5/wave-7 transcripts, measure-don't-
move per dk's standing ruling.

ADDENDUM 2026-07-19, cause CONFIRMED on dk's question ("is it a vm-cleanup of
tmp?"): NO - neither /tmp cleanup nor app pruning. Filesystem birth times: this
home dir 07-14 17:36, both repo clones 07-15 13:07/13:31 - **this VM is younger
than pilot #4**. The transcripts were never here; pilots #1-#4/GOAL-2/waves 1-5
ran on a previous exe.dev VM whose disk is gone. No cleanupPeriodDays configured
(default ~30d), so single-VM retention was never the problem. Also explains wave
6's 38-commit-stale clone. Consequence for dk's gitignore idea: a gitignored
in-repo copy dies exactly the way the transcripts died - only committed-and-pushed
content survives VM replacement. AGENTS.md corrected accordingly.

ADDENDUM 2 same day, backup search via ~/swamp (dk's ask) - DISCHARGED, verdict
definitive both ways: (1) pilot #4 is UNRECOVERABLE from backups - the BorgBase
account holds 7 repos and none was written between 2026-05-06 and 2026-07-15;
the old VM never backed up (vykar was first configured on THIS VM 07-15 ~14:07,
first snapshot 07-15 13:58, host telnik, and that earliest snapshot contains no
.claude/projects at all). (2) Going FORWARD the exposure is largely closed
without committing raw jsonl: vykar backs up all of /home/exedev to BorgBase
(repo ticumlna) on a frequent cron, .claude/projects included (verified in the
latest snapshot: 203 entries incl. the wave transcripts), retention
24h/7d/4w/6m - so raw transcripts that live >1 backup interval on this VM are
reachable for ~6 months via `vykar restore`/`vykar snapshot find`, surviving VM
replacement (recovery workflow exists in ~/swamp). Revised banking
recommendation: commit the THIN layer only (per-leg mine.sh summaries + P/N/Neg
folds in data/, KBs); rely on BorgBase for raw-transcript reach; drop the
commit-gzipped-raw idea. Caveat that keeps the thin layer mandatory: BorgBase
retention thins to monthly after 4 weeks, and anything needed past ~6 months or
analysis-ready must be in the repo.

## 2026-07-18 (sonnet session, same day as wave 6): efficiency battery + 0.13.32 spot-validation run, MIXED gate, two findings routed, wave-7 deferred on dk's word

Entry: dk asked for /shakedown pilot; deck check showed both queue items (efficiency
battery OWED since three ships landed - 0.13.30/31/32 - and the 0.13.32 plugin-channel
spot-validation) still open, plus wave-7 (yoink/architecture.md/anchors A/B/C)
sketched but not run. dk's word: wave-7 later, proceed on the two cheaper items, with
emphasis on latency/instruction-coherence/invocation-count analysis. Full pilot NOT
run this session - "pilot" as a /shakedown argument routed to the cheaper queue items
first per the standing doctrine->probes->pilot ordering, confirmed with dk before
spending.

**Deck at session start:** both repos clean and level with origin (`git fetch`
confirmed on this repo AND `~/shipshape` before anything else, per the wave-6
harness fix). Installed plugin 0.13.32 (`ac08582`), installed 07:13:04 UTC. This
session's own Claude Code process started 09:08:18 UTC - postdates the install, so
the installed-plugin channel was a live candidate from the start; verified
empirically anyway (tw2's transcript carries 0.13.31 marker phrases before any
greenfield leg ran, confirming the cache is serving current text, not a stale
snapshot).

**Ten legs, all sonnet-pinned, installed-plugin channel, dispatched in parallel,
mined on every notification, tree-verified (not report prose):** efficiency battery
(tw1 crew-batching, tw2 notes-commit, tw3 notes-arms, tw4 plank-gap, tw5 no-plant
fit-out, tw13 slow-census, fastpath-bootstrap) + 0.13.32 spot-validation (G1
greenfield opening, a TS bootstrap re-run, a NEW plain-JS bootstrap variant to check
`jsdoc -X` fires on the greenfield path too, not just legacy fit-out). Full numbers,
per-leg table, and findings in METRICS.md's "Efficiency battery + 0.13.32
spot-validation" section - not restated here in full.

**Wave total: 280 inv / 23.42M cache / 182.6k out / 17m37s wave wall (parallel).
100% sonnet, zero model leak** - confirmed by grepping `message.model` across all ten
transcripts including nested Crew/Boatswain children, every single entry
`claude-sonnet-5`.

**GATE VERDICT: MIXED, not clean-green like wave 5.** tw1/tw3/tw4 beat their wave-5
baselines outright (tw3 particularly: -55% inv, -58% cache). tw2 and tw5 blow the
efficiency battery's own ~10% bar - tw5 substantially (+24% inv/+63% cache/+77%
wall). Read as doctrine SCOPE growth (Shipwright now derives 7 methodology checks,
up from ~4-5 in the wave-5 era, producing 9 `@conformance` skeletons this run) rather
than a specific regression - no single doctrine version between wave 5 and 0.13.32
obviously owns it - but it is real, it compounds every fit-out leg going forward, and
it is stated plainly rather than absorbed into a vague "drift, watch" line.

**Two findings routed to dk, NOT shipped:**
1. **MEDIUM, reproduced 2/3 legs: `RIGGING.md`'s `## Dependencies` slot left
   literally `none` on the TS bootstrap and fastpath-bootstrap legs** despite each
   installing multiple confirmed tools (biome, cucumber, c8, gplint, tsx,
   typescript, @types/node all present in `package.json` on the TS leg; the
   `Dependencies` section empty on both). js-bootstrap got this right. The
   minimal-RIGGING letter says every confirmed-tool slot populates; `Dependencies`
   silently didn't, majority of the time it was exercised this wave.
2. **LOW-MEDIUM: the RIGGING.md schema has no distinct command slot for feature
   lint (gplint) separate from code lint (biome).** js-bootstrap proved gplint runs
   clean in its own transcript, but `RIGGING.md`'s `## Commands` carries only one
   `lint:` key (biome). Reproduced identically wherever gplint was confirmed - looks
   like a template/schema gap (the fast-path text names feature lint and code
   lint/format as two separate offer categories; the RIGGING.md shape only has room
   for one `lint` key), not a per-leg miss. Needs a ruling: fold gplint into `lint`
   (chain both tools) or add a second key.

Both are watch-only until dk rules; nothing shipped this session (no doctrine changes
were made or needed - this was a validation-only run).

**Positive markers, all tree-verified, matching the METRICS.md section in full:**
bulkhead hook self-heal live again (tw3, `grep -rn` denied -> `rg -n` retried
next invocation, one real catch); the slow-census pilot-#2-deadlock regression check
stayed clean at 0.13.32 (zero Monitor/pgrep/sleep-poll/`run_in_background` - the
harness's own belt-and-braces lines were deliberately withheld from tw13's dispatch,
so this is doctrine text alone holding); 0.13.31's tag-exclusion-survives-
recomposition fix held under real load (ts-bootstrap's five verification commands all
kept `--tags "not @captain and not @shipwright"` through a `node --import tsx`
wrapper); `plank-inventory` correctly `none`-on-TS / `jsdoc -X`-on-JS in both spot
legs, zero ts-morph/glue-script installs (wave-6 finding (b) stays closed); zero
cockpit reads, zero redundant confirmation runs (tw1/tw4 both inherited Crew's
carried green).

**QUEUE, updated:** efficiency battery and 0.13.32 spot-validation are now DISCHARGED
(this entry). Next session: (1) dk's ruling owed on the two findings above; (2)
wave-7 A/B/C (yoink orient-plan / architecture.md / token-economy target) on dk's
nod, still not run; (3) a full TodoMVC pilot is owed at some point to validate the
accumulated 0.13.26-0.13.32 doctrine at integration scale - not requested this
session, still open.

## 2026-07-18 wave 6: onboarding overhaul 0.13.30-0.13.32 SHIPPED + probed 3/3; yoink/architecture.md/anchors discussion recorded; OWNED: session ran on a stale cockpit clone

OPERATOR MISS FIRST: this session bootstrapped from a local clone at 88a1bbd, 38
commits BEHIND origin - pilots #2-#4, GOAL 1/2, and every 0.13.14-0.13.29 record
were in this repo all along; I mis-read the gap as "doctrine advanced outside the
cockpit" and three now-superseded commits (kept on local branch backup-wave6)
recorded a wrong wave number and a stale queue. Caught at push-reject; this
section is the corrected record. ~/shipshape itself WAS level with origin, so the
0.13.30-0.13.32 ships are unaffected. Harness fix: AGENTS.md bootstrap now fetches
THIS repo before the deck check.

Entry: dk invoked /shipshape:captain here; cockpit invariant held (declined to run
the role against this repo), dk redirected to shakedown with a real-use focus:
rough onboarding on new repos, four failure modes from ~/yoink (2026-07-17,
opencode, skills channel, vendored skills = 0.13.29 HEAD; sessions mined from the
opencode sqlite DB - new evidence source). dk's word: "yes, and probe".

1. 0.13.30 SHIPPED (121dfee; tests 213 green incl. 4 new hook cases): greenfield
   fork (no RIGGING + no production code -> discovery + fast path, NEVER
   Shipwright), initial commit = Captain's own bootstrap action (four text homes +
   bash-custody unborn-HEAD allowance), clean-deck gate binds at dispatch
   boundaries never conversation (harness-install artifacts ignore-or-fold), stack
   discovery names dialect/version verified live, batched quality-toolchain offer
   with confirmed-tool slot population (amends the 0.13.13 minimal-none letter on
   dk's explicit trade).
2. Probed same session, HEAD-text, sonnet-pinned, 3/3 PASS (G1 greenfield opening
   FULL PASS; G2 bootstrap PASS w/ findings; L1 legacy routing PASS). Hook replay
   vs installed cache 6/6. Numbers in METRICS wave 6. Model-pin note: sonnet
   132/132 incl. post-async-child continuations - the async-resumption fall did
   NOT reproduce under HEAD-text general-purpose spawns; likely plugin-channel
   agent-type specific.
3. Findings (a) tag-exclusion drop on recomposition and (b) ts-morph glue-script
   write-scope breach RESOLVED same day on dk's rulings: 0.13.31 (a26b210)
   Node-stack catalog (jsdoc -X on plain JS proven live; none-on-TS for jsdoc's
   silent-empty false clean; Biome GritQL plugin seam confirmed in 2.5.4; ts-morph
   out until needed; no-glue guard; tag-exclusion recomposition rule). 0.13.32
   (ac08582) ASCII style fix - OWNED MISS: 0.13.31 pushed with style.sh red (test
   loop swallowed the failure), caught post-push, ALL GREEN verified before the
   0.13.32 push. Installed 0.13.32; still open: (c) LOW biome sweep reformatted a
   committed operator file unreported; (d) obs: verification slot self-populated,
   L1 Shipwright staged its own deletion.
4. yoink bonus observations (real use): QM bulkhead held twice (refused a
   resumed-context dispatch); Captain wrongly paused a voyage on a status
   question; yoink deck = ONE commit with a whole voyage untracked (skills
   channel, no hooks) - custody cadence worth a look at its next harbour. yoink
   picks up 0.13.32 on its next `skills` re-vendor; skills.sh channel needs no
   version bump (serves the repo).

DESIGN DISCUSSION (dk, recorded; nothing shipped from it):
- yoink (@dk/yoink): verdict GOOD IDEA - attacks the retrieval class (iterations
  ARE latency; savings compound since every round re-prefills prior context).
  Converges with the existing GOAL-2 record: bin/plan.py already measured 14.7%
  of invocations as compilable waste, and the ballast probe proved context bulk
  is a CAUSAL rung-2 cost. Custody answered: stdin-heredoc form
  (`yoink - <<'PLAN' ... PLAN`) keeps the whole plan inside the Bash command
  string, bash-custody inspects unchanged, zero bypass; plans embed in skills.
  Coupling accepted (npx assumed; @dk/yoink adds no new dep class). Side effect
  valued: plans are explicit retrieval allowlists; labeled multipart feeds report
  fidelity. ADOPTION GATE = wave-7 A/B, orient-plans arm vs baseline, counting
  invocations + mistake/fix cycles (predicted: hygiene/QM legs -30-40%, bootstrap
  -15-20%, Crew flat). yoink seaworthiness is ours to finish first.
- architecture.md (https://architecture.md/ + timajwilliams/architecture
  prompt.md): adopt THE STANDARD WHOLE or not at all (standing decision below).
  The prompt's evidentiary rules are our Articles already; intent-bearing
  sections fill TRUTHFULLY in a spec-driven repo ("decisions homed in
  features/**; no in-tree roadmap") - standard-conformant one-liners, never a
  pruned house variant; SS14 Testing Strategy is the tiers/planks slot. Ours is
  mechanism/cadence only: Shipwright derives at fit-out (scale-gated), refits
  each harbour, jolly-style executable conformance pin (jolly proved it live:
  day-one drift caught, pinned by methodology-conformance.feature:80). CAUTION
  from GOAL 2: the doc ADDS inbound prefill weight (+0.84s/inv causal ballast
  finding), so it must EARN its weight in saved retrieval rounds - buy with
  wave-7 numbers.
- Semantic anchors (llm-coding.github.io/Semantic-Anchors): adopt as REGISTER,
  wording ship-ready on dk's word: Captain unpacks a user-named anchor into
  concrete scenarios (anti-XY decompression); Shipwright names an observed
  pattern by its established anchor PLUS tree evidence. Bare anchors stay banned
  from durable artifacts (existing standing decision generalized); never vendor
  the catalog; terms stay canonical or the cluster does not activate.
- Wave-7 sketch: one real-shaped state, arms = baseline / ARCHITECTURE.md /
  ARCHITECTURE.md + yoink orient plan; measure downstream retrieval invocations,
  wall, mistake/fix cycles, and inbound weight (instrument 1 exists). Folds the
  yoink gate, the architecture.md gate, and the economy target into one probe.

QUEUE next session (0.13.32 markers: captain "never dispatched at a greenfield
repository" + "never glue-scripted at bootstrap" + "however it is recomposed";
shipwright "a false clean, so derive" + "so is the initial commit"; boatswain
"whose own bootstrap action the initial commit is"; entry routing "nothing to
derive"): RESTART, then (1) efficiency battery - OWED, three ships landed since
the last run per the standing dk directive; (2) plugin-channel spot-validation of
0.13.32: greenfield opening leg (unborn-HEAD commit allowed by hook LIVE), a TS
bootstrap re-run (tags survive recomposition, plank-inventory stays none, no glue
script), a plain-JS bootstrap (jsdoc -X populated); (3) wave-7 A/B/C on dk's nod.
Sonnet-session pilots remain the standing pattern (this session was fable).

## 0.13.27 + 0.13.28 SHIPPED (0a26d67, 2a9e59a), pushed + installed, 2026-07-14. RESTART before any plugin-channel leg.

Two of pilot #4's three routed findings are now closed by doctrine. dk ruled both in-session.

**FINDING 1 CLOSED - a support edit's blast radius is its tier.** Boatswain's recheck table filed
verification support code with deletions and configuration, proved by "static discovery plus the
derived `typecheck` and `lint` gates ... they redden on a broken load or import." That clause is a
true statement of what those gates catch and the rule treated it as SUFFICIENT. Support code is not
non-executable: it runs inside every scenario whose steps route through it, and a behaviour change
to it loads, imports, typechecks and lints exactly as the old one did. Support code carries no
planks, so the plank join structurally cannot reach it - that is how it landed in the catch-all row.
A touched support hunk now selects the tier's enumeration sweep. dk chose the simple safe shape
(any support hunk -> broad) over the cheaper modify-only variant, accepting the cost.

**The row-order hole, caught by reading before probing.** 0.13.27 put the support row AFTER the
inherit row, and inherit reads "a fresh focused green covering the hunk ... run nothing." Pilot #4's
hand-off DID carry a fresh focused green exercising the touched `world.js`, so the inherit row was
satisfiable and the new row unreachable: the fix would not have bitten. 0.13.28 puts the support row
first and states no focused green covers it. **A rule can be correct and still be dead if a row
above it fires first.**

**FINDING 3 CLOSED - the rigging's own dependencies are rigging.** "Crew installs a selected
dependency" was a CIRCLE for the runner: Crew is dispatched only for a failing target, no target can
fail until the runner is installed, so the runner can never reach Crew. Every greenfield paid a
Captain->Shipwright refit round-trip (14 inv, pilot #4) to break it. dk's words: "rigging dependency
does not need to be installed by crew, eg cucumber itself, that just burns invocations pointlessly."
A dependency now routes by its CONSUMER: the runner, tier drivers, and quality-gate tooling are
installed when the rigging is fitted (Shipwright at fit-out, Captain on the fast path); Crew installs
only what the implementation itself consumes. Shipwright installs through the project's package
manager and blocks to Captain only for what that manager cannot provide, such as the runtime itself.
Plus check-precedence applied to the derivation: before `RIGGING.md` is written the deriving role
runs the runner once through a derived command. **A derived command that has never run is a claim,
not a value, and the role that inherits the claim pays for it.**

**FINDING 2 NOT SHIPPED, deliberately.** QM's Monitor instinct: two instances, both SELF-CAUGHT by
QM's own doctrine before any stall. The text is working. The belt-and-braces version is mechanical
(deny Monitor in the hook for internal roles) - plugin work, zero doctrine words. Routed, not written.

### THE A/B IS A NULL RESULT. The old text did NOT ship the break. Say so plainly.

New state, keep it: **tw17** (shared `formatClock` helper in `features/support/world.js`, widened to
serve a new spec, breaking `tides.feature` - the file NOT declared beside the change; declared work
2/2 green, static gate blind) and **tw18** (same, hardened: THREE broken consumers across three
support files). Builders in the session scratchpad; fold into `bin/probe-states.sh` if kept.

| Leg | Doctrine | Route to the answer | Inv | Cache | Outcome |
|---|---|---|---|---|---|
| tw17 GATE | 0.13.27 | quoted the new row, ran the **broad sweep** | 14 | 760k | Deck foul, no commit |
| tw17 control | 0.13.26 | read the one consumer, **guessed** the scenario, focused run | 9 | 422k | Deck foul, no commit |
| tw18 control | 0.13.26 | grepped 4 consumers, ran 3 focused runs | 9 | 457k | Deck foul, no commit |

**Zero commits in all three arms, tree-verified.** The probe CANNOT reproduce pilot #4's defect even
with three broken consumers in three files. A careful sonnet Boatswain gets there without the fix.
Pilot #4's two live misses (one shipped a real regression) remain the ONLY evidence the old row ships
regressions - real, tree-verified, but under load, and not reproduced here.

**What the probe DID establish, and it is worth more than the result it was fishing for.** Both
controls, independently and unprompted, declared their own row's proof VOID and overrode it: *"typecheck
and lint are both `none` in RIGGING.md, so that proof is void, and static discovery cannot see
behavioural drift in a widely shared helper ... I ran the three non-watch consumer scenarios for real
rather than trust the row's stated proof alone."* The table opens **"Recheck selection is a lookup, not
a judgment"** - and to be correct, both roles had to stop looking up and start judging. **A rule that
well-behaved roles must disobey in order to be right is defective whether or not they happen to disobey
it.** On any project with `typecheck: none` and `lint: none` the old row's proof was literally nothing.
The fix makes the override into the lookup. **Cost, honestly: +5 inv / +339k on a support-touching
custody leg.**

### VERBOSITY SWEEP: 352 words nominated (1.3%), NOT TAKEN. The rejections are the finding.

Doctrine-wide sweep across all six skills: 20 nominations, 352 words, ~1.3% of 27.2k. Almost all of it
role skills restating shared rules. **Not taken, and the harness's own rules say why:** that is the
token rung, the lowest on dk's ladder; "preserving tokens is not a major goal"; the matrix nominates and
never condemns; anything flagged gets a probe before it gets cut. Rejected outright:
- **the four Final-report "every tree claim is a command's answer" lines** - this is the 0.13.13
  report-fidelity rule and it FIRED IN ALL THREE LEGS RUN TODAY ("No claim in this report is
  by-read-only"). Its value is a false claim that never got made. Textbook load-bearing rule.
- **Crew's anti-gold-plating enumeration** (speculative edge cases / premature DRY / YAGNI /
  opportunistic cleanup -> "no refactors or dependency swaps") - guts the guard on the role most prone
  to the fault, to save 12 words.
- **Boatswain's check-precedence restatement** - both controls DID run the plank join; whether that came
  from the role skill or the shared Articles is untestable without a probe.

Applied only the two unambiguous cases, ONE FILE SAYING THE SAME THING TWICE (no rule-ownership question,
no re-homing): Captain's Voice restating its own opening line, Boatswain's hygiene note restating its own
Final report. 34 words.

### DISPOSITIONS (dk ruled, 2026-07-15): clear the board WITHOUT touching doctrine. Recommendation was do-nothing on all four; recorded so no future session re-litigates or naively acts.

- **Finding 2 (QM Monitor instinct): WATCH, do not hook naively.** Self-caught 2/2 under current text
  (0.13.16 wait rule + 0.13.17 parallel-children). The obvious fix - a PreToolUse hook denying `Monitor`
  for internal roles - is FEASIBLE (matchers take arbitrary tool names; role-scoping precedent exists in
  bash-custody) but is a **whack-a-mole trap, pilot-#3-proven**: a QM blocked off Monitor invented a
  broken Bash transcript-poll instead. The only complete mechanical fix denies the whole WAIT CLASS
  (Monitor + `pgrep`/`kill -0`/sleep-loops/transcript-result-greps), which is real design + careful test
  for a class that currently self-corrects. Not worth it now. **If ever revisited, deny the class, never
  Monitor alone.**
- **Partial-watch-strike: NON-FINDING, reclassified.** Original write-up called it invocation waste
  (a redispatched QM re-verifies a part-red watch's green entries from scratch). On reflection it is
  correct behaviour, not waste: Crew fixing the watch's red MOVES the deck, and re-running the greens is
  exactly the regression net the blast-radius finding (0.13.27/28) just argued for. If the deck did NOT
  move, the run-record inherits them by hash equality. Current behaviour is right both ways. Closed.
- **Exit-code-blind `timeout N | tail`: WATCH.** Never misfired. A fix means legislating how roles
  compose run commands = command-drift risk. Not worth a rule for a latent that has not bitten.
- **Deletion/config recheck row vs `typecheck: none`/`lint: none`: CLOSED, not a hole.** Verified live
  (2026-07-15): `cucumber-js --dry-run` load-checks every support/step module, so a broken import reddens
  even with both gates `none` - the row lists static discovery FIRST and it answers the load question. The
  support-code hole was unique because load-success != behaviour-preserved for code that runs inside
  scenarios; a full strict typecheck was verified to PASS the `HH:MM -> HH:MM:SS` helper (return type still
  `string`), so requiring the gates would NOT have caught pilot #4. The support fix depends on no gate
  being configured, by design. Only theoretically exposed on a non-Gherkin stack with no dry-run; not
  hardened (speculative).

### RECORDED, not open

- **Fixture defect found by the gate leg, unprompted and correct:** my tw17 runrecord wrote
  `"command":"focused"` instead of the full command string; the role ruled the line VOID per the Wake
  policy's record shape. Fixed in tw18's builder. The fixture was wrong; the role was right.
- **Both legs flagged a write-scope question I planted without meaning to:** the hand-off said "Crew
  advanced ... the verification support", but verification support is QM's write scope, not Crew's.
  Both roles caught it. Good behaviour, not a finding.
- **Operational, not a decision: RESTART owed before any plugin-channel leg or pilot.** This process
  snapshotted 0.13.26; 0.13.27/0.13.28 text runs only in HEAD-text mode from here. HEAD-text doctrine
  work needs no restart.

## 0.13.26 SHIPPED (7727de7), pushed + installed, 2026-07-14. RESTART before any plugin-channel leg.

**0.13.26 = 0.13.25 + Jolly's bulkhead fix.** `.ignore` only covered ripgrep/ag traversal,
never grep, so six vectors reached `CAPTAIN.md` through the Bash custody hook untouched:
`rg --glob`, `rg --no-ignore`, a shell glob in the path list, bare `grep -r`,
`grep --include`, `grep` with a shell glob. Two live QM roles were contaminated by this in
Jolly's session before the mechanism was understood. Fix denies the six leak vectors,
leaves 8 proven-safe search/build forms untouched (`rg` plain/`-t md`/`--hidden`, `rg` on a
named dir, `grep` on a named file, `rg` piped to `grep`, ordinary builds, cucumber focused
runs), scoped to internal roles only (Captain unaffected). Proven against a spliced copy
first (`incoming/jolly-bulkhead/`, 15/15 cases pass) before landing in the real hook.
Tests 209/209 green (bulkhead 10, homes 46, hooks 131, map 18, style 4).

## PILOT #4 (2026-07-14, sonnet, installed-plugin channel, doctrine 0.13.25, todopilot5/pilot5)

First pilot since Goal 2's stable-release baseline. Scaffold to first fully-green watchbill:
**~189 inv**. First reached 28/29 oracle (iteration 2, in-place DOM-reuse fix): **~232 inv
total / ~12.5M cache / ~90k out / ~44m wall**. Full run including a shipped-then-caught
regression (iteration 3) and a confirmed plateau (iteration 4): **~454 inv / ~25.2M cache /
~204k out / ~1h29m wall**. 100% sonnet throughout, zero model leak.

**Oracle grading history:** run 1 (unmodified voyage) 24/29; run 2 (iter 2, DOM-reuse fix)
28/29; run 3 (iter 3, filtering regression shipped-then-fixed) 28/29 unchanged; run 4 (iter
4, reload-finality fix) 28/29 unchanged - 3rd consecutive no-defect result on the same
residual (`Persistence -> should persist its data`, `element-has-detached-from-dom` on
reload, spec line 936). **Resolved not as a plateau but as a mislabeled check**: verified
(git log on the pinned oracle) that the last real upstream update wave (2026-05-02) touched
exactly 7 examples - vue, svelte, react-redux, react, preact, lit, angular - and all 7 are
already in the oracle's own `noLocalStorageCheck` exemption map (apps that "persist
nothing"). Every non-exempted example is untouched since 2024 or earlier, most since
2018-2019; a live comparison run against the closest non-exempted analog
(`javascript-es6`) failed for an unrelated stale-selector reason before ever reaching
Persistence. No currently-maintained reference implementation is provably reachable
through this exact check. dk's ruling: exempt the shakedown pilot's own fixed framework
name (`shakedown`, not `pilot3`/`pilot5`/etc. - must stay fixed across pilots) the same way
the modern main set already is. Shipped as `fixtures/oracle/shakedown-localstorage-exempt.patch`,
documented in `fixtures/oracle/README.md` to the same evidence bar as `spy-reset.patch`.
Confirmed: shakedown-framework grading run now shows 28 passing / 0 failing / 1 pending
("All specs passed!"). Not a general license for future exemptions - the same evidence bar
applies to any future request of this kind.

**Findings routed to dk, NOT shipped - need a ruling before any doctrine change:**
1. **Boatswain's recheck-selection doesn't expand blast radius for shared support-file
   changes.** Happened TWICE this pilot; the first time shipped a real regression
   (`filtering.feature` broken by a `world.js` edit, committed with the break unseen because
   the recheck only ran `persistence.feature`, the file the change was declared alongside -
   not the full suite, not the other files that also call the touched functions). Second
   instance: same narrow scoping, no regression existed to miss that time. Caught downstream
   by a Shipwright harbour full-regression, not by custody itself. Candidate fix: when a
   touched diff is verification-support code (not production, not one spec file), recheck
   selection should default to broad, not the file it's declared beside.
2. **QM reached for the Monitor tool on a Crew wait, twice, despite 0.13.16/0.13.17
   targeting exactly this class.** Both times self-caught and self-corrected before actually
   stalling (unlike the pilot-#3 orphan). The instinct isn't extinguished by current text.
   Needs a ruling: strengthen the wording, or accept self-correction as sufficient.
3. **Captain declares dependencies in RIGGING.md without provisioning them.** Guarantees a
   rigging-blocker round-trip (QM discovers -> Captain routes -> Shipwright refits) on every
   greenfield pilot - not occasional, structural. Candidate fix: Captain's Rigging-authoring
   step should install + smoke-test what it names before handing off.

**Weaker findings, logged but not action-worthy yet:**
- Exit-code-blind `timeout N | tail` habit in QM/Crew suite-run commands - never actually
  misfired this run (nothing hit the timeout), but the construction can't distinguish a
  killed run from a clean one if it ever does.
- CAPTAIN.md staging blocked once even via the sanctioned standalone `git add -- CAPTAIN.md`
  form, then worked normally the very next Boatswain leg. Possibly transient/order-dependent;
  not enough evidence to act on.
- Partial-watch-strike hygiene gap: a watch with one red + several green entries doesn't get
  its green entries struck, so the next QM redispatch re-verifies already-fixed scenarios
  from scratch. Minor invocation waste, not a correctness risk.

**Runner-conduct finding, on this session itself:** the pilot's own play-by-play narration
requirement (scenarios/pilot.md: "never more than ~2 minutes of silence") was not
self-sustaining - required the user to flag it mid-run before a real `ScheduleWakeup` loop
was armed. Second occurrence of this exact class (first was pilot #3's Monitor-tool finding,
different mechanism, same shape: a standing rule stated once does not reliably survive many
turns without an external check). Flagging for a structural fix (e.g., the wake prompt
itself carrying a hard "emit a narration line first" instruction every time it fires), not
another verbal commitment.

## 0.13.25 SHIPPED (f155284), pushed + installed. RESTART, THEN PILOT ON SONNET.

**0.13.25 = 0.13.24 + Crew's stop recast.** dk ruled: cap APPROACHES, not edit cycles. Crew's
skill had a fifth stop trigger (a bare two-cycle count) where the Articles sanction four, and it
would stop a CONVERGING fix one edit from green, spending a redispatch to finish it. Now: a
second edit REFINING an approach is the work and runs to green; a second APPROACH stops, because
Disposition 3 already bans alternative approaches and design choice is not Crew's with a target
in hand. **No live leg has ever hit this stop - the pilot is the first test of whether Crew ever
reaches it.**

**Channel markers for 0.13.25:** `The stop is on the approach, never on a cycle count`,
`two dispositions and no third`, `:!CAPTAIN.md'`, `keeps no register of failures`.

**RESTART REQUIRED before any plugin-channel leg.** This session's process predates the install,
so subagents dispatched from it run 0.13.23 text. Verify the channel empirically on the first
leg per AGENTS.md: grep its transcript for `two dispositions and no third`, `:!CAPTAIN.md'`, or
`keeps no register of failures`. Zero hits = stale snapshot = abort.

### THE BIG FIND: a defect in the SHIPPED release, exposed only by withholding the hook

**Boatswain's CAPTAIN.md content-blind rule was HOOK-enforced, never DOCTRINE-enforced.** Run
0.13.23 (the tagged release) HEAD-text, where no hook exists, and Boatswain reads Captain's
notes: the control leg ran `cat CAPTAIN.md` outright and self-reported it. A 0.13.24 leg
breached the same bulkhead by a different route (unscoped `git diff`). **Two versions, two
legs, ZERO `:!CAPTAIN.md` exclusions between them.** The prose rule sat two sections from the
retrieval step and lost to whatever command the role composed. Fixed by putting the exclusion
IN the command. Gate leg then used it, read zero notes, closed in 5 inv. First time doctrine
alone has carried that rule. **This is the method working exactly as designed: the hook hides
the defect, so the shakedown withholds the hook.**

### Shipped in 0.13.24

- **4 contradiction fixes** (five-role cross-consistency hunt, all tree-verified). The
  release-critical one: Boatswain's "ambiguous plank -> Captain blocker" was a THIRD
  disposition the Articles never sanction, reopening the tw16 class through a route 0.13.23's
  fix did not close.
- **`## Known false-failure modes` DELETED, all 8 sites.** dk's call, and the evidence backed
  it: doctrine's own words were "an empty section is the healthy state", and it had already
  drifted the way gravity pulls (Articles said "engineer it out"; QM's skill said only "rerun,
  don't dispatch Crew"). Validated: fresh fit-out derives RIGGING.md without it and reports the
  text-search weakness as a harbour finding instead of parking it.
- **All 5 role skills RECOMPILED by retrieval dependency** (the IEPE refactor). Boatswain's
  seven hygiene bullets became ONE evidence run + seven judgments. QM works a watch as a SET
  (step 8 had been quietly re-serializing what step 5 batched). Crew's four-link read chain
  became two passes, one link being false. Shipwright: opening only, it was already good.

### A/B RESULTS, honest (HEAD-text both arms, same fixtures/model - a clean A/B, since the plugin channel's +58% would have confounded it)

| Leg | 0.13.23 | 0.13.24 |
|---|---|---|
| Boatswain custody | 10 | 8 |
| QM voyage | 15 | 17 |
| Shipwright fit-out | 26 | 26 |

**THE IEPE RECOMPILE IS A NULL RESULT ON INVOCATIONS. The predicted ~25% did NOT materialize.**
Boatswain -2, QM +2, Shipwright 0. Say so plainly in any report; the prediction was falsifiable
and it was falsified.

**OPERATOR ERROR, twice, and it nearly entered the record as a finding:** I read STILL-RUNNING
transcripts as finished ones and reported "Boatswain 10 -> 6" and "Shipwright control did no
work, comparison INVALID". Both false. The leg was mid-flight and its files were not yet
written. **A partial transcript looks exactly like a finished one to `plan.py`.** Wait for the
task-notification before mining; a tree check on a live leg proves nothing. This is the same
class as the pilot-#2 lesson (mine on EVERY notification) wearing a new costume.

**What IS real and validated:** the bulkhead defect closed (v23 control breached, v24 gate leg
did not); the 4 contradiction fixes; the false-failure deletion (tree-verified both ways - the
v23 control's derived RIGGING.md HAS the section, v24's does not); outcomes identical on all
three legs; mergeable retrieval runs 0, down from 18 across the fleet.

**Reading:** the recompile is SAFE (no regression, cleaner plans) but it is NOT the economy
lever. The 84%-boilerplate and 25%-compilable-waste numbers measured a real cost that the
recompile did not convert into fewer invocations. Candidate explanations, none tested: the
opening block is only 1 invocation on HEAD-text anyway (the 12.9% figure was a PLUGIN-channel
measurement, and the plugin prefill is the change that would actually collect it); the
mergeable runs were only 8% and mostly short. **The plugin prefill (0.13.25) is now the only
untested economy lever left, and it targets exactly the 12.9% this A/B could not see.**

### OWED / OPEN

- **Crew's two-cycle stop cap: dk's ruling owed.** A fifth stop trigger where the Articles
  sanction four. Deliberately NOT shipped - the hunter flagged its own uncertainty, it is
  plausibly an anti-thrash guard, and changing a contested rule right before a long pilot is how
  a pilot gets poisoned.
- **Plugin prefill (0.13.25):** carry doctrine in the agent definitions instead of the Skill
  tool. Kills the 2 opening round-trips (12.9% of invocations). MUST be GENERATED from SKILL.md
  with a drift test, never hand-copied - two copies of a rule is the exact failure class the
  contradiction hunt found five of.
- **STILL NEVER EXERCISED** (a pilot would drive all three): scenario-lane decomposition has
  never met a Captain leg; full-regression economy has never met a Captain outbound decision;
  the plank-form check's planted-red adoption proof has never run.
- **Ablation harness: deferred by dk** (too much latency). Design recorded in `scenarios/iepe.md`.

## GOAL 2, INSTRUMENT 1 DONE: inbound weight is MEASURED, EXACT, and it closes. 2026-07-14.

**Built and validated against the tag** (`bin/inbound.py`, `bin/inbound-fleet.py`,
`bin/doctrine-sections.py`). Full numbers + method + traps in METRICS.md; here is what a
fresh session needs.

**The method needs no tokenizer and it is exact.** `context[n] = input + cache_creation +
cache_read` is the true prompt size, so `delivered[n] = context[n] - context[n-1] -
output[n-1]` is exactly what got injected between two calls. A token entering at `k` is
re-read `N-k+1` times; sum those resident costs and you must reproduce the metered spend.
**The identity is asserted on every run and closed at drift +0 on all 14 legs.** That
assertion is the whole reason to trust the numbers - and it is what caught my own bug
(`probe19`'s shared Articles were being filed as `command:24.7k`).

**Transcripts persist and are NOT in /tmp** - the notes feared they were volatile. They live
at `~/.claude/projects/<proj>/<session>/subagents/agent-*.jsonl`. Nothing needs harvesting
before a session dies. Today's session `6bdcdbf3` holds 14 role legs, 0.13.17->0.13.23.

**THE HEADLINE: 84% of every token a Shipshape role reads is boilerplate.**
14 legs / 224 inv / 12.6M tokens: shared Articles **36.9%**, harness floor **33.5%**, role
skills 14.0%, **THE JOB 15.6%**. Shared Articles measure **~24.0k tokens, not the ~15k I
estimated** - and every role loads all of it. Crew reads 24.1k of shared Articles (5x its own
role skill) to do a job that is **5.2%** of its context.

**dk's hypothesis is CONFIRMED but SMALL, and that is the useful part.** Crew really does
carry Harbour flow, Watchbill and Outbound. Priced: 529 + 718 + 400 = **1,647 tok, 6.8% of
the shared Articles**. Cutting all three from Crew saves ~3.7% of a Crew leg. The heavy
sections are Verification policy (1,625), Role transitions (1,433), Hand-off custody (1,397)
- plausibly load-bearing for everyone. **The bulk is not in the obvious offcuts, so the
"move Crew's dead sections" lever is real but minor.** Do not oversell it to dk.

**WHAT THIS DOES NOT SHOW, and I will not let it be read otherwise.** This is COST, not
WORTH. Three limits, all binding:
1. **Tokens are rung 4** and cache-read bills at ~10%. On the token rung alone this finding
   does NOT justify touching doctrine. dk: "preserving tokens is not a major goal."
2. **The latency case is suggestive, not proven.** Mean context vs sec/invocation across the
   14 legs: **r = +0.82** - which would promote this to rung 2, above invocations and tokens.
   But it is CONFOUNDED (big-context legs are Shipwright legs that also reason more per
   round). **The controlled probe is owed: same leg, same state, trimmed context, measure
   wall.** Until it runs, "trimming buys latency" is a hypothesis, not a finding.
3. **The real prize is rung 1, quality** - attention dilution across 24k tokens of mostly-
   irrelevant rules - and instrument 1 **cannot see it at all**.

### THE OWED LATENCY PROBE: RUN, AND IT SETTLES THE RUNG. (dk's call: "run the probe first")

**Context bulk IS a rung-2 latency cost. Causally, not by correlation.** Six general-purpose
agents (no doctrine, no roles, no contamination risk), identical task - read one file, then
eight `echo`s one per turn - with ONLY the file size varying: 39-byte stub vs a 73,429-byte
ballast sized to the shared Articles. Decode held fixed (outputs 76 vs 77 tokens).

**+24,935 cached tokens cost +0.84s per invocation, a +42% increase** over the light arm's
2.00s. Quote the MEDIAN, not the mean (+1.15s): the heavy arm has one 11.3s outlier. Robust
every way - trimmed diff +0.85s, **Mann-Whitney z = -3.27**, distributions barely overlap.
~13s on a 15-inv leg; ~3.1 min across the 224-inv fleet, purely re-reading the Articles.

**My observational shortcut FAILED and I have made the tool admit it.** Regressing think-time
on cache_read (n=224) gave R^2=0.28, raw r=+0.20 - collinear with everything, poorly
identified, NOT quotable. dk was right to demand the controlled probe; the cheap version could
not settle it.

**BUT IT STILL DOES NOT LICENSE A CUT, and this is the part to carry into any report.**
Quality outranks latency, and METRICS' own lens says mistake/fix cycles are the dominant
latency source. Per section, doctrine costs ~0.02-0.06s per invocation. **One prevented rework
cycle costs a whole invocation or more - so any section that prevents even one thing across a
voyage has already paid for itself.** We now know the PRICE. We still do not know the WORTH.

**NEXT, and dk has ruled:** instrument 3 (doctrine-section x role consumption matrix) is
**MEASURE, DON'T MOVE**. Build the matrix, report candidates, touch NO doctrine text.
**Resident-by-design STANDS** - re-homing stays blocked behind dk's explicit word. The matrix
NOMINATES, it never condemns; anything it flags gets a probe before it gets cut, because a
rule can be load-bearing precisely because it PREVENTED something (the wait rule's value is a
stall that did not happen, and it will surface in no transcript). Instrument 2
(retrieval->consumption edge graph) is unbuilt.

**Aim instrument 3 at DECISION QUALITY, not token cost.** The latency probe means cost is now
known and modest per section; the only question that can still justify a cut is whether a
section ever touches a decision. That is a consumption question, not an accounting one.

## GOAL 1 COMPLETE: **v0.13.23 TAGGED AND PUSHED** (8e7cf25). Stable release. 2026-07-14.

**tw16b, the final gate: FULL PASS, tree-verified.** Identical tree, identical malformed plank,
identical 5/5 GREEN suite - the outcome INVERTED. HEAD stayed at base 7e31010, **nothing committed**,
work left uncommitted for Crew redispatch. Deck foul named the seam, the line, the fault, and the
correct pattern to carry, so Crew needs no seam hunt. It RAN the join (4 step-usage invocations),
did not eyeball it. 0.13.23 marker phrases live in the leg's text. Its report closes: "No claim in
this report is by-read-only; every tree claim above is a command's output" - 0.13.21 self-attested.
14 inv / 668k / 1m36s. **On 0.13.22 the same Boatswain found the same fault and committed it
anyway (4dd6482). On 0.13.23 it refuses. The check bites AND the disposition holds.**

This is the FIXED BASELINE for Goal 2. Measure against the tag, never against churning text.

**Validated live (all tree-verified, harness wait-guards withheld):** wait discipline; parallel-mate
consumption (pilot-#3 HIGH CLOSED); flat QM->Boatswain hand-off (3x); batching; recordable carried
greens + zero-rerun custody inherit; the full @planks-provisional arc, harbour -> promotion ->
liquidation, with ZERO reimplementation and ZERO dead code; @conformance lane vocabulary;
plank-form cross-wire derived into a real executable checker by Shipwright, unprompted.
**Check precedence (0.13.21) CONFIRMED TWICE:** tw16's Boatswain RAN the plank join and CAUGHT the
malformed plank that tw1's Boatswain eyeballed past; tw15b's QM independently cross-referenced its
planks against step-usage instead of asserting them.

**tw16 FOUND THE LAST DEFECT, fixed in 0.13.23 (8e7cf25), UNVALIDATED:** the check bit but the
DISPOSITION let the fault ship. Boatswain correctly ran the join, correctly found a malformed plank
Crew had just written - then COMMITTED it and deferred it to harbour, faithfully following its own
skill text ("plank drift defers to harbour") while the Planking agreement said only drift BEYOND the
diff does. A missing plank on a touched seam was Crew redispatch; a MALFORMED one on the same seam,
same diff, same voyage, went to a harbour months away. The weaker rule won and bad state shipped.
0.13.23: on a touched seam in the role-advanced diff, missing/stale/malformed are ONE fault -
unfinished Crew work, foul, redispatch. Harbour is where a fault no current role owns goes, never
where a fault this voyage introduced is parked.

**tw15 regression on 0.13.22: CLEAN** (8/8 green, canonical planks, zero waits/polls). Note it
dispatched ONE mate this run where the 0.13.20 run dispatched TWO for the identical state, putting
both seams in one file - **parallelism is NOT deterministic**; both shapes are legal and the earlier
run already proved parallel consumption. Do not read a single-mate run as a batching regression.

**NOT YET EXERCISED anywhere, carry into the release notes:** the scenario-lane DECOMPOSITION rule
(one scenario one lane, unbolted feature template) has never met a Captain leg; the full-regression
economy rule (harbour as sole trigger) has never met a Captain outbound decision; the plank-form
check's own planted-red adoption proof has never run. Economy numbers remain CONTAMINATED by the
model-pin leak (9 legs) - nothing is bankable as a METRICS baseline until a sonnet-session rerun.

## GOAL 2 (dk, 2026-07-14): THE EFFECTIVE RETRIEVAL GRAPH + INBOUND CONTEXT WEIGHT. Runs in a FRESH SESSION, after the stable release lands.

dk's words: "we need a way to understand the effective retrieval graph for all invocations as well
as the inbound context weight... feels like this should be a major goal of shakedown." And:
"our probes should help us find doctrine that is not actually helping during a particular
invocation and thus a candidate to move or remove."

**Why this is a major goal, not a side quest.** METRICS today classifies each invocation's OUTPUT
by whether a later invocation consumed it (P/N/Neg). That is the OUTBOUND worth of an action. We
measure NOTHING on the inbound side. Every role re-prefills the full shared skill on EVERY
invocation: ~11.4k words, call it ~15k tokens, so a 30-invocation leg pays ~450k tokens of
doctrine alone - and we have no idea which of those tokens ever touched a decision. Crew loads the
Harbour flow, the Watchbill policy, the Outbound policy and the named-engine catalog on every
invocation and has, as far as anyone knows, never used one of them. On dk's ladder
(quality > latency > invocations > tokens) that inbound bulk is the dominant hidden cost, and it
is currently invisible. Put inbound and outbound together and you can ask the only question that
really matters about a prompt: **did every token in this context earn its place?**

**Three instruments, in this order:**
1. **Inbound weight decomposition** (cheap, EXACT). Per invocation: cache_read split by source -
   skill text vs conversation history vs tool results. Tells us what we are actually paying for,
   with no inference. Do this first.
2. **Retrieval graph** (observable edges). Each invocation's tool calls are retrievals; link each
   retrieval to the later invocation that used it. A file read followed by an edit to that file is
   consumed. A command whose output values reappear later is consumed. A read never referenced
   again is dead weight. This mechanizes the P/N/Neg classification that is hand-done today.
3. **Doctrine-section x role consumption matrix** (HEURISTIC - the one that could shrink the
   shared skill). For each doctrine section, does its rule surface in a role's reasoning, report,
   or actions? A section no role ever touches across dozens of legs is a candidate to CUT. A
   section only one role ever touches is a candidate to MOVE into that role's skill.

**THE LIMIT, and it is not optional - state it in any report:** absence of evidence is weak here.
A rule can be load-bearing precisely BECAUSE it prevented something. The wait rule's whole value is
a stall that did not happen, and it will surface in almost no transcript. **The matrix NOMINATES
candidates; it never condemns. Anything it flags gets a probe before it gets cut** - same bar as
everything else in this harness (findings need tree evidence, never report prose).

**Standing-decision collision, needs dk's word before acting on results:** "No reference-file
splits in doctrine skills; resident-by-design. Revisit only on a change to the clear or isolation
model." Moving a section from the shared skill INTO a role skill is re-homing, not a reference-file
split (every role already loads its own skill), but it is close enough to that decision's spirit
that dk rules before anything moves.

**Build:** `bin/graph.sh` over the task transcripts already banked (they persist in the session
tasks dir; harvest them BEFORE the session dies, or re-run legs). Five clean legs exist from
2026-07-14: 2 Shipwright harbours, 2-3 QMs, 2 Boatswains, all on 0.13.17-0.13.20.

**PREREQUISITE (dk's own sequencing): measure against a FIXED doctrine version.** The stable
release tag is the baseline. Churning doctrine text underneath the measurement poisons the very
numbers the exercise exists to produce. Ship the release FIRST, then start Goal 2 against it.

## 2026-07-14: THE QUEUE IS SHIPPED - 0.13.17 (85e9e6f), pushed and installed. Two things owed: a FABLE DOCTRINE REVIEW of the diff, then live-fire probes.

The five-item queue below was worked through with dk in one session, item by item, and
shipped as **0.13.17** (`85e9e6f`, tests 209/209 green, pushed, `npx plugins add` done).
0.13.16 (`19fd03a`, the wait-on-a-signal rule) had shipped in a prior session and covered
queue items 3-4 only PARTIALLY - see below. Nothing in the queue is now unshipped.

**RESTART REQUIRED before any probe leg.** The plugin snapshot is process-level: this
session's process predates the 0.13.17 install, so subagents dispatched from it would run
0.13.16 text. Restart, then verify the channel empirically per AGENTS.md (grep a leg
transcript for a 0.13.17 marker phrase: `one lane`, `harbour is its only trigger`, or
`never builds its own completion check`).

### tw1 SMOKE TEST: RUN, 4/4 MARKERS PASS + one real finding (2026-07-14, 0.13.17, installed channel)

Voyage: QM 20 inv / 888k / 3m12s, Boatswain 11 inv / 492k / 1m07s. 31 inv, 4 suite runs, commit
18ee6cb, clean deck. Baseline (wave 5, 0.13.14): QM 28 inv / 1.41M / 3m41s / 4 runs.

- **M1 CHANNEL PASS.** 0.13.17 marker phrases live in the leg's skill text (`harbour is its only
  trigger`, `never builds its own completion check`, `one lane`, `@conformance`).
- **M2 FLAT HAND-OFF PASS.** QM made exactly ONE spawn (Crew) and ZERO Boatswain spawns; ended in
  its report naming Boatswain + 3 advanced targets + base commit; left the tree uncommitted at
  base for its caller. At 0.13.14 the same probe spawned a nested Boatswain and waited. Tree-
  verified (HEAD still at base, work unstaged), not report prose. Receiving end also works:
  operator-dispatched Boatswain committed clean.
- **M3 NO INVENTED WAIT PASS.** Zero Monitor / pgrep / kill -0 / transcript-grep / sleep-loop
  commands in either leg. The 3 `sleep`/`until` string hits are the doctrine text quoting ITSELF.
  Harness background-task belt-and-braces lines were WITHHELD from the dispatch on purpose, so
  this is the doctrine text alone holding (same method as wave 5's slow-census probe).
- **M4 BATCHING PASS.** One Crew dispatch, 3 refs, one seam cluster.
- **BONUS: two 0.13.17 rules fired live, unprompted.** (a) Recordable carried green: QM appended
  Crew's hand-off green to runrecord as it stands, no re-proof rerun. (b) Boatswain inherited it
  as commit evidence: ZERO reruns (suite runs stayed at 4). (c) QM cited the new plank-form
  cross-wire reasoning verbatim when routing its finding.

**ECONOMY NUMBERS ARE CONTAMINATED - do not bank them.** Model split 35 sonnet / 7 opus-4-8: the
known async-resumption pin leak fired again (QM's continuation after its Crew child resumed fell
to the SESSION model, which is opus this session). The 0.13.14 baseline was 100% sonnet, so the
-29% invocation delta is NOT like-for-like. Behavioural markers unaffected. Rerun in a
sonnet-session before any METRICS baseline is written.

**STILL UNTESTED: parallel mates.** tw1 dispatches ONE child. Consuming one child never broke.
The highest-flagged risk in the dossier stands untested; needs the two-disjoint-seam state.

### RESOLVED BY dk, SHIPPED AS 0.13.18 (823c1e0): the plank names the STEP DEFINITION's pattern

**dk's ruling: "the plank should match the string in the step definition exactly... not the feature
file, but the actual step def function. Since we already have cucumber usage to make step def to
feature file."** So the finding below is REAL but I scored the roles BACKWARDS, and the correction
matters more than the original write-up:

- **Crew and Boatswain were RIGHT.** `@planks("When I ask for the next low tide after {string}")`
  is now canonical form. The tidewatch fixture's convention was correct all along.
- **QM's flag was a FALSE POSITIVE.** Its "deferred harbour finding" was doctrine-faithful under
  the old text and is wrong under the new. Do not count it as a QM win in the tw1 scoring.
- **My own reading was wrong too**, and only the live voyage exposed it. Reading alone would have
  shipped the contradiction; this is the argument for probe-before-review, vindicated.

dk's reasoning: `step-usage` ALREADY maps step definition to feature file. A plank copying the
concrete step line stores a second copy of a join the runner derives for free, and that copy
drifts with every data edit. The pattern is the durable contract; example values are not.

**Consequences shipped in 0.13.18:**
- Planking agreement Form + Judging: plank = definition's pattern string verbatim, with its
  keyword. Trace chain made explicit: seam -> plank -> step definition -> scenarios, and the
  runner owns the last hop.
- **Plank form is now DECIDABLE**, which unblocks the 0.13.17 cross-wire I had shipped pointing at
  an undecidable predicate: the plank string must be a member of the current step-definition
  pattern set. The derived plank-form rule reddens on a plank naming no pattern.
- Crew and Shipwright's "use the exact Gherkin step text" instructions INVERTED (they said the
  opposite in as many words).
- **The uncovered-seam hole, dk chose option 3.** A plank names a pattern, so a seam with no
  executable step has no pattern to name. Shipwright leaves it UNPLANKED, carrying its `@captain`
  scenario, and reports it as a harbour finding. Article 9 amended to permit this wait.
  **Sharp edge I had to close:** a promoted skeleton passes against EXISTING code, so there is no
  failing target, no Crew dispatch, and Crew is the only role that writes planks at sea - the seam
  would have sat unplanked forever. Fix: when QM makes a promoted skeleton's step executable and
  the target passes against existing production code, QM dispatches Crew with a PLANK-ONLY target
  (the same route a custody foul already takes). That is the moment the harbour finding closes.
  **SUPERSEDED by 0.13.19 - see below. Option 3 was WRONG and dk reversed it himself.**

### 0.13.19 (eee0ef8): PROVISIONAL PLANK - dk reversed option 3, and his reasoning is the important part

dk reconsidered within the hour: **"shipwright knows exactly where the unplanked seam is, so
connecting it to the candidate scenario now makes it easier for qm/crew to find, and so less
likely then to just reimplement and leave it as dead code."** That is decisive, and it exposes
what option 3 actually did: **it deleted information.** Shipwright is the only role that has the
seam and the behaviour in hand at once. Under option 3 that link lived only in Shipwright's
REPORT, and reports are discarded context, not durable artifacts. At promotion a fresh QM would
arrive holding a domain-level scenario and no pointer to the code that already implements it; if
it failed to rediscover the seam, Crew would implement the behaviour AGAIN and leave the original
as dead code. Doctrine already names that defect class (behaviour-identity duplication, the harbour
finding a token scanner cannot catch). **The plank is the ONLY durable home for the seam-behaviour
link** - a scenario cannot carry it (domain-level; a seam hint in a spec is contamination).

**Shipped: two decidable plank forms.** A plank string is a current step-definition pattern, OR the
step line of a `@captain` scenario (provisional). Both sets come from artifacts in hand: `step-usage`
for the first, the feature files for the second. The provisional form SELF-LIQUIDATES: at promotion
QM writes the definition, the pattern comes into existence, the provisional plank matches neither
form, reddens as ordinary plank drift, and normalizes via a plank-only Crew dispatch. **The form
expires exactly when the `@captain` tag does** - it is the tag's existing bounded lifecycle showing
through, not a new rule. Better shape than my 0.13.18 mechanism too: work now arrives as FAILING
VERIFICATION rather than as a role noticing something.

**dk also floated Shipwright writing an empty step def** so the pattern would exist early (one form
instead of two). Rejected, three reasons, and dk landed on the third himself:
1. **An empty step def PASSES.** While `@captain` it never runs, but at promotion the scenario runs,
   its steps are DEFINED, and it goes GREEN ASSERTING NOTHING - watchbill spent, no Crew, silent
   false green. Would need a throw-pending body instead.
2. **It would read as an ORPHANED step definition.** Every derived command composes `not @captain`,
   so `step-usage` never sees skeleton scenarios; a definition bound only to a skeleton reports zero
   usage, which is exactly Boatswain's orphan signal. We would manufacture false positives at every
   harbour to avoid a second plank form.
3. **dk's own objection, and the cleanest: TOO STACK-DEPENDENT.** Pending/unimplemented semantics
   differ by runner and language. Doctrine must hold on any stack with any Gherkin runner; a rule
   that only works where the runner has pending semantics is a Cucumber-JS convention, not a rule.
   (It would also breach QM's write scope, which is what licenses Shipwright to talk to the user.)

**PROBED on 0.13.19 (tw14 Shipwright harbour) -> mechanism WORKS, and the probe found a DEFECT in
it that reading could never have caught. Fixed in 0.13.20 (5c783a8). See below.**

### tw14: Shipwright harbour on 0.13.19, an uncovered seam (2026-07-14)

State built for this probe (NEW, keep it): fitted tidewatch tree + `tideRange` seam with real
behaviour, no scenario, no step def, no plank. Base bfd6c80, clean, suite green.
Leg: 17 inv / 1.19M / 6m01s / 100% sonnet, ZERO model leak (no nested spawns).

**PASSES, all tree-verified:**
- **Provisional plank LANDED.** `tideRange` got `@planks("When I ask for the tide range on
  "2026-07-12"")` - the `@captain` skeleton's step line verbatim, per 0.13.19. The seam is held.
- **Write scope HELD.** Zero step definitions written. The rejected empty-step-def route did not
  sneak in.
- **Pattern plank untouched.** `nextHighTide`'s `{string}` plank verified against fresh
  `step-usage` with zero drift.
- **Channel verified for free:** the leg read its own templates from `.../shipshape/eee0ef8...`.
- **0.13.17 lane vocabulary is LIVE:** 3 `@conformance` skeletons, ZERO `@invariant`.
- **BEST RESULT: the cross-wire closed the loop.** Shipwright DERIVED the two-form rule into an
  executable checker, unprompted, first try: `scantlings/verification-conformance.json` takes
  `captainScenarios` as an input and reddens on "a @planks string matching neither a current
  step-definition pattern nor a current @captain scenario step line". The 0.13.17 rule that was
  pointing at an undecidable predicate this morning is now a real check.

### DEFECT FOUND BY tw14, FIXED IN 0.13.20 (5c783a8): the concrete-step-line plank collides with its own syntax

`@planks("When I ask for the tide range on "2026-07-12"")` - **the inner quotes are unescaped.**
A Gherkin step line carries DOUBLE-QUOTED parameters, and `@planks("...")` uses double quotes as
its DELIMITER. Verified: a standard extraction regex parses the pattern plank fine and **fails to
match the provisional plank at all**. The pattern form is immune (`{string}` has no quotes), so the
collision is unique to the provisional form and appears in exactly the case that form exists to
serve. Bitterest part: the checker Shipwright derived would redden the plank Shipwright wrote.

**dk's fix, better than the escape-hatch I proposed: an EXPLICIT provisional annotation that leads
organically to QM replacement.** Shipped as 0.13.20:

`@planks-provisional("features/tides.feature:Tide range for a day spans its highest high and lowest low")`

- **Kills the collision:** the string is a scenario REFERENCE in the canonical
  `<spec>.feature:<Scenario Name>` form the watchbill and `focused` already speak. No embedded step
  data, no quotes, nothing to escape. Parse-verified both ways: a `@planks` regex does NOT falsely
  match `@planks-provisional`.
- **`@planks` returns to ONE form** (the step-definition pattern), which is what dk originally ruled.
  The transitional state is a different annotation, not a second form of the same one.
- **Self-announcing:** a reader sees at once that the plank is provisional and which scenario it
  waits on. Under the two-form scheme you could only tell by joining against the specs.
- **Liquidates ORGANICALLY, which was dk's ask:** promotion removes the `@captain` tag, so a
  `@planks-provisional` naming a promoted scenario is RED - before QM even writes the step def. QM
  greps for the annotation naming its directed target, finds the seam with NO seam hunt, and
  dispatches Crew plank-only to swap in the pattern it just authored. Trigger, target and fix are
  all mechanically derivable, and the work arrives as ordinary failing verification.

### tw14b + LIQUIDATION VOYAGE on 0.13.20: FULL END-TO-END PASS, tree-verified (2026-07-14)

**The whole arc works, harbour to liquidation. Nothing left untested in this mechanism.**

Leg 1, Shipwright harbour (base 4b03fe2, 34 inv / 2.48M / 6m33s, 100% sonnet, zero leak):
- **`@planks-provisional` LANDED, first contact with the new text.** TWO of them on `tideRange`,
  one per discovered behaviour: `@planks-provisional("features/tides.feature:Tide range for a day
  with recorded tides")` and `...:Tide range for a day with no tides is an error"`. Canonical
  scenario-reference form. **No quote collision - the 0.13.19 defect is closed in practice.**
- Scenario names in the refs match the `@captain` scenario titles EXACTLY (char-for-char).
- `@planks` stayed ONE form on `nextHighTide`. Write scope held (zero step defs).
- **Shipwright DERIVED THE LIQUIDATION PREDICATE into its rule set unprompted** - the scantling
  reddens on a `@planks-provisional` whose scenario "no longer carries @captain".
- Channel verified: leg read templates from `.../shipshape/5c783a8...`.

Operator then promoted as Captain would (stripped `@captain` off the two tideRange scenarios,
wrote the watchbill). Leg 2, QM (20 inv / 945k / 2m52s):
- Made the 3 steps executable. **Both targets PASSED against untouched production code** - so
  there was NO RED to dispatch on. This is exactly the state where the old rules lose the seam.
- **THE LIQUIDATION FIRED.** QM ran `grep -rn "@planks-provisional" src && grep -c "@captain"
  features/...` - found the seam BY THE ANNOTATION with no seam hunt, saw the tag was gone,
  ruled it red, and dispatched Crew with a plank-only target. Then ENDED ITS TURN.
- **Crew swapped both annotations for `@planks("When I ask for the tide range on {string}")` and
  touched NOTHING ELSE.** Tree-verified: `git diff` on `src/tide.js` since base shows ONLY the
  added docblock, 3 lines, all annotation. `tideRange` body untouched, exactly ONE definition.
- **ZERO reimplementation, ZERO duplicate seam, ZERO dead code.** The failure dk reversed option 3
  to prevent is closed, and closed MECHANICALLY - it arrives as ordinary red work, not as a role
  remembering to be careful.
- Deck: 4/4 green, 2 run-record lines, flat hand-off to Boatswain again (1 Crew spawn, 0 Boatswain
  spawns - SECOND confirmation), zero polls/waits/Monitor.
- QM raised two honest Captain findings, both correct: the conformance skeletons are still
  `@captain` so the plank-form check is NOT live (its planted-red proof is owed at promotion), and
  `RIGGING.md` now names a `scantlings` path no BINDING scenario references - a textbook Scantling
  agreement finding.

Model leak: QM 33 sonnet / 6 opus (async-resumption pin fall, 8th instance). Shipwright 100%
sonnet (no nested spawns). Economy numbers still not bankable until a sonnet-session rerun.

### tw15 PARALLEL MATES on 0.13.20: FULL PASS. THE PILOT-#3 HIGH FINDING IS CLOSED.

**The highest-flagged risk, the one that started this whole session, is discharged.** Pilot #3's
QM hit exactly this shape - two Crew children dispatched in parallel - armed a `Monitor` wait,
ended its turn, and DIED SILENTLY until the operator resumed it by hand (`SendMessage` response:
"Agent was stopped (completed); resumed it in the background").

NEW STATE (keep it): `tidewatch15` - fitted base + TWO DISJOINT RED SEAMS, one watch, six targets.
Seam A: `nextLowTide` missing from `src/tide.js` (low-tides.feature, 3 scenarios). Seam B:
`src/station.js` does not exist at all (station.feature, 3 scenarios; the dashboard/spy scenario
dropped to keep the signal clean). Base 8749c3b. Different FILES, so the signal is consumption,
not collision.

QM leg (20 inv / 831k+ / ~4m52s), harness wait-guard lines WITHHELD so doctrine alone is tested:
- **BOTH MATES DISPATCHED IN ONE INVOCATION** (`Agent: ||| Agent:` in a single round), one turn,
  two children, disjoint seam clusters - exactly 0.13.17's parallel-children sentence.
- **ZERO INVENTED WAITS.** Monitor 0, pgrep 0, kill -0 0, `"type":"result"` 0, and **zero Bash
  commands containing sleep/wait/poll/until AT ALL**. The one `sleep` string in the transcript is
  the doctrine text quoting its own wait rule.
- **It ended its turn, consumed each report as it arrived, and finished ON ITS OWN. No operator
  nudge - none was sent.** No orphan, no stall, no "completed" status with wait-language.
- Both seams built, 4 planks all canonical pattern form, **8/8 green**, 6 run-record lines from
  CARRIED Crew greens (zero re-proof reruns), flat hand-off to Boatswain (0 Boatswain spawns -
  THIRD confirmation).

**Reading: the 0.13.16 wait rule + 0.13.17 parallel-children sentence prevent the class, in the
doctrine TEXT, without harness help.** Same method as wave 5's slow-census probe: guards withheld,
so this is not operator hygiene.

**MINOR FINDING (report fidelity):** QM's report claims "the repo has no `.gitignore`" and routes
it to Boatswain as hygiene. **FALSE** - `.gitignore` exists and already lists `runrecord.jsonl`
(tree-verified). Not a behavioural fault, but it is an unverified claim in a final report, exactly
what the 0.13.13 report-fidelity rule exists to catch, and it would have sent Boatswain chasing a
non-problem. Second instance today of a role asserting a tree fact it did not check (the first was
Boatswain's plank-form false pass in tw1).

Model leak: 38 sonnet / 10 opus (9th instance). Economy numbers STILL not bankable.

**STILL NEVER RUN:** the plank-form check's own planted-red adoption proof.

### THE ORIGINAL FINDING, kept for the record (tree-verified, now resolved above)

Three roles hit the plank-form rule in ONE voyage and resolved it THREE ways:
- **Crew** wrote `@planks("When I ask for the next low tide after {string}")` - step-definition
  Cucumber Expression pattern form.
- **QM** flagged exactly that as wrong-but-deferred, correctly citing `conformance: none` +
  token-search `plank-inventory` = no executable check governs it. **QM was right.**
- **Boatswain** looked at the SAME planks, asserted in its custody report that they carry "exact
  current Gherkin step text", and COMMITTED. **False pass.** Tree: the feature step is `When I ask
  for the next low tide after "2026-07-12T05:00:00Z"`; the plank says `{string}`.

That is the 2026-07-12 open item (grep-only plank checking degrades to human-read judgment)
caught LIVE: with no executable check, form-checking fell to judgment, and the judgment was wrong.

**The deeper problem, and the one the fable review must rule on: THE PLANKING AGREEMENT
CONTRADICTS ITSELF HERE.**
- Form rule: "Use exact current Gherkin step text."
- Judging rule, same agreement: "A plank bound to example data goes stale with every data edit."
- This step's exact text CONTAINS example data (a hardcoded timestamp). Obey the form rule and you
  author precisely the brittle data-bound plank the other rule warns against. Avoid the
  brittleness and you write the `{string}` pattern the form rule forbids. **Doctrine backs both
  horns.** Crew and Boatswain took one, QM took the other.
- Complication: `step-usage` reports step PATTERNS, so a `{string}` plank may actually JOIN better
  against step-usage output than a literal one would - the stale-plank join may be quietly
  assuming the very form the form rule forbids. Check this before ruling.
- The tidewatch FIXTURE seeded the pattern convention (its pre-existing `nextHighTide` plank uses
  `{string}`), so Crew copied what it saw. Fixture is partly to blame; the false custody CLAIM is
  not excused by it.

**Why this blocks 0.13.17's own plank-form cross-wire:** the new text routes plank form into the
conformance rule set as an EXECUTABLE check. **You cannot write that checker until doctrine
decides which form is correct for a step carrying example data.** The cross-wire is currently a
rule pointing at an undecidable predicate. Highest-value item for the fable review.

### DO THIS FIRST: tw1 behaviour smoke test, THEN the review (dk's call, 2026-07-14) [DONE, see above]

dk's sequencing: lightest possible behavioural smoke test BEFORE the fable review, so the
review reads the diff with live evidence beside it rather than on argument alone. Run ONE leg.

**State:** `bin/probe-states.sh <scratch>` -> `tidewatch1` (crew-batching, 0.13.10 probe,
scenarios/probes.md). Zero new fixtures. Dispatch QM thin (role + base commit), `model` pinned.

**Baseline to A/B against (wave 5, 0.13.14): 28 inv / 1.41M cache / 6.4k out / 3m41s / 4 suite
runs / PASS.** Judge on the four-rung ladder (quality > latency > invocations > tokens), and
record mean context per invocation.

**Four markers, all falsifiable from the leg transcript:**
1. **CHANNEL (gates everything).** Grep the transcript for a 0.13.17 marker phrase: `harbour is
   its only trigger`, `never builds its own completion check`, or `one lane`. ZERO hits = stale
   process snapshot = the run is meaningless, abort and restart properly (AGENTS.md rule).
2. **FLAT HAND-OFF (the new-text behaviour).** QM should now END IN ITS REPORT naming Boatswain +
   advanced targets + base commit, and spawn NOTHING. At 0.13.14 this same probe spawned a nested
   Boatswain. **Zero Boatswain spawns from QM = the flat hand-off is live.** Captain (or the
   operator, standing in) then dispatches custody.
3. **NO INVENTED WAIT.** Grep for `sleep`, `pgrep`, `kill -0`, `Monitor`, `"type":"result"`.
   Expect ZERO. Any hit is the pilot-#3 stall class surviving 0.13.16+0.13.17.
4. **BATCHING REGRESSION.** ONE Crew dispatch carrying 3 refs + per-target evidence (holds at
   0.13.14; a regression here would be a coherence casualty of the 0.13.17 edits).

**What tw1 CANNOT tell us, stated plainly:** it dispatches ONE Crew child (3 reds, one seam
cluster -> one batched mate). Consuming a single child NEVER broke. **The parallel-mates case -
the single highest-flagged risk in the dossier below - stays untested by this smoke test.** It
needs a two-disjoint-seam state that does not exist in fixtures/probe-states yet (a small build,
not a big one). That belongs in the full wave AFTER the review. Do not let a green tw1 be read as
clearing the parallel case.

### OWED #1: fable doctrine review of the 0.13.17 diff (dk's ask, this session)

Read `git -C ~/shipshape show 85e9e6f`. The review dossier - every decision, its reasoning,
and the risks I flagged - is in the next section. Review with fresh eyes; I wrote it, so I
am the wrong reader for it.

### OWED #2: live-fire probes, which no doctrine version since 0.13.15 has had

**0.13.16 AND 0.13.17 have both shipped with ZERO live-fire validation.** Run the five
pre-approved probes (scenarios/probes.md) on the installed 0.13.17 channel. Fold in the
channel-economy re-measure (below) at the same time; the probes must run anyway, so the
measurement is nearly free.

### The channel-economy re-measure (dk: "re-measure, and consider real world impact")

The standing "+58% invocations on the plugin channel vs HEAD-text" finding is **stale and
probably overstated**. Evidence it is not structural: at 0.13.12 the five probes cost 182
inv (plugin, wave 3) vs 115 (HEAD-text, wave 2). At 0.13.14 the SAME probes on the plugin
channel cost 6+28+20+27+41 = **122 inv** (wave 5) - roughly HEAD-text parity. The gap
appears to track doctrine COHERENCE, not the channel (the wave-1-vs-wave-3 lesson wearing a
channel costume). Not a controlled comparison (different doctrine versions), hence the
re-measure: same five probes, 0.13.17, plugin vs HEAD-text, fixture v2 (rebuilds in ~19s,
deck hashes reproduce byte-exactly).

Record per leg, on the four-rung ladder: **wall-clock, invocations, cache-read, output, and
mean context per invocation.** Wall outranks invocation count now (see METRICS.md's rewritten
lens) - a plugin channel that runs more rounds but lands sooner is NOT convicted. Report leg
wall in absolute terms AND as a share, so the toy-suite distortion (~95% agent overhead)
stays visible rather than baked in.

Two things the probes structurally CANNOT see, and the report must say so: they measure the
plugin's **tax** and never its **insurance**. A conformant agent never trips a hook, so a
clean probe run shows the cost of enforcement and none of its value (the one time the value
showed was tw8's Crew attempting `cat CAPTAIN.md`). If the tax IS real, the cheapest lever
is plugin-side, not doctrine-side: **carry doctrine text in the plugin's agent definitions
instead of making roles load it through the Skill tool** - same text, same hooks, same
isolation, minus ~2 round trips per leg.

## 2026-07-14: REVIEW DOSSIER for the fable doctrine review of 0.13.17

Every decision below was worked out live with dk this session. Grouped by confidence, because
the review should spend its time on the third group.

### Settled by dk's explicit ruling - review for WORDING only, not for the decision

1. **Full-regression economy.** Harbour is the SOLE full-regression trigger. Outbound ships on
   the voyage's own focused/enumeration evidence. Cut: the Captain-skill "offer a full regression
   across all tiers" bullet, the Captain final-report bullet, the two-trigger sentences in the
   Verification policy and the Wake policy, Shipwright's "pre-outbound or the next harbour"
   nets, QM's "or a full regression" run-shape, and two README paragraphs.
   Rationale (dk, worked through in 3 steps): harbour is the only pivot that pairs the run with
   coverage triage and the economy audit, and that pairing is what makes the spend worth paying;
   the same run anywhere else spends the cost and discovers nothing with it. Sequencing
   (ship-then-harbour vs harbour-then-ship) becomes the user's free choice, not a doctrine order.
   **I raised one objection and dk overruled it, correctly:** killing the pre-outbound regression
   also removes the net that stops a live `PERTURBATION` token shipping. dk's ruling: "we worry
   far too much about misplaced perturbations... if they are truly harmless we don't need to hunt
   for them, they will eventually be removed as deadcode, if they are not harmless they will
   eventually cause a red and be sent to crew." No quiescence exception was written. **If the
   reviewer wants to reopen anything, this is the one place a real consequence was knowingly
   accepted.**
2. **Narration.** dk: "there is never a situation where I want silent background runs."
   The rule went through THREE shapes before landing, and the final one is much smaller than the
   first two, because dk kept correcting the frame:
   - I first proposed a cadence clause on QM's voice. dk: smart-but-silent is an internal-role
     token measure, not a Captain constraint; and in skill-only there is no spawning at all -
     Captain, QM, Crew and Boatswain all run in the foreground, so the human already sees every
     command, run and edit. **Silence is not a doctrine defect; it is created entirely by
     spawning with context isolation.** A foreground workflow must not be burdened or confused by
     text describing a problem it cannot have.
   - So the rule binds the ACT of dispatching, not the channel: a spawning-capable skill-only
     agent can choose to spawn, and the moment it does, the human's view goes dark. Conditional
     on spawning, it burdens nobody who runs in the foreground.
   - dk's final refinement: the runtime need NOT surface progress directly to the human; it is
     enough that progress is visible to an ACTIVE SEAT who narrates on a timer, **no more than 2
     minutes**. Option A accepted for skill-only: QM narrates in smart-but-silent (terse, but
     progress IS visible, and Captain explains it all at the end).
   **The load-bearing distinction, which the reviewer should check survived the prose:**
   completion is learned from the REPORT; visibility is served by NARRATION. The seat never wakes
   to find out *whether the work is done* (that is the busy-wait 0.13.16 kills, and exactly what
   pilot #3's QM did); it wakes to *tell the human what it can already see*. Same clock, two
   purposes. If doctrine blurs them, the next role reads the timer clause as permission to poll.
   **Known limit, written into the text:** timer wakes reach the MAIN SESSION only (this harness's
   own finding - a nested agent cannot self-schedule a wake). So the narrating-seat route serves
   the top seat and nothing below it; anything deeper needs the machinery route. Both routes are
   in the sentence deliberately.
   The remaining narration work is PLUGIN work, not doctrine: the plugin isolates the context, so
   the plugin owes the visibility back.

### Settled on my argument, dk did not contradict - review the DECISION, not just the wording

3. **Parallel children.** 0.13.16's "a dispatched agent ends on its report" is singular and never
   names the multiple-concurrent-children case, which is what actually broke in pilot #3. Written:
   *a role MAY dispatch several agents in one turn; it ends its turn, and consumes each report as
   it arrives.*
4. **No legal-polling recipe.** My note originally proposed naming a sanctioned in-turn
   ground-truth check (poll the work product, never transcript internals). **I inverted it** and
   the reviewer should sanity-check that call: writing "here is how to poll legally" would
   re-legitimize the exact instinct that burned two ~9-minute timeouts. Written as a prohibition
   instead: *the report is the only channel that says a dispatched role is done; a role never
   builds its own completion check out of a transcript, a process table, or a working file.*
   Scoped carefully to *inferring completion*, so it does NOT outlaw reading a dispatched role's
   progress for narration - those ask different questions. **That scoping is subtle and is the
   most likely place for a drafting error.**
5. **Flat QM->Boatswain.** dk's own design option, shipped. QM ends in its report naming Boatswain
   + advanced targets + base commit; QM's CALLER dispatches custody; Boatswain reports to Captain.
   Mirrors the foul direction, which already worked this way (a foul re-derives for a fresh QM,
   no return path needed). QM<->Crew stays nested because QM genuinely needs Crew's outcome to
   pick the next red target. Dispatch-contract table collapsed the two Boatswain rows into one
   ("To Boatswain"). **Check the receiver landed:** I added a Captain-workflow bullet making
   custody Captain's dispatch, because a flat hand-off with no receiver is a dropped voyage.
6. **Scenario lanes (@contract / @conformance).** The three-bucket muddle dk raised, resolved as a
   sharper trichotomy than the original note: the distinction is not "does a maintainer care" but
   **what the assertion is ABOUT** - (a) product behaviour (untagged default), (b) the product's
   own mechanical shape/contract, permanent, survives shipping (`@contract`), (c) the project's
   own METHOD, which expires (`@conformance`). `@invariant` was doing jobs (b) and (c) at once and
   is retired into them. Decomposition rule written: **one scenario, one lane** - and the
   feature-file template was changed, because it had been actively teaching the blur (a trailing
   `And the response conforms to the "<schema>" schema` bolted onto a product scenario as the
   RECOMMENDED shape). Also written: a report that counts scenarios counts BY LANE (dk's
   heads-up-display framing: a green product lane beside a red conformance lane is a different
   ship from the reverse, and one blended number tells the reader neither).
   **Naming is mine, not dk's** ("open to ideas" was his word). `@conformance` was chosen to match
   existing vocabulary (the `conformance` command, the verification-conformance rule set).
   **Migration cost is real and unpriced: every fitted-out project's `@invariant` scenarios and
   any tag-filtered command must be re-derived at next refit. Downstream carry, below.**

### Smaller items, all shipped, low risk

7. **Plank-form cross-wire.** The Planking agreement now routes plank form/placement into the
   derived verification-conformance rule set (proven red by a plant at adoption) instead of
   degrading to human-read judgment where no docblock/AST reader exists. Closes the 07-12
   LOW->MEDIUM open item.
8. **Minimal-RIGGING no longer `none`s out user-stated values.** The rule's intent is "don't
   invent"; a value the user said out loud is not invented. Fixes the tw9/wave-4 finding where a
   Captain wrote `none` over the user's explicit "Node 20 + npm".
9. **Carried greens are recordable.** A fresh green in a hand-off appends to the run record as it
   stands. Kills the record-append seam (QM re-running Crew-proven greens purely to author a
   record line) by applying custody's existing evidence-or-rerun principle.
10. **Hook blesses multi-path content-blind staging.** `git add -- <paths...> CAPTAIN.md` now
    passes; the previous "exactly these two forms" taxed the best-behaved batching Boatswain one
    cycle. Implemented by splitting the command on its separators and stripping the path ONLY
    inside a staging segment, so `git add -- src CAPTAIN.md ; cat CAPTAIN.md` still DENIES.
    5 new hook tests cover both directions (131 hook assertions green).

### Deliberately NOT written - the reviewer should confirm these absences are right

- **Voyage-scoping guidance** (1 QM cycle/7 scenarios vs 2 cycles/9 for identical intent, ~25 inv
  apart, clean outcomes both ways). Writing it risks over-constraining a judgment call.
- **QM plank-gap route variance** (three observed routes to the same clean outcome: QM
  self-re-derives, or Boatswain catches it in custody). Declared intentional flexibility.
- **The role-tiered economy lens** (Captain optimizes for visibility, tokens not a constraint;
  QM/Crew minimize invocations). Stays a SHAKEDOWN SCORING LENS in METRICS.md, not doctrine.
  Reason (dk agreed): doctrine gives roles OBLIGATIONS, not optimization TARGETS - a role told to
  "minimize invocations" will skip a verification run to save a round. The obligations already in
  doctrine (never rerun a proven green, batch one seam into one dispatch, never end a turn
  waiting) buy the same economy with no perverse incentive.
- **Model tiering / the pin leak.** Standing decision: harness-only, never doctrine text.

### Risks I am flagging against my own work

- **The narration/turn-discipline seam is the sharpest thing in this diff.** Two rules, one clock,
  opposite purposes. Read the Narration section and Hand-off custody together and check they
  cannot be read as licensing a poll.
- **`@invariant` retirement is a breaking vocabulary change** with an unpriced downstream cost.
- **The perturbation net was knowingly removed** (see item 1).
- **The full-regression cut touched 9 sites across 5 files plus the README.** `tests/homes.sh`
  caught one real break (I dropped the named "Selection MAY narrow intermediate confirmation"
  principle that Shipwright cites by name; restored). A second pair of eyes on the remaining
  cross-references is worth the spend - `grep -rn "full regression\|pre-outbound\|@invariant"`
  comes back clean, but clean greps are not a coherence proof.

## The five queued items, as they stood before this session (kept for the reviewer's context)

1. **Full-regression economy (dk's ruling, worked out live in 3 steps, see dated
   section below)**: cut the Captain-skill "offer a full regression across all
   tiers" bullet entirely; reword the Verification agreement's "the pre-outbound
   full regression and the harbour full regression always run whole" so harbour is
   the SOLE full-regression trigger - outbound proceeds on selective/focused-run
   evidence by default. Audit any place assuming "pre-outbound full regression" is
   a distinct concept for stale references.
2. **Narration ruling (dk's ruling, "there is never a situation where I want silent
   background runs", applies to real Captain use too)**: fold into 0.13.16 item 5's
   wording - "surfacing progress" must mean literal narrated text reaching the
   human on a cadence, never merely an internal report consumed at the end, and
   never a status/task-list UI element standing in for it.
3. **HIGH: Monitor-tool orphan stall on a NESTED agent** (see dated section below) -
   a QM leg ended its turn on an armed `Monitor` wait after dispatching parallel
   Crew children, and was confirmed genuinely stopped (`SendMessage` response:
   "Agent was stopped (completed); resumed it in the background") until the
   operator manually nudged it. Same failure class as the pilot-#2 fork stalls, now
   proven on a real Shipshape role, not just the harness runner seat. Needs a
   concrete doctrine answer for how a role should legally consume multiple async
   dispatch results without ending its turn on an unconsumed wait.
4. **Follow-on: self-devised sync marker is unreliable** (see dated section below) -
   after being warned off Monitor, the same QM leg invented a foreground Bash poll
   checking dispatched agents' transcript files for a `"type":"result"` JSONL
   marker that DOES NOT EXIST in this runtime's transcript format, burning a full
   ~9-minute timeout twice in the same leg (once self-recovered, once operator
   intervened to save the second wait). Needs a sanctioned in-turn ground-truth
   check named in doctrine (check the dispatched agent's actual work product - tree
   state, a fresh rerun of its target - never transcript internals, which are not a
   stable contract). dk raised a complementary design option (2026-07-14, mid-pilot):
   decouple QM->Boatswain into a flat, symmetric hand-off mirroring the
   already-working foul->fresh-QM direction (Boatswain already routes a foul to a
   FRESH QM with no shared context needed - making green->Boatswain equally flat
   removes the wait for that leg entirely); QM<->Crew stays nested since QM
   genuinely needs Crew's outcome to decide the next red target, but the QM<->Crew
   PARALLEL case (2+ concurrent children) still needs a named, trusted consumption
   pattern - the trouble started specifically at the first parallel dispatch, where
   QM didn't trust plain turn-ending to resume it and reached for Monitor instead of
   the plain sequential pattern (dispatch, end turn, trust auto-resume) that worked
   flawlessly every single-child time this pilot.
   **INDEPENDENT REAL-WORLD CONFIRMATION (dk, 2026-07-14, Estelle):** the identical
   failure class - QM using Bash to figure out whether Crew is done - is live in
   Estelle, not just this pilot's sim tree. This is not a pilot artifact; it is a
   real, observed production gap. dk confirmed this covers QM->Boatswain as well as
   QM->Crew - this pilot hit the SAME broken-poll-marker pattern on BOTH dispatch
   targets (once waiting on parallel Crew, once waiting on Boatswain custody), so
   the fix is not Crew-specific: any role a QM (or any dispatcher) waits on is in
   scope, which is also exactly why dk's flat-handoff proposal for QM->Boatswain
   above is one legitimate partial answer, not the whole fix - QM->Crew still needs
   its own reliable answer since it can't be flattened the same way. dk's framing
   raises the bar on the fix: doctrine
   needs a genuinely RELIABLE subagent-orchestration and results-harvesting pattern
   for a role dispatching and awaiting another role's work, and it needs to hold
   **whether the dispatch channel is the skill-only generic baseline (any
   subagent-capable runtime) or this specific open-plugin's own mechanisms**- not a
   narrow patch scoped to "don't use Monitor" or "don't grep transcript internals."
   The skill-only baseline's existing quality guardrail (no model/tool names in
   doctrine text) means this pattern must be described in terms of the DISPATCH
   CONTRACT's own vocabulary (a role's turn, a final report, a hand-off) rather than
   any one runtime's tool surface - whatever concrete mechanism a given runtime
   offers underneath, the doctrine-level rule is the same: dispatch, end your turn,
   consume the report when resumed, never invent your own completion-detection
   mechanism. This is now the highest-priority item in this queue.
5. **Scenario categorization** (dk, 2026-07-14, raised mid-pilot as a design question,
   not yet a ruling): three scenario buckets are currently blurred together with no
   clear vocabulary distinguishing them - (a) PRODUCT-INTENT scenarios, ordinary
   Captain-authored behavior a real user cares about; (b) SCANTLING/CONTRACT-
   ATTESTATION scenarios, methodology conformance the framework cares about
   (watchbill-shape conformance, perturbation quiescence, plank-form/coverage rules),
   partially tagged `@captain @invariant` today via the derived conformance rule set,
   but the tag alone doesn't communicate "this is process attestation, not product
   behavior" to someone scanning a feature file or watchbill; (c) DEV-ONLY
   VERIFICATION SCAFFOLDING, checks that matter only while actively fitting out/
   harbouring a project (plank-coverage derivation itself, methodology scaffolding),
   not even something a maintainer cares about once stable, let alone an end user.
   No existing tag distinguishes (a) from (c), and (b)'s `@invariant` tag doesn't
   self-explain its own category to a reader.
   **Sharper follow-on (dk, same session): (a) and (b) can live inside the SAME
   behaviour, not just the same feature file.** A single seam - e.g. "creating a
   resource via an API call" - naturally splits into a product-facing assertion
   (the resource is created, which the user genuinely cares about) and a separate
   contract-attestation assertion (the request/response conforms to the API's own
   schema/spec, which only the framework or maintainer cares about). Bundling both
   into one scenario blurs the exact distinction at stake: a reader can't tell,
   from one scenario asserting both "resource exists" and "matches schema X,"
   which half is product intent and which half is process attestation. This argues
   for scenario-level DECOMPOSITION as part of the fix, not just tag vocabulary -
   two scenarios (or a scenario plus a linked scantling check) per such seam, each
   purely one category, rather than one mixed scenario. Candidate angle for the
   fable session: name and document the three-way distinction explicitly (tag
   vocabulary and/or a feature-file convention), audit whether `@invariant` should
   also gain a reading note, check whether reports/watchbills should surface which
   bucket a
   scenario is in rather than leaving it implicit in tag combinations.

## 2026-07-14: pilot #3 CLOSED at 28/29 (dk's word) - main-loop runner architecture proven, doctrine SOUND, two runtime findings + one design fix routed

Closed by dk's explicit word after oracle run 3 landed 28/29 (matching attempt-2's
best result, at ~440 invocations vs attempt-2's 717 to the same score - see full
numbers in METRICS.md "Pilot #3"). Iteration 4 (a sharper reload-anchored DOM-identity
framing for the sole residual, "Persistence > should persist its data" - the same
detached-DOM signature attempt-2 diagnosed as a tier-observability boundary) got as
far as a drafted, unbuilt spec+watchbill before dk called the stop; queued as a
next-pilot starting point rather than built now.

**What this pilot proves:** the 0.13.14/0.13.15 doctrine text itself is sound under
real load - every actual verification/build/custody decision across 4 Captain legs,
3 QM voyages, 6 Crew legs, and 3 Boatswain legs was correct (custody-foul catch and
routing, parallel-mate collision caught by ordinary verification, tier-economy
choices, honest zero-defect QM findings). The main-loop runner architecture (no fork
delegation, ever) held: every stall this pilot was a ROLE inventing its own ad-hoc
wait mechanism inside a nested agent, never the runner/main-loop seat itself
orphaning - a structural improvement over pilot #2's fork-stall class, though not a
complete fix (see the two findings below, both routed to the next session).

**What needs fixing, all queued at the top of this file, none shipped mid-pilot:**
full-regression economy (dk's ruling), mandatory narration (dk's ruling), the
Monitor-orphan-stall + broken-poll-marker pair (HIGH, with dk's flat-handoff design
option), and scenario categorization (dk's design question, product-intent vs
scantling-attestation vs dev-only scaffolding, including same-behaviour
decomposition). Doctrine 0.13.15 itself is UNTOUCHED this session (verified: `git
-C ~/shipshape status` clean at d31b22f throughout) - this was a pure shakedown run,
zero doctrine edits, per the standing ship-first rule.

## 2026-07-14: pilot #3, follow-on finding - QM invents an unreliable self-devised sync marker, twice, after being warned off Monitor

Same iteration-3 QM leg (agent a2f1d9c7175a04c31), after the operator's explicit
warning in its dispatch text not to end its turn on a Monitor wait: QM correctly
avoided ending its turn (a genuine improvement - confirmed via `TaskOutput` showing
`status: running`, not stopped), but the mechanism it invented instead was a
foreground `Bash` poll loop (`until ... grep -q '"type":"result"' ... sleep 3;
done`) checking the dispatched Crew/Boatswain agent's own JSONL transcript file for
a `"type":"result"` marker. **That marker does not exist in this runtime's
transcript format** - entries are `"type":"assistant"`/`"type":"user"`, never
`"type":"result"` - so the condition can never match. QM burned its full timeout
(550s / ~9m10s) waiting on a condition that was true (the Crew leg had genuinely
finished within seconds) but unobservable through the marker it chose. It then
self-recovered correctly at the timeout: stopped the timed-out task, fell back to
checking ground truth directly (`git diff`, focused reruns, full suite) rather than
trusting the broken mechanism - no operator intervention needed for THIS recovery.

It then dispatched Boatswain and used the **identical broken poll condition again**
on the new agent's output file. The operator, having already verified the marker
format is universally absent (not file-specific), intervened proactively this time
- Boatswain had already finished and committed (64ca588) - to save a second ~9-minute
wasted wait, rather than let a known-unwinnable poll run to timeout twice in one
leg.

**Reading:** this is NOT the same HIGH stall class as the Monitor finding above (QM
never orphaned itself - it stayed within its own turn both times, so no external
resume was structurally required). It IS a distinct, real inefficiency: a role
inventing its own synchronization primitive from a plausible-looking JSONL field
name that happens not to exist, with no doctrine or harness guidance on how a role
should legally confirm a dispatched agent's completion from inside its own turn.
Candidate angle for the same doctrine-package session as the Monitor finding: name
a sanctioned in-turn ground-truth check (e.g. "poll the dispatched agent's actual
work product - tree state, an explicit rerun of its target - never the transcript
file's internal format, which is not a stable contract") rather than leaving roles
to reverse-engineer transcript internals under time pressure. Routed alongside the
Monitor-stall HIGH finding, not shipped.

## 2026-07-14: pilot #3, HIGH finding - the Monitor-tool orphan stall is a NEW instance of the 2-for-2 stall class, now hitting a NESTED agent

During pilot #3 iteration 2 (voyage 2, todopilot4), QM (agent ac335d299eccbca74)
dispatched two Crew agents in PARALLEL for two disjoint seams (rendering-identity
fix, edit-visibility fix) - itself a positive finding, the shared-deck batching
behaviour working correctly. After dispatching both, QM ran one bounded `sleep 60`,
then used `ToolSearch` to find and arm the `Monitor` tool (the sanctioned mechanism
for watching nested completions without a raw poll loop) instead of continuing to
poll. It then ended its turn on "holding for monitor notification."

A task-notification fired minutes later reporting QM's task as **"completed"** with
final text "Waiting for the monitor task to confirm and exit" - while both dispatched
Crew legs had, by that point, actually finished their work (confirmed by mining
their transcripts: both idle, no new activity for minutes). The operator queried
`TaskOutput` on the two Crew task IDs directly and got "No task found" - only QM's
own task ID remained queryable, and the harness's own agent-listing showed QM as a
resumable-but-stopped background agent, not one that would resume itself. The
operator sent QM a manual `SendMessage` nudge; the tool response confirmed explicitly:
**"Agent was stopped (completed); resumed it in the background with your message."**
QM was genuinely dead until manually resumed - not silently working and about to
report.

**This is the SAME failure class as the pilot-#2-attempt-2 fork stalls (CAPTAIN.md,
2026-07-13/14: "a turn that ends on a live background task does not auto-resume
when that task completes"), now confirmed for a THIRD trigger mechanism (raw
backgrounded Bash, a bare Agent-tool wait, and now the `Monitor` tool) and for the
first time observed on a NESTED agent rather than the main-loop runner itself.**
The prior two instances were both main-loop-seat stalls the operator caught by
mining on notification per the runner architecture; THIS instance is different in
kind - it is a Shipshape ROLE (QM) exhibiting the exact stall shape from inside a
real Shipshape voyage, not a harness/runner-seat problem. It directly contradicts
the 0.13.14 turn-discipline text ("A role never ends its turn waiting - not on a
background command, a notification, a timer, or another agent") and would have
been a silent, permanent stall in any run where the operator was not actively
mining every nested-agent transcript on a tight cadence - i.e. in ordinary real
usage without a shakedown-grade operator watching this closely, this voyage would
have died here with no auto-recovery.

**Severity and routing:** HIGH, doctrine + runtime seam, not yet fixed. Candidate
angles for the next session (not shipped, dk's word owed): (a) doctrine-side - the
turn-discipline sentence already forbids this in principle ("never ends its turn
waiting... on another agent"); a QM that dispatches multiple parallel children
needs concrete wording for HOW to consume multiple async results without a
tool-assisted wait if the runtime offers no synchronous multi-agent join; (b)
harness-side question for dk: does `Monitor`'s condition, when it fires, resume
ONLY the main session (like ScheduleWakeup/timers, per the standing 2-for-2 orphan
note) or is there a difference between "the agent's own turn already returned control
before the condition could fire" vs "the tool structurally cannot resume a nested
agent at all" - worth a targeted test outside a pilot to isolate; (c) process
question: should the operator's mining cadence treat "task shows completed with
suspicious wait-language in its final text" as an automatic resume-trigger, folded
into the runner architecture's play-by-play rules, rather than something caught by
the operator's judgement this one time. Not shipped - routing to dk alongside the
full-regression-economy and narration-ruling items above.

## 2026-07-14: dk sharpens narration ruling - ALWAYS, no exceptions, applies to real Captain use too

Mid-pilot-#3, dk ruled (verbatim intent): "there is never a situation where I want
silent background runs" and this applies to "normal shipshape captain and her in
shakedown too" - not just this harness's runner. This CONFIRMS and HARDENS the
0.13.16 draft item 5 candidate wording (role-tiered economy + timer-wake, drafted
2026-07-14 morning) from "candidate awaiting nod" to a settled requirement: the
human-facing seat (Captain, or any dispatcher a human is watching) must never let
a turn go by with dispatched work in flight and nothing surfaced to the human -
completion notifications are not the only legal narration point; while work runs,
narrate. Two operator-side misses this session that prompted the ruling: (1) using
TaskOutput's raw JSONL block dump as the "status update" instead of mining it down
to plain text first - technically not silent, but unreadable noise, correctly
read by dk as no narration at all; (2) reporting via the TaskList tool's structured
todo view alone with no accompanying prose - a task list is not narration, it does
not say what is happening right now in words a human reads. Fix applied live this
session: mine with bin/mine.sh (or equivalent compact tooling) into a short plain-
English paragraph every wake, never raw transcript, never a bare tool-list; wake
interval dropped to the runtime's 60s floor. NOT shipped to doctrine yet (mid-pilot,
no side-scope rule holds) - fold into the 0.13.16 package after this pilot closes:
the wording there should make explicit that "surfacing progress" means literal
narrated text reaching the human on a cadence, not merely an internal report that
gets consumed at the end, and not a status/task-list UI element standing in for it.

## 2026-07-14: dk's full-regression-economy ruling - ONLY harbour ever runs a full regression

Mid-pilot-#3, sparked by a real-world observation (Estelle's Captain ran a full
regression across all tiers via a fresh QM cycle, citing the Captain-skill "offer"
bullet, instead of routing to Shipwright harbour). dk's reasoning, worked through
live in three steps, lands on a firm ruling:

1. **The Captain-skill offer bullet is a third, uninstrumented full-regression
   trigger that shouldn't exist.** SKILL.md text: "If Boatswain reports passing
   verification, clean working tree, and local commit... If no discovered work
   remains, also offer a full regression across all tiers, run through a fresh QM
   cycle... this is a QM cycle, not a harbour entry." Unlike harbour, this trigger
   carries no coverage analysis, no weather-record feed, no economy accounting -
   it is a bare rerun offered reflexively at voyage-end. Its only real value
   (catching a break in an untouched opt-in tier while it's still cheap to
   bisect, before it goes stale across several more voyages) is real but marginal,
   and doesn't justify a standing doctrine offer that competes with harbour's own
   properly-instrumented full-tier pass.
2. **It directly conflicts with the Verification agreement's own economy
   sentence:** "Selection MAY narrow intermediate confirmation, never terminal
   proof: the pre-outbound full regression and the harbour full regression always
   run whole." That sentence names TWO mandatory full-regression triggers
   (pre-outbound AND harbour). The Captain-skill offer is a THIRD, informal one
   layered on top - internally inconsistent with the two-trigger framing already
   in the shared Articles.
3. **dk's full ruling supersedes even the "two mandatory triggers" framing:**
   pre-outbound should NOT force a full regression either. Outbound ships fine on
   selective/focused-run evidence alone - that IS the round-economy default
   working as intended. A full regression is ONLY ever a harbour action, because
   harbour is the only place it comes bundled with coverage analysis and economy
   instrumentation that makes the expensive spend worth it. Sequencing between
   outbound and harbour becomes the user's free choice, not a doctrine-forced
   order: ship now and harbour later (accepting selective evidence for this
   release), or harbour first if a full sweep before shipping is wanted this
   time. Full regressions are expensive; doctrine must never trigger one without
   the coverage/economy accounting that harbour provides.

**Doctrine package for next session (dk's word: "fix with a fable run after pilot
analysis"):** after pilot #3 closes and its analysis is delivered, a follow-up
session (fable model, per dk's standing model-tiering note that analysis/design
work runs fable while shakedown probes run sonnet) edits:
- Captain skill: remove or fold the "offer a full regression across all tiers"
  bullet entirely - no QM-cycle full-regression path should exist outside harbour.
- Shared Verification agreement / Articles: reword "the pre-outbound full
  regression and the harbour full regression always run whole" to name harbour as
  the SOLE full-regression trigger; outbound proceeds on selective evidence by
  default, full stop.
- Any place referencing "pre-outbound full regression" as a distinct concept
  (e.g. the Wake policy's weather-record note, if it assumes a pre-outbound run
  exists) needs a matching audit for stale references.
Not shipped now - mid-pilot, no side-scope rule holds absolute. This is the
scoped, pre-approved fix-cycle item for the very next session, ahead of whatever
else is queued (0.13.16 draft, pilot #3's own findings).

## Doctrine history 0.13.9 -> 0.13.15 (condensed 2026-07-14 - full wave-by-wave
narrative, per-leg numbers, and hook-shape findings live in git log + METRICS.md;
this trims ~1000 lines of fully-shipped, fully-superseded detail per dk's word not
to carry old baggage forward)

All items below are SHIPPED and validated live on the installed-plugin channel
unless noted. Version -> commit -> one-line outcome:

- 0.13.9 (HEAD-text pilot #1 era): strike-guard corroboration, wake voyage run
  record. First TodoMVC pilot: 517 inv, oracle 0/29 -> 18/29 after one iteration.
- 0.13.10 (c045b46): notes-custody hook alignment, batching SHOULD-strength,
  foul-to-fresh-QM re-derivation, canonical run-record example line, plant-red at
  QM/promotion. Five seam probes 5/5 PASS post-restart (wave 2, HEAD-text) after a
  channel-integrity HIGH finding (plugin snapshot is process-level, /clear doesn't
  refresh it - the AGENTS.md channel-verification rule was born here).
- 0.13.11 (26ca239): pathspec-limited Captain notes-commit, content-blind Boatswain
  staging, supersede-preferred disposal, command-fidelity rule. Wave 3 (first real
  plugin-channel firing): 5/5 pre-approved probes PASS, coherence-vs-token-thrift
  finding (-36% inv on coherent text at equal channel cost).
- 0.13.12 (de24fa7): scope-out blocking gate, greenfield fast path (5 required
  values, no methodology checks on voyage 1). Wave 3 extension: 8/8 legs incl. first
  live scope-out-gate firing and a tainted fast-path leg (cockpit-echo leak, clean
  re-run owed).
- 0.13.13 (49942d9): access-not-mention hook precision, minimal-RIGGING example
  block (examples bind, key lists don't), report-contract fidelity. Wave 4: 3/3
  spot-validations PASS incl. supersede CHOSEN LIVE first time (4th invitation,
  design-rule fix confirmed); model-pin-survives-only-till-first-async-resumption
  mechanism nailed.
- **Pilot #2 (0.13.13, todopilot2): PAUSED at leg 2** on a HIGH runtime deadlock -
  QM's nested background Bash sweep exceeded the ~2m foreground cap, auto-backgrounded,
  and the completion notification orphaned into a dead nested-agent chain (turn had
  already ended). Root-caused via full transcript reconstruction: Captain's zero-blocker
  real-browser tier choice (fast-path text absorbed the very methodology check pilot.md
  wants routed) made the census expensive enough to hit the cap. Three fixes drafted.
- 0.13.14 (670f3ab): turn discipline ("a role never ends its turn waiting"),
  census-to-dispatch, tier economy (cheapest-sufficient-tier default, A2). Efficiency
  battery ("wave 5"): 7/7 probes PASS incl. the purpose-built slow-census regression
  test for the pilot-#2 deadlock, clean with harness belt-and-braces lines withheld -
  confirms the DOCTRINE TEXT ITSELF (not just operator hygiene) prevents the class.
- **Pilot #2 attempt 2 (0.13.14, todopilot3): 717 inv to 24/29**, then an operator-side
  oracle-harness bug found and fixed (sinon `spy.reset()` removed in sinon 5, the
  vendored oracle's own package.json floats to modern cypress/sinon; fix vendored as
  `fixtures/oracle/spy-reset.patch`) - same app bytes re-graded **24/29 -> 28/29**.
  Iteration-6 reachability check (excluded from clean accounting, fable-session
  conditions) confirmed the last residual (Persistence detached-DOM) as a
  TIER-OBSERVABILITY BOUNDARY (real-Chrome async re-render jsdom can't see), not an
  app defect - the 0.13.14 tier-escalation escape hatch is the sanctioned route.
  Two runtime HIGH findings (both harness/runtime-seat, not doctrine): the
  coordinating fork twice ended its own turn on a live background task and stalled
  for hours until manually resumed - CONDEMNED delegated-fork orchestration for
  pilots; the main-session runner architecture (this file's binding pilot.md
  section) is the fix, proven first in iteration 6 and fully in pilot #3 below.
- 0.13.15 (d31b22f): artifact-kind outranks directory in write custody (a `.feature`
  file is the Captain's spec wherever it sits); fitting-out derives verification as
  the narrowest support directory, never a parent of specs.

Positive threads that held across every wave: contamination bulkhead (role refusal +
hook denial, falling cost); parallel Crew shared-deck design (verification is the
detector, no worktrees needed - validated again live in pilot #3); custody-foul
re-derivation and routing; round-economy discipline once text and hooks agree.

## Open items (trimmed 2026-07-14 - superseded 2026-07-12 handover/session-close
detail cut; git log + METRICS.md carry the full history)

- dk owns, still unresolved: jolly validation (real project, slow suite), model-
  tiering defaults (haiku custody outcome-safe but economy-leaky; sonnet economy-
  conformant), remote for this repo.
- `npx plugins doctor` prints "No plugins found" from any cwd while
  installed_plugins.json and cache are correct - upstream CLI quirk, unreported.
- Plank-inventory form/placement check (2026-07-12, LOW->MEDIUM, unresolved): grep-
  only plank-form checking degrades to human-read judgment (can't verify docblock
  FORM beyond a crude regex, can't verify PLACEMENT at all). A parser-backed checker
  under QM is legal today (Scantling agreement's bespoke-checker clause) but the
  Planking agreement and the derived conformance rule-set mechanism aren't
  cross-wired, so nothing prompts deriving one. Candidate: (1) cross-wire sentence
  routing plank-form into the derived rule set, proven red by a planted
  line-comment plank; (2) named-engine catalog entry for docblock inventory (jsdoc
  -X; acorn-backed bespoke checker).
- The shakedown repo is doctrine/plugin-consuming only; ~/shipshape stays
  doctrine/plugin-only (no notes, no sim artifacts). Binding behaviour lives in the
  doctrine skills; procedure lives in AGENTS.md and scenarios/; numbers live in
  METRICS.md; this file carries decisions and open items only.

## Shakedown log (trimmed 2026-07-14 - pilot #1's doctrine queue, the 0.13.11
candidates, and the 2026-07-12 probe pairs are ALL shipped/resolved by 0.13.11-0.13.12
per the condensed doctrine history above; full narrative in git log pre-2026-07-14
CAPTAIN.md history and METRICS.md's "TodoMVC pilot baselines" + "0.13.10/11/12 probes"
sections. Repo published to https://github.com/dmytri/shipshape-shakedown (private),
main tracks origin.)

## Standing decisions (dk's; do not revisit without the named change)

- Standards adopt WHOLE, never modified or adapted (2026-07-18): an adapted
  standard defeats the purpose - a standard is an anchor at file granularity and
  a house variant activates nothing. Conflicts with our articles resolve by
  filling the standard's shape truthfully from the tree, not by reshaping it.

- Operator/pilot-runner discipline (2026-07-13, dk, "latency is part of the test"):
  latency and invocation accounting during a pilot is a MEASURED OUTCOME, not
  incidental - the operator (or an operator-delegated fork) must not introduce its
  own extra work mid-pilot that isn't part of the doctrine being tested, because it
  warps the very numbers the pilot exists to produce. Concrete instance: pilot #2
  attempt 2's coordinating fork began running the oracle's Cypress suite against a
  reference implementation (Backbone) as a self-devised "control" to sanity-check
  the oracle harness before trusting todopilot3's failures - dk killed it
  ("DON'T TEST THE HARNESS FFS"). The instinct (distinguish real defects from
  harness/environment flakiness) was reasonable engineering judgment in isolation,
  but wrong for a pilot: it is operator-invented scope outside the dispatched
  procedure, and it silently taxes the latency/invocation numbers the pilot reports.
  Rule for future pilots: the operator dispatches and mines exactly the specified
  procedure (scenarios/pilot.md, prompts/pilot-dispatches.md) and reports what it
  finds; it does not add its own side-investigations, control runs, or verification
  apparatus mid-pilot no matter how well-reasoned, even when done cheaply on the
  operator's own turn rather than via a new role dispatch. Oracle failures get taken
  at face value and iterated on directly (translate to product-language spec
  feedback, quarantine intact) rather than triaged through operator-built tooling.
  If the operator has a genuine methodology concern, it routes it to dk as a
  question/finding afterward - it does not act on it mid-run.
- Pilot completion bar (2026-07-13, dk): "take the spec, make an app that passes all
  the tests, that's the whole point" - a pilot iterates autonomously (spec/watchbill
  amendment -> QM -> Crew -> Boatswain -> re-grade) until the oracle actually passes,
  not just until one product-language iteration lands some improvement. Pilot #1's
  stop at 18/29 after one iteration (9 residual failures, further iteration left as
  an unexercised "dk's call") was UNDER the real bar, not an example of where to stop
  - a real project might reasonably pause for user confirmation between iterations,
  but a pilot has no such reason to stop early: the whole point is measuring whether
  the harness can close the loop against an objective target unattended.
- Model pinning is harness-side only (2026-07-13): shakedown dispatches MAY pin
  `model`; the upstream shipshape skill-only baseline stays model-agnostic — no model
  names, tiers, or pinning guidance in doctrine text, ever. The async-resumption pin
  leak is a runtime concern to mine and report, never a doctrine candidate (tw8's
  cockpit-echo pin stays correctly classified as non-doctrine).

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

- **0.13.16/0.13.17 (BREAKING for fitted-out projects):** `@invariant` is retired into
  `@contract` (product's mechanical shape) and `@conformance` (project's own method). Every
  fitted project's `@invariant` scenarios and any tag-filtered command re-derive at next
  refit. Also carry: harbour is the sole full-regression trigger (outbound ships on
  selective evidence), the flat QM->Boatswain hand-off, the wait-on-a-signal rule, the
  no-self-devised-completion-check rule, and one-scenario-one-lane decomposition.
- Jolly and Estelle re-derive at next refit: everything 0.13.0-0.13.9, notably
  watchbill as sole QM channel, thin dispatch, broad/coverage without fail-fast,
  @invariant rename, planted-red vocabulary, trace-selected recheck, decision-table
  custody, runrecord slot in RIGGING, no-pre-check credentials.
- Pilots owe live-fire evidence: weather record, behaviour-identity duplication
  check, @eval tier, verification-economy audit at scale (TodoMVC pilot covers most).
- Open infra fork: automated live-agent bulkhead conformance harness vs the
  fixture-matrix proof in shipshape tests/bulkhead.sh - the probe catalog's
  contamination/bulkhead probes are the current answer; build more or accept.

## Inbound from Jolly (2026-07-14): the Bash custody hook does not hold the bulkhead

From Jolly's Captain. Live-fire finding, not theory: TWO QM roles were contaminated by
this vector today, in one session, and both were discarded mid-target. The second one
established the mechanism and refused to write a single step definition, which is the
behaviour the Articles want and the reason this is a hook fault and not a QM fault.

**The claim `.ignore` makes is false.** Jolly's `.ignore` asserted it kept Captain-only
notes out of crew-visible search "by construction". It does not. Six vectors reach
`CAPTAIN.md`; only bare `rg` is covered:

| vector                           | reaches the notes |
|----------------------------------|-------------------|
| `rg -l -e . .`                   | no (`.ignore` respected) |
| `rg -l --glob '*.md' -e . .`     | YES (`--glob` outranks the ignore rule) |
| `rg -l --no-ignore -e . .`       | YES |
| `rg -l -e . *.md`                | YES (a shell glob defeats ripgrep itself) |
| `grep -rl -e . .`                | YES (no `--include` needed at all) |
| `grep -rl --include=*.md -e . .` | YES (GNU grep never reads `.ignore`) |

No ignore-file can deliver this guarantee. GNU grep does not read `.ignore`, and an
explicitly named path outranks any ignore rule, so "use rg" is not a sound rule either.
`bash-custody.sh`'s own comment already concedes it: "a broad search that surfaces the
file without naming it stays with skill discipline." Discipline is what failed.

**The patch is built and proven, and NOT installed.** dk ruled: no plugin-cache edit in
Jolly, carry it here instead. Splice point is immediately after the `notecheck` deny block
in `bash-custody.sh`. Proof against the installed hook: it ALLOWS all six vectors above;
the patched hook DENIES all six, still PERMITS the eight ordinary search and build forms,
still denies named access, and applies to internal roles only, so Captain is unaffected.
The recovery message names a safe form. Proven-safe: `rg <pattern>`, `rg -t md`,
`rg --hidden`.

- Guard body: `incoming/jolly-bulkhead/guard.sh`
- Proof harness: `incoming/jolly-bulkhead/prove.py`
- Natural upstream home for the proof: `tests/bulkhead.sh`, which the open infra fork in
  Downstream carry already names.

**Two related findings, both unverified, both worth a look here rather than in Jolly.**

- The native Grep tool likely has the SAME hole. Its guard denies only when the payload
  CONTAINS the filename; a Grep call with pattern `foo` and glob `*.md` names neither the
  file nor a token. This is the tool an internal role reaches for FIRST. The underlying
  `--glob` override is proven; the harness passthrough is not, because Shipwright had no
  Grep tool to drive.
- A derived command that selects NOTHING exits 0 and reads as a pass. Jolly's `focused`
  could not select an `@eval` target at all (the default profile's `not @eval` ANDs with
  the CLI tags), so every `@eval` target "proven" through it was never run. Jolly refitted
  `focused` to run on a tag-free profile and to exit 1 when zero scenarios are selected.
  The same latent false green sits in `broad-*` and `coverage-*`. If the Rigging read
  contract is going to derive commands, it should require that selecting nothing reddens.

Jolly holds two `@captain` skeletons asserting the hook denies the six reaching vectors
and permits the three covered ones. They stay unpromoted until the patched hook lands.
They assert hook deny/permit rather than search result sets on purpose: a step definition
asserting "the notes file is absent from this result set" must NAME the notes file, and
the Read/Grep/Glob guard then blocks QM from writing or reading its own step definition.
Pre-clear that before promoting anything of the same shape here.
