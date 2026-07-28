# eval-clean-control — clean baseline after the containment fix (2026-07-23)

Sample (glm-4.7, devstral-2512, qwen3.6-35b-a3b), 3 draws, installed 0.13.64, with
the FIXED task (no VM-path leak; framed as "the ENTIRE codebase ... the only project
that exists") and live escape detection.

## Two findings

**1. Containment fix validated: 0 escapes.** No leg wandered out of the sim. (The one
known escape — glm-4.7 — was in the v2 arm under the leaky prompt.)

**2. Clear-rate rose 1/9 -> 4/9, and it is the FRAMING, not escape-removal.**

| Model | leaky control | clean control |
|---|---|---|
| devstral-2512 | 0/3 | **2/3** `C(p3/c3) C(p1/c1) .(p1/c0)` |
| qwen3.6-35b-a3b | 1/3 | 1/3 `C(p1/c1) .(p0/c0) .(p0/c5)` |
| glm-4.7 | 0/3 | **1/3** `C(p1/c2) .(p1/c0) .(p0/c0)` |
| TOTAL | **1/9** | **4/9** |

Retro escape-scan of the leaky control legs (tool calls only): ALL CLEAN — the control
arm never wandered. So the jump is NOT from removing escapes; it is from the stronger
scope framing helping models commit to inspecting the sim instead of second-guessing
scope. This is a HARNESS/DISPATCH lever for "more models clear" — no doctrine change.

## Caveats / next
- n=9 per arm, live variance. 1/9 vs 4/9 is directional (devstral 0->2/3 is the biggest
  mover, no model got worse), NOT conclusive. Owes more draws (extend clean to 5-6).
- The escape fix is valuable regardless: glm-4.7 DID escape in the v2 arm; the detector
  + path-leak fix prevent a real data-validity bug.
- Implication: earlier leaky-prompt measurements (baseline 5/14, researcher ranking,
  Candidate A's NULL at 1/9 vs 2/9) were run under the WEAKER framing and are confounded;
  the researcher ranking especially owes a clean re-run before it goes to the consumer.
- Note qwen's erratic draws: one wrote 5 @captain but 0 @planks (c5/p0) — did the
  scenario work, skipped planking. Clear requires both; a partial like this is a near-miss
  worth watching as a distinct failure mode.
