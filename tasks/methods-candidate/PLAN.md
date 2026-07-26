# Methods candidate — autonomous execution plan (primed 2026-07-26)

**You are a fresh session picking this up. Execute the whole arc autonomously — assume confirmation,
push through, do NOT stop to ask. Bootstrap first: read AGENTS.md, CAPTAIN.md, METRICS.md, then this.**

## MISSION / definition of done
Build a Shipshape doctrine candidate that introduces **"methods"** (a formalization of rigging
`## Commands`) and, specifically, **composite methods** — named, pre-specified bundles of the
commands a role runs together at a checkpoint, authored as one **yoink** plan so they run in **one
invocation instead of N**. Then: refine it with deepseek-v4-flash draws, then sail one full mimo
TodoMVC pilot. **Done when** the mimo candidate pilot reaches 28/29 and you have reported the
invocation/latency/cost delta vs the baseline below, with a clear verdict on whether composites cut
round-trips.

## THE PRINCIPLE (why this should work)
Move the **composition** of doctrinal actions out of the model's probabilistic point-of-use
inference and into **exact fitting-out specification**, run **verbatim**. The atomic commands are
already specified in RIGGING.md and run verbatim (strict anti-drift rule, shipshape SKILL ~line 384).
What's currently inferred per-use (and varies per draw) is *which commands a checkpoint entails and
whether to batch them*. A composite method pins that down. Payoff: latency ↓ (N calls → 1 bundle),
consistency ↑ (fixed composition can't vary by draw), verbatim reliability (hand the model the exact
composition). This is v1 = **latency/composition play only**; DEFER expected-set enforcement to v2.

## BASELINE TO BEAT (mimo v2.5, current 0.13.65, clean run)
`inv=268 · toolcalls=343 · cost=$0.141 · latency=8.4s/RT · 28/29 · planking 22/22`
(reproduced as mimo2: $0.151, 3 voyages — planking was 0/0 that draw; planking is draw-unstable.)
Compute with `python3 bin/cohort-metrics.py <wave-tag>`.

## COMPOSITION MAP (from role-skill audit — the clusters to formalize)
Deterministic clusters (batchable — no need to see intermediate output before the next command):
- **C1 Boatswain hygiene (HIGHEST VALUE)** — `plank-inventory && step-usage && typecheck && lint`
  (boatswain SKILL ~67). ALREADY written as a deterministic `&&` chain, "one run and not four"
  (~72). `conformance` substitutes for `plank-inventory` where plank rules are derived; drop any
  `none` command. Runs at the open of every custody job.
- **C2 QM verify** — `focused` (batched over all targets, one invocation) + `plank-inventory` +
  `step-usage`, one pass (qm SKILL ~71). Runs once per watch.
- **C4 Shipwright harbour** — `coverage` per configured tier, cheapest first (shipwright ~129).
- **C5 Shipwright condemnation proof** — `typecheck` + `lint` + `focused` (shipwright ~145).
- **C8 plank-judging join** — `plank-inventory` × `step-usage`, the reusable unit inside C1 & C2.
Reactive (do NOT batch): C3 (QM tier sweep across tiers), C6 (Boatswain recheck — hunk class chosen
from data first). Leave these as-is.

**KEY EMPIRICAL QUESTION for the flash draws:** does the model already run C1 as one `&&` invocation,
or as 4 separate bash calls? If already 1, the composite's win is small; if N, the named yoink
composite is the fix. Measure this directly (grep the QM/Boatswain leg `session.jsonl` for how the
cluster commands were issued — count distinct bash toolCalls carrying those command strings).

## CANDIDATE LOCATION & SHAPE
- Candidate skills already copied to **`experiments/methods-candidate/skills`** (byte-copy of
  `experiments/yoink-settle/skills` = current 0.13.65). Modify THIS copy; never the baseline.
