# Metrics: how to read a shakedown

## The three numbers per leg (bin/mine.sh on the task transcript)

- invocations: model API calls (grouped by message.id). The primary cost driver -
  each re-prefills the whole context (~50-80k cache-read on sonnet legs).
- output tokens: reasoning + report. Small (5-15k/leg); NOT the cost driver.
- wall: first-to-last timestamp. ~95% agent overhead on toy suites, so wall tracks
  invocations x model speed, not verification.

Token cost ~= cache_read x invocations. Latency lever == token lever == fewer rounds.

## Suite executions (bin/runs.sh on the project)

The runlog BeforeAll hook logs every EXECUTING cucumber run (dry-runs excluded - they
run no hooks). Duplicates of the same argv with no intervening tree change = redundancy.
Attribute phases by line ranges (record the count between legs).

## Baselines (2026-07-12, sonnet, tidewatch fixture, doctrine 0.13.x)

| Leg | Invocations | Cache-read | Out | Wall |
|---|---|---|---|---|
| Shipwright fit-out (0.13.6) | 36 | 2.95M | 37k | 8.2m |
| Captain (0.13.6) | 13 | 610k | 8.9k | 1.4m |
| Captain (0.13.8, round economy) | ~10 tool uses | - | - | 44s |
| QM + foreground Crew (0.13.6) | 25 (incl 4 wasted polls) | 1.30M | 14k | 3.5m |
| Boatswain custody (0.13.7 table) | 15 | 712k | 10.6k | 2.6m |
| Boatswain custody haiku | 14-16 | ~500-600k | 6-8k | 1.4-2.2m |

Suite executions: fit-out ~8-11; voyage 14 (0.13.3) -> 8 (0.13.6) -> lower with wake
evidence (0.13.8).

## The audit lens (per dk)

For each invocation ask: worth its cost? mergeable into another invocation, another
job, another role? Known classes: opening reads (batchable), independent hygiene checks
(batchable), polling waits (eliminate - foreground spawns), discover+step-usage (one
run serves both, 0.13.8), custody reruns of caller-proven greens (inherit - decision
table row 1 / wake record).
