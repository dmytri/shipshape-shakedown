# Operator presets — driving the NEW-way pilot (Captain-directed voyages)

Reusable operator prompts + decision rules distilled from the 28/29 TodoMVC pilot
(2026-07-24; full narrative in `data/todomvc-newsim-01/OPERATOR-LESSONS.md`). The
operator is the main session loop; each voyage it hands ONE intent to Captain via
`eval-voyage.sh --captain-task <file>`, then grades out-of-band with `oracle-grade.sh`.

Two hard rules that hold for EVERY intent:
- **Oracle quarantine.** Never mention the oracle, its tests, selectors, framework name,
  or a reference implementation in any Captain intent. Re-phrase every failure as a
  USER-observable symptom in product language. (A raw runtime ERROR the app throws —
  e.g. a browser `NotFoundError` — is legal to quote; it is the app's behaviour, not the
  test.)
- **Always end with the STOP line** (Captain authors specs+watchbill only, no code, no
  commit) and keep the intent SHORT, CONCRETE, ACTION-FIRST. Open-ended "investigate and
  figure it out" prompts make a cheap model read endlessly and author nothing (tree-proven
  v10/v11). Give it the artifact to write.

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

### Template (fill the ‹brackets›)

```
You are the Shipshape Captain role agent. Read the Shipshape shared Articles and the
Captain role skill (both available as skills) and follow them.

Project root: PROJECT_ROOT_PLACEHOLDER — work ONLY inside it. Small, concrete task; do
not over-investigate and do not rewrite working code. Everything works except ‹one bug in
product language›.

THE BUG (real, and a user sees it in a browser): ‹symptom in product language; quote the
app's own thrown error if there is one›. ‹one sentence of the mechanism, from reading
js/app.js›.

Add this scenario to `features/‹file›.feature` and put it on the watchbill — it FAILS on
the current code:

  Scenario: ‹name›
    Given ‹concrete precondition›
    When ‹the user action›
    Then ‹the observable, falsifiable result›

  [OR, for a tier-invisible/structural defect, a scantling instead:]
  Scenario: ‹@conformance› ‹structural rule name›
    Then ‹the source of js/app.js satisfies: "‹exact structural property›"›

The production fix (watchbill target for the crew) must be MINIMAL and must not rewrite
working logic: ‹the smallest change, named concretely›. After the fix, the ENTIRE existing
scenario suite must still pass — if a change would break any existing scenario it is the
wrong change.

Author the scenario and the watchbill target now, then STOP: do not write production code
or step definitions, do not commit, push, or tag. Report briefly in your Final report form.
```

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
