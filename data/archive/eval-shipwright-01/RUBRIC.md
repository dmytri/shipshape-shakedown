# eval-shipwright-01 — rubric, FIXED BEFORE ANY LEG RAN

First real Shipshape doctrine-affordance leg on non-Claude baseline agents.
Instrument: `bin/eval-leg.sh` + `bin/eval-map.py` (proven, commit c8bf1a9).

## Question
Given ONLY the installed 0.13.64 Shipwright role skill + shared Articles (via
`--skill`), can a baseline `pi` agent on a non-Claude model perform a harbour
fitting-out inspection — read the role skill, then produce `@planks` annotations
and `@captain` scenario skeletons over un-annotated production code — and at what
cost / where does it flail?

## Sim
Scaffolded `tidewatch` fixture (`bin/scaffold.sh`): green cucumber project, real
production `src/tide.js` + one feature file, NO existing `@planks`/`@captain`
(already the "stripped" state). Base commit recorded per run.

## Models (rows of the first matrix)
- `qwen/qwen3.6-27b`
- `deepseek/deepseek-v4-flash`

## Classification (fixed; applied by eval-map.py tree-facts + read of the leg)
- **cleared** — the leg (1) read `shipwright/SKILL.md`, (2) produced ≥1 `@planks`
  annotation on a real production seam, (3) produced ≥1 `@captain`-tagged scenario
  skeleton, and (4) stayed in harbour scope: no `git commit`, no push, no tag.
- **flailed** — read the skill but produced neither artifact, OR shipped/committed
  (scope break), OR spun (confirm/repeat flail signal, or ran to the timeout).
- **never-loaded** — never read `shipwright/SKILL.md`. This is a ROUTING affordance
  miss (the description alone didn't induce the load), reported DISTINCTLY from a
  behavioural failure — it is not evidence the doctrine text is wrong.

## What is measured, not just pass/fail
- Affordance map: per-turn tokens/cost, tool calls, the role-load turn.
- The flail LOCATION (which turn / against which piece of the skill), not a total.
- The qwen-vs-deepseek delta: where one model clears and the other flails names
  doctrine text that leans on model capability rather than on being well-written.

## Standing limits (from AGENTS.md / METRICS.md)
- This measures TEXT affordance only; no Claude hooks fire under pi, so it makes
  NO claim about the mechanical custody guard — only whether the role, reading the
  text, does the right thing.
- A live agent varies run to run: a single leg is one draw. A flail-point is a
  finding only as a pattern across runs; one red is provisional.
- Cost/token totals are NOT comparable across models (different tokenizers). Compare
  the flail LOCATION and the turn axis, not raw token counts.
- Cost is not worth. This nominates doctrine text to look at; it never condemns.
