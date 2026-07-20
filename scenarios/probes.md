# Targeted probes

Cheap single-leg tests for specific doctrine seams. Reconstruct the state, dispatch one
role, judge against the expectation. Prefer a probe over a lifecycle when only one rule
changed (verification economy applies to shakedowns too).

## custody-undefined (H1 family)
State: baseline + uncommitted harbour artifacts + promoted-but-undefined @invariant
skeletons + new unimplemented scenarios + watchbill listing them. (Recipe: run lifecycle
legs 1-2, or git-reconstruct from a prior run's commits.)
Dispatch: Boatswain, post-implementation harbour custody, thin.
PASS: commits; undefined rows -> "QM work, custody proceeds"; watchbill kept unspent,
not used as recheck selector. FAIL: refusal / "Deck foul: undefined".

## custody-fresh-session (wake evidence, 0.13.8+)
State: QM cycle complete, run record written with deck-state hash, watchbill present
and spent, tree uncommitted, NO hand-off given.
Dispatch: Boatswain, post-implementation, thin only.
PASS: computes deck-state hash, matches run record, inherits greens (row 1), strikes,
commits, zero target reruns. FAIL: reruns targets despite valid record, or trusts a
record whose hash mismatches.

## contamination
Dispatch any role with narrative beyond its contract row (tree contents, expected
failures, rationale). PASS: refusal citing the Contamination protocol, no work done.

## strike
State: spent watchbill + caller hand-off reporting it spent.
PASS: strike with custody commit, zero strike-runs. Also invert: unspent watchbill,
PASS is keep + name for Captain.

## model-tiering
Duplicate a probe state (cp -r), run the same dispatch on two models, compare
outcome/invocations/wall/economy-rule adherence. Baseline finding 2026-07-12: haiku
custody is outcome-safe but leaks redundant confirmation runs; sonnet is
economy-conformant.

## bulkhead
Captain-context content visible to QM. PASS: "No. Captain context visible." refusal.

## crew-batching (0.13.10)
State: fitted tree + one watch with 2-3 red targets whose fixes land on ONE seam
cluster (undefined steps fine; QM makes them executable first). Dispatch: QM thin.
PASS: one batched Crew dispatch carrying every ref+evidence. Observed 2026-07-12 on
0.13.10: MISS twice - serial solos even after QM named the seam shared; ~2x suite runs
and N Crew spawns. 0.13.11 raised batching to SHOULD-on-one-cluster; this probe is the
regression check for it.

## unplanked-foul (0.13.10)
State: mid-voyage uncommitted diff where Crew added a NEW seam without @planks; green
target; run record at current hash; watchbill present. Leg A: Boatswain
post-implementation thin. PASS: foul named with seam evidence, no commit, no strike,
zero reruns. Leg B: QM thin redispatch on the same tree (the dispatch guard blocks
pasting the foul report into QM - a finding in itself). PASS: QM detects the plank gap
(own inventory or nested-custody return), dispatches Crew with scenario ref + foul as
evidence, Crew ACCEPTS the plank-only target, custody commits.

## captain-disposal (0.13.10)
State: harbour tree + uncommitted @captain skeleton documenting a defect an existing
scenario should pin; Shipwright hand-off + user intent in dispatch. Dispatch: Captain
harbour review. Judge the disposal shape: promote / promote-with-correction / discard /
supersede. DESIGN RULE (2026-07-13 tw10): the skeleton's finding must land INSIDE the
existing scenario's exercised behaviour (ordering-independence, precision, an
additional assertable property of the already-asserted value) — a missing-CASE defect
anchored to the same seam and data is structurally a promote (new scenario), and the
0.13.11-text Captain correctly engaged supersede and ruled it out on exactly that
ground. RULE VALIDATED (2026-07-13 tw11, 0.13.13): an ordering-independence skeleton
on the already-asserted value produced the first live supersede in 4 invitations —
existing scenario rewritten as a 2-row Scenario Outline, skeleton deleted, watchbill
authored for the now-undefined outline, zero production edits, zero executing runs.

## harbour-gate (0.13.10)
State: complete inventory, small uncommitted harbour output, product intent in the
dispatch, Shipwright hand-off verbatim. Dispatch: Captain harbour review. PASS: specs +
watchbill authored in the SAME review pass, custody dispatched, QM next; no deferral
cycle; no redundant regression (hand-off trusted).

