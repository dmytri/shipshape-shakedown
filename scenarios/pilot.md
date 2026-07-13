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

- Never clone, reference, or mention the upstream tests inside the pilot project, in
  any role prompt, in any asset, or in any artifact a role can read. The vendored
  app-spec.md is the only external material that enters the project.
- Roles derive all verification from the spec alone. If their scenarios happen to
  converge with the oracle's checks, that convergence IS the measurement.
- Grade after the lifecycle ends, out-of-band, from a separate directory the project
  never sees. Never feed failures back verbatim mid-pilot: if a pilot iterates, route
  a failure to Captain re-phrased as USER intent in product language ("editing a todo
  to an empty string should remove it"), never as test output, selectors, or the
  suite's existence.
- A pilot where any role saw the oracle is void. Note the leak, rebuild, rerun.
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
