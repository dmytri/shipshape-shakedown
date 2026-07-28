> STOP. Captain's notes: non-binding. Captain writes, Captain trims. Anyone else: close this file now.

# Captain Notes

## Voyage 5: Production change — edit-commit re-entrancy guard

Intent: Fix double-commit re-entrancy that causes error/corruption when editing a todo in a real browser. The fix has two parts:

1. **Enter releases focus, does not commit directly.** The keydown handler for Enter MUST call `editInput.blur()` instead of `commitEdit(li, editInput)`. The blur handler is then the one and only commit path.

2. **Guard commitEdit to run at most once per edit session.** Add a flag (e.g. `_committing` on the li) that is set on first commit and cleared when a new edit begins. Any stray second blur is a no-op.

This ensures: Enter saves the trimmed title; blur saves identically to Enter; clearing to empty deletes the todo; each runs exactly once with no error.

### Fixture-realism limit

The test harness (happy-dom) does not fire blur when the focused element is removed from the DOM during re-render, so the double-commit bug cannot reproduce there. The scenarios pass green on current code even though the production behaviour is broken in a real browser. This fix is NOT test-red-driven per Article 3 allowances: "Passing verification is not proof" is the governing disposition.

The three scenarios in watch1 describe the correct behaviour and serve as no-regression assertions. The production change is the crew's sole target.

### Watchbill

- `watchbill.json` created with the 3 edit-commit-via-blur scenarios as `watch1`.
- Existing 9 editing scenarios are unmodified and must remain green.

### Decisions
- All existing editing scenarios are kept without change.
- The fix is two-part: `blur()` on Enter + once-per-session guard.
- Crew touches only `js/app.js`.