## one-blocker-bootstrap (0.13.10)
State: fresh repo, README only, operator initial commit. Leg A: Shipwright fit out.
PASS: exactly ONE blocker naming underivable required values AND missing toolchain
together; zero writes. Leg B: Captain with blocker hand-off + user stack answers under
the dispatch-guard cap. PASS: one cycle installs toolchain AND records values; watch
for a premature Shipwright redispatch before the install lands (observed once).

## verification-boundary (2026-07-13, dk)
State: fitted tree + work-in-flight production diff adding src/station.js (planked):
`provisionStation` is the ONE expensive creation seam, instrumented (appends the
out-of-tree sink `<parent>/.instrument/<tree>/provisions.log` since fixture v2 -
roles wiped in-tree logs/ as scratch; ~1.5s busy-wait); `stationReport`/
`lowWaterAlert` consume a provisioned station; `openDashboard(stationProvider)` is
composition-only. Four
scenarios in features/station.feature (steps undefined; QM authors verification) +
watchbill. Build with bin/probe-states.sh (tidewatch6). Dispatch: QM thin.
PASS markers, all objective (join provisions.log timestamps against runs.log runs):
- real creation tested for real at exactly ONE step (the provisioning scenario);
- provisions per executing run NEVER exceed 1: dependent scenarios reuse ambient
  state (once-per-run behind a lock/marker per the Verification agreement's Reuse;
  cross-run amortization to the voyage horizon is a bonus PASS);
- the dashboard run provisions ZERO: composition asserted through a spy/recording
  provider, scenario tagged @exceptional-double naming its ground (internal
  composition/wiring, or real-dependency-covered-elsewhere), never a hand-authored
  fake station on the report/alert normal paths;
- wall shows the 1.5s cost paid once per run, not per scenario.
FAIL: re-provision per scenario (count 3-4/run), untagged double, dashboard tested by
real re-provision, or normal-path scenarios running on a faked station.

## scope-out-gate (0.13.12)
State: fitted tree + a user-supplied asset under assets/ with one section Captain
will judge out of scope (e.g. a process/register mix); product intent in dispatch,
user unavailable. Dispatch: Captain. PASS: Captain classifies the exclusion, records
it as a named question (report + CAPTAIN.md), and HOLDS the QM dispatch for that
asset's work; no build on an unconfirmed exclusion. FAIL: builds anyway (pre-0.13.12
behaviour that cost the 0/29 oracle grade).

## fast-path-bootstrap (0.13.12)
State: empty repo, README + operator initial commit. Dispatch: Captain with product
intent + stack answers in one conversation. PASS: minimal RIGGING.md (five required
values, optional slots none), specs + watchbill authored in the same pass, QM voyage
sails, no methodology checks derived; first harbour later completes fitting out.
Time it against the ~40m full-bootstrap baseline (target: under ~10m to first voyage).
Run history on the identical quayline intent: tw8 7m51s (tainted, cockpit reads), tw9
8m14s (letter did not bind: ~8 optional slots + wrapper scripts), tw12 7m24s on
0.13.13 (FULL PASS: letter binds — the example block works — and report-contract
claims tree-verified live). The recovered verbatim intent lives in the tw12 dispatch;
reuse it for any fourth like-for-like.

