# eval-candidateA v1 — seam-disposition ledger gate — SAMPLE result (one draw each)

Control = installed 0.13.64 (baseline data). Treatment = the seam-ledger candidate
(`candidate.diff`). Sample: 2 failers + 1 clearer. Text-affordance only; ONE draw
each — provisional.

| Model | | verdict | inv | wall s | cost $ | @planks | @cap | ledger emitted? |
|---|---|---|---|---|---|---|---|---|
| glm-4.7 | control | no | 36 | 285 | 0.133 | 1 | 0 | no (bare summary) |
| glm-4.7 | **treatment** | **no** | 44 | 438 | 0.170 | 1 | 0 | **YES** |
| devstral-2512 | control | no | 52 | 270 | 0.097 | 0 | 0 | no |
| devstral-2512 | **treatment** | **no** | 30 | 617 | 0.055 | **1** | 0 | partial |
| qwen3.6-35b-a3b | control | CLEAR | 16 | 211 | 0.166 | 1 | 1 | — |
| qwen3.6-35b-a3b | **treatment** | **CLEAR** | 16 | 96 | 0.130 | 1 | 1 | — |

## Verdict: v1 does NOT flip the failers. Informative partial, not a null.

- **Neither failer cleared** — both still write **0 `@captain` scenarios**. v1 does not
  earn a ship.
- **But it bought structural compliance:** glm-4.7 now emits a real "Seam-disposition
  ledger" section (it followed the new form) and devstral now planks the seam (1 vs 0).
- **The off-ramp survived by moving down one level.** glm's ledger lists ONE row —
  `src/tide.js::nextHighTide — covered` — and concludes 0 gaps. The ledger operates at
  SEAM (function) granularity, so a model can plank the one function, call it "covered,"
  and still never enumerate the distinct BEHAVIOURS (empty tide table, only-low-tides)
  that the clearing models found. The v1 coverage-!=-completeness *sentence* was still
  exhortation glm ignored.
- **Clearer held: no regression, no bloat** — qwen3.6-35b CLEAR both arms, same 16
  invocations, treatment even slightly cheaper. The edit costs a clearer nothing.

## Learning -> Candidate A v2 (still "clearer, not harder")

Make the ledger enumerate at the BEHAVIOUR level, not the seam level: for each seam,
list every behaviour it implements — the happy path AND each boundary/error path the
code handles — each dispositioned (binding scenario named, or a `@captain` gap). A seam
as a single "covered" row is incomplete; "covered" is a per-behaviour claim. This forces
the enumeration where glm currently asserts "100% => covered."

## Caveats
- ONE draw each — glm could vary; the *mechanism* (seam-level ledger insufficient) is
  consistent across both failers and explained, so v2 is well-motivated, but a firm
  verdict owes repeat draws.
- Do NOT ship v1. `~/shipshape` untouched.