- The candidate is two coordinated changes:
  1. **Doctrine (role skills):** extend the "run verbatim from RIGGING.md" contract in the shipshape
     core to cover **composite methods** — named entries a role runs as one invocation. Then point
     the C1/C2(/C4/C5) checkpoints at their composite by name (Boatswain runs the `hygiene` method;
     QM runs the `verify` method) instead of describing/inferring the command set. Keep prose minimal
     — you are addressing the role and naming the method, not re-teaching doctrine.
  2. **Rigging (the fitting-out artifact):** the TodoMVC sim's `RIGGING.md` gains a composite-method
     section specifying each composite AS A YOINK PLAN, e.g.
     `hygiene: npx @dk/yoink --run "<plank-inventory>" --run "<step-usage>" --run "<typecheck>" --run "<lint>"`.
     (typecheck/lint are `none` in the TodoMVC rigging — see below — so the TodoMVC `hygiene`
     composite is effectively `plank-inventory`+`step-usage`; `verify` = `focused`+`plank-inventory`
     +`step-usage`. Pick composites that are genuinely ≥2 commands on THIS stack or the batching win
     is nil.) Specify composites at fitting-out **exactly** so roles run them, not infer them.
- TodoMVC rigging today (`.eval-scratch/*/sim/RIGGING.md`): commands are `discover/focused/broad/
  coverage/step-usage: npx cucumber-js …`, `plank-inventory: grep -rn "@planks" js/`,
  `typecheck/lint/conformance: none`. So on this stack the real ≥2-command composites are **`verify`**
  (focused+plank-inventory+step-usage) and the **QM/Boatswain plank join** (plank-inventory+step-usage).
  Make the candidate's RIGGING.md carry these as yoink plans, and have the sim's RIGGING.md authored
  WITH them (either vendor a candidate RIGGING.md into the scaffold, or instruct the fitting-out to
  write them — vendoring is cleaner for a controlled test; see Phase 1).
- **yoink availability:** the `@dk/yoink` skill + `skills`-CLI install are already wired in the
  toolkit (DRIVER_SHARED_NM node_modules has `@dk/yoink`). yoink runs via `npx @dk/yoink`.

## PHASE 1 — BUILD (edit `experiments/methods-candidate/skills` + a candidate RIGGING.md)
1. shipshape core: add the composite-method concept to the RIGGING-read contract (a `## Methods` or
   composite section is a named command that is one invocation; run it verbatim; it is command
   composition, still under the anti-drift rule).
2. QM skill: at the verify checkpoint (C2), instruct running the `verify` method (one invocation).
3. Boatswain skill: at hygiene (C1), instruct running the `hygiene` method (one invocation).
   (Shipwright C4/C5 optional in v1 — do them only if cheap; the QM/Boatswain wins are the core.)
4. Candidate RIGGING.md: create `assets/rigging-candidate.md` (or update the scaffold path) that adds
   the composite yoink plans to the standard TodoMVC rigging. Make the scaffold/pilot use it so the
   sim is fitted out WITH the composites. Verify a composite yoink plan actually runs:
   `npx @dk/yoink --run "grep -rn @planks js/" --run "npx cucumber-js --dry-run --format usage"`.
5. Keep the baseline (`experiments/yoink-settle/skills`) untouched for A/B.

## PHASE 2 — REFINE with deepseek-v4-flash (`deepseek/deepseek-v4-flash`)
Flash is the cheap stress canary (~$0.58, ~11 voyages — hammers the machinery). Run candidate draws:
- `bin/eval-drive-todomvc.sh --wave methflash-N --model deepseek/deepseek-v4-flash --skills-dir
  "$PWD/experiments/methods-candidate/skills" --clone <own-clone> --port <own-port> --oracle-correct`
- After each draw, CHECK (don't assume): did roles actually invoke the composite methods (grep leg
  `session.jsonl` for `@dk/yoink` and the composite names)? Did the C1/C2 clusters collapse to ONE
  bash toolCall vs the baseline's separate calls? Any breakage (yoink plan malformed, role confused
  by the method reference, verbatim-run failing)? Fix the candidate and re-draw until: (a) roles run
  the composites verbatim reliably, (b) invocations on those checkpoints drop, (c) still reaches 28/29.
- Also run ONE flash BASELINE draw (`--skills-dir experiments/yoink-settle/skills`) to get the
  per-cluster invocation count WITHOUT composites, for the A/B. This answers the key empirical Q.
- Iterate 2–4 flash draws max; flash is for shaking out mechanics, not statistics.

