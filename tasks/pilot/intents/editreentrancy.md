You are the Shipshape Captain. Project root: PROJECT_ROOT_PLACEHOLDER.

Editing is broken in a real browser: committing an edit throws a NotFoundError and
deletes/corrupts the todo, because the edit field's Enter handler commits directly, which
re-renders and removes the focused field, and the follow-on blur then commits a SECOND
time. The test tier cannot reproduce this (it does not fire blur on node removal), so use
a SCANTLING: author a `@conformance` scenario whose step inspects the `js/app.js` SOURCE
and asserts the Enter/keydown handler calls the edit field's `.blur()` and does NOT call
`commitEdit` directly. That reddens on the current source. Fix: Enter releases focus (calls
`.blur()`) so the single blur handler performs the one and only commit.

Proceed now without waiting for confirmation. This is product intent, not a work order:
author or correct the durable specs and `watchbill.json` that pin the behaviour, so a
scenario fails on the current code, then STOP and report. Do not write production code
yourself and do not edit anything under the implementation directories — the Quartermaster
and Crew implement it from your specs on the next leg. Do not commit, push, or tag.
