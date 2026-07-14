# Inference-Efficient Prompt Engineering (IEPE)

The shakedown method for analysing any instruction — a role skill, an agreement, a
dispatch, a harness prompt — as the *execution trajectory* it produces, not as text.

**dk's framing (2026-07-14), which this file exists to preserve:**

> A prompt no longer causes just one model response. An agent receives instructions,
> makes a model invocation, retrieves files or tool results, invokes again, and continues
> until the task is complete. **The real object being engineered is not the initial prompt.
> It is the entire sequence of inference and retrieval that the instructions produce.**

> **An inference pass is justified only when inference is required.**
> **Context is justified only when it contributes to the outcome.**

## The three observations

1. **Every invocation has inbound context** — instructions, history, agent state, retrieved
   files, tool output. Not all of it is equally useful. Some improves the outcome, some has
   no effect, and some actively makes the result worse.
2. **Many retrievals need no inference between them.** An agent may read `package.json`,
   invoke, read `tsconfig.json`, invoke again — when both could have been fetched together.
   Independent retrievals group into deterministic **retrieval blocks**.
3. **An invocation should happen only where inference decides what comes next.**

So the goal is to compile

```
inference -> retrieval -> inference -> retrieval -> inference -> retrieval -> inference
```

into

```
retrieval block -> inference -> dependent retrieval block -> inference -> result
```

## The two questions, kept separate

A context block is one of three things, and the distinction is the point:

| Class | Test | Disposition |
|---|---|---|
| **unused** | removing it changes nothing | nominate to move or cut — never condemn on one state |
| **positive** | removing it makes the outcome worse | load-bearing; keep, and the probe just proved its worth |
| **negative** | removing it makes the outcome BETTER | the context is harming; highest-value find |

- **Was this context used?** — observable from a transcript.
- **Did using it help?** — NOT observable. Only intervention answers it.

Negative context is real and has cost us a release: **tw16**. Boatswain's own skill said
"plank drift defers to harbour" while the Planking agreement said only drift *beyond the
diff* does. The role read both, followed the weaker one, and committed a malformed plank
Crew had just written. Nobody would have found that by counting tokens.

## The method: running an IEPE pass on an instruction

1. **Measure the inbound weight.** `bin/inbound.py <leg>` / `bin/inbound-fleet.py <session>`.
   Exact, no tokenizer: `context[n] = input + cache_creation + cache_read` is the true prompt
   size, so `delivered[n] = context[n] - context[n-1] - output[n-1]` is exactly what was
   injected between two calls. A token entering at `k` is re-read `N-k+1` times, so its
   RESIDENT COST is `size x (N-k+1)`. **Summing resident cost must reproduce the metered
   spend — the tool asserts this identity and it closes at drift +0.** If it ever drifts, the
   decomposition is unsound; do not trust the numbers.
2. **Derive the retrieval plan the instruction implies.** `bin/plan.py <session>`. Read the
   instruction end-to-end and ask, for every retrieval it orders: *what does this depend on?*
   Independent retrievals belong in one block. A retrieval that consumes an earlier
   retrieval's result is a second pass and earns its own turn.
3. **Recompile the instruction** so its natural reading order IS the compiled plan.
   **Structure by retrieval dependency, not by topic.** This is the load-bearing step and
   the easiest to get wrong; see "What actually binds" below.
4. **Validate.** Re-run the same fixed state and re-measure. The prediction must be
   falsifiable per role: *this block collapses, these pairs vanish, invocations drop by N.*
   If the numbers do not move, the rewrite did not bind — and you learn that from one leg
   instead of from an argument.
5. **For worth, not cost: ablate.** See `scenarios/ablation.md` (deferred; design recorded).

## What actually binds — the hardest-won lesson in this harness

**Examples bind. Prose does not.** Learned three separate times:

- The 0.13.11 record fix: a key list did not bind; an example line did.
- The minimal-`RIGGING` fix: the wording alone did not bind; the template did.
- **Boatswain's deck**: the skill said *"The deck is Boatswain's one retrieval"* — and
  Boatswain split the deck into separate turns in **7 of 14 measured legs**. The prose was
  right and it did not bind. What binds is the exact command, in a fenced block, whose
  output the next step reads.

So an IEPE recompile does not add a rule telling the role to be efficient. It **states the
exact command** and lets the good plan fall out.

## The standing rulings that constrain this work

These are dk's, they are binding, and an IEPE pass that violates them is wrong:

- **Doctrine gives roles OBLIGATIONS, never optimization TARGETS.** Tell a role to
  "minimise invocations" and it will skip a verification run to save a round.
- **The lever is on OUR side of the table.** "Minimizing invocations is a function of OUR
  prompt, context and role engineering — never something we tell the agents to do via the
  prompts. That would be backwards."
- **The ladder: quality > latency > invocations > tokens.** An IEPE win that costs quality
  is not a win. Tokens are LAST: "preserving tokens is not a major goal."
- **IEPE is a shakedown lens, not doctrine text.** It measures and improves the instruction.
  It never ships *as* an instruction.

## Merging is not free — the one real trap

Retrieval merging and context minimisation **pull against each other**. Resident context has
a MEASURED latency cost: +0.84s per invocation per ~24k cached tokens (controlled probe,
Mann-Whitney z = -3.27; METRICS). Fetch five files because two *might* be needed and you save
two invocations (rung 3) while paying three files of resident context on every invocation for
the rest of the leg (rung 2).

**Merge what the plan retrieves anyway. Never merge speculatively.**

## Evidence to date (v0.13.23 baseline, 14 legs / 224 invocations / 12.6M tokens)

| Finding | Number |
|---|---|
| Of every token a role reads, boilerplate | **84%** (shared Articles 36.9%, harness floor 33.5%, role skills 14.0%) |
| ...leaving the actual job | **15.6%** |
| Invocations issuing exactly ONE tool call | **83.9%** |
| Opening block (Skill loads; no inference needed) | **12.9%** |
| Independent retrieval runs (none consumed the prior result) | **8.0%** |
| Compilable waste, at zero quality risk | **~25%** |
| Latency cost of ~24k resident cached tokens | **+0.84s/invocation (+42%)** |

Crew is the sharpest case: it loads 24.1k tokens of shared Articles — **5x its own role
skill** — to do a job that is 5.2% of its context.

## The limits, and they are not optional

- **Cost is not worth.** Everything above measures COST. A doctrine section can be
  load-bearing precisely BECAUSE it prevented something — the wait rule's whole value is a
  stall that did not happen, and it surfaces in no transcript.
- **The matrix NOMINATES; it never condemns.** Anything flagged gets a probe before a cut.
- **An ablation is only valid against a state that exercises the section's trigger.**
  Otherwise you prove nothing and call it "unused" — the same error as the tw10 supersede
  probe, whose invitations were structurally wrong (the agent was blameless).
- **Green is not an acquittal.** Ablation shows whether behaviour CHANGED, not whether the
  outcome was RIGHT. A leg can change behaviour and still land green by luck.
