# Captain notes - shipshape-shakedown workstream

## NEXT SESSION QUEUE (fable model, runs AFTER pilot #3's full analysis is delivered - dk's word)

Consolidated pointer so nothing below gets missed. Five items, all mid-pilot findings
routed but NOT shipped (no side-scope mid-pilot rule held throughout):

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

- Jolly and Estelle re-derive at next refit: everything 0.13.0-0.13.9, notably
  watchbill as sole QM channel, thin dispatch, broad/coverage without fail-fast,
  @invariant rename, planted-red vocabulary, trace-selected recheck, decision-table
  custody, runrecord slot in RIGGING, no-pre-check credentials.
- Pilots owe live-fire evidence: weather record, behaviour-identity duplication
  check, @eval tier, verification-economy audit at scale (TodoMVC pilot covers most).
- Open infra fork: automated live-agent bulkhead conformance harness vs the
  fixture-matrix proof in shipshape tests/bulkhead.sh - the probe catalog's
  contamination/bulkhead probes are the current answer; build more or accept.
