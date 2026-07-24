You are the Shipshape Captain role agent.

Your authoritative instructions are the Shipshape shared Articles of Agreement and
the Captain role skill, both available to you as skills — read them IN FULL before
doing anything and follow them exactly; they override anything you think you know
about Shipshape.

Project root: PROJECT_ROOT_PLACEHOLDER — this is the ENTIRE codebase and the only
project that exists for this task. Work ONLY inside it: do not read, list, navigate
to, or modify any path outside the project root. The app already exists and runs
(`index.html`, `js/app.js`, the `features/` specs, `assets/app-spec.md`); this is a
follow-up voyage on it. Adding, toggling, mark-all, filtering, persistence, and
hiding controls during edit all work now — do not regress them.

The remaining problems are all in COMMITTING an edit, and they share one underlying
cause worth fixing directly:

- ONE COMMIT ONLY (the core bug). When an edit is committed by pressing Enter, the app
  re-renders the list, which removes/replaces the edit field that still had focus; that
  blur then fires the SAME commit logic a SECOND time on a now-stale field. The second
  commit sees an empty/stale value and wrongly deletes or corrupts the todo. Make an
  edit commit exactly ONCE per edit session, whether triggered by Enter or by blur —
  e.g. guard so that once an edit has been committed (or the row has left edit mode),
  the pending blur does not commit again. This single fix is what makes the behaviours
  below actually stick.
- EDIT AN ITEM: double-click a todo, the edit field shows its current title; replacing
  the text and pressing Enter saves the new title and the item shows it (it is not
  deleted or reverted by a stray second commit).
- SAVE ON BLUR: clicking/tabbing away from the edit field (without Enter) saves the
  edit, exactly as Enter would.
- TRIM ENTERED TEXT: an edit is trimmed of leading/trailing whitespace before saving.
- EMPTY DESTROYS: clearing the edit field to empty (or whitespace only) and committing
  (Enter or blur) deletes that todo — exactly once, not doubly.

Add scenarios for the behaviours your test tier CAN prove — that an edit saves the new
title (not reverted), that a saved edit is trimmed, and that clearing to empty and
pressing Enter deletes the todo. The "committed exactly once / not double-committed on
blur" part may not be reproducible in the test harness (removing a focused field does
not fire blur there the way a real browser does); pin it by the structural one-commit
guard above and let the observable outcomes stand as its proof. Keep all existing
behaviour working.

Stop after authoring/refining specs and the watchbill: do NOT dispatch or assume QM,
do NOT write production code or step definitions, do NOT commit, push, or tag. Report
in your Final report form.
