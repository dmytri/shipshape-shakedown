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
PASS: one batched Crew dispatch carrying every ref+evidence. Observed 2026-07-12: MISS
twice - serial solos even after QM named the seam shared; ~2x suite runs and N Crew
spawns. Watch the wording seam ("MAY batch ... fallback") until 0.13.11 rules.

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
supersede. Supersede has never been chosen live (2 designed invitations). Anchor the
skeleton to the existing scenario's own data to invite supersede hardest.

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

Plugin-channel notes (2026-07-12): dispatches carry NO git-author line (scaffold sets
repo-local author; an author line got one QM dispatch refused as contamination).
Nested spawns inherit the parent model only for the parent's first spawn - later
spawns fall to the session model unless the parent pins `model`; mine per leg and
report the split.
