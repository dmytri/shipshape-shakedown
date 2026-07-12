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
| custody-fresh-session probe (0.13.8 plugin channel, row-1 inherit) | 14 | 623k | 15.8k | 3.0m |
| strike probe, hand-off control (0.13.8 plugin channel) | 13 | 614k | 13.7k | 2.9m |
| stale-record probe (0.13.8 plugin channel, void + rerun by trace) | 27 | 1.47M | 15.9k | 4.0m |

Suite executions: fit-out ~8-11; voyage 14 (0.13.3) -> 8 (0.13.6) -> 3 (0.13.8 with
wake run-record: one red classify, one Crew-local, one QM terminal green; custody ran
zero). Probe pair 2026-07-12: row-1 inherit 0 executions, hand-off strike 0, stale-record
1 (exactly the owed focused rerun; argv in runs.log matches the focused shape).

Full voyage 0.13.8 (Captain + QM/Crew + fresh-session custody): 35 invocations,
~1.53M cache-read, ~17k out, ~5.6m wall. Same intent on 0.13.3: 15.7m.

## TodoMVC pilot baselines (2026-07-12, sonnet, HEAD-text legs, doctrine 0.13.9)

27 dispatched role legs, greenfield to graded app. Role-leg totals only: 517
invocations, ~41.1M cache-read, ~749k out, 4h31m lifecycle wall. ~39 nested
Crew/Boatswain subagent transcripts (QM-spawned) NOT included; mine from the session
tasks dir for implementer-side numbers. Notable legs: QM build voyage 111
invocations / 12.7M / 92m (17 Crew dispatches); Shipwright harbour 31 / 4.25M / 14m;
Shipwright fit-out completion 34 / 3.47M / 13m. Bootstrap (empty repo to first
product spec) cost 10 legs / ~65m - the harbour-gate deferral in the first Captain
spec leg is the single largest avoidable serialization.

Oracle (tastejs/todomvc pinned ff43b02e, cypress 15.14.2, operator-side quarantine
held): first grade 0/29 (template-markup gate, 28 unmeasured); after ONE
product-language iteration (template sections promoted to binding specs, 5 scenarios,
5 Crew fixes): 18 passing / 9 failing / 2 skipped. The 9 residual failures are
objective unauthored conformance findings (see CAPTAIN.md).

## 0.13.10 validation probes (2026-07-12, sonnet, HEAD-text)

| Probe | Invocations | Cache-read | Out | Wall | Verdict |
|---|---|---|---|---|---|
| QM seam-parallel Crew (2 disjoint seams, one file) | 14 | 571k | 12.4k | 3.8m | PASS: 2 parallel mates, collision self-healed |
| Boatswain notes custody + strike + record shape | 22 | 1.20M | 24.4k | 5.1m | FULL PASS, transcript-verified content-blind |
| Shipwright fit-out plank rules | 25 | 2.34M | 59.5k | 12.0m | PASS derivation; MISS plant-red (timing ambiguity, 3 divergent obs) |

Probe 2 tool-call audit: deck diff composed as `git diff <base> -- . ':!CAPTAIN.md'`
verbatim; only mtime stat and by-path add touched CAPTAIN.md. Zero content reads.
Probe 2 also live-validated: void-on-any-byte (record died when CAPTAIN.md landed),
rerun by trace exactly the 2 owed targets, strike after own append at current hash,
canonical JSON record lines.

## 0.13.10 seam probes, plugin channel (2026-07-12 evening, installed 0.13.10 c045b46, sonnet top-leg dispatch)

Five pre-approved probes, 31 legs total (7 dispatched + 24 nested), all mined including
nested Crew/Boatswain/QM. Totals: 409 invocations, 18.16M cache-read, 412k out, 41m
wave wall (probes parallel). Model split: sonnet-5 264 inv / 12.57M; fable-5 145 inv /
5.59M (nested spawns after a parent's first fall to the session model unless the parent
pins `model` explicitly - tw3's Captain pinned, all-sonnet children; every other parent
leaked). Nested fable-5 Crew ran 7-9 inv vs sonnet Crew 11-12 on like-for-like solos.

| Probe | Legs | Inv | Cache | Out | Wall | Suite runs | Verdict |
|---|---|---|---|---|---|---|---|
| 1 Crew batching arm | 5 | 61 | 2.39M | 40k | 11.5m | 16 | MISS: 3 solo Crew sequential on a seam QM itself named shared |
| 2 unplanked-foul route (2a+2b) | 4 | 48 | 2.11M | 50k | 1.8m + 9.4m | 5 | PASS: foul ruled (no commit/strike/runs); Crew ACCEPTS plank-only target; route closes with commit |
| 3 @captain supersede | 8 | 114 | 5.05M | 100k | 22.9m | 5 | MISS: promote-with-correction chosen; supersede still unobserved live |
| 4 harbour-gate same-pass | 7 | 89 | 3.50M | 81k | 20.4m | 12 | PASS: specs+watchbill in the review pass, zero redundant regression; bonus full voyage |
| 5 one-blocker bootstrap (5a+5b) | 7 | 97 | 5.11M | 142k | 3.7m + 36.1m | uninstrumented | PASS: one blocker; one Captain cycle resolves values AND toolchain; full fit-out + methodology suite green |

