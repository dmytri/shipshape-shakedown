# Methods candidate — composite methods as a latency play (2026-07-26)

**Status: IN PROGRESS — this file is written as the run proceeds; the verdict section is authoritative only when it says FINAL.**

## What the candidate is

Two coordinated changes, `experiments/methods-candidate/skills` (diff: `candidate-diff.txt`,
53 lines) against 0.13.65:

1. **`shipshape` Rigging read contract** — an optional `## Methods` section holds composite
   methods (`verify`, `hygiene`): one command that runs several `## Commands` values in a single
   invocation and reports each part's output and status separately. A method is *command
   composition already made at fitting out*, so a role runs it verbatim exactly as it runs a
   command; assembling that set by hand at the point of use is drift.
2. **`shipwright` Rigging shape** — how to derive `verify` (the `focused` run over a whole target
   set joined with `plank-inventory` and `step-usage`) and `hygiene` (`plank-inventory`,
   `step-usage`, `typecheck`, `lint`, `conformance` substituting where plank rules are derived),
   dropping `none` parts, refusing a composite that reduces to one command, and giving each part
   its label and timeout.
3. **`qm` step 5** points the verify checkpoint at the `verify` method; **`boatswain` hygiene**
   points the hygiene run at the `hygiene` method. Both keep the pre-existing command form as the
   no-method fallback.

Inbound cost of the doctrine text (deterministic, no legs): shipshape +166 tok (+0.75%),
qm +128 (+3.3%), boatswain +71 (+1.6%), shipwright +248 (+2.0%) — a QM leg carries ~+294 tok.

The **rigging** side is a cockpit asset, not doctrine: `assets/rigging-todomvc-methods.md` carries

    verify:  npx @dk/yoink --max-bytes 200000 --run 'npx cucumber-js {scenario}' --label focused --timeout 900 \
                                             --run 'grep -rn "@planks" js/' --label plank-inventory --timeout 60 \
                                             --run 'npx cucumber-js --dry-run --format usage' --label step-usage --timeout 300
    hygiene: (the same, without the focused part)

Note that **no yoink doctrine is involved**: the composite is a rigging VALUE the role runs
verbatim, so the candidate carries zero yoink text in the skills (dk reverted yoink from doctrine
on 2026-07-25 and this respects that).

## BASELINE, measured before spending anything (mimo v2.5, 0.13.65)

`bin/cohort-metrics.py`:

| wave | final | voyages | wall | inv | toolcalls | tok_in | tok_out | cost | s/RT |
|---|---|---|---|---|---|---|---|---|---|
| todomvc-mimo | 28/29 | 5 | 37.3m | 268 | 343 | 617k | 94k | $0.141 | 8.4 |
| todomvc-mimo2 | 28/29 | 3 | 47.4m | 286 | 369 | 530k | 120k | $0.151 | 9.9 |

### The per-checkpoint picture the candidate is aimed at (`bin/cluster-audit.py`, new)

Counting how the checkpoint command sets were ACTUALLY issued in banked legs:

| wave | bash | cuc | foc1 (fan-out) | focN (batched) | broad | plnk | usage | join |
|---|---|---|---|---|---|---|---|---|
| todomvc-mimo | 163 | 64 | 11 | 14 | 26 | 5 | 0 | 0 |
| todomvc-mimo2 | 232 | 137 | **77** | 6 | 48 | 3 | 0 | 0 |
| todomvc-hy3 | 77 | 35 | 4 | 1 | 25 | 3 | 4 | 2 |
| todomvc-qmax | 240 | 64 | 8 | 12 | 37 | 12 | 15 | 5 |
| todomvc-dpro | 126 | 49 | 13 | 5 | 19 | 4 | 8 | 1 |
| todomvc-glm52 | 154 | 69 | 11 | 1 | 46 | 6 | 7 | 3 |
| todomvc-kimi | 63 | 21 | 2 | 3 | 7 | 1 | 6 | 0 |
| todomvc-mm | 273 | 108 | 12 | 0 | 65 | 9 | 25 | 0 |

Two facts this settles for free, before any candidate leg ran — and they **reframe the plan's key
empirical question**, which was "does the model already `&&`-batch C1 hygiene?":

1. **The C1/C2 hygiene cluster is mostly not batched because it is mostly NOT RUN AT ALL.**
   `step-usage` was run **0 times** in both mimo waves, and the plank join (`plank-inventory` and
   `step-usage` in one call) **0 times in 5 of 8 waves**, never more than 5. So at these
   checkpoints the composite's headline win cannot be "4 calls become 1" — there were never 4
   calls. What a named composite buys there is **that the checkpoint happens at all**: the act
   becomes one copyable value instead of a set the role must assemble. That is a conformance win
   (and squarely the "make the form require the act" pattern), NOT a latency win.
2. **The real round-trip sink is the `focused` fan-out.** Doctrine already says run the focused
   command over the whole target set in ONE invocation; mimo2 ran **77 single-scenario cucumber
   invocations against 6 batched** (mimo run 1: 11 vs 14 — the same model, the other way round).
   That is the draw-unstable, dominant latency cost, and it is exactly a *composition inferred at
   the point of use*. So the candidate's `verify` method is aimed at the biggest available prize,
   and the mechanistic question becomes: **does a pre-specified `verify` method hold the batched
   form where prose does not?**

## Arms

Both flash arms are fitted out with the SAME vendored rigging so nothing but the composite
section and the skill text differs (roles otherwise author `RIGGING.md` themselves and its
content varies per draw — unusable as a control):

| arm | wave | skills | rigging |
|---|---|---|---|
| candidate | `methflash-c1` | `experiments/methods-candidate/skills` | `assets/rigging-todomvc-methods.md` (with `## Methods`) |
| control | `methflash-b1` | `experiments/yoink-settle/skills` (= 0.13.65) | `assets/rigging-todomvc-base.md` (no `## Methods`) |

Model `deepseek/deepseek-v4-flash` (the cheap stress canary), `--oracle-correct`, parallel, own
oracle clone / port / toolkit copy each.

## Results

(to be filled)

## Verdict

(to be filled)
