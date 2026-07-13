# Captain notes - shipshape-shakedown workstream

## 2026-07-13 night: 0.13.14 efficiency battery GREEN ("wave 5") - pilot #2 attempt 2 cleared, running next

dk's word this session: run the queued gate (efficiency battery) then the pilot,
autonomously, report everything at the end. Also flagged and left alone: a stray
committed-but-unpushed-and-uninstalled 0.13.15 commit sitting in ~/shipshape
(d31b22f, write-custody artifact-kind fix, tests green locally) - undocumented in
this log, out of scope for this run per dk's word, not shipped/touched.

Channel verified empirically at session start: process began 19:35:36 UTC, after
the 0.13.14 install (19:22:20 UTC per installed_plugins.json, cache 670f3abe1e9d).
First dispatched leg (tw2 captain notes-commit) carried the 0.13.14 marker
"cheapest tier sufficient to observe" - confirmed live before trusting the rest.

Full numbers in METRICS.md "0.13.14 efficiency battery (wave 5)". Verdict: GREEN,
7/7 legs PASS on outcome, all sonnet (zero model leak - session model is sonnet so
even a nested-child fall lands on-tier). One numeric drift: tw4 QM plank-gap ran
+22% invocations vs the wave-3 baseline (22->27) - single-metric, clean outcome,
not a stop condition, routed as a watch-item. The critical result: **tw13
slow-census, the purpose-built regression test for the pilot-#2 HIGH deadlock, PASSED
clean with the harness's own background-task belt-and-braces lines WITHHELD** - QM's
broad sweep exceeded the foreground cap (~159s), was consumed and acted on in the
very next invocation, zero pgrep/kill-0/sleep-poll/wait patterns anywhere in the
transcript, Crew dispatched with the fix, clean Final report. This confirms the
0.13.14 doctrine text itself (turn discipline + census-to-dispatch + tier economy)
prevents the failure class, not just operator dispatch hygiene - the gate dk asked
for is satisfied. Two minor findings routed (not shipped): tw4's foul-catch route
varied a third way (Boatswain's own custody pass caught it this time, vs QM
self-re-deriving in wave 2/3) - still legal and clean, flagged as a variance to
watch, not a defect; fast-path-bootstrap's Captain correctly distinguished a
peer-relayed answer from direct user approval before treating it as product data -
a positive behavioural note.

Proceeding straight to pilot #2 attempt 2 (clean rerun, fresh scaffold, NOT a resume
of the parked todopilot2 tree) per dk's word this session and the standing
doctrine->probes->pilot sequencing. Full account to follow in this file once the
pilot lifecycle completes or hits a stop-worthy blocker.

## 2026-07-13 evening: pilot #2 PARKED on dk's word; doctrine fix package drafted; restart-ready

dk's ruling (2026-07-13, after the forensic addendum below): the pilot does NOT
resume until (1) doctrine is fixed so the pilot-#2 error class cannot recur and
(2) the probe battery has been rerun on the fixed doctrine confirming efficiency
(latency + invocation count) against the wave-3/4 baselines. Sequence is
doctrine -> probes -> pilot; the pilot is last.

Harness fixes SHIPPED this session (operator-owned): AGENTS.md slow-suite dispatch
rules + operator-driven pilot legs + mine-on-every-notification; preamble.md
background-task dispatch lines + Captain stop-line pattern; pilot.md
operator-driven procedure; probes.md gains the slow-census regression probe (the
designed re-creation of the pilot-#2 trigger, run WITHOUT the harness lines so it
tests doctrine alone) and the efficiency-battery rule (five pre-approved probes +
fast-path-bootstrap + slow-census after any doctrine ship; bar ~10% of newest
baseline or better, regressions route to dk before the pilot).

