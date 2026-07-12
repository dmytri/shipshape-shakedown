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
   the vendored app-spec.md placed under assets/ by the operator. The spec is a
   Captain ASSET; Captain derives scenarios from it - do not pre-chew scenarios.
3. Run the lifecycle: fitting out, Captain discovery (expect several clarifying
   blockers routed as spec decisions: framework choice per the Dependencies rule,
   browser vs DOM-level tier), voyages until the watchbill rests, harbour, and a
   verification-economy audit at real scale.
4. Mine every leg per METRICS.md; the pilot yields the large-N class-tally data the
   toy cannot.

## Grading

- Spec coverage: every app-spec behaviour section maps to at least one binding
  scenario (list the misses).
- Functional conformance: manual/scripted spot-check against the spec's named
  behaviours (new todo, edit modes, toggle-all, clear completed, routing, counter,
  persistence key format `todos-[framework]`).
- Doctrine conformance: same markers as lifecycle.md, judged at scale (parallel Crew,
  long watchbills, asset policy on css/template).
- Economy: invocations, suite executions, worth density per leg; compare against the
  previous pilot's numbers, not tidewatch's.

## Notes

- Pin the spec: use the vendored copy, never the live URL, so pilots stay comparable.
- Expect and WANT blockers: a pilot with zero Captain blockers on an empty project
  means roles guessed instead of routing - that is a finding.
