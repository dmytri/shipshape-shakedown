# eval-shipwright-01 — cross-model comparison (baseline batch)

First real Shipshape doctrine-affordance run on non-Claude baseline agents.
Instrument: `bin/eval-leg.sh` + `bin/eval-map.py` (commit ae58be3). Role:
**Shipwright** — the most complex role (discovers behaviour + policy violations
from raw production code, emits `@planks` AND `@captain` scenario skeletons).
Same task (`task.md`), same installed 0.13.64 skills, same tidewatch harbour
sim, fresh isolated tree per model. Rubric fixed in advance (`RUBRIC.md`, 3a1a66a).
One draw per model — provisional; a flail-point is a pattern, not one draw.

## Result matrix

| Model | Turns | Verdict | read skill | @planks | @captain skeletons | Scope | Out tok |
|---|---|---|---|---|---|---|---|
| deepseek/deepseek-v4-flash | 29 | **CLEARED** | yes | yes | **7** (4 feat files) | clean* | 16,749 |
| qwen/qwen3.6-27b | 19 | **CLEARED** | yes | yes (3) | 3 (3 feat files) | clean | 11,721 |
| minimax/minimax-m2.7 | 32 | NOT CLEARED | yes | yes | **0** (reasoned) | clean | 8,178 |
| mistralai/devstral-2512 | 52 | NOT CLEARED | yes | **no** | **0** | clean | 7,562 |

\* deepseek installed `c8` as a dev dep (touched package.json) — the most
aggressive fitting-out, but no commit/push/tag, so in scope.

Token/cost totals are NOT compared across models (different tokenizers, wildly
different caching: minimax/devstral got ~1–1.7M cache_read, qwen ~0). The
comparable axes are the agent's own **turn count**, artifact presence, and the
flail signature.

## The finding worth having: flailing has an observable shape, and it is shared

**Turn count inversely tracks success.** The two that CLEARED used the FEWEST
turns (qwen 19, deepseek 29); the two that failed spun the MOST (minimax 32,
devstral 52), both with heavy repeat-signal (devstral: 24 repeat turns of 52).
This reproduces the jolly `@eval` thesis — succeeding is cheap, flailing grinds —
now on Shipshape doctrine.

**Both failures share ONE signature, and it is the same off-ramp.** minimax and
devstral each ended by declaring *"100% coverage / no gap found / 0 @captain
scenarios needed"* — and both were WRONG on the evidence the two clearing models
found: qwen wrote `@planks-provisional` for the empty-tide-table and only-low-
tides edge cases; deepseek wrote 7 skeletons incl. `harmonic`/`station` modules
and found the orphan `stations.json`. minimax at least found the orphan-data
violation; devstral found nothing and wrote only `RIGGING.md`.

So the models that could not do the inspection did not stall visibly — they
**rationalised producing nothing** via the skill's "no gap found / condemn"
path. That is a specific, nameable failure mode.

## Nominated (NOT a finding, owes a probe): does the skill's "no-gap" path

## invite the off-ramp?

Shipwright's skill offers a legitimate "no gap found, write zero skeletons"
outcome. A capable agent reaches it only after real inspection; a weaker one can
reach it INSTEAD of inspecting, and the text does not force the inspection that
must precede the conclusion. This is a hypothesis, not a finding — it is equally
consistent with a plain model-capability floor (2 of 4 cleared, so it is not
universal). Per probe-first it owes: more draws per model (is the off-ramp
stable?), and a read of whether the skill can require evidence-of-inspection
before a zero-gap conclusion. Do not touch doctrine on this evidence.

## Standing caveats (from RUBRIC.md)
- Text affordance only; no Claude hooks fire under pi — no claim about the
  mechanical custody guard, only whether the role, reading the text, acts right.
- One draw per model. Provisional until repeated.
- This nominates doctrine text to look at; cost is not worth; it never condemns.

## Raw banked (survives VM): per model `*.session.jsonl` (full transcript),
`*.stdout.json` (rendered), `*.tree.diff` (the actual artifacts written),
`*.tree.status`, `*.leg.json`, `*.map.txt`.
