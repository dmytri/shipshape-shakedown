# Edit-commit re-entrancy guard

The edit field's keydown handler for the Enter key MUST release focus by calling `.blur()` on the edit input element and MUST NOT call `commitEdit` directly. The blur handler on the edit input MUST be the single path that commits the edit.

This structural rule prevents the double-commit re-entrancy bug that occurs in a real browser: when the Enter handler calls `commitEdit` directly, the re-render removes the still-focused edit field from the DOM, which causes the browser to fire `blur` on the removed node, which calls `commitEdit` a second time on a stale node, producing a `NotFoundError` and corrupting the todo.

## Structural constraint

The `editInput.onkeydown` function body that handles `ENTER_KEY` (keyCode 13) must contain:

- A call to `editInput.blur()` — this releases focus and triggers the blur handler in a single controlled path.
- No call to `commitEdit` — the blur handler is the only commit path.

The `editInput.onblur` function body is the sole allowed call site of `commitEdit`.

## Check method

Read `js/app.js`, locate the `onkeydown` assignment inside the `dblclick` handler, inspect the `ENTER_KEY` branch. Assert:

1. The branch contains `editInput.blur()` or an equivalent focus-release expression.
2. The branch does NOT contain `commitEdit`.

A passing conformance check on this scantling means the structural rule is satisfied.