# Operator lessons — NEW-way TodoMVC pilot #1 (deepseek-v4-flash, candidate yoink-settle)

The pilot.md axis-4 lens (instruction fidelity) turned on the OPERATOR: what worked and
what didn't when directing Captain, voyage by voyage. Running log; updated each voyage.
The oracle is quarantined — every intent below is product language, never a test/selector/
oracle reference.

## Standing target
28/29 IS the ceiling (dk): the 29th spec is the perennial pending/unpassable one. Goal =
drive the 5 real-browser failures to 0, i.e. 23 passing + 5 = 28/29, 1 pending. 23/29 is
NOT a plateau to accept — keep iterating.

## What WORKED directing Captain

- **Concrete, enumerated symptoms in product language.** V2 (routing/persistence) listed
  the exact broken behaviours as a bulleted user-visible list ("Active shows every todo",
  "selected link not highlighted", "reload loses filter"). Self-suite jumped 27→34 green
  in one voyage. Enumerating each broken behaviour beats a vague "fix the filters."
- **Naming the missing DELIVERABLE, not just the symptom.** V3 (blank page) said both the
  symptom ("open in a browser, blank page") AND what a working result concretely is ("a real
  `index.html` at the root, built from the template markup, that loads `js/app.js` via a
  script tag"). Produced `index.html` + 40/40 self + the first real oracle (0→23/29). When
  the gap is a missing artifact, describe the artifact in product terms, not only the pain.
- **Hard STOP-lines on the Captain dispatch.** Every intent ended "author specs + watchbill,
  then STOP; do not dispatch/assume QM, do not write code, do not commit." Zero Captain→QM
  contamination across 5 voyages; Captain always handed back cleanly.
- **A Captain no-op is not fatal.** V2 Captain added no new commit (judged the existing
  specs sufficient) yet QM still fixed from them. Don't force Captain to churn specs when
  the specs already cover it — the value can be entirely in the QM rebuild.

## What DID NOT work

- **Re-stating oracle failures as product complaints ALONE (V4 → no movement, 23→23).** The
  5 failing behaviours were already GREEN in the roles' own happy-dom self-suite (40/40), so
  QM had no red target and "fix these behaviours" changed nothing. **Lesson: when the self-
  suite is green but the browser is broken, product-intent restatement is insufficient — the
  bug the roles can't reproduce, they can't fix.** The operator must push on TEST
  FAITHFULNESS: get the roles to write a scenario that reproduces a real user click and
  actually goes red, THEN fix (what V5 attempts). Restating the symptom a second time is
  wasted spend; change the LEVER, not the volume.
- **Test-faithfulness nudge ALONE (V5 → still 23/29).** "The checks pass yet a real user is
  blocked → make the scenarios faithful and go red, then fix" did NOT move it either. Captain
  added no new scenarios; the roles stayed inside their green happy-dom suite. A realism
  exhortation with no concrete reproduction is still too abstract for this baseline.

- **THE LEVER THAT (V6, under test) TARGETS: operator DIAGNOSES root cause, then phrases the
  ROOT as a product symptom — not the surface symptom.** V4/V5 failed because I re-stated the
  surface ("checkbox doesn't work"). Reading the oracle's ACTUAL assertions (legitimate — the
  operator must know what failed to translate it) showed the 5 failures are really TWO defects:
  (a) `render()` full-teardown `innerHTML` rebuild invalidating the row identity the test holds
  (the keyed-DOM-identity class METRICS documents across pilots — the self-suite misses it
  because its steps re-query fresh), and (b) a missing `todomvc-app-css` dependency so `.editing`
  never hides controls (CSS-driven visibility, absent in the build). V6 phrases BOTH as product
  symptoms in the METRICS-established language: "the list FLICKERS/rebuilds on every change,
  update rows in place" and "the app doesn't include its stylesheet, controls not hidden on
  edit." **Lesson: when symptom-restatement plateaus, the operator's job is to root-cause the
  failure (reading the oracle spec is fair for translation) and aim the intent at the CAUSE
  the roles' own suite can't see, in product language.**

