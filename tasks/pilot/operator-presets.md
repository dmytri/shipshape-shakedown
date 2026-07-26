# Operator presets — driving the NEW-way pilot (Captain-directed voyages)

Reusable operator prompts + decision rules distilled from the 28/29 TodoMVC pilot
(2026-07-24; full narrative in `data/todomvc-newsim-01/OPERATOR-LESSONS.md`). The
operator is the main session loop; each voyage it hands ONE intent to Captain via
`eval-voyage.sh --captain-task <file>`, then grades out-of-band with `oracle-grade.sh`.

Three hard rules that hold for EVERY intent:
- **Address the role, give clear intent, and TRUST THE DOCTRINE.** Do not re-prime or
  re-phrase Shipshape in the intent — no "read the Articles and follow them." Do not restate
  doctrine MECHANICS the skill already carries. An intent is just: name the role, the project
  root (and base commit for QM), and the product intent.
  - **HEADLESS EXCEPTION (learned 2026-07-25, newsim-02, tree-evidenced).** Stripping the
    intents bare regressed the pilot: the Captain skill says "tell them what you will do and
    wait for confirmation," and a headless `pi -p` run has no human to confirm, so Captain
    states a plan and the turn ends with zero artifacts (0/2 draws). QM stops at the Crew
    hand-off the same way. In a headless pilot the operator IS the absent human, so the intent
    MUST carry the confirmation the role is waiting for: a lean action directive — Captain
    "proceed without waiting for confirmation; author the specs and watchbill, then stop; do
    not commit/dispatch"; QM "assume the downstream roles in place and carry the voyage to a
    green self-suite; do not push/tag." This is NOT doctrine re-priming (it restates no
    Article); it supplies the human turn the runtime removes. Isolation proof: the same lean
    launch + the primed intent authored 9 features + watchbill; the bare intent authored
    nothing. This regression was bff21ad, unvalidated until this run.
  A dispatch this session actually used and won on:
      `You are the Shipshape Captain. Project root: ‹path›.`
      `‹the product intent — what a user needs / what is broken›.`
  QM is leaner still — the doctrine dispatch surface is role + base commit, full stop:
      `You are the Shipshape Quartermaster. Project root: ‹path›. Base commit: ‹sha›.`
