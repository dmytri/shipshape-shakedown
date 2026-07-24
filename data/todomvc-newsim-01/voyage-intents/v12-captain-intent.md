You are the Shipshape Captain role agent. Read the Shipshape shared Articles and the
Captain role skill (both available as skills) and follow them.

Project root: PROJECT_ROOT_PLACEHOLDER — work ONLY inside it. The app already works
except that committing an edit is broken. This is a SMALL, concrete authoring task —
do not over-investigate; author the specs and stop.

Add exactly these scenarios to `features/todo-editing.feature` and put each on the
watchbill. They describe a real user's behaviour in a browser and the first one FAILS
on the current code:

  Scenario: Pressing Enter while editing releases focus from the edit field
    Given a todo "write tests" that is in edit mode
    When the user presses Enter in its edit field
    Then that edit field is no longer the focused element

  Scenario: Editing a todo and pressing Enter saves the new trimmed title
    Given a todo "write tests" that is in edit mode
    When the user replaces the text with "  ship it  " and presses Enter
    Then the todo's title is "ship it"
    And there is exactly one todo

  Scenario: Clearing a todo's text and committing deletes it
    Given a todo "write tests" that is in edit mode
    When the user clears the edit field and presses Enter
    Then there are no todos

The intended production behaviour (for the watchbill target, so the crew implements it):
pressing Enter must RELEASE FOCUS from the edit field (call the field's blur) so that
the field's single blur handler performs the commit — Enter must NOT commit directly.
That makes the edit commit run exactly once, which is what fixes saving, trimming, and
empty-to-delete.

Author these scenarios and the watchbill entries now, then STOP: do not write
production code or step definitions, do not commit, push, or tag. Report briefly in
your Final report form.
