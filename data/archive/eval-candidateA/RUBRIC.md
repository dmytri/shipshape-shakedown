# eval-candidateA — rubric, FIXED BEFORE ANY TREATMENT LEG RAN

Watchword: **"prompt clearer, not harder."** Candidate A is a STRUCTURAL edit, not
exhortation — see AGENTS.md "Eval tier".

## Hypothesis
Shipwright's Final report form lets a model summarise its way to "no gap found /
100% / 0 violations" WITHOUT walking every seam — the no-gap off-ramp, taken by weak
AND capable models alike (devstral, minimax, glm-4.7, qwen3.5-397b). Candidate A adds
a required **seam-disposition ledger** to the report (reusing the existing
`plank-inventory` command): every seam accounted for by its disposition, and "no gap"
earned seam-by-seam, plus coverage% != behaviour completeness. Making the OUTPUT
require the walk should flip failers without harming clearers.

## Arms (anti-pollution: ~/shipshape untouched)
- CONTROL = installed 0.13.64 (the baseline/researcher data already banked, same
  task/skills/sim, one draw each).
- TREATMENT = gitignored `experiments/no-gap-ledger/skills/shipwright` (installed
  shipwright + the ledger-gate edit) + installed `shipshape`. Diff banked at
  `candidate.diff`; the skill copy itself is never committed.

## Models
- SAMPLE (fast iteration): glm-4.7 (flagship off-ramp), devstral-2512 (zero-artifact),
  qwen3.6-35b-a3b (clearer regression check).
- FULL baseline (9) only for the final confirmation.

## Verdict per leg (unchanged bar + ledger check)
- cleared = read shipwright skill, @planks on a real seam, >=1 @captain skeleton,
  in scope (no commit/push/tag). NEW observation: did it produce the ledger?
- flailed / not-cleared = missing an artifact, off-ramp, spun, or scope break.
- never-loaded = never read shipwright/SKILL.md (routing miss, reported distinctly).

## Decision
- HELPS = treatment CLEARS a failer that control did NOT, with no clearer regressing
  and no cost blow-up.
- NULL (capability floor) = failers do not move -> do NOT ship (0.13.50 discipline).
- REJECT = a clearer regresses, or cost/turns balloon materially.
- One draw is provisional. Confirm with repeat draws + full baseline BEFORE routing
  to dk. Ship only via ship-first (edit ~/shipshape, bump, tests green, push,
  reinstall) on dk's word.

## Caveats
- Text affordance only (no Claude hooks under pi).
- Cost/tokens not comparable across models; compare VERDICT movement and flail location.