- **Give the EXACT error — do not rephrase (dk, 2026-07-25).** A real user pastes what they
  see; they do not translate a failing assertion into "product language." So on an
  oracle-correction voyage, COPY-PASTE the failing assertion text verbatim into the Captain
  intent — the failing-test description IS the bug report ("should allow me to mark all items
  as completed"). Rephrasing is operator craft that adds distortion and cost for no gain, and
  earlier lessons that spent effort translating symptoms are superseded here. The one thing a
  real user never has is the REFERENCE IMPLEMENTATION (the oracle's own solution source) — that
  stays quarantined; never paste or describe it. Drop only the pure oracle-identifying label
  (the `TodoMVC - <framework> --` prefix) if it is trivially separable; the behavioural
  assertion text itself goes in verbatim. A raw runtime error the app throws (e.g. a browser
  `NotFoundError`) is likewise pasted as-is.
- **Short, concrete, action-first.** Open-ended "investigate and figure it out" prompts make
  a cheap model read endlessly and author nothing (tree-proven v10/v11). Give it the artifact
  to write. This is about the INTENT being concrete — not about re-explaining doctrine.

---

## PRESET A — Pilot kickoff (voyage 1, the build)

Use `tasks/pilot/captain-todomvc.task.md` verbatim (build the app from the vendored
spec + template). It is the only voyage whose intent is not derived from a grade.
After it lands, run the roles' self-suite; do NOT grade the oracle until the self-suite
is fully green (phase-1 gate). Then Preset B for every voyage after.

---

## PRESET B — First turn after an oracle grade (the derive-next-voyage procedure)

This is the operator's core craft. Run it every time a grade comes back below 28/29.

**Step 1 — get the failing test titles** from `oracle-grade.sh`'s "## failing tests".
These are pasted VERBATIM into the Captain intent (see the exact-error rule above) — no
translation step. If you need the assertion detail to root-cause, capture the full cypress
run once and read the `N) … : AssertionError …` blocks; paste those verbatim too. The only
thing you never pass on is the reference implementation's source.

**Step 2 — GROUP failures by shared root cause.** Several failing titles are usually one
bug (e.g. 4 checkbox/mark-all failures = one DOM-identity render; 3 edit failures = one
reentrancy or one ordering bug). Read `js/app.js` to find the single cause. Fix causes,
not symptoms — one cause per voyage.

**Step 3 — classify the bug's TIER, which picks the red-target mechanism:**
- **Tier-visible** — the roles' happy-dom suite CAN reproduce it (DOM structure, classes,
  order, values, presence). → Give Captain a plain **failing scenario** that reddens in the
  self-suite. This is the default and it drove 0→24 and 25→28.
- **Tier-invisible** — needs real-browser event semantics happy-dom lacks (the big one:
  removing a focused element fires `blur` synchronously — happy-dom does NOT). No executing
  scenario can redden it. → Give Captain a **SCANTLING**: a `@conformance` scenario whose
  step inspects the SOURCE and asserts a structural rule ("the Enter handler must call
  `.blur()`, not `commitEdit` directly"). It reddens on the source text where the DOM tier
  can't. Do NOT waste voyages restating the symptom — QM only acts on a red target, and a
  green suite means it no-ops (tree-proven v8–v13: 0 writes).

**Step 4 — write the Captain intent from the template below.** Give the exact scenario
(near-Gherkin) or scantling, name the SMALLEST fix, and require the full existing suite to
stay green (a cheap model over-reaches and breaks the app on big rewrites — v15). The
`eval-voyage.sh` guard reverts a voyage that leaves the self-suite red, protecting the base.

### Template (fill the ‹brackets›) — lean; paste the exact failures; headless proceed line

```
You are the Shipshape Captain. Project root: PROJECT_ROOT_PLACEHOLDER.

These behaviours are failing:
‹paste the failing assertion lines VERBATIM from the grade, one per line›

Proceed now without waiting for confirmation. Prove and fix these: cover each with a scenario
that fails on the current code — for a real-browser-only / structural defect the executing
tests can't catch, a @conformance check over the js/app.js source instead. Make the SMALLEST
change; keep every existing behaviour working. Then stop; do not commit or dispatch.
```

Keep it to those few lines. Everything about authoring specs, the watchbill, stop-lines, and
custody is the role skill's job — do not restate it. For a scantling case, name the exact
structural property (e.g. "the Enter key handler must call the edit field's .blur() and must
not call commitEdit directly").

**Step 5 — after the voyage:** if `VOYAGE-REGRESSED` (guard reverted it), the change was
too big — re-issue with an even smaller, more surgical fix. If `VOYAGE-COMPLETE`, re-grade
the oracle and loop to Step 1 until 28/29 (28 is the ceiling; the 29th is perennially
pending). Update `OPERATOR-LESSONS.md` with what the voyage taught.

---

## Anti-patterns (each cost real voyages — do not repeat)
- Restating a symptom the green suite already passes → QM no-ops. Give a RED target.
- An investigation mandate ("trace the bug, figure out the fix") → Captain reads endlessly,
  authors nothing. Hand it the scenario/scantling to write.
- Demanding a failing SCENARIO for a tier-invisible bug → impossible; use a scantling.
- A big "rewrite render/the handler" ask → cheap model breaks the app. Demand the smallest
  change and require the suite stay green.

---

## Multi-model / autonomous-driver lessons (3-model TodoMVC run, 2026-07-25)

`bin/eval-drive-todomvc.sh` runs a whole pilot autonomously (build → grade → matched prepared
intent → regrade, to 28/29, with breakers). Running deepseek-v4-flash / qwen3.7-plus / glm-4.7 in
parallel taught:
- **`skills` CLI belongs in the shared toolkit**, never the npx cache (ephemeral — evicted mid-run,
  failed every leg).
- **Intent selector must be MAJORITY-based and cycle on ties** — a lone residual (e.g. one back-button
  fail) otherwise hijacks a voyage from the real 5-failure group, and a 1-1-1 split makes it repeat
  one intent forever. Keep `edithide` separate from `domidentity`.
- **Retry the bwrap overlay-mount error** under parallel legs on a shared node_modules lowerdir.
- **NEVER kill a driver mid-voyage casually** — it leaves a dirty git tree that grades garbage and
  can corrupt the pilot (lost the first qwen run). Let the voyage finish (≤10 min), or rely on the
  resume's `git reset --hard HEAD`.
- Model efficiency varies WIDELY on the same task: glm-4.7 / qwen3.7-plus reached 28/29 in 3 voyages
  (~170 round-trips); deepseek-v4-flash took ~11 (~416). glm shipped a servable page in its build;
  the others needed a separate page voyage. See data/todomvc-3model-compare/REPORT.md.

---

## Oracle-correction refinement — paste-exact is necessary but NOT sufficient (2026-07-26, qmax)

The 7-model frontier run (adds mimo-v2.5, hy3, minimax-m3, kimi-k3, qwen3.7-max). Five models were
stuck for a full voyage-cap on the prepared `edithide` intent; a single oracle-correction voyage that
pasted the VERBATIM cypress `AssertionError` converged each in one shot — decisive proof of the
exact-error rule. But qwen3.7-max then stalled at 26/29 on the checkbox toggle failures even WITH the
verbatim error, and it was **the operator's prompt, not the model**. Two prompt defects, now fixed in
`correction_intent()`:

- **A verbatim error can MISLEAD when its surface text targets the test author.** The checkbox failure
  is a Cypress *detached-from-DOM* error whose own remediation text says "break up the chain / rewrite
  `cy.get('button').click()`…" — advice to a TEST author. The model can't change the (quarantined,
  fixed) oracle, so that advice is a dead end, and the real cause (the app re-renders the list on
  toggle, detaching the node) is buried. FIX: keep the error verbatim as EVIDENCE, but add the
  operator's read of the CAUSE and an explicit "the acceptance suite is FIXED and CORRECT — take only
  the cause it names, ignore any advice to change the test." `correction_intent()` now injects a
  class-aware diagnosis (detached-DOM/re-render → "preserve element identity, mutate in place").
- **Never tell the model to write a failing scenario for a browser-only defect.** The old correction
  template said "cover each failure with a scenario where your harness can" — contradictory for a
  tier-invisible bug the happy-dom suite can't redden. It makes the model spin trying to author an
  impossible red target, then give up. FIX: state that an unreproducible-in-harness failure is EXPECTED
  for a browser-only defect, and to guard it with a source-level `@conformance` check + fix the app —
  the tier-invisible/scantling rule (Preset B, Step 3) applied to correction voyages.

Infra hardening from the same run (a full disk kept faking findings):
- **Grades MUST run under `xvfb-run -a`.** Parallel cypress runs otherwise collide on X display `:99`
  ("Server is already active for display 99") and return UNPARSEABLE/bogus scores — this faked a
  glm-5.2 "shipwright regression" (really ENOSPC) and hid qmax's real state. `oracle-grade.sh` now
  wraps cypress in `xvfb-run -a` (free display per run) and hard-fails (exit 6, `GRADE: DISK-ERROR`)
  on ENOSPC instead of parsing disk noise as a grade.
- **Void legs must not silently burn the cap.** Under <~3G free, bwrap `--tmp-overlay` fails all
  retries → the leg produces no session → the voyage lands as a 44s no-op and the driver counts it,
  grinding the whole cap to nothing (qmax V6–V20, then V21–V28). `eval-voyage.sh` now aborts a void
  leg (exit 6); the driver RETRIES that voyage (bounded 4×, disk-gated) and STOPs loudly with a
  `--resume-from N` hint rather than counting no-ops. A `disk_ok` preflight (2G) guards every
  voyage/grade/Shipwright.
- **Don't diagnose from status polls — read a leg log the FIRST time a voyage looks dead.** A voyage
  finishing in ~40s with an unchanged score is a void-leg tell; drilling one `*.leg.log` immediately
  shows `overlay mount failed (attempt 6) … leg is void`. Passive "update?" polling let two full
  resumes grind before this was caught — the expensive operator mistake of the run.
