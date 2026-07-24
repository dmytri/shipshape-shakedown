# Operator presets — driving the NEW-way pilot (Captain-directed voyages)

Reusable operator prompts + decision rules distilled from the 28/29 TodoMVC pilot
(2026-07-24; full narrative in `data/todomvc-newsim-01/OPERATOR-LESSONS.md`). The
operator is the main session loop; each voyage it hands ONE intent to Captain via
`eval-voyage.sh --captain-task <file>`, then grades out-of-band with `oracle-grade.sh`.

Three hard rules that hold for EVERY intent:
- **Address the role, give clear intent, and TRUST THE DOCTRINE.** Do not re-prime or
  re-phrase Shipshape in the intent — no "read the Articles and follow them," no "author the
  durable specs and the watchbill, stop after, do not commit/push/tag." The role skill
  (loaded via `--skill`) already carries all of that; repeating it is noise. An intent is
  just: name the role, the project root (and base commit for QM), and the product intent.
  A dispatch this session actually used and won on:
      `You are the Shipshape Captain. Project root: ‹path›.`
      `‹the product intent — what a user needs / what is broken›.`
  QM is leaner still — the doctrine dispatch surface is role + base commit, full stop:
      `You are the Shipshape Quartermaster. Project root: ‹path›. Base commit: ‹sha›.`
- **Oracle quarantine.** Never mention the oracle, its tests, selectors, framework name,
  or a reference implementation. Re-phrase every failure as a USER-observable symptom in
  product language. (A raw runtime ERROR the app throws — e.g. a browser `NotFoundError` —
  is legal to quote; it is the app's behaviour, not the test.)
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
If you need the assertion detail (to root-cause), capture the full cypress run once and
read the `N) … : AssertionError …` blocks. Reading the oracle spec to understand WHAT
failed is legitimate (you must know it to translate it); acting on it as anything but
product intent is not.

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

### Template (fill the ‹brackets›) — lean; no doctrine priming

```
You are the Shipshape Captain. Project root: PROJECT_ROOT_PLACEHOLDER.

The app works except: ‹symptom in product language — what a user sees; quote any error the
app itself throws›. ‹one sentence of mechanism from reading js/app.js, if it helps›.

Prove and fix it: ‹the observable acceptance, e.g. "editing the middle todo keeps it in
place"›. Cover it with a scenario that fails on the current code — for a real-browser-only /
structural defect the executing tests can't catch, a @conformance check over the js/app.js
source instead. Make the SMALLEST change; keep every existing behaviour working.
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