DOCTRINE 0.13.14 SHIPPED on dk's word (2026-07-13 evening, "ship both now" + A2):
commit 670f3ab, pushed, installed (cache 670f3abe1e9d), tests 194 green
(bulkhead 10, homes 46, hooks 117, map 17, style 4). THIS session's subagents
stay snapshotted at 0.13.13 (install postdates process start) - the 0.13.14
probes REQUIRE the restart; run nothing installed-plugin here. Marker phrases
for next-session channel verification: shared "counts as never run", qm "never
an open wait", captain "cheapest tier sufficient to observe". The shipped
wording (identical to the draft below, A2 chosen for item 3): turn discipline
homed in Hand-off custody after the report-travels paragraph; census-to-dispatch
homed in QM step 4 around the kept sentence "Spend the watch once its red list
is dispatched" (the shared Watchbill policy already said "one enumeration
sweep" - one voice held); tier economy homed ONCE in the Captain fast-path
bullet (Shipwright's existing "per the Captain skill" reference carries it; no
second home, per the 0.13.13 exceptional-double lesson).

The as-drafted package (kept for history; homes verified against 49942d9 text):
1. Turn discipline (shared Articles, home: Role transitions, next to the
   role-hand-off/final-report paragraph at ~line 334): "A role's turn ends only in
   its final report. A role never ends its turn waiting - not on a background
   command, a notification, a timer, or another agent. Work in flight at report
   time is either consumed before reporting or reported as a blocker. A
   verification run whose output the role has not read is not evidence and counts
   as never run." Evidence: pilot-#2 QM ended its turn "waiting for the background
   completion notification"; the completion fired 2m later into a dead agent chain.
