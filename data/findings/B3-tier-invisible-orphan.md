# FINDING B3 (doctrine, both arms): nobody owns the reddening check for a tier-invisible defect

Two cells in the R6 matrix stalled at 27/29 on the SAME failure, with clean instruments —
no truncation, no missing modules, no lost custody, Captain authoring every voyage:

  R6-cand-hy3   27/29, 11 voyages stuck   (candidate doctrine)
  R6-mid-mimo   27/29, 12 voyages stuck   (midway = control + methods)

Failure: `Editing -- should remove the item if an empty text string was entered` — the
edit-commit reentrancy. happy-dom does not fire blur on node removal, so NO executing scenario
in the roles' tier can redden it. The corpus has recorded this tier limit twice before.

## What the transcripts show

R6-cand-hy3 v8-captain (20 turns, 160,974 chars of thinking) diagnosed it exactly: 38 mentions
of `blur`, 8 of "impossible", 10 of `happy-dom`, and it REACHED FOR THE RIGHT ROUTE — 5 mentions
of `scantling`, including the planted-red methodology. Then it refused, on doctrine grounds:

  "a bespoke conformance checker is verification support under QM, not a Captain-owned
   scantling file ... I should NOT move the check to a scantling file (that would be QM's job)."

So Captain wrote a scenario + watchbill and stopped. R6-mid-mimo shows the same shape (v10
mentions scantling once, blur 28; v11 blur 38 and no scantling at all), and its QM legs then
run 6-12 turns with ZERO writes, voyage after voyage.

## The seam

- The only reddable artifact for this defect is a STRUCTURAL check over the source.
- Captain owns durable requirements (scantlings) but doctrine tells it a bespoke checker is
  verification support, which is QM's.
- QM owns verification support but acts on RED TARGETS from the watchbill.
- The watchbill can only carry scenarios, and every scenario Captain can write PASSES in this
  tier — that is what tier-invisible means.

=> The defect is diagnosed, the route is known, and no role is positioned to create the artifact
that would redden it. Both arms stall identically, so this is SHARED doctrine, not the
candidate's regression.

## Why it matters beyond one test

This is the same class the banked pilots hit: dk's own steer in newsim-01 was a SCANTLING, and
it worked — deepseek coded the one-line fix immediately once the check reddened. The steer came
from the OPERATOR. Without it, the loop cannot self-serve.

## Candidate fixes (NOT applied; dk's call, alongside B1/B2)

1. Let Captain own the reddening structural check when the executing tier provably cannot
   express the defect — i.e. state the exception, since the Scantling agreement already allows
   structural facts as durable requirements.
2. Or let QM open verification support on its own initiative when a watchbill target is green
   in-tier but named by an outside failure — today it has no mandate to act without a red.
3. Or give the watchbill a second entry kind: a structural obligation, not just a scenario
   reference, so the channel Captain already owns can carry it.

Fix 3 is the "prompt clearer, not harder" shape: it makes the artifact able to express the
obligation, rather than exhorting a role to try harder.