Leg worth densities: P2a Boatswain custody-foul 100% (9 inv/351k/1.8m - new best custody
baseline), P1 voyage Boatswain 100% (10 inv), tw3 strike Boatswain 100% (10 inv, record-
corroborated strike, zero strike-runs - 0.13.9 arm FULL PASS live), tw5 fit-out
Shipwright#2 100% (12 inv incl. two planted-red proofs), P1 QM 91%, P2b QM 91%, P5b
Captain 91%, P3 Captain 88%, P4 Captain 78% (refused-dispatch poll cluster: sleep 240
et al, ~400k waste from one over-narrated dispatch). Run redundancy: tw1's serial-solo
shape staled ~5 Crew mid-proofs (charged to the batching MISS, not discipline).

## Class tally (impact frequency; update every shakedown)

| Class | Instances | P | N | Neg | Worthiness |
|---|---|---|---|---|---|
| skill/rigging reads (opening) | 76 | 76 | 0 | 0 | 100 (31 plugin legs pay exactly the 2-read tax; resident-by-design holds) |
| deck retrieval + context reads | ~160 | ~152 | ~8 | 0 | ~95 (N: package.json re-reads, duplicate scans, one find dupe) |
| owed verification runs | 38 | 33 | 5 | 0 | 87 (5 solo-shape staled Crew mid-proofs in tw1; charge to batching MISS) |
| redundant confirmation runs | 0 | - | - | - | discipline-level still 0 across 24 more plugin legs (2026-07-12 seam probes) |
| polls/waits | 9 | 0 | 9 | 0 | 0 (7 new: parents sleeping on async nested spawns, worst sleep 240; structural to async Agent spawns, not role discipline) |
| evidence ops (run record, deck-state hash) | 24 | 23 | 1 | 0 | 96 (hash computes, appends, strike corroboration all consumed; QM inherited record greens twice) |
| staging/commit/report | 33 | 30 | 3 | 0 | 91 (8 commits; N: post-commit re-lists, one denied CAPTAIN.md commit - see hooks finding) |
| mid-leg doctrine re-read | 3 | 3 | 0 | 0 | 100 (both new instances preceded and shaped a disposal/fit-out decision) |
| contaminated/premature dispatches | 3 | 0 | 0 | 3 | 0 (git-author line to QM; over-narrated Boatswain; Shipwright before toolchain - each cost a refused leg + parent rework, ~400k worst case) |
| contamination refusals/guards | 4 | 4 | 0 | 0 | 100 (2 agent refusals, 2 hook blocks; every one caught a real contract breach, cheapest 0 tokens at the hook) |

Leg worth densities 0.13.8: Captain ~90%, QM 73%, wake-custody 82%.
Probes 2026-07-12 (sonnet, plugin channel): fresh-custody 100%, hand-off strike 100%,
stale-record 91%.
Seam probes 2026-07-12 evening: see the 0.13.10 seam probes section above; overall
P~391/N~15/Neg 3 of 409 (~95% positive).

## The audit lens (per dk)

Classify EVERY invocation's impact by one objective test - trace whether its output
was consumed:

- POSITIVE: a later invocation or the final artifact demonstrably used it (an edit
  follows a read, a dispatch follows a red list, a commit follows a green, a refusal
  caught a real fault). Record the consumer ("-> #9" or "-> commit").
- NONE: output never referenced again, or it re-established a fact already in
  context/evidence (redundant confirmation runs, re-reads, polls).
- NEGATIVE: output caused a wrong action, rework, or a false conclusion (e.g., the
  watchbill-as-recheck-selector broad run that produced a wrongful refusal).

Per leg report: counts P/N/Neg, and worth density = P-tokens / total cache_read.
Class worthiness accumulates across shakedowns: for each invocation class (skill read,
deck retrieval, owed run, hygiene check, confirmation run, poll...), worthiness =
(positives - negatives) / instances, i.e. "out of 100 runs of this class, how often
did it have positive impact." Classes trending under ~50 are merge or eliminate
candidates; a doctrine change is cost-validated when its target class's frequency
rises. Keep the class tally in this file under Baselines.

For each invocation also ask: mergeable into another invocation, another
job, another role? Known classes: opening reads (batchable), independent hygiene checks
(batchable), polling waits (eliminate - foreground spawns), discover+step-usage (one
run serves both, 0.13.8), custody reruns of caller-proven greens (inherit - decision
table row 1 / wake record).
