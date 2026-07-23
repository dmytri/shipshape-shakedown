# eval-shipwright-researcher — the SAIA researcher's accessible models, on OpenRouter

Which of the models a **real Shipshape consumer** (GWDG SAIA) can reach actually
drive the hardest role (Shipwright) well? Tested via OpenRouter (no SAIA cluster
access; OR has exact matches for all but 3 SAIA-only: apertus-70b, devstral-2-123b,
qwen3-omni — untested). Control doctrine (installed 0.13.64), one draw each, fresh
isolated tree per model, same task/skills as eval-shipwright-01. **Provisional:
one draw is a single sample; a flail-point is a pattern, not one draw.**

## Full comparison (baseline + researcher merged, all axes)

| Model | Verdict | Inv | Wall s | Cost $ | @planks | @cap | Note |
|---|---|---|---|---|---|---|---|
| qwen3.5-122b-a10b | **CLEAR** | 25 | 145 | 0.2269 | 1 | 1 | fastest cleared |
| qwen3.6-35b-a3b | **CLEAR** | 16 | 211 | 0.1663 | 1 | 1 | fewest invocations |
| deepseek-v4-flash | **CLEAR** | 29 | 520 | 0.1088 | 1 | 4 | cheapest; most thorough |
| mistral-medium-3.5 | **CLEAR** | 54 | 609 | 0.4959 | 2 | 1 | cleared but spun/expensive |
| qwen3.6-27b | **CLEAR** | 19 | 679 | 0.3265 | 3 | 3 | baseline clear |
| qwen3-coder-next | ERROR | 1 | 0 | 0.0000 | 0 | 0 | **empty response** (non-starter; re-run) |
| llama-3.1-8b | no | 6 | 10 | 0.0039 | 0 | 0 | floor; did ~nothing |
| gpt-oss-120b | no | 12 | 42 | 0.0098 | 0 | 0 | fast off-ramp |
| qwen3-30b-a3b-2507 | no | 28 | 130 | 0.0941 | 0 | 0 | no artifacts |
| minimax-m2.7 | no | 32 | 222 | 0.0767 | 2 | 0 | off-ramp (baseline) |
| devstral-2512 | no | 52 | 270 | 0.0965 | 0 | 0 | off-ramp (baseline) |
| glm-4.7 | no | 36 | 285 | 0.1330 | 1 | 0 | **silent off-ramp: declared 100%/0-violations, wrote 0 scenarios** |
| qwen3.5-397b-a17b | no | 26 | 408 | 0.3265 | 1 | 0 | planked then stopped; no scenarios |
| gemma-4-31b | no | 12 | 661 | 0.0625 | 0 | 0 | slow, no artifacts |

**CLEARED 5/14.** Cost/wall are OpenRouter's own (from pi's per-turn usage);
not perfectly cross-comparable (tokenizers/caching differ), but directionally real.

## Deliverable for the researcher (of THEIR accessible set)

- **Best value:** `qwen3.6-35b-a3b` — cleared in the fewest invocations (16) and cheap ($0.17).
- **Fastest:** `qwen3.5-122b-a10b` (145 s).
- **Cheapest:** `deepseek-v4-flash` ($0.11) — and the most thorough (4 skeletons).
- **Avoid for this task:** the biggest/most-capable did NOT clear — `qwen3.5-397b-a17b`
  planked then stopped; `glm-4.7` is the **dangerous** one: it confidently reported
  *"100% coverage, 0 violations, 0 @captain"* while producing nothing — a silent
  failure that LOOKS successful. A consumer trusting its report ships an un-inspected
  codebase believing it was cleared.
- **Re-run:** `qwen3-coder-next` returned an empty completion (provider/model issue).

## The finding worth having (strengthens Candidate A; NOT shipped)

**Capability does not predict clearing, and the no-gap off-ramp is MODEL-AGNOSTIC.**
The most capable accessible model (`qwen3.5-397b-a17b`) and a strong agentic-coding
model (`glm-4.7`) both failed to produce `@captain` skeletons, `glm-4.7` via the exact
"100% / no gap" off-ramp the weak baseline models (minimax, devstral) took. Meanwhile
mid-size MoE models cleared cleanly and cheaply. **A defect that strong AND weak models
hit alike is doctrine, not a capability floor** — the skill lets any model declare
"no gap" without proving inspection first. This is the sharpest evidence yet for
Candidate A (the seam-ledger report gate). Owes: repeat draws (one sample each), then
the A/B control-vs-candidate probe.

## Standing caveats
- Text affordance only (no Claude hooks under pi).
- One draw per model — provisional.
- 3 SAIA-only models untested; a couple of OR builds may differ slightly from SAIA's.
