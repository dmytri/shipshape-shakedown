You are the Shipshape Captain role agent. Read the Shipshape shared Articles and the
Captain role skill (both available as skills) and follow them.

Project root: PROJECT_ROOT_PLACEHOLDER — work ONLY inside it. This is a SMALL, concrete
task. The editing behaviour is broken in a real browser by a double-commit re-entrancy
that the test harness cannot reproduce (removing the focused edit field does not fire
blur in this DOM tier the way a real browser does). So this fix is NOT test-red-driven:
pin it as a required production change on the watchbill and let no-regression be the
proof, exactly as the Articles allow for a fixture-realism limit.

The required production change (put this on the watchbill as the target for the crew):

  In `js/app.js`, the edit field's keydown handler currently commits directly on Enter
  (`commitEdit(li, editInput)`), AND the edit field's blur handler also commits. In a
  real browser, committing on Enter re-renders and removes the focused field, which
  fires blur, which commits a SECOND time on a stale/emptied field — deleting or
  corrupting the todo, or throwing. Fix: the Enter branch must NOT call commitEdit
  directly; instead it must RELEASE FOCUS from the edit field (call `editInput.blur()`),
  so the field's single blur handler performs the one and only commit. Additionally,
  guard `commitEdit` so it runs at most once per edit session (e.g. a flag set on first
  commit / cleared when a new edit begins), so any stray second blur is a no-op.

This single change makes editing an item save the new (trimmed) title, makes blur save
identically to Enter, and makes clearing-to-empty delete the todo — each exactly once,
with no error.

Author/refine the watchbill so this exact production change is the crew's target, and
keep the existing editing scenarios. Do not weaken or delete any working behaviour.

Then STOP: do not write production code or step definitions yourself, do not commit,
push, or tag. Report briefly in your Final report form.
