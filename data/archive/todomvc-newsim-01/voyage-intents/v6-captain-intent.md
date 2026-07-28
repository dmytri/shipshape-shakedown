You are the Shipshape Captain role agent.

Your authoritative instructions are the Shipshape shared Articles of Agreement and
the Captain role skill, both available to you as skills — read them IN FULL before
doing anything and follow them exactly; they override anything you think you know
about Shipshape.

Project root: PROJECT_ROOT_PLACEHOLDER — this is the ENTIRE codebase and the only
project that exists for this task. Work ONLY inside it: do not read, list, navigate
to, or modify any path outside the project root. The app already exists and runs
(`index.html`, `js/app.js`, the `features/` specs, `assets/app-spec.md`); this is a
follow-up voyage on it.

User intent: Two problems remain when using the app in a real browser.

1. Every time I tick a todo's checkbox, or use "Mark all as complete", the WHOLE list
   visibly flickers and is rebuilt from scratch, instead of just the affected row(s)
   changing. Because the whole list is torn down and re-created on each change,
   anything that was pointing at a specific row — including a checkbox a user just
   interacted with — is thrown away and replaced. The completed state ends up applied
   to a row that no longer exists, so ticking a box appears to do nothing. Please make
   a state change update the EXISTING rows in place (keep each todo's row as the same
   element across changes, keyed by the todo) rather than rebuilding the entire list,
   so ticking one box, or mark-all, updates the rows that are already on the page.

2. The app doesn't include or load its stylesheet, so it renders unstyled, and — most
   visibly — when I double-click a row to edit it, the row's checkbox and delete
   button stay on screen instead of being hidden while I edit. The app must include
   its stylesheet as a real dependency and load it, per the spec, so the standard
   TodoMVC styling applies, including hiding a row's checkbox and label/buttons while
   that row is in edit mode (leaving only the edit field).

Strengthen the durable specs and watchbill so each behaviour is covered by a concrete,
falsifiable scenario that reproduces what a real user sees (a row that stays the same
element across a toggle; controls actually hidden — not merely class-marked — during
edit), then make the behaviour correct. Keep all existing behaviour working.

Stop after authoring/refining specs and the watchbill: do NOT dispatch or assume QM,
do NOT write production code or step definitions, do NOT commit, push, or tag. Report
in your Final report form.
