# TodoMVC pilot (integration tier)

The acceptance-scale shakedown: build a working TodoMVC app through the full Shipshape
lifecycle from EXTERNAL intent nobody in the loop authored. Run at release milestones,
not per change - it is expensive (multi-voyage). For doctrine deltas and probes, use
the tidewatch fixture (scenarios/lifecycle.md); this pilot is the full regression.

## Why external intent

Improvised intents share authorship with the doctrine fixes under test, so they
subconsciously test what was just fixed. The vendored spec (fixtures/todomvc/app-spec.md,
from tastejs/todomvc, MIT) is stable, independent, and rich in real edge cases:
editing semantics (double-click, escape/enter, empty-destroys), routing filters,
toggle-all coupling, persistence keys, counter pluralization.

## Procedure

1. Scaffold an EMPTY project dir (git init + one operator commit of a README only;
   fitting out must derive everything, including a Captain blocker for the missing
   test runner - a dependency decision).
2. User intent to Captain, verbatim: "Build a TodoMVC app following this spec" +
   BOTH vendored assets placed under assets/ by the operator: app-spec.md AND
   app-template.index.html (the spec's Template section incorporates the
   todomvc-app-template repo by reference; the first pilot vendored only the spec,
   Captain scoped the unreachable Template section out, and the oracle graded 0/29 on
   the template-markup gate). The spec and template are Captain ASSETS; Captain
   derives scenarios from them - do not pre-chew scenarios.
3. Run the lifecycle OPERATOR-DRIVEN, leg by leg (pilot #2, 2026-07-13: an
   auto-chained Captain->QM nested-async voyage deadlocked - the browser-tier
   suite exceeded the runtime's ~2m foreground cap and a background completion
   cannot resume a finished nested agent chain). Stop Captain after
   specs+watchbill with an explicit stop-line; dispatch QM yourself; carry the
   background-task dispatch lines from prompts/preamble.md in every leg. Expect
   several clarifying blockers routed as spec decisions: framework choice per the
   Dependencies rule, browser vs DOM-level tier. Voyages until the watchbill
   rests, harbour, and a verification-economy audit at real scale.
4. Mine every leg per METRICS.md; the pilot yields the large-N class-tally data the
   toy cannot.

## Grading

- Spec coverage: every app-spec behaviour section maps to at least one binding
  scenario (list the misses).
- Functional conformance: run the OFFICIAL upstream oracle, not spot-checks. TodoMVC
  ships a parameterised Cypress spec (tastejs/todomvc `tests/` + `cypress/e2e/spec.cy.js`)
  covering add/edit/toggle/route/persist, run against a served app. Clone upstream,
  serve the pilot build at the expected path (or point `baseUrl` at it), run
  `npx cypress run --env framework=<pilot>`. Every failure is an objective conformance
  finding nobody in the loop authored - the external-verifier gold standard. Pin the
  upstream commit used and record it with the pilot results so grades stay comparable.

## Oracle quarantine (100% pop quiz, 0% shadow spec)

The oracle is OPERATOR-SIDE ONLY and the role agents MUST NOT learn it exists:

- Never clone, reference, or mention the upstream tastejs/todomvc REPOSITORY - its
  tests AND its reference example implementations (examples/*, any framework's
  working solution) - inside the pilot project, in any role prompt, in any asset, or
  in any artifact a role can read. The vendored app-spec.md and app-template.index.html
  are the only external material that enters the project; both are the shared
  challenge scaffold (spec + common markup convention every implementation uses), not
  a solution or an assertion set.
- Roles derive all verification from the spec alone. If their scenarios happen to
  converge with the oracle's checks, that convergence IS the measurement.
- Two-phase gate, strictly ordered: PHASE 1 (build) runs to the project's OWN
  watchbill fully struck (every spec-derived scenario the roles wrote themselves is
  green) before PHASE 2 (grade) ever starts. Do not copy the build into the oracle
  harness or run the oracle suite while the watchbill still has red entries - the
  pilot must pass its own self-authored tests first, on its own terms, before it is
  measured against anything external.
- Grade after phase 1 rests, out-of-band, from a separate directory the project
  never sees. Never feed failures back verbatim: if a pilot iterates, route each
  failure to Captain re-phrased as USER intent in product language ("editing a todo
  to an empty string should remove it"), never as test output, selectors, or the
  suite's existence.
- Iterate PHASE 1 -> PHASE 2 -> PHASE 1 -> ... until the oracle suite passes in full.
  A pilot is not done at "one iteration landed some improvement" - dk's ruling
  (2026-07-13): "take the spec, make an app that passes all the tests, that's the
  whole point." Each cycle is a normal voyage (spec/watchbill amendment -> QM ->
  Crew -> Boatswain -> re-grade), not a special mode; only the failure's origin is
  disguised, not the mechanism.
- The operator grades and iterates using exactly this procedure - it does not invent
  its own side-investigations, control runs, or verification apparatus (e.g. running
  the oracle suite against a reference implementation to sanity-check the harness)
  mid-pilot, however well-reasoned; that is scope the pilot never asked for and it
  taxes the very latency/invocation numbers the pilot exists to measure. Oracle
  failures are taken at face value. A methodology concern about the oracle itself is
  routed to dk afterward as a question, never acted on mid-run.
- A pilot where any role saw the oracle (tests OR reference implementations) is
  void. Note the leak, rebuild, rerun.
- Doctrine conformance: same markers as lifecycle.md, judged at scale (parallel Crew,
  long watchbills, asset policy on css/template).
- Economy: invocations, suite executions, worth density per leg; compare against the
  previous pilot's numbers, not tidewatch's.

## Notes

- Pin the assets: use the vendored copies (fixtures/todomvc/app-spec.md and
  fixtures/todomvc/app-template.index.html), never live URLs, so pilots stay
  comparable.
- Expect and WANT blockers: a pilot with zero Captain blockers on an empty project
  means roles guessed instead of routing - that is a finding.
