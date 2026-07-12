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