2. Census-to-dispatch (QM skill, strengthens the existing "Spend the watch once
   its red list is dispatched" in step 4/line 61): "One sweep enumerates the
   watch: once the red list is in hand with per-target evidence, dispatch is owed
   before any further executing run of that tier. A long-running sweep is consumed
   within the turn - started, read to its summary, acted on; an environment that
   cannot complete the sweep within the turn is a tooling blocker to Captain,
   never an open wait." Evidence: census in hand 18:07:52, full redundant re-run
   launched 18:08:03.
3. Tier economy (Captain skill fast-path bullet + Verification policy), TWO
   OPTIONS for dk:
   A1 (route it): the verification tier is the one methodology decision the fast
   path still surfaces in the interactive conversation (browser vs DOM vs
   process-level, with per-run cost); silence adopts the cheapest sufficient tier.
   A2 (default-cheap, operator's lean - serves the economy directive): voyage 1
   verifies at the cheapest tier sufficient to observe the specified behaviour; a
   real-browser tier is adopted only when the user names it or a specified
   behaviour cannot be observed below it, and then as a named recorded decision.
   Evidence: pilot-#2 Captain unilaterally chose Playwright/Chromium with zero
   blockers -> 2m42s per census, the failure chain's root enabler; pilot #1
   routed browser-vs-DOM as a blocker. Fixes 1+2 alone prevent the deadlock; 3 is
   the economy component dk's ruling also asks for.
Hook implications: none (text-only). Ship-first rule applies: bump 0.13.14, tests
green, commit, push, install, THEN restart; if dk nods this session, ship this
session so the next session runs 0.13.14 by construction (the 0.13.13 pattern).

NEXT SESSION (restart-ready queue, in order):
0. `/model sonnet` + `/effort medium` FIRST - dk's saved defaults are now
   fable/xhigh from the forensic conversation. This is not just accounting:
   dk's word (2026-07-13) is probes run on sonnet, or haiku where a baseline
   exists, NEVER a stronger model - a stronger model masks doctrine weakness
   with native competence, and the async-resumption leak sends even a pinned
   leg to the session model at its first nested-child resumption, so the
   session model IS the probe tier. Void any leg that escalated above its
   intended tier (mine the model split per leg).
1. Bootstrap per AGENTS.md; deck check: expect ~/shipshape clean at 670f3ab,
   installed 0.13.14 (SHIPPED this session - nothing to ship).
2. Channel-verify with a 0.13.14 marker phrase on the first leg: shared "counts
   as never run", qm "never an open wait", captain "cheapest tier sufficient to
   observe".
3. Run the efficiency battery per probes.md: five pre-approved probes (tw1-tw5),
   fast-path-bootstrap (verbatim quayline intent, tw12 dispatch), slow-census
   (tw13 - now BUILT INTO bin/probe-states.sh and smoke-proven this session:
   whole builder green, tw13 slow scenario 2m30s > the ~2m foreground cap by
   design; the build costs +150s for the honest slow-scenario verify). All legs
   sonnet-pinned in a sonnet session (dk's model-discipline word above);
   optionally a haiku arm on the Boatswain custody probe where the haiku
   baseline exists (14-16 inv / 1.4-2.2m). Mine everything incl. model split,
   compare inv/wall per leg vs wave-3/4 baselines, classify, record in
   METRICS.md. Priority order if trimming: slow-census FIRST (it is the
   regression probe for the exact error), then boatswain-notes-arms + fast-path
   (the 0.13.13-validated seams re-checked under 0.13.14 text), then the rest.
4. Pilot #2 attempt 2, CLEAN RERUN, same session once 3 is green and efficient -
   dk's standing word (2026-07-13 evening: "get to where you are confident to
   start a new session with sonnet and try pilot again"); still confirm cost in
   ONE line at pilot start per the command. Clean rerun, NOT resume: 0.13.14's
   tier rule changed the doctrine under the old tree - todopilot2's RIGGING
   embodies the pre-fix Playwright choice, so resuming would neither validate
   the fix nor give clean accounting. Procedure per scenarios/pilot.md
   (operator-driven) with the exact dispatch texts in prompts/pilot-dispatches.md;
   oracle quarantine absolute; emphasis unchanged (invocation + latency vs pilot
   #1: 517 inv / 4h31m / 13x-bare target 2-3x; attempt-1's 84 spent inv reported
   alongside, not folded in). Attempt-1 tree left at the old scratchpad path as
   forensic evidence only.

## 2026-07-13 pilot #2 PAUSED at leg 2 (QM): stalled without dispatching Crew - HIGH finding, dk's word to pause and record

Real restart confirmed (process start 17:50/17:51 UTC, well after the 13:49 UTC
0.13.13 install); session model set to sonnet per dk's restart plan. Cost confirmed
with dk before spending (~half pilot #1's legs, 1.5-2.5h). Scaffolded todopilot2:
empty repo (README-only operator commit c529b99), both vendored assets committed
(app-spec.md + app-template.index.html, 98f5f7c). Dispatched `shipshape:captain`
(installed-plugin channel, model sonnet) with the verbatim pilot user intent.

Leg 1 Captain (agent a1d2688960eb7f1ff): 32 inv / 1.88M cache / 14.0k out /
17:53-18:07 (14m13s), all sonnet. Greenfield fast path used correctly: RIGGING.md
(vanilla JS, npm, cucumber-js + Playwright/Chromium), AGENTS.md, private CAPTAIN.md
notes, 9 `.feature` files covering every app-spec.md section, watchbill.json (watch1
= `@logic` tier), zero plants. `cucumber-js --dry-run` confirmed all 9 features parse
clean. Working tree correctly left uncommitted (rides to QM). Zero Captain blockers
this leg - flagged per pilot.md's own caution ("a pilot with zero blockers means
roles guessed instead of routing") but framework/storage-key/routing decisions were
made explicitly and recorded as decisions, not silently assumed, so this reads as
legitimate direction-already-given greenfield fast path, not a guess - watching for
whether it recurs as a real gap.

Leg 2 QM (agent ae3fb9a872bf0b9e9, nested under Captain, spawnDepth 2): 52 inv /
3.90M cache / 28.4k out / 17:56-18:08 (11m31s), all sonnet. STALLED - did NOT
dispatch Crew.

**HIGH finding, tree- and transcript-verified (not report prose):** QM wrote
verification support correctly (features/support/{hooks,server,world,steps}.js,
Playwright-driven), then ran the full suite itself via foreground and background
Bash (`npx cucumber-js --tags "not @captain and not @shipwright"`, 8 executing runs
by transcript grep - fixture is uninstrumented, no runlog.js hook, so counted by
grep per METRICS.md convention) instead of dispatching Crew for the resulting red
targets. Confirmed via the session's subagents directory: only 2 subagent
transcripts exist for this pilot (Captain, QM) - zero Crew, zero Boatswain spawned,
at any depth. Suite result: 1/33 scenarios passing, 32 failing (expected - zero
production code exists; no `js/`, no `index.html`, no `coverage/` in the tree).
QM's last five tool calls: a background `while kill -0 <dead-pid>; do sleep 3;
done` poll loop (the polled PID was already dead - `ps -p` returned not-found),
`echo waiting`, `echo idle`, then final text "I'll wait for the background
completion notification before continuing" - no such notification could ever
arrive; nothing was actually dispatched async. Two consecutive task-notifications
reported "completed" (each agent's own turn genuinely ended) while implying
continued progress that was not happening - operator-side transcript verification
caught this, self-report alone would have missed it.

Doctrine/harness angle for dk (none shipped, routing only): QM's contract is
verify-then-dispatch-Crew-for-reds, not self-implement; this QM instead treated the
red census as terminal and never composed a Crew dispatch at all - a silent
same-role-does-everything failure mode distinct from the previously-catalogued
batching MISS (which at least dispatched Crew, just serially). Candidate questions:
does the QM skill text give a legal-looking off-ramp into self-running the suite
repeatedly instead of dispatching once reds are known; should a QM leg's own
foreground/background Bash suite-running be capped or flagged if no Crew dispatch
follows within N runs. Needs QM skill text review before doctrine change, not
shipped.

FORENSIC ADDENDUM (same day, full transcript reconstruction on dk's "wtf" - this
CORRECTS the paragraph above; the "same-role-does-everything" frame was wrong. QM
wrote ZERO production code and never self-implemented; it died inside census
mechanics before ever reaching its dispatch step. Second-by-second chain, all
transcript-verified):

1. ROOT ENABLER (Captain leg, doctrine tension): Captain unilaterally chose
   real-Chromium Playwright for the whole @logic tier. Pilot #1's Captain routed
   "browser vs DOM-level tier" as a blocker; this Captain raised zero blockers -
   the 0.13.12/13 greenfield fast path ("no methodology checks", direction already
   in hand) textually absorbed the very decision pilot.md says it WANTS surfaced
   ("a pilot with zero Captain blockers means roles guessed - that is a finding").
   Consequence: 33 scenarios x 5s locator timeout on missing DOM = 2m42s per broad
   sweep. Every downstream failure flows from census cost. Operator under-weighted
   this at leg-1 report time (classified it "legitimate direction-already-given").
2. QM support work 17:57-18:04 was genuinely good: server/world/hooks/steps,
   duplicate-step dedup, static discovery (192 steps bind), bounded 5s timeouts.
3. Census mechanics 18:04-18:08: full sweep run FOREGROUND with `timeout 280` ->
   the runtime auto-backgrounded it at the ~2m foreground cap (18:04:58 ->
   18:06:58 "running in background with ID bxhsev1bg"). QM tried `sleep 120` ->
   BLOCKED by runtime. Armed a Monitor whose condition polled
   `pgrep -f cucumber-js | head -1` - which matched the UNRELATED concurrent
   jolly session's long-running cucumber process (lowest PID wins): cross-session
   false wait signal. QM killed the monitor, cat'ed the completed sweep output at
   18:07:52 - FULL census in hand (1 passed/32 failed + summary line).
4. FATAL 30s (18:08): with the census in hand, QM re-ran the ENTIRE sweep again
   (`rm -f broad.log && timeout 280 npx cucumber-js ... > broad.log &`, pid
   1049929) - a redundant confirmation run, the exact class the audit lens scores
   0 - then composed three broken waits (bare `wait` in a fresh shell: no
   children, returned instantly; a background `kill -0 1049929` poll; `echo
   waiting`/`echo idle`) and ENDED ITS TURN on "I'll wait for the background
   completion notification."
5. DEADLOCK (18:10, runtime seam, HIGH): the re-run completed into broad.log at
   18:10 (byte-equivalent census, 22505 bytes) and the poll task fired "cucumber
   run finished" at 18:10 - but QM's turn had ended 18:08:25 and Captain's
   18:07:29. Background-task completion does NOT resurrect a finished nested
   subagent chain: the notification was delivered into the void. The harness
   promise "You will be notified when it completes" is broken across the
   nested-agent turn boundary. QM's own reasoning text contains zero mentions of
   Crew dispatch intent (every "Crew" hit in its transcript is loaded skill text);
   its plan was census-first and the plan never survived the census.
6. Operator misses (owning them): (a) let Captain auto-chain QM nested-async -
   wave-4 tw12 validated that chain shape ONLY on a fast toy CLI suite where the
   2m foreground cap never bites; pilot #1 was operator-driven leg by leg; nested
   chain + slow browser suite was an untested combination and is exactly where
   the turn-boundary deadlock lives. (b) On QM's 18:08 "completed" notification,
   operator checked the tree, saw no change, and kept waiting ~25m instead of
   mining the transcript immediately - QM was still resumable then (task IDs
   later expired). Mining-on-notification, not tree-diff-on-notification, is the
   correction; folded into the next-run procedure.
7. LOW boundary note: QM wrote broad.log to the session scratchpad ROOT, outside
   the project tree - first WRITE-side "work only inside the project root" slip
   (previous breaches were reads); no cockpit content touched.

Findings recap for dk: HIGH runtime deadlock (nested background-task notification
orphaning) - harness-side fix candidates: dispatch rule "never end your turn with
a live background task; consume or kill it first" + operator-driven pilot legs;
MEDIUM doctrine tension - fast path suppresses the tier blocker pilot.md wants
(should verification-tier choice stay a routed decision when a browser tier is on
the table?); MEDIUM QM census discipline on expensive suites (one census then
dispatch; the re-run-in-hand instance joins the redundant-confirmation class);
LOW cross-session pgrep contamination (match on project path, not process name);
LOW write-boundary slip. None shipped; all await dk's word.

Contrast with pilot #1, for scale: pilot #1 bootstrap ~65m/10 legs, voyage worked
(17 Crew dispatches, 92m). Pilot #2 bootstrap 14m (fast path working as designed,
best pilot bootstrap yet) but the voyage deadlocked at leg 2. Different failure,
not a regression of the same one: pilot #1 never exposed this seam because its
legs were operator-driven, HEAD-text (no nested async), and its per-run
verification was cheaper.

dk's word (2026-07-13, mid-run): PAUSE here. Do not resume/redispatch this leg or
start a fresh QM this session. Findings stand as recorded; pilot #2 resumes only on
dk's word. Sim tree todopilot2 left as-is (2 commits, 32 reds, uncommitted
verification support) for inspection. Session model changed to FABLE post-pause
(dk, for the forensic conversation): if the pilot resumes in THIS session, async
resumption falls now land on fable - uniform-sonnet accounting needs either a
fresh sonnet session or accepted mixed accounting.

## 2026-07-13 wave 4: 0.13.13 validated live 3/3 + fixture v2 shipped; deck is pilot-ready

dk's word: all three proposed items, "get to our best state so we can do an account
run and pilot." Discharged in full; 9 legs, every one marker-verified on 0.13.13
(49942d9 cache), zero cockpit reads (boundary 9/9 incl. a greenfield state), full
numbers in METRICS "wave 4".

1. Fixture v2 SHIPPED (harness-owned, pre-decided): runs.log/provisions.log sink
   out-of-tree at `<parent>/.instrument/<tree>/`; runrecord homes at project root,
   gitignored; runs.sh falls back for pre-v2 trees. States rebuild green ~19s; fresh
   deck-hash baseline tw3=22c21b4b tw4=35ff6754 reproduces byte-exactly.
2. 0.13.13 spot-validation 2/2 PASS: (a) Boatswain notes arms all conformant on the
   root runrecord, zero reruns, ONE denial in a NEW shape — multi-path
   `git add -- <files> CAPTAIN.md` batch, strict-conformant per "exactly these two
   forms", self-healed 1 retry (the wave-3 misfire shapes never recurred naturally;
   ship-time 4/4 replay stays their ground truth); (b) fast-path FULL PASS on the
   verbatim quayline intent: minimal-RIGGING letter BINDS (every optional slot
   literally none, no wrapper scripts — every tw9 miss clean), report-contract
   fidelity live (Captain drove its binary pre-report; operator re-drive reproduces
   every claim), 7m24s to specs+watchbill+QM (3rd consecutive <10m), clean deck
   29m51s across two voyages, watchbill absent at rest.
3. tw11 supersede: CHOSEN LIVE, first in 4 invitations — the tw10 design rule
   (finding INSIDE the exercised behaviour) is validated. Scenario Outline supersede,
   skeleton deleted, watchbill for the now-red outline, zero production edits, zero
   executing runs (dry-run tree-verification: the cheap report-fidelity shape).
4. Model-pin mechanism NAILED (harness, dk owns tiering): an explicit pin survives
   only until the leg's first async-child resumption; the continuation falls to the
   session model and later children inherit the fall. Timeline proof in METRICS.
   Legs without nested spawns held their pin end-to-end.
5. Findings routed, none shipped: multi-path staging bless-or-price call; letter
   `none`s out user-stated stack values (Node 20/npm -> none, parked in notes) —
   wording question; two-voyage scoping economy note (+~25 inv vs tw8/tw9's single
   voyage, coherent seam split, not a defect); no-args -> NaN exit 0 CLI edge
   (voyage-1-legal, first-harbour item); v2 sink visible in runlog.js drew one
   read-only parent-dir ls.
6. Invocation-economy assessment delivered on dk's ask (safe levers, decision-ready):
   record-append ruling (hash-equality-guarded inherit; fast path's `runrecord: none`
   ran ZERO redundant confirmations this wave — direct evidence), bless multi-path
   content-blind staging, round-economy wording for Boatswain/QM (the 0.13.8 Captain
   precedent), spawn-count reduction via batching (shipped), deliberate model-tiering
   probe. Do-not-touch list: owed runs, opening reads, bulkheads.

OPEN (unchanged, dk has not ruled): record-append seam. Deck state: 0.13.13 fully
live-validated, fixtures v2, boundary discipline proven — PILOT-READY.

RESTART-READY, PLAN CONFIRMED BY dk (2026-07-13, end of wave-4 session): restart into
a fresh session with session model set to SONNET (makes the async-resumption pin leak
harmless — all falls land on sonnet, uniform accounting, comparable to pilot #1),
then run `/shakedown pilot` — pilot #2 on 0.13.13 AS-IS (no doctrine changes first;
the two pending rulings are known small costs the pilot should show in its numbers).
Cost estimate stated to dk: ~half of pilot #1's legs, 1.5-2.5h wall — confirm the
final cost in ONE line at pilot start per the command, then run to completion.
Oracle quarantine ABSOLUTE (operator-side grading only; no role sees the oracle).
Mine EVERY leg including nested (wave-4 procedure: tasks-dir symlinks into the
session subagents dir); count runs by transcript grep on uninstrumented greenfield
trees; classify per the audit lens; emphasis = invocation + latency accounting vs
pilot #1 baselines (517 inv / 4h31m / 13x-bare-session target toward 2-3x). The
account run (real project) remains dk-owned, after the pilot.

## 2026-07-13 session close: 0.13.13 SHIPPED on dk's word ("ship all five"); restart-ready

Doctrine 0.13.13 (49942d9) committed, pushed, installed 13:49 UTC; tests 194 green
(hooks 117 incl. 8 new access-vs-mention shapes). This session's subagents stay
snapshotted at 0.13.12; next session runs 0.13.13 by construction. The five:
1. Hook precision: CAPTAIN.md deny is now ACCESS, not mention - quoted prose
   (echoed labels, commit messages) strips before the check, a lone quoted path
   unwraps first so quoting cannot hide a read, metadata stats (ls/stat/test) and
   git-global-flag staging forms (git -C <dir> add -- CAPTAIN.md) allowed for
   Boatswain. Ground truth: the four EXACT wave-3 payloads replayed against the
   new script - three misfires now allow, the tw8-Crew cat chain still denies.
2. Boatswain skill wording matches the access rule (opens/searches/edits/removes).
3. @exceptional-double one voice: inline mark in verification support is the home;
   tag-table row + both agreement mentions reworded (scenario-tag voice removed).
4. Fast-path minimal RIGGING: binding example block embedded in the Captain
   skill's fast-path bullet (all-none slots literal); Shipwright cross-references.
5. Captain Final report: observable-contract claims tree-verified before reporting.

OPEN (dk has not ruled): the record-append seam - Crew hand-off green recordable
vs re-proof as the record's standing price. 4 live instances; batching already
cut the price to one batched rerun per voyage.

Next session queue (restart first; 0.13.13 markers for channel verification:
boatswain "not access and pass", captain "let the tree answer", shipwright
"embeds the exact minimal form", shared table "the mark lives inline in
verification support"):
1. Plugin-channel spot-validation of 0.13.13: one Boatswain hygiene leg composing
   labels + stat (expect zero denials), one fast-path leg on an empty repo with
   the boundary-line dispatch (expect the example block to bind: all-none slots,
   no wrapper scripts; also re-checks report-contract fidelity live).
2. Sharpened supersede invitation per the probes.md design rule (finding INSIDE
   the existing scenario's exercised behaviour).
3. Fixture v2 bump (pre-decided, do at session start before any probe states):
   sink runs.log/provisions.log outside the sim tree, move fixture runrecord out
   of logs/, record the new probe-state hashes in METRICS as the fresh baseline.

## 2026-07-13 wave 3: integrated plugin-channel re-run DISCHARGED (7 PASS + 1 tainted); dk nodded the two 0.13.12 probes mid-session

Real restart confirmed (process 11:49 UTC > install 08:01 UTC); channel verified by
marker grep on EVERY leg per the AGENTS.md rule — first genuine live firing of
0.13.12 text AND hooks. dk's mid-run word: the two 0.13.12 probes (scope-out gate,
fast-path bootstrap) joined the pre-approved five + verification-boundary. Eight
probes, 16 legs, all states from bin/probe-states.sh (tw3/tw4 deck hashes byte-equal
to the wave-1/2 baselines) + hand-built tw7 (fitted + noticeboard asset, RIGGING
assets slot pointed at assets/) and tw8 (empty repo). Full numbers in METRICS.md
"wave 3".

1. The five pre-approved probes: 5/5 PASS on the plugin channel — the owed
   integrated validation is closed. Text and hooks now agree live on every seam the
   0.13.11 ship touched: pathspec notes commit allowed first try (tw2, a185a21),
   content-blind staging + exclusion diff + row-1 inherit + corroboration strike
   (tw3, e38f706), ONE batched Crew dispatch (tw1, 5 suite runs vs wave-2's 8),
   QM's own foul re-derivation with Crew accepting the plank-only target (tw4),
   no-plant fit-out leaving the tree uncommitted (tw5), canonical record lines
   everywhere incl. void-on-edit + fresh append (tw4) and empty-record appends (tw1).
2. verification-boundary (dk's probe): PASS on the objective log joins — main
   window 4 runs / 1 provision, dashboard run provisioned ZERO through a spy,
   standalone cold-cache run provisioned exactly once, 1.5s paid once and amortized
   cross-run (bonus). The @exceptional-double mark landed INLINE in steps.js naming
   both grounds with agreement citations; the gherkin scenario is untagged.
3. scope-out gate: PASS, first live firing. Captain drafted specs + watchbill,
   classified the posting-procedure section, recorded it as a named question in
   report + CAPTAIN.md, and HELD the QM dispatch (zero spawns, zero runs, no commit
   past base). The board-template section went INTO binding specs byte-verified —
   the pilot's 0/29 shape is closed from both directions.
4. fast-path bootstrap: TAINTED PASS. Outcomes objective and all PASS-shaped
   (5-value RIGGING with every optional slot none, no methodology checks, 6 specs +
   watchbill in one pass, voyage green, CLI correct on all band edges incl. the
   surfaced 37.5 rounding question, custody + pathspec notes commits, clean deck;
   empty-repo to specs+QM-dispatched 7m51s — under the 10m target — and voyage
   complete ~17.5m vs ~40m baseline). BUT the Captain walked out of the empty repo
   into the operator cockpit (harness AGENTS/CAPTAIN/METRICS, probes.md incl. this
   probe's PASS rubric, fixtures/probe-states/RIGGING.md as its rigging template) —
   7 touches, sole leak in 16 legs; its own QM/Crew/Boatswain stayed clean. Not
   valid as independent validation; clean re-run owed. Its `model: sonnet` pin on
   the QM dispatch is cockpit-echo (my AGENTS.md rule), not doctrine behaviour.
5. Hook layer live: 4 denials, each self-healed in 1 retry. One CORRECT catch (tw8
   Crew attempted `cat CAPTAIN.md` — the bulkhead works). Two gap-(b) misfires:
   tw3's echo label (predicted), and NEW costume — tw8-Btsn denied for naming
   CAPTAIN.md in its commit-MESSAGE prose while staging it legally content-blind.
   One strict-conformant deny: `ls -la CAPTAIN.md` mtime stat (the 0.13.11 "every
   other command naming the file" wording outlaws wave-2's stat hygiene). Routed:
   gap (b) fix still pending dk; plus a wording question — should a metadata stat
   and commit-message prose count as "naming the file"?
6. NEW findings routed to dk, none shipped: (a) plugin channel costs +58%
   invocations vs HEAD-text for identical outcomes on identical states (182 vs 115
   on the five probes; tw2 14v8, tw3 30v13, tw5 40v26) — hooks + Skill loads +
   finer stepping; dk's lens says outcome first (5/5 both), so this is the price
   tag on enforcement, not a defect; (b) @exceptional-double is two-homed (tag
   table reads scenario-tag, Verification agreement says "mark inline"; tw6 chose
   inline, untagged scenario would redden a tag-reading forbidden-doubles scan) —
   one-line home ruling wanted; (c) record-append seam +3 instances (tw1/tw4/tw8);
   batching already shrank its price to one batched rerun; (d) model leak unchanged
   (3/8 nested legs fell to fable — always the parent's SECOND spawn).
7. Harness (operator-owned): SHIPPED — plugin-channel dispatches now carry "Work
   only inside the project root" (probes.md + preamble.md; tw8's breach was
   greenfield-state exposure: empty repo + role opening conventions + session cwd).
   QUEUED for next fixture bump (breaks old-wave hash reproducibility, so not
   mid-stream): sink runs.log/provisions.log outside the sim tree — tw6's QM
   legitimately wiped logs/ twice as scratch and the probe survived only because
   the QM checkpointed its own counts; near-miss: `rm -f logs/*.json` sat one
   extension away from runrecord.jsonl — consider homing the record outside logs/
   in the fixture RIGGING, and route the LOW doctrine question whether the Wake
   policy wants a record-not-in-scratch caution. Note: 2026-07-12's tw5 bootstrap
   probe (plugin channel, empty repo) shares the breach exposure — unmined for it.
8. Clean fast-path re-run (tw9, autonomous continuation, same intent + boundary
   line): PARTIAL PASS, taint mechanism closed — zero harness touches, zero
   denials, no cockpit-echo pin. Fast-path mechanism validated on a clean channel:
   8m14s empty-repo to specs+watchbill+QM (target <10m), honest real-spawn
   verification, custody + pathspec notes commits, clean deck. TWO conformance
   misses the tainted leg had masked, routed to dk: (e) the minimal-rigging letter
   does not bind — tw9 populated ~8 optional slots and authored a focused-wrapper
   script + cucumber config at bootstrap where the rule says "every optional slot
   none"; tw8 matched the letter only because it read the fixture template.
   Candidate 0.13.13: embed a minimal-RIGGING example block in the fast-path rule
   (the 0.13.11 record lesson: examples bind, key lists don't). (f) Report-contract
   fidelity: tw9's Captain reported a positional CLI contract while the tree
   implements named flags — the reported shape prints $NaN; caught only by driving
   the binary. A report claim naming an observable contract should be tree-checked
   before reporting. Also: 4th model-leak instance (tw9 Boatswain to fable).
9. Owed next: gap-(b) hook fix + exceptional-double home + stat/commit-message
   wording + minimal-rigging example + report-fidelity seam, all on dk's word.
   Supersede probe (tw10) run this session as the last owed wave item — verdict in
   the wave-3 METRICS addendum.

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

- Jolly and Estelle re-derive at next refit: everything 0.13.0-0.13.9, notably
  watchbill as sole QM channel, thin dispatch, broad/coverage without fail-fast,
  @invariant rename, planted-red vocabulary, trace-selected recheck, decision-table
  custody, runrecord slot in RIGGING, no-pre-check credentials.
- Pilots owe live-fire evidence: weather record, behaviour-identity duplication
  check, @eval tier, verification-economy audit at scale (TodoMVC pilot covers most).
- Open infra fork: automated live-agent bulkhead conformance harness vs the
  fixture-matrix proof in shipshape tests/bulkhead.sh - the probe catalog's
  contamination/bulkhead probes are the current answer; build more or accept.