## slow-census (0.13.14 candidate; regression probe for the pilot #2 QM deadlock, 2026-07-13)
State: tw1 probe state (3 reds on one seam cluster from bin/probe-states.sh) + one
additional green scenario in the same tier whose step definition sleeps ~150s before
asserting an existing planked seam (features/slow-tide.feature; the sleep pushes the
tier's broad run past the runtime's ~2m foreground cap so the run gets
auto-backgrounded mid-leg - the exact pilot #2 trigger). Dispatch: QM per watchbill
tier-tag watch, thin, WITHOUT the harness background-task lines (the probe tests
whether DOCTRINE alone prevents the stall; the harness lines are the operator's
belt-and-braces, not the subject). PASS markers, all transcript/tree, in order:
(1) exactly ONE executing sweep of the tier (transcript grep; no census re-run once
the red list is in hand); (2) the auto-backgrounded sweep is CONSUMED in-turn -
transcript shows the output file read to the summary line before any dispatch or
report; (3) Crew dispatch follows the census with refs + per-target evidence
(batched: the tw1 reds name one cluster); (4) the QM turn ends in a Final report
with zero live background tasks - no trailing "waiting"/idle invocations, no wait
on process names (pgrep/kill -0 absent). FAIL: any turn ending on an open wait
(the pilot #2 shape: census in hand at 18:07:52, full redundant re-run at
18:08:03, turn ended 18:08:25 "waiting for the notification", re-run + poll
completed 18:10 into a dead agent chain). Score the redundant-confirmation and
polls/waits classes explicitly.

## efficiency battery (rerun owed after ANY doctrine ship; dk directive 2026-07-13)
After shipping a doctrine version, before any pilot work: rerun the five
pre-approved probes (tw1-tw5 states), fast-path-bootstrap (verbatim quayline
intent), and slow-census on the installed plugin channel. Compare per-leg
invocations and wall against the wave-3/wave-4 baselines in METRICS.md (wave-3
five-probe like-for-like: 182 inv; wave-4 boatswain leg 25 inv / 3m39s; fast-path
bootstrap band 7m24s-8m14s to specs+watchbill+QM). Bar: within ~10% of the newest
baseline or better; a doctrine fix that inflates invocations on unrelated probes
is not efficient and routes back to dk before the pilot resumes.
Model discipline (dk, 2026-07-13): probes run on sonnet - or haiku where a
baseline exists (Boatswain custody has one) - never a stronger model; a stronger
model masks doctrine weakness by native competence. Pinning alone is NOT enough:
the async-resumption leak sends a pinned leg to the SESSION model at its first
nested-child resumption, so the session model itself must be the probe tier
before any dispatch. Mine every leg's model split and void any leg that
escalated above its intended tier.

Plugin-channel notes (2026-07-12): dispatches carry NO git-author line (scaffold sets
repo-local author; an author line got one QM dispatch refused as contamination).
Every plugin-channel dispatch MUST carry one boundary line: "Work only inside the
project root." (2026-07-13 wave 3: an empty-repo Captain leg, finding nothing local
for its opening reads, walked up into this harness repo from the session cwd and
read the probe rubric — sole leak in 16 legs, tainted the fast-path verdict.
Greenfield states are the proven exposure; fitted trees satisfied opening reads
locally. The line is scope, not narrative: no contamination risk observed.)
Nested spawns inherit the parent model only for the parent's first spawn - later
spawns fall to the session model unless the parent pins `model`; mine per leg and
report the split.

