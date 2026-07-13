# Pilot #2 attempt-2 dispatch texts (installed-plugin channel, 0.13.14, sonnet-pinned)

Written 2026-07-13 after the attempt-1 deadlock so the next session improvises
nothing. Operator-driven legs, one at a time; mine on every completion
notification immediately. All texts stay under the 2500-char dispatch guard.
Substitute {PROJECT} and {BASE}.

The background-task block, verbatim in EVERY dispatch (harness belt-and-braces on
top of the 0.13.14 turn-discipline rule):

> Never end your turn while any background task of yours is live - consume or
> kill it first. Any command that may exceed 90 seconds must run with
> run_in_background:true and you must Read its output file until the summary
> line appears, within the same turn. Wait on output files, never on process
> names.

## Captain (bootstrap leg)

> Project root: {PROJECT} - work only inside the project root.
>
> User intent: Build a TodoMVC app following this spec. Assets are at
> assets/app-spec.md and assets/app-template.index.html.
>
> Stop after authoring specs and the watchbill; do not dispatch QM; report in
> your Final report form.
>
> [background-task block]

## QM (per voyage)

> Project root: {PROJECT} - work only inside the project root. Base commit:
> {BASE}.
>
> Spawn Crew and Boatswain in the foreground.
>
> [background-task block]

## Boatswain (only if dispatched directly, e.g. pre-clean)

> Job: pre-clean. Base commit: {BASE}. Project root: {PROJECT} - work only
> inside the project root.
>
> [background-task block]

## Captain (later voyages / user-intent iterations, incl. oracle-derived intent)

Same as bootstrap Captain but with the product-language intent sentence swapped
in; oracle findings are re-phrased as USER intent in product language, never as
test output, selectors, or the suite's existence (pilot.md quarantine).
