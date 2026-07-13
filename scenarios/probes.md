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

Channel verification (2026-07-13, mandatory): the plugin snapshot is process-level
and survives /clear. Marker-grep every installed-plugin leg's transcript for a
phrase unique to the doctrine version under test BEFORE judging the leg; a wave
without a positive marker check is channel-unverified. Two waves (2026-07-12
evening "0.13.10 seam probes", 2026-07-13 wave 1) ran ~0.13.8 text undetected and
had to be re-dated. HEAD-text mode is immune (explicit skill paths at HEAD); in
HEAD-text mode instruct role agents to spawn nested roles as general-purpose
subagents with the same preamble, never shipshape:* types (stale in a stale
session).
