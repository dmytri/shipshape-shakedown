> STOP. Captain's notes: non-binding. Captain writes, Captain trims. Anyone else: close this file now.

# Captain Notes

Binding behaviour lives in `.feature` specs and referenced `assets/**`. History lives in git. These notes carry only what the next cycle needs.

## Current Voyage

Building a TodoMVC app following `assets/app-spec.md` with vanilla JavaScript and localStorage persistence.

### Stack
- Language: JavaScript (vanilla, no preprocessors)
- Runtime: none (browser-based)
- Package manager: npm
- Test runner: Cucumber with happy-dom
- Persistence: localStorage

### Artifacts Created
- `RIGGING.md` - Minimal rigging with 5 required values
- `features/todo-management.feature` - Comprehensive scenarios covering:
  - Core todo management (add, toggle, edit, delete)
  - Mark all as complete behavior
  - Todo count and pluralization
  - Clear completed button
  - Persistence to localStorage
  - Routing (all/active/completed filters)
  - Initial state behavior
- `watchbill.json` - 4 watch groups for QM targets:
  - todo-management-core (19 scenarios)
  - persistence (2 scenarios)
  - routing (6 scenarios)
  - initial-state (2 scenarios)

### Next Steps
1. QM should verify scenarios and provide step definitions
2. Crew implements production code in `js/app.js`
3. HTML template at `assets/app-template.index.html` should be copied to `index.html`
4. CSS from todomvc-app-css should be installed

### Key Requirements from Spec
- Use base markup from template without comments
- Double quotes in HTML, single quotes in JS/CSS
- Use constant for keyCode (ENTER_KEY = 13)
- Trim input before creating todos
- Editing saves on blur and Enter, cancels on Escape
- Empty edit destroys todo
- localStorage key format: `todos-vanillajs`
- Filter persistence on reload
- Routes: #/, #/active, #/completed

### Assets Referenced
- `assets/app-spec.md` - Product specification
- `assets/app-template.index.html` - Base HTML template