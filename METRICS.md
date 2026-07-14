# Metrics: how to read a shakedown

## The three numbers per leg (bin/mine.sh on the task transcript)

- invocations: model API calls (grouped by message.id). The primary cost driver -
  each re-prefills the whole context (~50-80k cache-read on sonnet legs).
- output tokens: reasoning + report. Small (5-15k/leg); NOT the cost driver.
- wall: first-to-last timestamp. ~95% agent overhead on toy suites, so wall tracks
  invocations x model speed, not verification.

Record all four per leg, plus MEAN CONTEXT PER INVOCATION (cache_read / invocations). That last
number decides whether a leg's extra rounds are cheap-and-fast or fat-and-slow; without it,
invocation count silently stands in for two things it may not track.

The old shorthand "token cost ~= cache_read x invocations; latency lever == token lever == fewer
rounds" is RETIRED (dk, 2026-07-14): it holds only while context per invocation is constant. It
is not. More small, low-context, fast invocations can beat fewer large costly ones on BOTH wall
and tokens. Invocations are a PROXY for the two things actually paid, never the target itself.

## Suite executions (bin/runs.sh on the project)

The runlog BeforeAll hook logs every EXECUTING cucumber run (dry-runs excluded - they
run no hooks). Duplicates of the same argv with no intervening tree change = redundancy.
Attribute phases by line ranges (record the count between legs).
Fixture v2 (2026-07-13): the log sinks out-of-tree at `<parent>/.instrument/<tree>/runs.log`
(roles wiped in-tree logs/ as scratch in wave 3); bin/runs.sh reads the sink first and
falls back to logs/runs.log for pre-v2 trees. The fixture runrecord homes at the project
root (`runrecord.jsonl`, gitignored), not in logs/. Uninstrumented states (fast-path
empty repos) count runs by transcript grep instead.

## Baselines (2026-07-12, sonnet, tidewatch fixture, doctrine 0.13.x)

| Leg | Invocations | Cache-read | Out | Wall |
|---|---|---|---|---|
| Shipwright fit-out (0.13.6) | 36 | 2.95M | 37k | 8.2m |
| Captain (0.13.6) | 13 | 610k | 8.9k | 1.4m |
| Captain (0.13.8, round economy) | ~10 tool uses | - | - | 44s |
| QM + foreground Crew (0.13.6) | 25 (incl 4 wasted polls) | 1.30M | 14k | 3.5m |
| Boatswain custody (0.13.7 table) | 15 | 712k | 10.6k | 2.6m |
| Boatswain custody haiku | 14-16 | ~500-600k | 6-8k | 1.4-2.2m |
| custody-fresh-session probe (0.13.8 plugin channel, row-1 inherit) | 14 | 623k | 15.8k | 3.0m |
| strike probe, hand-off control (0.13.8 plugin channel) | 13 | 614k | 13.7k | 2.9m |
| stale-record probe (0.13.8 plugin channel, void + rerun by trace) | 27 | 1.47M | 15.9k | 4.0m |

Suite executions: fit-out ~8-11; voyage 14 (0.13.3) -> 8 (0.13.6) -> 3 (0.13.8 with
wake run-record: one red classify, one Crew-local, one QM terminal green; custody ran
zero). Probe pair 2026-07-12: row-1 inherit 0 executions, hand-off strike 0, stale-record
1 (exactly the owed focused rerun; argv in runs.log matches the focused shape).

Full voyage 0.13.8 (Captain + QM/Crew + fresh-session custody): 35 invocations,
~1.53M cache-read, ~17k out, ~5.6m wall. Same intent on 0.13.3: 15.7m.

## Pilot #3 (2026-07-14, sonnet, installed-plugin channel, doctrine 0.13.15, todopilot4, main-loop runner architecture)

