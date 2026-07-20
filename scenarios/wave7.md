# Wave 7 — orientation economy: baseline vs ARCHITECTURE.md vs carried plan

Folds three open questions into one probe, per the 2026-07-18 design discussion: the
**architecture.md gate**, the **yoink orient-plan gate**, and the **token-economy target**.
Written 2026-07-20 as wave-7 readiness. NOT YET RUN.

Rubric is fixed here, BEFORE any leg, per the probe-first rule now standing in AGENTS.md.

## Preconditions — all three, verified before spending

1. **0.13.36 and 0.13.37 validations both GREEN** (see CAPTAIN.md's queue block). Wave 7 is
   pilot-class work and the efficiency battery's own rule gates it behind a validated doctrine
   version. Do not open wave 7 on unvalidated text.
2. **Session model is sonnet**, and the session is the probe tier — pinning alone does not hold,
   per the async-resumption leak. Wave 7 has nested spawns by design, so an opus session voids it.
3. **yoink seaworthy**: green @eval + custody committed + repo pushed. As of 2026-07-20 the
   first is done (exit 0, 64s, 3.5MB session.jsonl) and the third is outstanding — 2 commits
   unpushed, plus one uncommitted `D watchbill.json`. **The push is Captain-only and dk's;
   the harness does not push a consuming project.** Arm C is blocked until it lands.

## The state — deliberately NOT a clean probe fixture

This is the one place the standing META-FINDING gets addressed rather than restated: three
consecutive probe fixtures failed to reproduce pilot-scale faults because they were *too clean*
(one file, plank inventory ready-made rather than derived, no voyage context, single-purpose
legs). Wave 7's state is built against that list:

- **Planks spread across several implementation files**, not one, and `plank-inventory` must be
  DERIVED from the tree rather than read ready-made out of `RIGGING.md`.
- **Real voyage context**: a watchbill with several targets across more than one feature, a
  populated `CAPTAIN.md`, prior commits with real messages, a run record with history.
- **Mixed seam states** — some planked and sound, some absent, at least one malformed — so the
  join has to discriminate rather than confirm.
- **Multi-role legs**, not single-purpose ones: each arm runs a Captain→QM→Crew→Boatswain chain,
  because the thing under test is *orientation cost across a chain*, which a single leg cannot
  show.

Build it from `bin/scaffold.sh` plus a wave-7 fixture set; record the deck-state hash so the
three arms are provably byte-identical at entry.

## Arms — identical state, identical dispatches, one variable

| Arm | Orientation material carried |
|---|---|
| **A baseline** | current doctrine only |
| **B architecture** | + `ARCHITECTURE.md` at repo root, the architecture.md standard WHOLE (never a pruned house variant, per the standing decision), intent-bearing sections filled truthfully for a spec-driven repo |
| **C carried plan** | + `ARCHITECTURE.md` + the yoink orient plan embedded in the skill |

Arm C's plan is the yoink candidate as ruled: a shipped WORKING pipeline, not prose. Its named
test case is **the plank join** — the gather+extract side is fully deterministic
(`plank-inventory` + `step-usage` + string extraction; judgment enters only at the final
matched/stale/malformed call), so this arm tests plan-as-carried-pipeline fidelity.

## Measures, and what each is for

| Measure | Tool | Why |
|---|---|---|
| retrieval invocations per leg | `bin/mine.sh` | the round-collapsing claim |
| **plank-join N cluster** | per-invocation audit, `bin/bank.sh` | **the sharpest single number — see baseline below** |
| mistake/fix cycles | transcript, tree-verified | coherence, not just volume |
| wall | `bin/mine.sh` | latency is not a proxy for tokens, per METRICS.md |
| inbound weight + doctrine share | `bin/inbound.py`, `bin/inbound-fleet.py` | ARCHITECTURE.md ADDS prefill; it must earn it |
| compilable waste | `bin/plan.py` | the retrieval plan the instruction implies |

**The plank-join baseline is ~27 N invocations across 3 legs** (pilot #5 fold:
boatswain-voyage1-foul 14, boatswain-recheck 6, qm-voyage1 8), at 0% worthiness — every
join-running leg improvised the extraction with 5–7 failed `rg`/`grep`/node variants. That is the
measuring stick for arm C.

## PASS bars, fixed in advance

- **Arm B earns its weight** only if saved retrieval rounds exceed the prefill it adds. The
  GOAL-2 causal ballast finding is +0.84s/inv, so B must show a net win on BOTH inbound weight
  and invocations. A wash is a FAIL for B: the standing decision is adopt-whole-or-not-at-all,
  and "costs a little, saves a little" does not buy a permanent inbound tax.
- **Arm C passes** if the plank-join N cluster drops materially against the ~27 baseline AND no
  new fault class appears. Predicted from the 2026-07-18 note: hygiene/QM legs −30–40%,
  bootstrap −15–20%, Crew flat.
- **Honest qualification, stated so the wave measures the right thing**: Boatswain's retrieval
  side is ALREADY batched (one `jsdoc && cucumber && gplint && biome` invocation), so arm C
  tests extraction-pipeline fidelity more than round-collapsing. Do not credit it with round
  savings that were already collected.
- **Null result is a real outcome.** If A ≈ B ≈ C, nothing ships and both gates close as "not
  worth their weight" — which on 2026-07-19's record is the single most likely outcome and must
  not be argued away.

## Sequencing

Nothing ships ahead of the gate. If arm C wins, custody-path adoption is a larger step than arm
C's own scope and gets its own ruling. The interim no-dep fallback, if dk wants the bleeding
stopped sooner, is the already-routed example join command in doctrine text or a derived
`RIGGING.md` slot — which the yoink plan subsumes if the gate passes.
