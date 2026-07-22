# Pilot dispatch texts (installed-plugin channel, sonnet-pinned)

Written 2026-07-13 after the pilot-#2 deadlock so the next session improvises
nothing. Operator-driven legs, one at a time; mine on every completion
notification immediately. All texts stay under the 2500-char dispatch guard.
Substitute {PROJECT} and {BASE}.

**The dispatch surface is role plus base commit, full stop.** Pilot #7's QM refused a
directed dispatch TWICE, and was right both times: any additional scope - even a bare
scenario name - routes through `watchbill.json`, never through dispatch prose. The QM
text below carried `Spawn Crew and Boatswain in the foreground` until 2026-07-22; that
line was operational instruction in a dispatch, and it is struck. Crew spawning is
doctrine's own from 0.13.51 (`qm/SKILL.md:72` dispatches an isolated subagent), so the
line was also redundant.

The background-task block is HARNESS BELT-AND-BRACES, not doctrine, and it is optional:

- Carry it for pilot and lifecycle legs, where completing the voyage is the point.
- OMIT it for any probe of the background-stall class, and say so in the rubric. It
  instructs the role to do what that class is measuring, so carrying it manufactures a
  pass (0.13.50 probe, and the 0.13.49 hook probe 2026-07-22).

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
> [background-task block, if carried]

## Boatswain (only if dispatched directly, e.g. pre-clean)

> Job: pre-clean. Base commit: {BASE}. Project root: {PROJECT} - work only
> inside the project root.
>
> [background-task block]

## Captain (later voyages / user-intent iterations, incl. oracle-derived intent)

Same as bootstrap Captain but with the product-language intent sentence swapped
in; oracle findings are re-phrased as USER intent in product language, never as
test output, selectors, or the suite's existence (pilot.md quarantine).
