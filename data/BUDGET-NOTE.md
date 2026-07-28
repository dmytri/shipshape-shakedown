# The output budget is per-MODEL, not uniform — and leg.json's max_tokens is intent, not fact

Measured in live legs, 2026-07-28:

| model | budget actually enforced | across arms |
|---|---|---|
| deepseek/deepseek-v4-flash | 4096   (peaks land exactly on 4096; legs cut off) | identical |
| xiaomi/mimo-v2.5           | 131072 (peak observed 49,362)                   | identical |
| tencent/hy3                | 131072 (peaks ~15-16k)                          | identical |

`bin/eval-leg.sh` seeds each leg's isolated `models-store.json` with a uniform cap and records
`max_tokens` in `leg.json`. **pi does not honour it.** It refetches model metadata at launch and
applies `max_tokens ?? 4096` in memory, so the seeded file is written and ignored. Verified three
ways: the seeded store in a running leg read 32768; that same leg was cut off at exactly 4096 with
`stopReason=length`; and a direct API call with `max_tokens=32768` is accepted by the provider
(`finish_reason=stop`), so the limit is pi's, not OpenRouter's.

## What this constrains

- **Arm vs arm within a model: VALID.** All three arms of a model run the same budget.
- **Voyage counts across models: NOT comparable.** flash works in a 4096 window while mimo and
  hy3 have 131072 — a 32x difference in how much a role may emit per response.
- flash is the only model under real budget pressure, which makes its cells the most revealing:
  a flash leg that ruminates is TRUNCATED, while a mimo leg that ruminates completes an expensive
  no-op. Measured: P6-ctrl-cmimo v5-qm burned its full 131,072 on 564,744 characters of thinking
  and emitted no text and no tool call at all.

## Owed

`leg.json` should record the OBSERVED budget, derived from the session's peak and stopReason,
rather than the requested one. Until then read `bin/peaks.py` for the truth and treat
`leg.json:max_tokens` as intent only.
