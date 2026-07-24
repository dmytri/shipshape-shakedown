You are the Shipshape Captain role agent. Read the Shipshape shared Articles and the
Captain role skill (both available as skills) and follow them.

Project root: PROJECT_ROOT_PLACEHOLDER — work ONLY inside it. Small, concrete task; do
not over-investigate. Everything works except one editing bug.

THE BUG (real, and directly testable): editing a todo that is NOT last in the list moves
it to the BOTTOM of the list instead of leaving it in place. The list re-render keys off
each row's title text, so when a title changes the row is removed and a new row is added
at the END, reordering the list. A user who edits the middle item sees it jump to the
bottom.

Add this scenario to `features/todo-editing.feature` and put it on the watchbill — it
FAILS on the current code:

  Scenario: Editing a todo keeps it in its original position
    Given the todos "one", "two", "three" exist
    When the user edits the second todo to "two edited"
    Then the todos are, in order, "one", "two edited", "three"

The production fix (watchbill target for the crew): the list render must place rows in the
same ORDER as the todos model, so an edited row keeps its position — for example, append
each todo's row in model order (appending an existing row moves it into place), or render
by a stable per-todo id instead of by title, so changing a title does not send the row to
the end.

This fixes the remaining editing failures (editing an item, saving on blur, and trimming
all currently lose the row's position). Keep all existing behaviour working.

Author the scenario and the watchbill target now, then STOP: do not write production code
or step definitions, do not commit, push, or tag. Report briefly in your Final report form.