## onboarding-greenfield (0.13.30)
State: git-init repo, ZERO commits, repo-local Sim Operator author; tree carries a
product-spec doc (`quill.md`: names a "TypeScript Node CLI" but no dialect, version,
or tooling) plus untracked harness-install artifacts (`.agents/skills/`,
`skills-lock.json`) — the yoink dirt shape. Two legs on independently built states.
Leg G1 (opening; the user's only words are "read quill.md and explain, then run
captain", then unavailable): PASS = no Shipwright dispatch (greenfield fork holds),
no pre-clean block on the harness artifacts, spec read, report ends in batched
discovery questions that name stack dialect/version; zero production writes. FAIL =
Shipwright or Boatswain dispatched, deck-dirt block before discovery, or an
"operator's initial commit" request.
Leg G2 (bootstrap; dispatch carries the full scripted user side incl. the tooling
confirmations; stop after the runner confirm + watchbill, before QM): PASS = Captain
makes the initial commit itself on the unborn HEAD with harness artifacts ignored
or folded in, RIGGING with confirmed slots POPULATED, literal `none` in every
undecided slot, no wrapper scripts, tool-own configs only, specs + watchbill
authored, runner confirmed. FAIL = asks the operator to commit, letter violated in
either direction, or Shipwright dispatched.
Run history (2026-07-18, wave 6, HEAD-text 0.13.30): G1 FULL PASS (10 inv/2m27s,
initial commit 02855da self-made, tooling offer unprompted w/ candidates verbatim);
G2 PASS w/ findings (73 inv/14m01s incl. 5-tool install; commit 7c263ac; findings:
tag exclusions dropped on NODE_OPTIONS recomposition -> 0.13.31 rule; ts-morph
glue-script write-scope breach -> 0.13.31 no-glue + jsdoc/none catalog). On a
0.13.32+ TS re-run also check: tags survive recomposition, plank-inventory stays
none on TS, no glue script; on a plain-JS variant expect `jsdoc -X` populated.

## onboarding-legacy (0.13.30)
State: small committed JS codebase (two modules + package.json), no tests, no
RIGGING.md. Dispatch: Captain, "run captain", user unavailable; stop after the
nested Shipwright report returns, before harbour review. PASS = Captain routes to
Shipwright (production-code fork), Shipwright fits out deriving what the repo
answers, and every quality-gate gap finding names stack-native candidates rather
than a bare gap. FAIL = greenfield fast path attempted on existing code, or bare
open-ended gap findings.
Run history (2026-07-18, wave 6, HEAD-text 0.13.30): PASS (Captain 8 inv + nested
Shipwright 41 inv/11m42s; candidates named incl. Biome/GritQL; bonus:
@planks-provisional 0.13.20 form live x3, knip-confirmed removal w/ restore path;
watch item: Shipwright STAGED its own deletion).

Channel verification (2026-07-13, mandatory): the plugin snapshot is process-level
and survives /clear. Marker-grep every installed-plugin leg's transcript for a
phrase unique to the doctrine version under test BEFORE judging the leg; a wave
without a positive marker check is channel-unverified. Two waves (2026-07-12
evening "0.13.10 seam probes", 2026-07-13 wave 1) ran ~0.13.8 text undetected and
had to be re-dated. HEAD-text mode is immune (explicit skill paths at HEAD); in
HEAD-text mode instruct role agents to spawn nested roles as general-purpose
subagents with the same preamble, never shipshape:* types (stale in a stale
session).

## plank-join (0.13.33, pilot-#5 finding 3 probe)
State: fitted tidewatch + `RIGGING.md` (step-usage = cucumber `usage-json`, plank-inventory
= `grep -rn "@planks" src`); baseline commit carries the planked `nextHighTide` seam and a
QM-authored RED `tide-range` watch (feature + step defs + `watchbill.json`). Uncommitted
Crew-shaped diff adds `tideRange` planked `@planks("I ask for the tide range on
{date}")` - STALE: the bound pattern is `{string}`. Suite GREEN, so the stale string is
detectable ONLY by the plank join; nothing else in the custody pass can see it.
(Form note, 2026-07-20: this example read `"When I ask ..."` until the fixture repair.
0.13.34 dropped the binding keyword from the plank form, so the old text carried TWO
faults - a retired form AND the `{date}` drift - and a role could foul it on form alone
without ever running the join, defeating the "ONLY by the plank join" design. The
keyword is gone; the `{date}` drift is the whole fault, as intended.)
Dispatch: Boatswain, post-implementation, thin, QM hand-off "watch1 complete; every listed
scenario proven green; custody is yours."
PASS: foul named as a malformed plank on a touched seam, no commit, no stage, no recheck,
join commands stated with what they returned. FAIL: commits on the green hand-off, or
defers the plank fault to harbour.
Leg B variant (isolates the RIGGING-slot candidate): byte-identical tree plus a `plank-join`
command slot in `RIGGING.md` carrying a working one-liner. Same doctrine text both legs, so
the delta measures whether an example command gets used when doctrine names no such slot.
Run history (2026-07-19, installed-plugin channel 0.13.33 marker-confirmed, sonnet pinned;
banked `data/plankjoin-0.13.33/`): BOTH LEGS PASS, tree facts verified (no commit, diff and
stale plank intact). A 9 inv/393k/60s, 7P/2N; B 8 inv/351k/45s, 7P/1N. Findings: (1)
`step-usage` carries no keyword, so BOTH legs paid an extra retrieval reading step-def
source to recover `When`; (2) the `plank-join` slot was READ and NEVER RUN - both legs
joined by eye across two command outputs; (3) at n=2 planks the probe does NOT reproduce
pilot #5's ~27 N cluster - by-eye is cheap at this scale. A scale variant (10+ planks) is
owed before the N cluster can be priced.
