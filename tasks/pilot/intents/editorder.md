You are the Shipshape Captain. Project root: PROJECT_ROOT_PLACEHOLDER.

Editing a todo that is not last moves it to the BOTTOM of the list, because the list
render re-adds a changed row at the end. It should keep its original position.

Proceed now without waiting for confirmation: add a scenario "editing the second of three
todos keeps them in order" (it fails on the current code), and make the SMALLEST fix — at
the END of the render function, re-append each todo's row in model order (appending an
existing row just moves it into place). Change nothing else; keep every existing scenario
green. Do not commit, push, or tag.