- **ROOT-CAUSE + DISCRIMINATING-SCENARIO direction WORKED (V7 → 23→24, the whole checkbox/
  DOM-identity class solved).** What finally moved it, after 3 stuck grades: (1) name the root
  cause in product terms (the list rebuilds every change, throwing away the row the user
  clicked), (2) demand a scenario that REPRODUCES it in the roles' own tier (hold a reference
  to one `<li>`, toggle, assert it's the SAME element) so QM gets a red target its happy-dom
  suite can actually fail on, and (3) name the concrete fix shape (update rows in place, keyed
  by todo; hide edit controls via the app's OWN `css/app.css`, not an external package). Self-
  suite went 40→44 (Captain added the discriminating scenarios), `render()` dropped the
  `innerHTML=''` rebuild, and 5 failures cleared at once.
  - **Finding about the model (record, don't hide): deepseek-v4-flash needed near-
    implementation-level direction to cross this**, where the sonnet pilots' Captain reasoned
    to the same fix from a bare "flicker/reset" complaint. The new-way pilot CAN reach the bar,
    but the operator direction required is markedly more explicit for this baseline. That gap
    IS a headline pilot result, not a footnote.
- **Progress is LAYERED: fixing one root cause exposes the next.** V7 solving the DOM-identity
  class surfaced 4 editing-commit failures (save-on-blur, trim, empty-destroys, edit-an-item)
  that the rebuild had masked. Expect the failing SET to change, not just shrink; re-diagnose
  each grade rather than assuming the same targets.

## The operator's prompt is the main variable — match it to what the roles' TIER can catch (dk, 2026-07-24)

dk's nudge: "if deepseek is not succeeding, consider if it's your prompting." Correct — V7
proved deepseek CAN do the hard fix (keyed reconciliation) with the right prompt, so the
variance across V4–V8 is the OPERATOR'S prompt, not a model ceiling. The rule that fell out:

- **The ONLY channel to QM is a scenario Captain writes that FAILS on the current code.** QM
  works to green its own suite and stops; a scenario that passes on the buggy code is invisible
  to it. So the operator's real job is to get Captain to author a DISCRIMINATING (currently-red)
  scenario — not to describe symptoms. Symptom-restatement (V4/V5/V8) never moved it; a demanded
  failing scenario (V7 identity check) moved it in one voyage.
- **BUT some bugs are invisible to the roles' TIER, and then TDD framing is the WRONG prompt.**
  The editing double-commit depends on "removing a focused element fires `blur`" — happy-dom does
  NOT do this (METRICS documents the exact limit). So NO happy-dom scenario can redden it;
  demanding "write a failing scenario" for it is impossible and misdirects the roles. For a
  tier-invisible bug the operator must give STRUCTURAL reasoning (name the reentrancy, direct a
  one-commit guard) and accept the self-suite can only prove the observable outcomes (trimmed
  save, empty-destroys-on-Enter), not the blur-on-removal itself. Diagnosing the failure (reading
  the oracle spec AND the app code) is what tells you WHICH prompt shape fits.
- **Keep prompts focused, not bloated.** Long prescriptive intents risk burying the one lever.
  Lead with the single root fix; list observable acceptance behaviours; stop.

- **V8 & V9 were operator NO-OPS — the sharpest lesson (dk: "consider if it's your prompting").**
  Tree-evidenced: `js/app.js` unchanged since V7 (`ddf628f`), no `features/` commits since V7,
  self-suite frozen at 44/44, V9 QM ran only 7 turns and changed nothing. My editing intents (v8
  symptom list, v9 structural prose) produced ZERO durable change. Root cause: **QM only acts on a
  RED target; a tier-invisible bug yields none; so intent addressed to Captain-as-spec-author dies
  at the handoff.** Describing a behavior the roles' green suite already "passes" gives neither
  Captain nor QM a reason to act. The fix is not louder symptom prose — it is to give Captain an
  INVESTIGATION mandate (read `js/app.js`, trace the event sequence) so it produces a watchbill
  target QM will engage, with a mechanism hint (unify the Enter and blur commit paths to one)
  rather than a bare "make editing work." Escalate to the explicit code change only if investigation
  framing still no-ops.

- **THE prompting craft for a tier-invisible bug: REFRAME it into a tier-VISIBLE property (v11).**
  V8 (symptoms), V9 (structural prose), V10 (investigation mandate + mechanism hint) ALL no-op'd —
  `js/app.js` untouched since V7, three wasted grades — because none gave QM a RED target and QM
  acts only on red. The reentrancy itself can't redden in happy-dom (no blur-on-removal). The move
  that works (and is how the sonnet pilots crossed this exact bug): find a TESTABLE PROPERTY whose
  truth implies the fix. Here: "pressing Enter in the edit field RELEASES FOCUS" — happy-dom tracks
  `activeElement`/blur, the current code commits directly on Enter without blurring, so that scenario
  goes RED; satisfying it (Enter calls `editInput.blur()`, the single blur handler commits once)
  eliminates the double-commit and fixes all 4 editing failures together. **Operator craft: don't
  ask for the untestable behaviour or hand the code — engineer a red-able proxy property that forces
  the fix.** That is the difference between a prompt that moves QM and one that no-ops.

- **BIGGEST prompting lesson: deepseek Captain FLAILS on investigation mandates and never writes
  the artifact (v11 tree-proof).** v11 Captain ran 16 turns = 25 reads + 8 bash + ZERO writes, and
  ended MID-INVESTIGATION ("let me examine the editing handling more closely…") — it spent the whole
  budget reading and produced no scenario, so QM got nothing and no-op'd in ~45s. My v10/v11 intents,
  by asking Captain to "investigate and trace," caused exactly this. Contrast the voyages that MOVED
  (v2 routing, v3 page, v7 identity): each handed Captain a CONCRETE deliverable to author. **Rule:
  for this baseline, prompts must be SHORT, CONCRETE, ACTION-FIRST — give Captain the exact scenario
  to write (near-Gherkin), not an open investigation. Open-ended "figure it out" prompts burn the
  turn budget on reads and yield no durable output.** This is the single highest-leverage correction
  to my operator prompting across the whole pilot.

- **THE doctrine-native fix for a tier-invisible bug: a SCANTLING (dk's steer, v14).** Six voyages
  (v8–v13) proved QM will not touch a green suite, and happy-dom cannot redden the reentrancy — so
  no executing scenario gives QM a target. A SCANTLING does: it is a STRUCTURAL check over the
  SOURCE (not runtime DOM), so "the Enter keydown handler must route through `blur`, not call
  `commitEdit` directly" reddens on the current source text and greens when fixed — a real target
  QM/Crew can act on, independent of the DOM tier. This is the Shipshape-native answer to a fixture
  the executing tier can't reach, and it's what I should have reached for at v8 instead of six
  scenario/prose attempts. Pair it with pasting the REAL runtime error (the browser's
  `NotFoundError` from the double `removeChild`) to Captain as a genuine bug symptom (legitimate —
  it's a runtime error, not the oracle's tests). Operator lesson: when the executing tier can't
  redden a structural defect, reach for a scantling, not louder prose.

- **CLOSING ARC — how the last mile actually landed (v14→v16, reached 28/29).**
  - **v14 (scantling): +1 → 25/29.** dk's scantling steer worked: a STRUCTURAL check ("Enter handler
    must route through blur, not commitEdit directly") reddened on the SOURCE where no happy-dom
    scenario could, gave QM a real target, and deepseek CODED the fix (`editInput.blur()`). This
    settled dk's "deepseek can't code" question: it CAN — every blocker was targeting, not capability.
  - **v15 (regression): render rewrite BROKE the app** (self-suite 48→6 red, oracle 0/29), and the
    operator-custody commit poisoned the base. TWO fixes: reverted to the v14 good state, and hardened
    `eval-voyage.sh` to REVERT any voyage that leaves the self-suite red (a broken build never becomes
    the next base). Lesson: demand the SMALLEST change and keep the guard; a cheap model will over-
    reach on a big rewrite.
  - **v16 (surgical): +3 → 28/29.** The final 3 failures were ONE tier-VISIBLE bug (keyed-by-title
    render appends an edited row at the end, breaking order). A plain position scenario reddened it in
    happy-dom (no scantling needed), and a surgical "append rows in model order at the end of render,
    change nothing else" intent got deepseek to fix it without regressing. All specs passed, 28/29.
  - **Meta-lesson across the whole pilot: the operator's job is TARGETING.** Match the red-target
    mechanism to the bug's tier — plain scenario for tier-visible, SCANTLING for tier-invisible/
    structural — keep prompts short/concrete/action-first, demand minimal changes, and guard the base
    against regressions. Every stuck stretch was a targeting failure on my side, not the model's.

## FINAL: 28/29, deepseek-v4-flash, 16 voyages, 32 legs, 518 inv, $1.33. Oracle 0→23→24→25→28.

## Operator PROCESS bugs (harness, not Captain-directing) — all fixed
- `&&`-idiom under `set -e` in run_leg returned 1 on the clean path → killed the pilot
  silently after a good leg. Use `if/fi`. (Cost: one 24-min silent hang.)
- `pkill` in the SAME command that launched a voyage SIGTERM'd the launcher (exit 144, voyage
  never started). Launch voyages via `setsid bash -c '...' & disown`, never beside a pkill.
- Oracle `start-server-and-test` waits forever on a missing `index.html`; capped with
  `WAIT_ON_TIMEOUT` + an outer `timeout`.
- Oracle wait URL must be the build's real entry (`examples/<fw>/index.html`), not the
  `examples/` directory (404 → timeout).
