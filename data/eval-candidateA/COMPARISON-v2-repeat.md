# eval-candidateA — REPEAT-DRAW result (3 draws/model/arm) — the real verdict

Control (installed 0.13.64) vs v2 (behaviour-level seam-ledger candidate), sample of 3
models, 3 draws each = 18 legs. CLEAR = @planks on a seam AND >=1 @captain skeleton AND
no commit. Per-draw C/. shown.

| Model | Control | V2 |
|---|---|---|
| devstral-2512 | 0/3  `.(p2/c0) .(p3/c0) .(p1/c0)` | 1/3  `.(p2/c0) C(p5/c4) .(p2/c0)` |
| qwen3.6-35b-a3b | **1/3**  `C(p1/c3) .(p1/c0) .(p0/c0)` | 0/3  `.(p1/c0) .(p3/c0) .(p3/c0)` |
| glm-4.7 | 0/3  `.(p1/c0) .(p1/c0) .(p1/c0)` | 1/3  `.(p0/c0) C(p1/c5) .(p1/c0)` |
| **TOTAL** | **1/9** | **2/9** |

## Verdict 1: Candidate A is NULL — DO NOT SHIP.

1/9 vs 2/9 is a ONE-LEG difference. The corpus rule is explicit (0.13.50): "a difference
of one leg is not a result." v2's structural effect is real and reproducible — it forces
a behaviour-level ledger (glm and qwen both emit one) — but it does NOT reliably flip the
outcome. The apparent per-model movements (devstral 0->1, glm 0->1, qwen 1->0) are within
one-draw noise and roughly cancel. The off-ramp is substantially a JUDGMENT/CAPABILITY
floor: the ledger compels enumeration but not the correct gap-vs-covered disposition, and
no wording compels judgment. Probe-first worked exactly as designed — it stopped a
do-nothing doctrine edit from shipping. ~/shipshape untouched.

## Verdict 2 (bigger): single-draw CLEARED verdicts were OVERSTATED.

qwen3.6-35b-a3b — labelled a "clearer" (CLEAR in the baseline table AND v1) — clears only
**1/3** under control. Its CLEAR was one-draw variance. The honest picture of the hardest
role for mid-size models is not binary CLEARED/not; it is a LOW, NOISY clear-rate (~1/3 or
less). This is the corpus's own lesson ("outcome is a function of when you look") applied
to affordance: a model's clear verdict is a function of which draw you look at.

**Consequence for the record:** the 5/14 baseline table (eval-shipwright-01,
eval-shipwright-researcher) and the researcher best/fastest/cheapest ranking are
SINGLE-DRAW snapshots. They are directionally suggestive but NOT earned at n=1. Any
"which model drives Shipshape well" claim owes clear-RATES (repeat draws) before it is
handed to the real consumer as a recommendation.

## What survives
- The instrument, the model-agnostic off-ramp finding, and v2's reproducible structural
  effect (behaviour-level enumeration) all stand.
- The eval's DEFAULT going forward must be repeat draws + clear-rate, not single draws,
  for any ship-or-recommend decision. Single draws are fine only for cheap exploration.
