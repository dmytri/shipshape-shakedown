# Golden-set candidate test — PRE-REGISTERED before any leg ran (dk, 2026-07-23)

## Design
Control-armed, repeat-draw evaluation over the GOLDEN SET (14 models, data/eval-batches/golden.txt).
- CONTROL  = current shipped doctrine, installed 0.13.64 (shipshape + shipwright), NO yoink skill.
- TREATMENT = yoink-settle candidate (central Batched-retrieval Article + operative rule at the
  point of action + opening hoist example; on conformance-gate base) + the yoink skill.
- 3 draws per model per arm (42 legs/arm, 84 total). EVAL_NO_STDOUT=1 (bank light layer only).

## Two deliverables
1. TOP-3 model ranking, from the CONTROL arm (current doctrine) — like the researcher pass:
   best-clearing, fastest (wall/round-trips), cheapest ($).
2. YOINK verdict, TREATMENT vs CONTROL per model.

## Rubric (fixed before results)
- FLOOR (gate): CLEAR-rate. Treatment must NOT drop a model below its own control CLEAR-rate.
  CLEAR = wrote >=1 @conformance skeleton in a .feature (the mandatory deliverable) AND >=1 @planks.
  Affordance outranks everything: a latency win that costs CLEAR fails.
- #1 GOAL latency: round-trip count = tool calls and turns (each is a sequential model round-trip).
  Also wall_s. Lower is better. Yoink adoption (bash-outside-yoink -> 0) is the mechanism.
- #2 GOAL tokens: fresh tok_in + cache hit%. Secondary; may regress for well-cached models
  (big bundle = one large input) and that is acceptable under latency-first.
- "A difference of one leg is not a result": judge on 3-draw RATES, not single legs.
- Model variance is expected and FINE: some models adopt yoink better than others; the floor is CLEAR.
