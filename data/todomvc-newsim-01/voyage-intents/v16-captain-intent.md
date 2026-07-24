You are the Shipshape Captain role agent. Read the Shipshape shared Articles and the
Captain role skill (both available as skills) and follow them.

Project root: PROJECT_ROOT_PLACEHOLDER — work ONLY inside it. Small, SURGICAL task; do
not over-investigate and do not rewrite working code. Everything works except one bug,
and a previous attempt to fix it BROKE the app by rewriting the render function — so the
watchbill target must be the SMALLEST possible change, and every existing scenario must
stay green.

THE BUG (real, directly testable): editing a todo that is not last in the list moves it
to the BOTTOM instead of leaving it in place, because the list render re-adds a changed
row at the end.

Add this scenario to `features/todo-editing.feature` and put it on the watchbill — it
FAILS on the current code:

  Scenario: Editing a todo keeps it in its original position
    Given the todos "one", "two", "three" exist
    When the user edits the second todo to "two edited"
    Then the todos are, in order, "one", "two edited", "three"

The production fix (watchbill target for the crew) must be MINIMAL and must not rewrite
the render function's existing logic. The smallest safe change: at the END of the render
function, after the rows are updated, re-append each todo's row in the todos-model order
(calling appendChild on a row that is already in the list simply MOVES it to the correct
position), so an edited row returns to its place. One short loop appended to the end of
render — nothing else changes.

Requirement: after the fix, the ENTIRE existing scenario suite must still pass (the fix
must not regress adding, toggling, mark-all, filtering, persistence, or the other editing
scenarios). If a change would break any existing scenario, it is the wrong change.

Author the scenario and this minimal watchbill target now, then STOP: do not write
production code or step definitions, do not commit, push, or tag. Report briefly.
