# Three-model NEW-way TodoMVC pilot comparison (2026-07-25)

Same doctrine (candidate **yoink-settle**, installed via the `skills` CLI — normal launch,
no `--skill`), same upstream Cypress oracle (pinned + patches + `framework=shakedown`), same
autonomous driver (`bin/eval-drive-todomvc.sh`) + operator playbook. Three models, run in
parallel, each own oracle clone + port. **All three reached 28/29** (28 is the ceiling; #29 is
the perennial pending test).

## Headline table

| | deepseek-v4-flash | qwen3.7-plus | glm-4.7 |
|---|---|---|---|
| **Oracle result** | **28/29 ✓** | **28/29 ✓** | **28/29 ✓** |
| **Voyages to pass** | ~11 (1 build + 10 iter) | **3** (build + page + domidentity) | **3** (build + domidentity + edithide) |
| **Legs** (Captain+QM) | 22 | 6 | 6 |
| **Invocations** (model round-trips) | 416 | 180 | **166** |
| **Total tool-calls** (latency proxy) | 591 | 243 | **179** |
| **tok_in / tok_out** | 2.33M / 220k | 832k / 105k | 594k / 48k |
| **cache_read** | 16.9M | 8.7M | 4.4M |
| **Cost** | **$0.58** | $0.96 | $0.67 |
| **Wall-clock total** | ~48 min | ~40 min | **~31 min** |
| **Build leg (QM) turns** | ~85 | 85 | ~179 |
| **Oracle trajectory** | 0→22→22→22→25→25→25→26→27→27→27→28 | 0→23→28 | 23→27→28 |

## Per-model character (from transcripts — see each `*/driver.log` and banked builds)

- **deepseek-v4-flash** — cheapest per run ($0.58) but the LEAST sample-efficient: ~11 voyages,
  many of them stuck (routing×2, domidentity×3, back-button×2 produced no score change). Part of
  that was the driver's early selector bug (fixed mid-run), but deepseek also genuinely needed
  multiple attempts per defect class and needed the page as a SEPARATE voyage (its build shipped
  0/29 — no servable index.html). Clean, doctrine-correct role reports. Its cheap token price +
  heavy caching keep total cost lowest despite 2.5× more round-trips.

- **qwen3.7-plus** — the strongest problem-solver. Its build QM leg self-resolved four subtle
  bugs UNPROMPTED, named in its own report: a happy-dom `assert.strictEqual` infinite-loop on DOM
  comparison, a **stale DOM reference after `render()`** (the DOM-identity defect the others needed
  a whole voyage for), a missing step pattern, and filter-persistence-on-reload. Because it already
  understood the render/DOM issue, ONE domidentity voyage took it 23→28 (fixed all 5 checkbox/edit
  residuals at once). Most thorough specs (its builds wrote 44–49 scenarios in earlier runs). Most
  expensive ($0.96 — pricier model + heaviest output tokens).

- **glm-4.7** — the most EFFICIENT end-to-end and the most deployment-complete: its build alone hit
  **23/29** because it produced a real servable `index.html` in the build (deepseek/qwen did not),
  and every iteration voyage made progress (23→27→28, zero stuck voyages). Fewest round-trips (179)
  and fastest wall-clock (~31 min). Crisp, disciplined role reports (planks, perturbation check,
  verify command, custody). Best value on the latency-first axis.

## The doctrine finding: near-ZERO yoink adoption across ALL THREE

The candidate's central claim — every retrieval batched through `npx @dk/yoink` (the Batched-
retrieval Article) — was **not followed by any of the three models** on the Captain/QM/Crew/
Boatswain roles: 0 yoink-plan bash calls across all legs; deepseek merely *referenced* `@dk/yoink`
in 3 legs (never ran a real plan), qwen and glm never mentioned it at all. This confirms, now across
three independent non-Claude models, the earlier single-model finding: **the shared Article alone
does not drive yoink adoption; only a per-role operative rule at the point of action does** (the
golden run's Shipwright — the one role the candidate yoink-ified — adopted it; the four roles it did
NOT yoink-ify ignore it). If yoink adoption is the goal, the operative rule must be carried into the
Captain/QM/Crew/Boatswain work-loops, not left to the shared Article. — routed to dk.

## Caveats (honest)
- deepseek's 22-leg / 416-inv figure is inflated by ~4 stuck voyages, partly the driver's early
  selector bug. Its "clean-path" cost would be lower, but still more voyages than glm/qwen.
- qwen's numbers are from a clean rerun; an earlier qwen run was corrupted by operator mid-voyage
  kills (a harness lesson, below) and discarded.
- Single draw per model — directional, not a rate. A fair rate needs repeat draws (AGENTS.md).

## Operator / playbook feedback (what this run taught — folded into the tooling)
See the committed driver/tooling changes; the load-bearing ones:
1. **`skills` CLI must live in the shared toolkit** — the npx cache is ephemeral and evicted mid-run,
   which failed every leg of the first launch.
2. **Majority-based intent selector + cycling on ties** — a single residual (e.g. one "back-button"
   fail) hijacked voyages from a 5-failure group; and a 1-1-1 residual split made the selector repeat
   one intent forever. Now it picks the biggest group and cycles on ties. Split `edithide` out of
   `domidentity`.
3. **Overlay-mount retry** — concurrent legs overlaying one shared node_modules lowerdir intermittently
   fail `Can't make overlay mount`; retry up to 4×.
4. **Resume-with-reset** — operator intervention after a breaker must `git reset --hard HEAD` first;
   killing a driver mid-voyage leaves a dirty tree that grades garbage (corrupted the first qwen run).
5. **Never kill a driver mid-voyage without expecting a dirty tree** — the biggest operator lesson;
   the resume-reset now recovers it, but the clean move is to let a voyage finish (they're ≤10 min).
6. Prepared-intent library keyed to failure signatures works well for the common path; the long tail
   (build-specific residuals like back-button, browser-history) still needs an operator intent or a
   library addition.
