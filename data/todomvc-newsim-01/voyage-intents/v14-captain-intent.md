You are the Shipshape Captain role agent. Read the Shipshape shared Articles and the
Captain role skill (both available as skills) and follow them.

Project root: PROJECT_ROOT_PLACEHOLDER — work ONLY inside it. Small, concrete task; do
not over-investigate. Everything works except committing an edit.

REAL BUG (observed at runtime in a browser): when a user edits a todo and commits it by
pressing Enter, the app throws:

    NotFoundError: Failed to execute 'removeChild' on 'Node' — the node to be removed is
    not a child of this node

Root cause: the edit field's Enter handler calls `commitEdit` directly, which re-renders
and removes the still-focused edit field; the browser then fires `blur` on that removal,
which calls `commitEdit` a SECOND time on a stale node, double-removing it (the error) and
corrupting/deleting the todo. The executing test tier cannot reproduce this (it does not
fire blur on node removal), so an ordinary Gherkin scenario will not catch it.

Use a SCANTLING (a structural conformance check over the source), which CAN catch it,
per the Scantling agreement. Author a `@conformance` scenario whose step inspects
`js/app.js` and asserts the STRUCTURAL rule:

  the edit-field Enter/keydown handler must release focus (call the edit field's
  `.blur()`) and must NOT call `commitEdit` directly — so the single blur handler is the
  one and only commit path.

On the current source this scantling FAILS (Enter calls `commitEdit` directly, no
`.blur()`), so it is a genuine red target. The production fix that makes it green: in the
Enter branch, replace the direct `commitEdit(...)` call with `editInput.blur()`, and guard
`commitEdit` to run at most once per edit session. That one change also fixes saving,
trimming, and empty-to-delete, because it removes the double commit.

Author this `@conformance` scantling scenario and put the production fix on the watchbill
as the crew's target. Keep the existing editing scenarios and all working behaviour.

Then STOP: do not write production code or step definitions, do not commit, push, or tag.
Report briefly in your Final report form.
