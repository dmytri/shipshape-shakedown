> STOP. Captain's notes: non-binding. Captain writes, Captain trims. Anyone else: close this file now.

# Captain Notes

Binding behaviour lives in `.feature` specs and referenced `assets/**`. History lives in git. These notes carry only what the next cycle needs.

## Voyage 1 — TodoMVC greenfield build (cont.)

- **Spec source**: `assets/app-spec.md`
- **Template source**: `assets/app-template.index.html`
- **Stack**: vanilla JavaScript, no preprocessors
- **Persistence**: localStorage, key `todos-vanillajs`
- **Routing**: hash-based (`#/`, `#/active`, `#/completed`)
- **Tier**: happy-dom
- **Specs**: `features/todo-management.feature` — 34 scenarios; `features/servable-page.feature` — 1 scenario
- **Dependencies added**: `todomvc-common`, `todomvc-app-css` (npm)
- **Files created**: `index.html` (from template), `css/app.css` (empty override)

## Voyage 2 — Browser history navigation

- **Fix**: Removed `e.preventDefault()` from filter click handler so clicking a filter link updates the hash and pushes a history entry; `hashchange` listener already calls `setFilter()`.
- **New scenarios**: 2 browser-history scenarios added to `todo-management.feature`
- **Step defs**: `browser navigates back` and `browser navigates forward` added
- **Next**: dispatch QM; tree has uncommitted work