First pilot run under the 0.13.14/0.13.15 doctrine AND the pilot.md runner architecture
(main-session-loop only, no fork delegation, timer-wake narration, mine-on-every-
notification). Fresh scaffold (empty repo + vendored app-spec.md + app-template.index.html,
commit 497c74f). Oracle pinned ff43b02e with the fixtures/oracle/spy-reset.patch applied
from the start (no in-run oracle-harness bug this time — attempt-2's fix ships as a fixture
now). Channel verified: 0.13.15 doctrine live (tests 203/203 green pre-run); the specific
0.13.15 write-custody/Cucumber-layout marker did not fire this pilot (this project's
`verification: tests` layout sits beside, not nested under, `specs: features`, so the new
rule's exact trigger condition never arose — not a gap, just an untouched seam this run).

**Voyage (bootstrap to first fully-green QM-derived suite, 27 named scenarios):**
Captain 30 inv/1.96M/23.6k out (08:15:13-08:20:00, ~4m47s); QM top-level 46 inv/3.23M/
30.5k out (08:20:52-08:50:25) + nested Crew build 63 inv/6.86M/69.7k out + nested Crew
custody-fix 13 inv/539k/2.1k out (QM caught a genuine custody foul: Crew's routing fix
had globally monkey-patched `window.setTimeout` in PRODUCTION code to defeat jsdom's
async hashchange timing — routed to Boatswain, Crew redispatched, test-only fix landed
in `world.js` instead) + Boatswain 19 inv/923k/5.9k out. **Voyage total: 171 inv / 13.51M
cache / 132k out**, commit 670d99c. Zero deadlocks, zero orphan stalls this leg.

**Oracle grading, iterated per the two-phase gate (quarantine held throughout — verified
via transcript grep on every leg, only hit a legitimate `tastejs` URL inside the vendored
spec asset):**

| Run | Captain | QM (+nested) | Oracle result | Residual named |
|---|---|---|---|---|
| 1 (unmodified voyage) | - | - | **23/29** | render-churn/detached-DOM (5), missing CSS-driven edit-hide (1) |
| 2 (stable identity + edit-visibility) | 18 inv | 55 + nested (Crew A 23, Crew B 25, interference-fix Crew 10, Boatswain 18) | **27/29** | label not hidden (CSS gap under-specified in iteration-2 feedback), same-class persistence detach |
| 3 (label hide + persistence-settle) | 20 inv | 46 + nested (Crew 18, Boatswain 16) | **28/29** | Persistence detached-DOM (same signature as attempt-2's residual) |
| 4 (reload-anchored DOM identity, spec drafted, NOT built) | 22 inv | - (dk's word: stop here) | not re-graded | queued for next session, see CAPTAIN.md |

Iteration 2's parallel Crew dispatch (2 disjoint seams: DOM-reconciliation, edit-mode
hiding) **genuinely collided** — mate A's new `updateLi()` reconciliation path didn't carry
mate B's hidden-state logic, regressing an already-green target. QM caught it as an
ordinary failing verification target (not a silent miss), dispatched a solo follow-up Crew
fix, reverified clean. Live validation of the "parallel Crew stays shared-deck, verification
is the detector" standing decision — worked exactly as designed.

**Totals through the built iterations (voyage + iterations 2-3, iteration 4 spec-only
excluded from the "reached 28/29" figure since it was never executed):**
171 (voyage) + 149 (iter 2: 18+55+23+25+10+18) + 100 (iter 3: 20+46+18+16) = **440
invocations to reach 28/29** (442 including iteration 4's spec-only Captain leg).
Cache-read ≈ 27.9M, output ≈ 228k. **Compare attempt-2: 717 invocations to reach the
same 28/29** (442 voyage + 275 iteration, plus a separate operator-side oracle-harness
fix) — pilot #3 reached an equal-or-better result in ~39% fewer invocations, with no
oracle-harness bug this time (fixed from the start) and a genuinely cleaner residual
read (same failure signature as attempt-2's, now seen twice across two independent
apps — stronger evidence it is a tier-observability boundary, not an app defect).

**Instruction fidelity — two real findings, both HIGH/routed, neither shipped (see
CAPTAIN.md for full evidence chains):**
1. **Monitor-tool orphan stall on a nested agent** (HIGH): iteration-2 QM dispatched two
   parallel Crew children, armed the `Monitor` tool, and ended its turn — confirmed via
   `SendMessage` response ("Agent was stopped (completed); resumed it") that this
   orphaned exactly like the pilot-#2 fork stalls, now proven on a real Shipshape role,
   not just the harness runner seat. Operator-resumed manually.
2. **Self-devised sync marker is unreliable** (follow-on): after being warned off Monitor,
   the same QM invented a foreground Bash poll checking dispatched agents' transcripts
   for a `"type":"result"` JSONL marker that does not exist in this runtime's transcript
   format — burned two ~9-minute timeouts in one leg (once self-recovered at timeout,
   once operator-nudged to save the second wait) waiting on a condition that could never
   match, even though the work it was waiting on had already finished within seconds
   both times.

Both QM legs otherwise behaved well: correct custody-foul catch and routing (voyage),
correct parallel-mate collision handling via ordinary verification (iteration 2), correct
self-recovery via ground-truth checks (`git diff`, fresh reruns) once its invented wait
mechanisms failed (iteration 3). The failures are specifically in HOW a role waits on
multiple/uncertain async children, not in the underlying verification/build work, which
was uniformly sound across all four legs.

**Model split:** 100% sonnet across every mined invocation, zero leak (session model is
sonnet throughout).

**dk rulings this pilot, routed to a follow-up fable session (full text in CAPTAIN.md,
none shipped — mid-pilot no-side-scope rule held):**
1. Full-regression economy: only harbour should ever run a full regression (cut the
   Captain-skill "offer" bullet; reword the Verification agreement so harbour is the sole
   trigger, not "pre-outbound and harbour").
2. Narration ruling: the human-facing seat must ALWAYS narrate progress in plain text
   while dispatched work runs — no silent gaps, no raw-transcript dumps, no bare
   task-list views standing in for narration. Applies to real Shipshape Captain use, not
   just this harness.
3. The Monitor-stall and broken-poll-marker findings above, with a design option raised
   by dk: decouple QM->Boatswain into a flat, symmetric hand-off (mirroring the
   already-working foul->fresh-QM direction) rather than a nested wait; QM<->Crew stays
   nested (QM genuinely needs Crew's outcome) but needs a named, trusted way to consume
   multiple concurrent children without inventing an ad-hoc wait mechanism.

## Pilot #2 attempt 2 (2026-07-13/14, sonnet, installed-plugin channel, doctrine 0.13.14, todopilot3)

Clean rerun (fresh scaffold, not a resume of the parked attempt-1 tree) after the
0.13.14 efficiency battery gated GREEN. Full account in CAPTAIN.md; numbers here.

**Voyage 1 (bootstrap to first fully-green QM-derived suite, 32/32 scenarios):**
Captain (specs+watchbill, incl. a toolchain blocker + resume) 50 inv/3.77M/31.5k
out; QM blocked-then-resolved attempt 10 inv/402k/5.05k out; QM voyage (retry)
111 inv/12.66M/65.3k out top-level + 14 nested Crew/Boatswain legs 271 inv/14.24M/
106.2k out. **Voyage total: 442 inv / ~31.1M cache / ~208k out, ~53m active leg
wall** (scaffold-to-green ~56m wall-clock). Zero deadlocks, zero polls/pgrep/kill-0
patterns anywhere, all-sonnet (zero model leak - session model is sonnet).
**Tier economy A2 validated live**: Captain chose jsdom verification over a
real-browser tier and named it as an open question rather than unilaterally
adopting Playwright - the exact attempt-1 root-cause fix, holding on re-test.

**Oracle grading** (tastejs/todomvc pinned ff43b02e, operator-side only, quarantine
held throughout - verified via transcript grep for oracle terms on every leg,
only hit being a legitimate "tastejs" URL inside the vendored app-spec.md's own
Template section): run 1 (unmodified voyage-1 build) **21/29 passing** - already
better than pilot #1's first grade (0/29). Iterated per dk's word (spec/watchbill
amendment -> fresh QM -> Crew -> Boatswain -> re-grade, oracle failures translated
into ordinary product-language feedback, never exposing the oracle to any role):

| Iteration | Captain | QM (+nested) | Oracle result |
|---|---|---|---|
| 2 (render churn, edit-mode hiding, first-write persistence) | 32 inv | 38 + 93 nested (5 Crew/Boatswain legs) | 23/29 |
| 3 (label-hide, add-settling via mark-all proxy) | 20 inv | 22 + 39 nested (1 Crew/Boatswain pair) | 24/29 |
| 4 (save-before-clear ordering, startup-render-path) | 23 inv | 29, 0 nested - both scenarios ALREADY PASSED against unmodified production code | 24/29 (unchanged) |
| 5 (reload-settle stability) | 22 inv | 18, 0 nested - scenario ALREADY PASSED, no defect found | 24/29 (unchanged) |

Iteration total: 275 inv. **Grand total, full pilot: 717 inv** (442 voyage + 275
iteration) to reach 24/29 (82.8%) - a HIGHER pass rate than pilot #1's 18/29 (62%,
one iteration, 517 inv total lifecycle). Zero deadlocks, zero contamination, zero
cockpit reads, zero role-boundary breaches across every leg.

**Plateau finding (routed, not a doctrine defect):** the 3 residual failures (two
`reset`-property CypressErrors on the harness's own storage-spy teardown, one
reload-timing DOM-detachment) held EXACTLY unchanged across iterations 3-5 despite
three independently-framed product asks each landing real spec coverage - QM's own
honest verification found no production defect on two of those three passes (Crew
never dispatched, scenarios already passed against untouched code), and the app's
`src/index.html` was byte-identical from commit `cea5a54` onward. This is strong
evidence the residual 3 are not reachable through further product-language
iteration - most plausibly a test-harness/library-version artifact independent of
app behaviour, not a real spec gap. Operator did not build a comparison/control
apparatus to confirm this (out of scope per dk's word); this is inference from the
app's own source and QM's repeated independent findings, not further diagnosis.

**CLOSE-OUT (2026-07-14 morning, operator-side; full chain in CAPTAIN.md):** the
plateau inference above was CONFIRMED by reading the pinned oracle source: 2 of
the 3 residuals were the oracle's own `spy.invoke('reset')` calling a
sinon-removed API on a path every upstream-maintained framework skips
(noLocalStorageSpyCheck covers the whole modern main set - they persist nothing).
One-line operator-side fix (reset -> resetHistory), vendored as
fixtures/oracle/spy-reset.patch. **Same app bytes re-graded: 24/29 -> 28/29,
zero skips** (the before-each fix un-skipped 2 Mark-all tests, which pass).

Iteration 6 (2026-07-14, the completion-bar reachability check; EXCLUDED from
clean pilot accounting - fable session model, post-stall conditions): Captain 30
inv/2.51M/9m0s (30/30 sonnet, pin held, no nested spawns) - amended 2 features +
watchbill (3 scenarios), correctly identified both coverage gaps (neighbour-vs-own
node identity; post-reload reference blindness), stop-line held. QM 29
inv/1.87M/9m51s (25 sonnet + 4 FABLE - the async-resumption fall, live in a fable
session, confirming the sonnet-session requirement) + nested Boatswain legs 5+21
inv all-sonnet (one dispatch-contract foul self-caught: first Boatswain dispatch
over-narrated, withdrawn, redispatched clean); commit a9e3aea. ALL 3 scenarios
GREEN AGAINST UNMODIFIED PRODUCTION - production bytes unchanged since the 28/29
grade, so the grade stands by identity (re-run would be a redundant confirmation).

**Verdict on the last residual (Persistence detached-DOM): a TIER-OBSERVABILITY
BOUNDARY, not an app defect the loop failed to fix.** Three product-language
framings across iterations 4-6 all verified green at the jsdom tier; the oracle's
real-Chrome run observes an async re-render the jsdom settle-window snapshots do
not. The doctrine-sanctioned path already exists: 0.13.14 tier economy escalates
to a browser tier when a specified behaviour cannot be observed below it, as a
named recorded decision. Pilot #3 guidance: full-green target stands; if this
residual class appears, the product-language feedback should name the observable
behaviour and the tier escalation is the legal route - that firing live would
itself be a validation of the A2 rule's escape hatch.

**Attempt-2 final: 28/29 (96.6%) at 717 clean-accounting invocations** (+ the
excluded iteration-6 reachability check: 85 inv incl. nested). Pilot #1: 18/29
(62%) at 517 inv. Attempt 1: 84 inv spent, deadlocked (reported alongside, not
folded).

## TodoMVC pilot baselines (2026-07-12, sonnet, HEAD-text legs, doctrine 0.13.9)

27 dispatched role legs, greenfield to graded app. Role-leg totals only: 517
invocations, ~41.1M cache-read, ~749k out, 4h31m lifecycle wall. ~39 nested
Crew/Boatswain subagent transcripts (QM-spawned) NOT included; mine from the session
tasks dir for implementer-side numbers. Notable legs: QM build voyage 111
invocations / 12.7M / 92m (17 Crew dispatches); Shipwright harbour 31 / 4.25M / 14m;
Shipwright fit-out completion 34 / 3.47M / 13m. Bootstrap (empty repo to first
product spec) cost 10 legs / ~65m - the harbour-gate deferral in the first Captain
spec leg is the single largest avoidable serialization.

Oracle (tastejs/todomvc pinned ff43b02e, cypress 15.14.2, operator-side quarantine
held): first grade 0/29 (template-markup gate, 28 unmeasured); after ONE
product-language iteration (template sections promoted to binding specs, 5 scenarios,
5 Crew fixes): 18 passing / 9 failing / 2 skipped. The 9 residual failures are
objective unauthored conformance findings (see CAPTAIN.md).

## 0.13.10 validation probes (2026-07-12, sonnet, HEAD-text)

| Probe | Invocations | Cache-read | Out | Wall | Verdict |
|---|---|---|---|---|---|
| QM seam-parallel Crew (2 disjoint seams, one file) | 14 | 571k | 12.4k | 3.8m | PASS: 2 parallel mates, collision self-healed |
| Boatswain notes custody + strike + record shape | 22 | 1.20M | 24.4k | 5.1m | FULL PASS, transcript-verified content-blind |
| Shipwright fit-out plank rules | 25 | 2.34M | 59.5k | 12.0m | PASS derivation; MISS plant-red (timing ambiguity, 3 divergent obs) |

Probe 2 tool-call audit: deck diff composed as `git diff <base> -- . ':!CAPTAIN.md'`
verbatim; only mtime stat and by-path add touched CAPTAIN.md. Zero content reads.
Probe 2 also live-validated: void-on-any-byte (record died when CAPTAIN.md landed),
rerun by trace exactly the 2 owed targets, strike after own append at current hash,
canonical JSON record lines.

## 0.13.10 seam probes, plugin channel (2026-07-12 evening, installed 0.13.10 c045b46, sonnet top-leg dispatch)

RE-DATED 2026-07-13: channel forensics (marker-phrase greps over every leg transcript)
show these legs loaded pre-0.13.10 skill text and hooks (~0.13.8/9 process-level plugin
snapshot; /clear does not re-snapshot). Numbers and behavioural observations stand;
version attribution corrected in the 2026-07-13 section below. Key re-readings:
batching MISS x2 occurred with NO batching arm in the agents' text; supersede MISS
occurred with a tag table offering only promote/discard (supersede entered 0.13.10);
the "0.13.9 strike arm FULL PASS" was model-native (corroboration wording absent from
all 12 Boatswain legs' text).

Five pre-approved probes, 31 legs total (7 dispatched + 24 nested), all mined including
nested Crew/Boatswain/QM. Totals: 409 invocations, 18.16M cache-read, 412k out, 41m
wave wall (probes parallel). Model split: sonnet-5 264 inv / 12.57M; fable-5 145 inv /
5.59M (nested spawns after a parent's first fall to the session model unless the parent
pins `model` explicitly - tw3's Captain pinned, all-sonnet children; every other parent
leaked). Nested fable-5 Crew ran 7-9 inv vs sonnet Crew 11-12 on like-for-like solos.

| Probe | Legs | Inv | Cache | Out | Wall | Suite runs | Verdict |
|---|---|---|---|---|---|---|---|
| 1 Crew batching arm | 5 | 61 | 2.39M | 40k | 11.5m | 16 | MISS: 3 solo Crew sequential on a seam QM itself named shared |
| 2 unplanked-foul route (2a+2b) | 4 | 48 | 2.11M | 50k | 1.8m + 9.4m | 5 | PASS: foul ruled (no commit/strike/runs); Crew ACCEPTS plank-only target; route closes with commit |
| 3 @captain supersede | 8 | 114 | 5.05M | 100k | 22.9m | 5 | MISS: promote-with-correction chosen; supersede still unobserved live |
| 4 harbour-gate same-pass | 7 | 89 | 3.50M | 81k | 20.4m | 12 | PASS: specs+watchbill in the review pass, zero redundant regression; bonus full voyage |
| 5 one-blocker bootstrap (5a+5b) | 7 | 97 | 5.11M | 142k | 3.7m + 36.1m | uninstrumented | PASS: one blocker; one Captain cycle resolves values AND toolchain; full fit-out + methodology suite green |

Leg worth densities: P2a Boatswain custody-foul 100% (9 inv/351k/1.8m - new best custody
baseline), P1 voyage Boatswain 100% (10 inv), tw3 strike Boatswain 100% (10 inv, record-
corroborated strike, zero strike-runs - 0.13.9 arm FULL PASS live), tw5 fit-out
Shipwright#2 100% (12 inv incl. two planted-red proofs), P1 QM 91%, P2b QM 91%, P5b
Captain 91%, P3 Captain 88%, P4 Captain 78% (refused-dispatch poll cluster: sleep 240
et al, ~400k waste from one over-narrated dispatch). Run redundancy: tw1's serial-solo
shape staled ~5 Crew mid-proofs (charged to the batching MISS, not discipline).

## 0.13.11/0.13.12 validation, two waves (2026-07-13, sonnet top legs, the five pre-approved probes)

Wave 1 dispatched installed-plugin `shipshape:*` agents and unknowingly ran STALE text
and hooks (~0.13.8/9; the plugin snapshot is process-level, this Claude Code process
dates from Jul 12 12:42, and /clear does not refresh it). Kept as the old-text
control. Wave 2 re-ran byte-identical reconstructed states (deck-state hashes
reproduced exactly: 13d9a2e/a545663) in HEAD-text mode at 0.13.12 de24fa7. HEAD-text
carries no hooks; the 0.13.12 hook layer was ground-truthed by synthetic payload
replay instead. Integrated plugin-channel re-run owed after a real restart.

| Probe | Wave 1: stale ~0.13.8/9 text + old hooks | Wave 2: 0.13.12 text (HEAD-text) |
|---|---|---|
| 1 crew-batching | shape-MISS: 1-ref solo dispatch + QM self-verified the rest; 1 Crew spawn; 6 suite runs | PASS: ONE batched dispatch, 3 refs + per-target evidence, explicit one-mate-one-cluster marker; batched red census; 8 runs (3 = QM re-proof for record append); commit 15b2f65 |
| 2 captain notes-commit | FAIL: plain `git add && git commit` denied by old hook; Captain routed to a doomed Boatswain + SendMessage resume; notes never committed (3 legs spent) | PASS: `git commit -m <msg> -- CAPTAIN.md` composed first try; notes-only commit 75833ab; 8 inv / 73s; zero cycles |
| 3 boatswain notes arms | MISS x2 (old text): CAPTAIN.md left unstaged, watchbill left unstruck despite record corroboration; 3 hook denials incl. `git add CAPTAIN.md` | FULL PASS: `git diff <base> -- . ':!CAPTAIN.md'`, `git add -- CAPTAIN.md` content-blind, row-1 inherit (0 runs), record-corroboration strike (first live firing WITH its text), commit 2dd9382 |
| 4 QM plank-gap | PASS via nested-custody foul return (3 nested legs) | PASS via QM's OWN re-derivation per the 0.13.11 clause (2 nested legs); record void-on-edit then fresh-append correct; commit c930df1 |
| 5 record shape + no-plant fit-out | record: 4th divergent shape (`"command":"focused","result":"green"`); fit-out: 3 plant-red cycles at fit-out, 7 skeletons, 40 inv / 3.79M / 14.7m / 7 runs | record: canonical x4 incl. 3 appends on an EMPTY record (example line binds); fit-out: ZERO plants, tree uncommitted, 3 skeletons + 5-rule conformance scantling, runrecord+weather derived git-ignored, no script files, 26 inv / 2.51M / 12.2m / 5 runs |

Leg accounting: Wave 1, 11 legs: 180 inv / 9.69M cache / 176k out / 14.9m wave wall.
Tops: QM-tw1 22/934k/6.6m, Captain-tw2 17/763k/5.3m (+nested Boatswain 14/543k/5.3m),
Boatswain-tw3 17/867k/4.4m, QM-tw4 20/892k/10.9m, Shipwright-tw5 40/3.79M/14.7m;
nested Crew 8-9 inv, nested Boatswains 8-17 inv.
Wave 2, 9 legs: 115 inv / 6.58M cache / 124k out / 12.5m wave wall. Tops: QM-tw6
20/973k/6.8m, Captain-tw7 8/354k/0.9m, Boatswain-tw8 13/629k/2.7m, QM-tw9
16/834k/11.0m, Shipwright-tw10 26/2.51M/12.2m; nested Crew 7 and 11, Boatswain 7 and 7.
Same states, coherent text: -36% invocations, -32% cache, zero mistake/fix cycles
(wave 1 spent 4 hook denials, 1 doomed dispatch + SendMessage resume, and closed 2 of
5 probes with failed outcomes). dk's latency lens quantified: coherence is the lever.

Hook ground truth (synthetic payload replay against 0.13.12 bash-custody.sh): ALLOW
boatswain `git add CAPTAIN.md`, `git add -- CAPTAIN.md`, `:!CAPTAIN.md` exclusion;
ALLOW captain `git commit -m <msg> -- CAPTAIN.md`; DENY captain `git commit -am`.
Gaps: (1) `git -C <root> add -- CAPTAIN.md` DENIED - strip patterns cover only the
bare `git add` forms; (2) ANY prose mention of CAPTAIN.md elsewhere in a compound
command DENIED, including echo section labels - wave 2's textbook Boatswain composed
exactly such a label, so the best-behaved agent still eats a spurious denial on the
plugin channel; (3) the commit denial message leads with "Boatswain holds local
commit custody", which steered wave 1's Captain into the doomed Boatswain dispatch;
the corrective pathspec form sits in sentence 2. All three routed to dk.

Model split: nested inheritance identical in both modes - first spawn inherits the
parent's model (sonnet), later spawns fall to the session model (fable). W1 2/5
nested fable, W2 2/4. Record-append economy seam: both wave-2 QMs re-ran
Crew-proven greens in their own hands solely to append record lines (4 runs), reading
the wake append as the running role's own; either Crew's hand-off green should be
recordable or the re-proof is the record's standing price - routed to dk.

## 0.13.12 integrated plugin-channel wave (2026-07-13 post-restart, "wave 3", sonnet top legs pinned)

The owed re-run, DISCHARGED. Real process restart verified (process 11:49 UTC >
install 08:01 UTC); channel verified empirically per AGENTS.md: role-skill marker
phrases positive on every leg (captain: `pathspec-limited` + `Greenfield fast path`;
qm: `expensive fallback, never the default` + re-derivation clause; boatswain:
`Staging is not reading`; shipwright: both 0.13.11/0.13.12 phrases; shared Asset
policy marker consumed on tw7). First live firing of the 0.13.12 hook layer.

| Probe | State | Verdict |
|---|---|---|
| 1 crew-batching | tw1 | PASS: ONE batched Crew dispatch, 3 refs + per-target evidence, one-mate-one-cluster marker; 5 suite runs (vs 8 wave-2); canonical record on empty log; commit 76b0067 |
| 2 captain notes-commit | tw2 | PASS: `git commit -m <msg> -- CAPTAIN.md` first try, hook allowed live, notes-only commit a185a21, zero cycles |
| 3 boatswain notes arms | tw3 | PASS all arms: `:!CAPTAIN.md` diff, `git add -- CAPTAIN.md`, row-1 inherit 0 runs, corroboration strike, commit e38f706; 1 gap-(b) denial (echo label), self-healed |
| 4 QM plank-gap | tw4 | PASS: foul re-derived by QM itself, Crew accepted plank-only target, record void-on-edit + fresh canonical append at cb1ded8e, 3 runs, commit 7bf1c5b |
| 5 record + no-plant fit-out | tw5 | PASS: zero plants, tree uncommitted, 3 skeletons + 5-rule scantling, checker file correctly left to QM, 4 runs |
| verification-boundary | tw6 | PASS on objective joins: main window 4 runs/1 provision (QM's own checkpoint), dashboard run 0 provisions via spy, inline `@exceptional-double` naming both grounds, standalone cold-cache run exactly 1 provision, cross-run amortization bonus; commit f6e2446 |
| scope-out-gate (0.13.12) | tw7 | PASS first live firing: exclusion held as named question (report + CAPTAIN.md), QM dispatch HELD (zero spawns), specs+watchbill drafted unspent; template section entered binding specs byte-verified |
| fast-path-bootstrap (0.13.12) | tw8 | TAINTED PASS: outcomes objective (minimal 5-value RIGGING, no methodology checks, 6 specs, voyage green, CLI correct on all band edges, 3 commits, clean deck; empty-repo to specs+QM 7m51s, voyage complete ~17.5m vs ~40m baseline) BUT the Captain read the operator cockpit incl. probes.md rubric — not valid as independent validation; clean re-run owed with hardened dispatch |

Leg accounting (16 legs, all mined incl. nested): 332 inv / 19.33M cache / 295k out /
20.2m wave wall (parallel). Tops: tw5-Shipwright 40/3.59M/13.7m, tw8-Captain
35/3.38M/18.8m, tw3-Boatswain 30/1.59M/3.3m, tw1-QM 28/1.29M/6.5m, tw8-QM
28/1.39M/8.7m, tw6-Btsn 27/1.51M/6.3m, tw6-QM 23/1.43M/14.2m, tw4-QM 22/975k/7.4m,
tw7-Captain 15/814k/4.8m, tw2-Captain 14/558k/2.2m; nested Crew 12-15 inv,
Boatswains 9-27. Worth densities: tw7 100% (new best Captain leg), tw6-Btsn 92%,
tw1-Crew 92%, tw8-Crew 91%, tw3 89%, tw5 87%, tw6-QM 87%, tw4-Btsn/tw1-Btsn/tw8-Btsn
86%, tw4-Crew 84%, tw4-QM 83%, tw1-QM/tw8-QM 82%, tw8-Captain 81% (cockpit-breach
Neg x4), tw2 73%. P/N/Neg ≈ 292/35/5.

Like-for-like, the five pre-approved probes (9 legs): wave 3 = 182 inv / 9.91M /
130k out, 5/5 PASS, 1 spurious denial, zero failed outcomes. Wave 1 (stale plugin) =
180 inv / 9.69M, 4 denials, 2/5 failed. Wave 2 (HEAD-text) = 115 inv / 6.58M, 5/5.
Read: coherence decides outcomes at equal channel cost (w1 vs w3); the plugin
channel itself costs +58% invocations over HEAD-text for identical outcomes on
identical states (per-leg: tw2 14v8, tw3 30v13, tw5 40v26) — hooks, Skill-loading,
and finer-grained stepping; routed to dk as a channel-economy observation.

Hook layer live tally: 4 denials, each self-healed in exactly 1 retry. 1 CORRECT
catch (tw8 Crew attempted `cat CAPTAIN.md` — first live contamination catch of the
0.13.12 hook); 2 gap-(b) misfires (tw3 echo label; tw8-Btsn naming CAPTAIN.md in
commit-MESSAGE prose while content-blind staging it legally — new costume); 1
strict-text-conformant deny of `ls -la CAPTAIN.md` mtime stat (tw6-Btsn; the
0.13.11 "every other command naming the file" wording makes the wave-2 stat
hygiene illegal on the plugin channel). Precision this wave: 1 real catch per 3
spurious cycles.

Model split: nested inheritance leak unchanged — first spawn inherits sonnet, the
parent's later spawns fall to session fable (3/8 nested legs: tw1/tw4/tw8
Boatswains). fable 29 inv / 1.09M; sonnet 303 / 18.24M. tw8 Captain's `model:
sonnet` pin on its QM dispatch is cockpit-echo (it read harness AGENTS.md), not
doctrine behaviour. Record-append seam: +3 instances (tw1, tw4, tw8 QMs re-ran
Crew-proven greens in own hands); batching shrank the per-instance price to one
batched rerun (tw1) from wave-2's 3 solos.

Clean fast-path re-run (tw9, same intent + shipped boundary line): PARTIAL PASS.
Boundary HELD — zero harness-path touches, zero denials, no cockpit-echo model pin
(tw9's QM went UNSET and inherited sonnet; its Boatswain fell to fable, 4th leak
instance). Fast-path mechanism ✓: one-conversation bootstrap, no methodology
checks, honest real-spawn verification (7 scenarios green, steps spawnSync the
actual CLI), custody 136f851 + pathspec notes bd20e75, clean deck; empty-repo to
specs+watchbill+QM-dispatched 8m14s (tw8: 7m51s; both under the 10m target on
like-for-like intent), ~18.5m to clean deck. Two conformance MISSes the tainted
leg masked: (1) the minimal-rigging letter did NOT bind — tw9 populated ~8
optional slots (discover/broad/step-usage/plank-inventory/weather/runrecord/tier
policy/dependency) and authored `scripts/focused.js` + `cucumber.js` at bootstrap,
where the rule says "every optional slot none" (tw8 matched the letter only
because it read the fixture template — the wording alone doesn't bind; same
lesson as the 0.13.11 record fix: examples bind, key lists don't); (2)
report-contract fidelity — the Captain's final report declared a positional CLI
contract while the tree implements named flags (`--length/--nights/--hull`;
reported shape prints $NaN), caught only by driving the binary. Chain: Captain 43
inv/3.20M/44.3k/19m40s + QM 27/1.29M + Crew 10/398k + Boatswain 9/341k (fable) =
89 inv / 5.23M / 82.4k. Tally deltas folded: skill reads +8 (all P), polls +2,
redundant confirmation +1 (QM re-proof of Crew-proven green), commits +2; row
totals above not restated per-row for the tw9 chain — trend unchanged.

Supersede probe (tw10, last owed wave item; harbour state, uncommitted @captain
skeleton documenting the real tideRange -Infinity missing-day defect, anchored to
the existing scenario's seam and data): disposal CONFORMANT — promote with
corrected assertion, folded into the owning feature file, skeleton file deleted,
watchbill authored for the now-red case, zero verification runs in the review
pass, production untouched (red left for QM per the workflow). Supersede was
ENGAGED AND RULED OUT explicitly ("no existing binding scenario already pinned
this seam's missing-data case") — first live engagement with the 0.13.11
preference rule (marker present x2), and the reasoning is textually sound: a
missing-CASE defect naturally lands as a new scenario. Verdict: not an agent
miss; a PROBE-DESIGN finding — all three designed supersede invitations to date
anchored findings OUTSIDE the existing scenario's exercised behaviour, which
promote handles correctly. A true invitation needs the finding INSIDE it (e.g.
ordering-independence or precision of the already-asserted value). Supersede
remains unobserved live, diagnosis upgraded from "arm may not bind" to
"invitations were structurally wrong." Leg: 16 inv / 797k / 8.5k / 3m0s, boundary
held, zero spawns (stop-after-review honoured).

## 0.13.13 spot-validation + fixture v2 ("wave 4", 2026-07-13 post-restart, sonnet top legs pinned)

First live firing of 0.13.13 (49942d9) text AND hooks. Session postdates the 13:49 UTC
install by construction (process start 13:57); channel verified empirically on EVERY
leg per the AGENTS.md rule — role marker phrases positive in all 9 transcripts
(boatswain "not access and pass", captain "let the tree answer", shared table marker),
all skills resolved from the 49942d9fadbc cache dir.

Fixture v2 baseline: probe states rebuild green in ~19s and deck hashes reproduce
byte-exactly across independent builds — tw3 `22c21b4b`, tw4 `35ff6754` (replaces the
pre-v2 pair 13d9a2e/a545663, unreproducible from v2 fixtures by design). Sinks live:
tw3/tw4 operator prefix = 2 runs each in `.instrument/`.

| Probe | State | Verdict |
|---|---|---|
| boatswain notes arms (0.13.13 seams 1-2) | tw3 v2 | PASS all arms: `:!CAPTAIN.md` diff, content-blind staging, row-1 inherit on the ROOT runrecord (0 reruns), corroboration strike, commit d0832cc, clean close. ONE denial, NEW shape: multi-path `git add -- <role-files> CAPTAIN.md` batch (plus `git rm` in the compound) — strict-conformant per "exactly these two forms", self-healed in 1 retry to the exact form. Wave-3 misfire shapes (echo label, commit-msg prose, stat) did not naturally recur; ship-time 4/4 payload replay remains their ground truth |
| fast-path bootstrap, 3rd like-for-like (0.13.13 seams 4-5) | tw12 | FULL PASS, clean channel: verbatim tw8/tw9 quayline intent + boundary line. Minimal-RIGGING letter BINDS (required values populated, every optional slot literally `none`, no wrapper scripts, no methodology checks — every tw9 miss clean); report-contract fidelity live (Captain drove its own binary pre-report; operator re-drive reproduces every reported example, band edges 8->18/12->18 inclusive, tw9's $NaN mode closed). Empty-repo to specs+watchbill+QM-dispatched 7m24s (tw8 7m51s tainted, tw9 8m14s; target <10m — 3rd consecutive), clean deck 29m51s across TWO voyages (Captain split domain/CLI seams; tw8/tw9 sailed one) — 3 commits + pathspec notes baa3172, watchbill absent at rest, zero denials, zero cockpit reads |
| captain-disposal, sharpened supersede invitation | tw11 | PASS — SUPERSEDE CHOSEN LIVE, first observation in 4 designed invitations. Finding placed INSIDE the exercised behaviour per the tw10 design rule (ordering-independence of the already-asserted 3.8). Captain quoted the preference rule, rewrote the existing scenario as a 2-row Scenario Outline (committed/shuffled, both pin 3.8), deleted the skeleton, authored watchbill for the now-undefined outline, CAPTAIN.md rationale, ZERO production edits, ZERO executing runs (tree-verified by dry-run — the cheap shape of report fidelity), zero spawns. The tw10 diagnosis ("invitations were structurally wrong") is confirmed |

Leg accounting (9 legs, all mined): 162 inv / 8.23M cache / 116k out / 30m25s wave wall
(parallel front). Leg A Boatswain 25/1.30M/9.3k/3m39s (wave-3 same probe: 30/1.59M).
tw11 Captain 23/1.26M/18.8k/4m26s (tw10: 16/797k — tw11 did the full supersede edit).
tw12 chain 114/5.67M/88k: Captain 40/2.66M/29m51s, QM1 20/862k, Crew1 14/719k, Btsn1
8/281k (100% density, zero-rerun inherit), QM2 13/486k, Crew2 12/435k, Btsn2 7/232k.
Executing runs: tw12 chain 13 by transcript count (QM1 3, Crew1 2, QM2 6, Crew2 2,
Boatswains 0 — both inherited); tw3 0 beyond operator prefix; tw11 0 (dry-run only).
P/N/Neg ≈ 144/16/2 (~89% positive). Redundant confirmation runs: ZERO — with
`runrecord: none` (fast path) the record-append seam never triggers; evidence for the
open ruling.

Model-pin finding (harness, sharpened — mechanism nailed): an explicit `model: sonnet`
pin holds only until the leg's first ASYNC-CHILD RESUMPTION; the continuation falls to
the session model (fable), and children spawned after the fall inherit it. Timeline
proof: tw12 Captain sonnet 14:41:04 -> fable 14:58:25 (QM1 completed 14:57:17); QM1
sonnet 14:48:30 -> fable 14:52:26 (Crew1 completed 14:52:08); whole cycle 2 all-fable.
Subsumes the "later spawns fall" observation (6th+ instance). Legs pinned WITHOUT
nested spawns held sonnet end-to-end (Leg A, tw11).

Findings routed to dk, none shipped: (a) LOW hook shape — bless multi-path content-blind
staging (`git add -- <paths...> CAPTAIN.md`) or keep the denial as the standing price of
"exactly these two forms"; the best-behaved batching agent pays 1 cycle. (b) LOW wording
— the minimal-RIGGING letter binds so hard it `none`s out USER-STATED stack values
(Node 20 + npm went to `none`; Captain parked them in notes and flagged the sandbox's
Node 24 honestly). Should user-named values populate their slots at bootstrap?
(c) economy observation — identical intent sailed as 2 QM cycles/9 scenarios (tw12) vs
1 cycle/7 (tw8/tw9): coherent seam split, +~25 inv; voyage-scoping guidance is a
possible lever, not a defect. (d) unpinned CLI edge found by driving the binary:
no-args -> `NaN`, exit 0 — voyage-1-legal, first-harbour item. (e) harness note: v2's
out-of-tree sink is visible in runlog.js source; Leg A's Boatswain `ls`ed the parent
scratch dir once after reading it (read-only, sibling names only, cockpit untouched
9/9 legs).

## 0.13.13 pilot #2 (2026-07-13, sonnet, installed-plugin channel, todopilot2) - PAUSED at leg 2

Real restart, channel and cost both confirmed before spending (see CAPTAIN.md). Two
legs run before dk paused the pilot on a HIGH finding (QM stalled without
dispatching Crew - full account in CAPTAIN.md, not restated here).

| Leg | Role | Inv | Cache-read | Out | Wall | Model | Verdict |
|---|---|---|---|---|---|---|---|
| 1 | Captain | 32 | 1.88M | 14.0k | 17:53:16-18:07:29 (14m13s) | sonnet 32/32 | PASS: greenfield fast path, 9 features + RIGGING + watchbill, zero plants, dry-run clean |
| 2 | QM (nested, spawnDepth 2) | 52 | 3.90M | 28.4k | 17:56:54-18:08:25 (11m31s) | sonnet 52/52 | STALL: verification support written, 8 executing suite runs (transcript-grep count, fixture uninstrumented), 32/33 red as expected - but zero Crew dispatch, ends polling a dead PID |

Totals so far: 84 inv / 5.78M cache / 42.4k out. Model split: 84/84 sonnet - zero
leak (session-model pin holds when the session itself runs sonnet, per the
restart-plan rationale that motivated setting the session model before this pilot).
Suite executions: 8 by transcript grep (no runlog.js hook in the TodoMVC fixture);
1/33 passing pre-Crew (expected - no production code exists).

Forensic correction (same day, on dk's ask; full chain in CAPTAIN.md): the QM
stall was NOT self-implementation - zero production code written, zero Crew
mentions in QM's own reasoning. Chain: Captain's unilateral real-browser tier
choice (zero blockers; pilot #1 routed browser-vs-DOM as a blocker) made a broad
sweep cost 2m42s -> QM's foreground sweep hit the runtime's ~2m cap and was
auto-backgrounded -> `sleep` blocked -> Monitor armed on a `pgrep -f cucumber-js`
condition that matched the unrelated concurrent jolly session's cucumber (LOW:
cross-session contamination; match on project path, not process name) -> census
successfully read 18:07:52 (1/32 + summary) -> QM re-ran the full sweep anyway
(redundant confirmation class, +1 instance -> 8 total, worthiness stays 0) ->
ended turn on three broken waits -> re-run and poll both completed 18:10 into a
finished agent chain: notification orphaned, silent deadlock (HIGH, runtime).
Executing-run recount: 8 total; ~3 killed mid-run by QM's own timeout wrappers,
1 the redundant void re-run. Class tally deltas from this pilot fragment held
until the pilot completes or dk voids it; the redundant-confirmation +1 and
polls/waits +5 (echo-waiting/idle, dead-PID poll, broken wait, monitor cycle) are
recorded here for the eventual fold.

## 0.13.14 efficiency battery ("wave 5", 2026-07-13, sonnet, installed-plugin channel, session model sonnet)

Restart-ready queue item 3, run before pilot #2 attempt 2 per dk's doctrine->probes->pilot
ruling. Channel verified empirically: tw2 Captain leg carried the 0.13.14 marker
"cheapest tier sufficient to observe"; tw1/tw3/tw13 carried their own markers
("never an open wait", "not access and pass"/"Staging is not reading"). All 7 legs
dispatched `model: sonnet`; every top-level transcript's `message.model` field was
100% `claude-sonnet-5` - zero leak (session model IS sonnet this run, so even a
nested-child fall lands on the intended tier, per the wave-4 mechanism finding).

| Probe | State | Inv | Cache | Out | Wall | Runs | Verdict |
|---|---|---|---|---|---|---|---|
| 2 captain notes-commit (channel verify) | tw2 | 6 | 123k | 1.8k | 30s | 0 | PASS, cheapest yet (wave-3 tw2: 14 inv) |
| 1 crew-batching | tw1 | 28 | 1.41M | 6.4k | 3m41s | 4 | PASS: ONE batched Crew dispatch, 3 refs/1 seam; matches wave-3's 28 inv, shorter wall, fewer runs (4 vs 5) |
| 3 boatswain notes arms | tw3 | 20 | 972k | 6.4k | 2m18s | 0 (inherited) | PASS all arms: content-blind staging, row-1 inherit (hash-equal, zero reruns), corroboration strike, commit c320109; BETTER than wave-4's 25 inv |
| 4 QM plank-gap | tw4 | 27 | 1.32M | 9.3k | 4m27s | 5 | PASS: foul caught (this run via Boatswain's custody pass -> QM redispatched Crew plank-only), commit 44b50c1; +22% inv vs wave-3's 22 (mild drift, watch not block - outcome clean, no contamination) |
| 5 no-plant fit-out | tw5 | 41 | 2.82M | 21.5k | 6m19s | 4 | PASS: ZERO plants (grep for PERTURBATION/setTimeout in transcript = prose mentions of the check, not an actual plant), 4 `@captain @invariant` scenarios + verify-rules.json, 1 content-catalog finding routed not fixed; vs wave-3's 40 inv/3.79M/13.7m - same inv, much less wall |
| slow-census (0.13.14 regression probe) | tw13 | 19 | 848k | 7.2k | 5m54s | 5 (incl. 1 operator build-time prefix) | **PASS - the pilot-#2 deadlock trigger, doctrine alone, NO harness background-task lines given.** Broad sweep ran once (`timeout 280`, ~159s, over the ~120s cap), consumed and acted on immediately (Edit follows straight after in the next invocation), zero pgrep/kill-0/wait/sleep-poll patterns in the whole transcript, Crew dispatched with the fix, clean Final report. The turn-discipline + census-to-dispatch text (0.13.14) holds against its own designed regression test. |
| fast-path-bootstrap | fastpath12 | 13 | 531k | 10.9k | 6m38s | uninstrumented (transcript: 1 focused MODULE_NOT_FOUND rerun -> green) | PASS: minimal RIGGING (5 required values), one Scenario Outline spec+watchbill, real CLI (no doubles), QM voyage sailed to clean deck full completion in 6m38s (vs tw12's 7m24s to specs+watchbill+QM-dispatched only - this run went further, faster). Legitimate Captain blocker raised (fee rates + boundary semantics) and answered as sim-user; Captain correctly flagged the answer's provenance (relayed, not direct) rather than treating it as outbound approval - good behaviour, not a finding. |

Totals: 154 inv / 8.03M cache / 63.5k out / wave wall ~20m (parallel front after channel
verify). GATE VERDICT: GREEN. All 7 legs PASS on outcome; only tw4 drifted numerically
above the ~10% bar (+22%, 22->27 inv) and it is a single-metric drift on an otherwise
clean, contamination-free, zero-redundant-rerun leg - not the "structurally broken"
condition that would stop the pilot. The one probe purpose-built to regress the
attempt-1 HIGH deadlock (slow-census) passed cleanly with the harness's own
belt-and-braces lines withheld, meaning the 0.13.14 doctrine text itself (turn
discipline + census-to-dispatch + tier economy) is confirmed to prevent the failure
class, not just the operator's dispatch hygiene. Pilot #2 attempt 2 is cleared to run.

Findings routed to dk, none shipped: (a) tw4's QM plank-gap route this run went via
Boatswain's own custody pass finding the foul first (rather than QM's own
re-derivation before dispatching custody) - still a legal, clean PASS shape, but a
third observed route through this probe (wave-2/3 saw QM self-re-derive; this run saw
Boatswain catch it) - worth confirming this variance is intentional flexibility, not
drift; (b) fast-path-bootstrap's Captain correctly distinguished a peer-relayed
answer from direct user approval and flagged it for confirmation rather than treating
it as outbound-authorized - a positive behavioural observation, recorded for the
credit column.



| Class | Instances | P | N | Neg | Worthiness |
|---|---|---|---|---|---|
| skill/rigging reads (opening) | 180 | 180 | 0 | 0 | 100 (+14 wave 5, 2 Skill loads x 7 legs; holds at 0.13.14) |
| deck retrieval + context reads | ~430 | ~406 | ~24 | 0 | ~94 (wave 5: no new N observed - zero cockpit reads, zero stray parent-dir walks) |
| owed verification runs | 122 | 117 | 5 | 0 | 96 (+20 wave 5: tw1/tw4/tw13 red censuses+Crew local+QM terminal greens, tw5's full-tier regression, tw3's inherited row-1 zero-rerun, fastpath's MODULE_NOT_FOUND->green) |
| redundant confirmation runs | 7 | 0 | 7 | 0 | 0 (+0 wave 5 — zero instances across all 7 legs) |
| polls/waits | 45 | 0 | 45 | 0 | 0 (+13 wave 5: tw1 8 sleep-polls on nested Crew, tw4 ~4 hold/sleep cycles, tw13 1 sleep - notably tw13's OWN broad-sweep consumption cost ZERO polls, the doctrine-fix marker) |
| evidence ops (run record, deck-state hash) | 62 | 61 | 1 | 0 | 98 (+6 wave 5: tw1/tw4/tw13 record appends, tw3 hash-equal inherit, fastpath tree-verified binary drive) |
| staging/commit/report | 78 | 73 | 7 | 3 | 87 (+7 wave 5: tw2/tw1/tw3/tw4/fastpath commits all landed clean, tw5 harbour output correctly left uncommitted for Captain/Boatswain) |
| mid-leg doctrine re-read | 3 | 3 | 0 | 0 | 100 (no new instances) |
| contaminated/premature dispatches | 3 | 0 | 0 | 3 | 0 (no new instances; all 7 wave-5 dispatches accepted) |
| contamination refusals/guards | 13 | 7 | 2 | 4 | 23 (no new instances wave 5 - zero denials across all 7 legs) |
| operator-cockpit reads (sim-boundary breach) | 4 | 0 | 0 | 4 | 0 (+0 wave 5: boundary held 7/7, zero cockpit touches) |

Pilot #3 deltas (2026-07-14, ~440 invocations across 4 Captain/3 QM/6 Crew/3
Boatswain legs; not individually re-classified per invocation given the leg count -
qualitative deltas only): skill/rigging reads and deck retrieval stayed high-positive
throughout (every role opened correctly, zero cockpit reads across 16 legs, holds the
100/~94 worthiness at 0.13.15); owed verification runs positive and heavy (every
focused/broad sweep across 3 build+iteration cycles landed evidence a next action
used); redundant confirmation runs stayed at 0 new instances - QM's post-edit reruns
in iterations 2-3 were legitimate re-proofs (verification support genuinely changed
underneath the prior green), not redundant confirmation of unchanged state;
staging/commit/report +4 clean commits (670d99c, 2fb4390, 64ca588), zero negatives;
contamination refusals/guards and operator-cockpit reads: 0 new instances, oracle
quarantine held perfectly across every leg (transcript-verified). **polls/waits: +2
NEW severity, not just count** - a Monitor-armed wait that genuinely orphaned a
nested QM (operator-resumed) and a self-devised poll-marker condition that could
never match, burned twice (~9m timeout each, once self-recovered, once
operator-nudged). Both are QM inventing its own synchronization primitive rather
than trusting the proven single-child Agent-tool auto-resume pattern (which held
100% across every OTHER dispatch this pilot, sequential and otherwise) - the class's
0 worthiness holds, but the FAILURE MODE sharpened from "wasted invocations" to
"can silently orphan a live voyage," which is the HIGH finding routed to the next
session (see CAPTAIN.md).

Leg worth densities 0.13.8: Captain ~90%, QM 73%, wake-custody 82%.
Probes 2026-07-12 (sonnet, plugin channel): fresh-custody 100%, hand-off strike 100%,
stale-record 91%.
Seam probes 2026-07-12 evening: see the 0.13.10 seam probes section above; overall
P~391/N~15/Neg 3 of 409 (~95% positive).

## GOAL 2, INSTRUMENT 1: inbound context weight (2026-07-14, measured at tag v0.13.23)

**Built:** `bin/inbound.py` (one leg), `bin/inbound-fleet.py` (all legs in a session),
`bin/doctrine-sections.py` (section cost inventory). Measured against the FIXED tag per dk's
sequencing - installed plugin cache `8e7cf2504ecb` is byte-identical to `v0.13.23` (verified
by diff, not assumed).

**The method is EXACT and needs no tokenizer.** The API reports, per invocation,
`context[n] = input + cache_creation + cache_read` - the true prompt size. So
`delivered[n] = context[n] - context[n-1] - output[n-1]` is exactly the tokens injected
between two calls, whatever the channel. A token entering at invocation `k` is re-read by
every invocation `k..N`, so its RESIDENT COST is `size x (N-k+1)`, and summing resident cost
over every block reproduces the metered spend. **That identity is asserted on every run and
closes at drift +0 on all 14 legs.** If it ever drifts, the decomposition is unsound and the
tool says so.

**Two traps, both hit and both fixed - do not reintroduce them:**
1. The doctrine body does NOT arrive as a tool result. `Skill` returns a 36-char stub
   (`Launching skill: shipshape:boatswain`); the text is injected by another channel and is
   not reliably written to the transcript at all. Attribution by CONTENT silently misses it.
   Attribute by the CALL: price ordinary tool results at the leg's own observed char->token
   rate, give doctrine the residual.
2. Before that fix, `probe19`'s shared Articles were filed as `command: 24.7k` because that
   invocation called `Skill` and `Bash` together and a char-proportional split handed the
   tokens to Bash. An instrument that miscounts its own headline is worthless; the ledger
   identity is what caught it.

**Fleet: 14 legs / 224 invocations / 12,616,440 tokens read.**

| Source | Share of all inbound spend |
|---|---|
| shared Articles (`shipshape/SKILL.md`) | **36.9%** |
| harness floor (system prompt + tool schemas + dispatch) | **33.5%** |
| role skills | 14.0% |
| **THE JOB** (everything retrieved, run, and reasoned) | **15.6%** |

**84% of every token a Shipshape role reads is boilerplate.** The shared Articles measure
~24.0k tokens (74,255 chars), confirmed independently by two roles on two legs - not the
~15k the notes estimated. Every role loads it in full: Crew 24,086, QM 24,055, Boatswain
24,040, Shipwright 24,066.

| Role | Legs | Inv | Shared loaded | Role skill | JOB% of its context |
|---|---|---|---|---|---|
| Crew | 5 | 50 | 24,086 | 4,732 | **5.2%** |
| Boatswain | 3 | 44 | 24,040 | 7,234 | 11.2% |
| QM | 4 | 79 | 24,055 | 6,574 | 14.8% |
| Shipwright | 2 | 51 | 24,066 | 16,071 | 25.1% |

Crew is the sharpest case: **the shared Articles are 5x the size of Crew's own role skill**,
and the actual job is 5.2% of what Crew reads.

**dk's named suspects, priced.** He guessed Crew carries Harbour flow, Watchbill and Outbound
it never uses. All three are real, and all three are SMALL: Watchbill 718 tok, Harbour flow
529, Outbound 400 - together 1,647 tok, **6.8% of the shared Articles** (~16.5k per 10-inv
Crew leg). Cutting all three from Crew saves ~3.7% of a Crew leg's spend. The heavy sections
are Verification policy (1,625), Role transitions (1,433), Hand-off custody (1,397) - all
plausibly load-bearing for every role. **The bulk is not in the obvious offcuts.**

**THE CAVEAT THAT REFRAMES THE WHOLE RESULT, and it must ride with any citation of these
numbers:** cache-read tokens bill at ~10% of input, so 12.6M cache-read is real but modest in
money, and dk's own ladder puts tokens LAST ("preserving tokens is not a major goal"). On the
token rung alone this finding would not justify touching doctrine. What promotes it is
LATENCY (rung 2, outranking invocations and tokens): across the 14 legs, mean context per
invocation vs seconds per invocation gives **Pearson r = +0.82**. **Confounded** - the
big-context legs are Shipwright legs that also reason more per round, so this is SUGGESTIVE,
NOT CAUSAL. The controlled test is a probe: same leg, same state, trimmed context, measure
wall. That probe is owed before any claim that trimming buys latency.

And the real prize is rung 1, QUALITY - attention dilution across 24k tokens of mostly-
irrelevant rules - which **instrument 1 cannot measure at all**. Cost is not worth.

## GOAL 2, THE OWED LATENCY PROBE: SETTLED. Context bulk IS a rung-2 cost (2026-07-14)

dk's ruling was "run the probe first" - settle latency before building more instruments,
because latency is the ONLY rung that could promote Goal 2 above the token rung it does not
deserve. Done. `bin/ballast-probe` = `make-ballast.py` + `ballast-compare.py`.

**The observational shortcut FAILED, and the tool now says so out loud.** Regressing think-time
on cache_read while controlling for output (`bin/latency-probe.py`, n=224) gives a positive
cache_read coefficient but **R^2 = 0.28 and raw r = +0.20**. cache_read is collinear with
everything - it grows monotonically within a leg, and later invocations also write more. The
coefficient is POORLY IDENTIFIED and must not be quoted as a finding. Observational data could
not settle this; that is exactly why the controlled probe was owed.

**The controlled probe: identical task, only the cached prefix varies.** Six general-purpose
agents (NO Shipshape doctrine anywhere - no role behaviour, no contamination risk, pure
runtime measurement). Both arms read one file, then run eight `echo` commands one per turn.
Identical tool-call structure, identical tiny outputs, so decode is held fixed. The ONLY
difference is the size of the file read:
- LIGHT: 39-byte stub -> ~23.6k mean context
- HEAVY: 73,429-byte ballast (sized to the 74,255-byte shared Articles) -> ~48.5k mean context

The ballast lands as a tool result at invocation 1 and is RESIDENT and CACHED thereafter -
exactly how doctrine behaves.

| Arm | n | Mean ctx | Mean out | Mean think | **Median think** | Stdev |
|---|---|---|---|---|---|---|
| LIGHT | 14 | 23,564 | 76 | 2.16s | **2.00s** | 0.52s |
| HEAVY | 21 | 48,499 | 77 | 3.31s | **2.84s** | 1.97s |

**+24,935 cached tokens cost +0.84s per invocation on identical work - a +42% increase.**
Quote the MEDIAN: the heavy arm has a long right tail (one 11.3s call) that skews the mean to
+1.15s. Robustness: median diff +0.84s, trimmed diff +0.85s, **Mann-Whitney z = -3.27**
(rank-based, distribution-free, p~0.001). The distributions barely overlap.

**VERDICT: resident cached context carries a real, CAUSAL time cost.** The task is held fixed
and only the prefix varies, so this is the causal result the confounded per-leg r=+0.82 could
never deliver. Carrying the shared Articles costs ~0.84s/invocation: ~13s on a 15-invocation
leg, ~3.1 minutes across the 224-invocation fleet. **Context bulk is a rung-2 latency cost, so
Goal 2 is promoted above the token rung.**

**AND IT STILL DOES NOT LICENSE A CUT - the ladder is why.** Quality outranks latency, and
METRICS' own lens says mistake/fix cycles are the dominant latency source. One prevented rework
cycle costs a whole invocation or more, buying back many seconds of prefill. Priced per section,
a rule costs ~0.02-0.06s per invocation; **any section that prevents even one cycle across a
voyage has already paid for itself.** The price tag is now known. The WORTH is not, and remains
instrument 3's question - followed by a probe, per the standing limit.

One incidental finding worth keeping: **a LIGHT-arm agent refused the task** and asked whether
the eight-silent-echoes instruction was itself a compliance test. Correct instinct, and a
reminder that inert-looking probe scaffolding is not invisible to the agent reading it.

## The audit lens (per dk)

**THE LADDER (dk, 2026-07-14, binding): quality > latency > invocations > token usage.**

Four rungs, in that order, each outranking everything below it. This SUPERSEDES the 2026-07-13
formulation, which fused latency and invocations into one rung ("latency measured in
invocations"). They are now separate, and the order has teeth:

- **Quality** first, always. An outcome that is wrong is not made right by being cheap or fast.
- **Latency** second, and it OUTRANKS invocation count. A leg that runs more rounds but finishes
  sooner WINS. Wall-clock is the tiebreaker above round count.
- **Invocations** third. They hold their own rung because each round is both a cost and a chance
  to err; mistake/fix cycles (refusals, fouls, denied-command retries, rework loops) are the
  dominant latency source, which is why framework coherence is the key lever.
- **Token usage** last. Avoid waste; never optimize for it. "Preserving tokens is not a major
  goal" (dk). Sending MORE tokens LESS often for the same outcome is a win, not a cost.

**Corollary (dk, 2026-07-14): minimizing invocations is a function of OUR prompt, context and
role engineering - never something we tell the agents to do via the prompts. That would be
backwards.** The lever is on our side of the table: coherent text (the -36% wave-1-vs-wave-2
result), one retrieval instead of three, a batched dispatch, a hand-off that carries evidence so
the next role does not re-derive it. Instructing the agent to "use fewer rounds" pushes the cost
onto the only party who can pay it by cutting corners on the actual work.

So doctrine gives roles OBLIGATIONS, never optimization TARGETS. Tell a role "minimize
invocations" and it will skip a verification run to save a round; tell it "never rerun a proven
green, batch one seam into one dispatch, never end a turn waiting, consume each report as it
arrives" and the economy falls out with no perverse incentive. The rounds drop because there is
less to do, not because someone was told to hurry. The role-tiered lens below is for SCORING a
leg after the fact, and is deliberately NOT doctrine text.

Role-tiered refinement (dk, 2026-07-14): the optimization target differs by seat.
CAPTAIN (human-facing): play-by-play visibility is the priority - the user and
Captain must be able to know what Crew is doing at all times; token spend at this
seat is explicitly NOT a constraint ("token optimization is not our goal at the
captain level"); the goal is clearing the session as soon as possible with the
user fully informed throughout. QM/CREW (worker seats): MINIMIZE MODEL INVOCATIONS
- end-to-end latency reduction is the primary goal, token efficiency a side
benefit. Judge legs accordingly: a Captain leg is never dinged for verbose
surfacing/report-chaining; a QM/Crew leg is dinged per avoidable invocation
(polls, redundant confirmations, rework cycles), not per token.

Classify EVERY invocation's impact by one objective test - trace whether its output
was consumed:

- POSITIVE: a later invocation or the final artifact demonstrably used it (an edit
  follows a read, a dispatch follows a red list, a commit follows a green, a refusal
  caught a real fault). Record the consumer ("-> #9" or "-> commit").
- NONE: output never referenced again, or it re-established a fact already in
  context/evidence (redundant confirmation runs, re-reads, polls).
- NEGATIVE: output caused a wrong action, rework, or a false conclusion (e.g., the
  watchbill-as-recheck-selector broad run that produced a wrongful refusal).

Per leg report: counts P/N/Neg, and worth density = P-tokens / total cache_read.
Class worthiness accumulates across shakedowns: for each invocation class (skill read,
deck retrieval, owed run, hygiene check, confirmation run, poll...), worthiness =
(positives - negatives) / instances, i.e. "out of 100 runs of this class, how often
did it have positive impact." Classes trending under ~50 are merge or eliminate
candidates; a doctrine change is cost-validated when its target class's frequency
rises. Keep the class tally in this file under Baselines.

For each invocation also ask: mergeable into another invocation, another
job, another role? Known classes: opening reads (batchable), independent hygiene checks
(batchable), polling waits (eliminate - foreground spawns), discover+step-usage (one
run serves both, 0.13.8), custody reruns of caller-proven greens (inherit - decision
table row 1 / wake record).