## PHASE 3 — mimo full pilot (the validation)
Once the candidate is stable on flash: one clean SOLO mimo run.
- `bin/eval-drive-todomvc.sh --wave meth-mimo --model xiaomi/mimo-v2.5 --skills-dir
  "$PWD/experiments/methods-candidate/skills" --clone <own-clone> --port <own-port> --oracle-correct`
- Must reach 28/29. Then compute `bin/cohort-metrics.py meth-mimo` and compare to the baseline
  (268 inv / 343 tc / $0.141 / 8.4s). Also count C1/C2 cluster invocations candidate vs baseline.

## MEASUREMENT & WIN CONDITIONS
- **Primary:** total invocations + tool-calls + cost + latency, candidate vs baseline, holding 28/29.
- **Mechanistic:** on the C1/C2 checkpoints specifically, did N bash calls become 1 yoink bundle?
  (This is the real proof; total-invocation deltas can be noisy across draws.)
- **Secondary:** planking consistency (did specifying the plank join as a method steady it?).
- **WIN** = the composite checkpoints demonstrably collapse to one invocation AND total round-trips
  drop at equal 28/29. **NULL result is a valid, reportable outcome** (e.g. "the model already
  `&&`-batched C1, so composites added nothing" — that itself answers the latency question).

## HARNESS OPERATIONAL REFERENCE
- Model slugs: mimo=`xiaomi/mimo-v2.5` (driver default), flash=`deepseek/deepseek-v4-flash`.
- Each parallel/solo pilot needs its OWN oracle clone + node_modules: `cp -a .eval-scratch/oracle-clone
  .eval-scratch/oracle-clone-<tag>`; `DRIVER_SHARED_NM=$PWD/.eval-scratch/.shared-nm-<tag>` (copy from
  `.eval-scratch/.shared-nm/node_modules`). Use distinct ports (8880+).
- **Disk is the recurring hazard.** Keep >3G free or bwrap `--tmp-overlay` voids legs. Guards now
  active: driver `disk_ok` (2G) skips/aborts; `oracle-grade` runs cypress under `xvfb-run -a`
  (parallel-safe) and hard-fails on ENOSPC; `eval-voyage` aborts a void leg (exit 6) and the driver
  RETRIES the voyage 4× then STOPs loudly (`--resume-from N`). Run a background pruner:
  `while :; do find .eval-scratch/todomvc-* -name pi.stdout -mmin +3 -delete; sleep 60; done &`.
  Reclaimable if tight: old `~/.local/share/claude/versions/*` (keep the running one), finished waves'
  `pi.stdout`. Do NOT touch `~/.local/share/opencode` (dk's, 2.7G) or `~/.cache` (cypress binary).
- **Monitor, don't poll passively** (the expensive mistake last session — two dead runs ground for
  ages before I read a leg log). Arm a Monitor on `<wave>/driver.log` for `oracle [0-9]+/29|INFRA|
  VOID|REACHED|PILOT END|STOP`, and the FIRST time a voyage finishes in ~40s with an unchanged score,
  READ a leg log immediately (`*-qm.leg.log`) — that's the void/overlay tell.
- Grade a committed sim manually: `bin/oracle-grade.sh --build <sim> --out <f> --clone <clone> --port N`.
- `--oracle-correct` = every voyage pastes the exact cypress failure to Captain (refined, cause-aware
  prompt for detached-DOM etc.); no-give-up. Use it for all these runs.

## AUTONOMY DIRECTIVES
Assume confirmation and approval. Push through without stopping. Use monitors + the guards; free disk
proactively. Do not kill a driver mid-voyage (dirty tree). If a run genuinely stalls on INFRA 4×,
free disk and `--resume-from N`. Keep the baseline skills pristine. When done, write results to
`data/methods-candidate/REPORT.md` and update CAPTAIN.md. Only surface to dk at the end with the
verdict — unless something is fundamentally ambiguous about dk's intent (not the case here).

## REPORT (what to deliver at the end)
`data/methods-candidate/REPORT.md`: the candidate's diff summary; the C1/C2 per-checkpoint invocation
A/B (baseline vs candidate, flash + mimo); the mimo full table vs baseline (inv/tc/cost/latency/28-29);
planking note; and the verdict — did composites cut round-trips, by how much, and is the concept worth
promoting toward a shipped doctrine change (or a v2 with enforcement). Then tell dk.
