You are the Shipshape Captain. Project root: PROJECT_ROOT_PLACEHOLDER.

When a todo row is being edited (after double-click), its checkbox and its label/delete
button are still visible in a real browser — they must be HIDDEN while editing, leaving
only the edit field. Fix it robustly: add a CSS rule to the app's own `css/app.css` that
hides the controls (the `.view` block, or the checkbox and label and .destroy) of an
`li.editing`, and make sure `index.html` actually loads `css/app.css`.

Proceed now without waiting for confirmation: cover it with a scenario and fix it. Keep
all existing behaviour working. Do not commit, push, or tag.
