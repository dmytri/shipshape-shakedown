#!/usr/bin/env bash
# Scaffold an (almost) empty TodoMVC project for a NEW-way pilot.
# Usage: scaffold-todomvc.sh <target-dir>
#
# Sibling of scaffold.sh (tidewatch), but for the acceptance-tier TodoMVC pilot
# graded by the upstream Cypress oracle. Per scenarios/pilot.md the project starts
# empty and the roles build the whole app from the vendored spec + template.
#
# DEVIATION from the pure empty-project pilot, deliberate for an AUTONOMOUS single
# pi run (no operator in the loop to resolve a framework/runner blocker mid-voyage):
# a minimal package.json names cucumber as the runner and the shared toolkit carries
# cucumber + happy-dom (the DOM tier the prior pilots used), so QM/Crew can author and
# run a DOM-level suite without blocking on a dependency decision. The app itself —
# index.html, js/, css/, the scenarios — is entirely the roles' to build.
set -euo pipefail
TARGET="${1:?usage: scaffold-todomvc.sh <target-dir>}"
HERE="$(cd "$(dirname "$0")/.." && pwd)"
mkdir -p "$TARGET/assets"
cd "$TARGET"

# The two vendored Captain ASSETS — the ONLY external material that enters the project
# (oracle quarantine, scenarios/pilot.md). Spec + the common markup template.
cp "$HERE/fixtures/todomvc/app-spec.md" assets/app-spec.md
cp "$HERE/fixtures/todomvc/app-template.index.html" assets/app-template.index.html

cat > README.md <<'MD'
# TodoMVC (shakedown build)

A TodoMVC app to be built following `assets/app-spec.md`, using
`assets/app-template.index.html` as the base markup. Vanilla JS, no preprocessors.
The test runner is Cucumber (see package.json); write DOM-level scenarios under
`features/` and step definitions under `features/support/`.

Verification support ships with the project: `features/support/world.js` loads the REAL
`index.html` and `js/app.js` into a happy-dom window before every scenario, and exposes
`this.document` / `this.window`. Drive the app through those; do not build a DOM by hand.
MD

# The harness contract, stated where a reader finds it (2026-08-02). world.js hard-codes the load
# paths -- index.html and js/app.js at the project root -- and NOTHING in the fixture said so, so
# every Captain in 15 fit-out cells reverse-engineered the harness source to learn it. The two
# most expensive flash cells were the two that spent the most turns doing it, and it is why
# `implementation` came out `src` in one arm and `js` in another: the fact was discoverable only
# by reading verification support. A real project's harness documents where the app lives; this
# is that documentation, not a hint -- it is the fitting-out INPUT the layout should be derived
# from.
cat > AGENTS.md <<'MD'
# Project agent rules

## Harness contract

The verification harness (`features/support/world.js`) loads the page at `index.html` and the
application at `js/app.js`, both at the project root, and executes the application source itself.
Production code belongs in `js/`. Stylesheets the page links belong in `css/`.

Crew writes the application. Captain and Shipwright never write production code: this section
says where the application lives so the rigging can name it, not that the reader should create
it.
MD

cat > package.json <<'JSON'
{
  "name": "todomvc-shakedown",
  "version": "0.1.0",
  "private": true,
  "scripts": { "test": "cucumber-js" },
  "devDependencies": {
    "@cucumber/cucumber": "*",
    "happy-dom": "*",
    "gplint": "*",
    "jsdoc": "*",
    "c8": "*",
    "@biomejs/biome": "*",
    "knip": "*",
    "@dk/yoink": "*"
  }
}
JSON

printf 'node_modules\n' > .gitignore

# VERIFICATION SUPPORT — the fixture's own harness, shipped because its ABSENCE was defect 6
# (2026-07-27, P5-cand-flash). With no harness, the app-loading contract fell to whichever role
# wrote steps first; that wave's steps built their own DOM (`new Window(); body.innerHTML = html`),
# so its suite ran 19/21 GREEN over an EMPTY js/ while the oracle read 0/29 for twelve voyages.
# Every doctrine obligation was discharged correctly over a product that was one boolean — the
# tier let conformance and correctness decouple. This harness removes that possibility by
# construction: every scenario runs against the REAL index.html with the REAL js/app.js executed,
# and a missing or broken artifact FAILS in the roles' own tier, where the correction loop can see
# it. Tooling belongs in the fixture (dk, 2026-07-27); the artifacts roles must author do not.
mkdir -p features/support
cat > features/support/world.js <<'JS'
const fs = require('node:fs');
const path = require('node:path');
const { setWorldConstructor, Before, After } = require('@cucumber/cucumber');
const { Window } = require('happy-dom');

const ROOT = path.resolve(__dirname, '..', '..');

class AppWorld {
  // Load the REAL page and the REAL app. A missing artifact is a loud failure here, not a
  // silently-green suite: the executable tier must exercise the production artifact.
  loadApp() {
    const indexPath = path.join(ROOT, 'index.html');
    const appPath = path.join(ROOT, 'js', 'app.js');
    if (!fs.existsSync(indexPath))
      throw new Error(`verification support: ${indexPath} does not exist — the app has no page to load`);
    if (!fs.existsSync(appPath))
      throw new Error(`verification support: ${appPath} does not exist — the app has no code to run`);
    const appSource = fs.readFileSync(appPath, 'utf8');
    if (appSource.trim().length === 0)
      throw new Error(`verification support: ${appPath} is empty — there is no application to verify`);

    // disableJavaScriptFileLoading: the harness executes app.js itself as inline source, and a
    // real <script src> under happy-dom attempts a network fetch (ECONNREFUSED, pilot 0.13.64).
    this.window = new Window({
      url: 'http://localhost/',
      settings: { disableJavaScriptFileLoading: true },
    });
    this.document = this.window.document;

    // The app must EXECUTE, not merely be present. Two things were measured 2026-07-28 and both
    // bit an earlier version of this harness:
    //   1. happy-dom does NOT run scripts the parser sees — neither an appended <script> with
    //      textContent nor one inlined into document.write(). window.eval() DOES run them. An
    //      earlier harness looked green while app.js never ran, because its only assertion
    //      checked that the PAGE had loaded. A weak test hid a broken loader.
    //   2. DOMContentLoaded never fires from write()/close(), so an app that defers its init to
    //      DOMContentLoaded or window.load — the common TodoMVC shape — would never initialise
    //      and the harness would fail CORRECT code. The lifecycle events are dispatched here.
    // disableJavaScriptFileLoading stops the page's own src tag attempting a network fetch
    // (ECONNREFUSED under happy-dom, pilot 0.13.64).
    this.document.write(fs.readFileSync(indexPath, 'utf8'));
    this.document.close();
    this.window.eval(appSource);
    this.document.dispatchEvent(new this.window.Event('DOMContentLoaded', { bubbles: true }));
    this.window.dispatchEvent(new this.window.Event('load'));

    // ROUTING. happy-dom updates location.hash but NEVER fires hashchange — measured
    // 2026-07-28, both by assignment and by clicking an in-page anchor. A TodoMVC router
    // listens for hashchange, so without this the filter/back-button behaviour is
    // UNREACHABLE in this tier: one wave spent seven correction voyages implementing filter
    // links that nothing could ever drive, stuck at 22/29 the whole way. Route the two ways a
    // real browser changes the hash, so routing is exercisable rather than merely present.
    const w = this.window;
    this.document.addEventListener('click', (e) => {
      const a = e.target && e.target.closest ? e.target.closest('a[href^="#"]') : null;
      if (!a) return;
      const next = a.getAttribute('href');
      if (w.location.hash !== next) { w.location.hash = next; w.dispatchEvent(new w.Event('hashchange')); }
    }, true);
    return this.document;
  }

  // Drive the router the way a user's address bar does.
  navigate(hash) {
    if (!this.window) throw new Error('verification support: navigate() before the app was loaded');
    if (this.window.location.hash === hash) return;
    this.window.location.hash = hash;
    this.window.dispatchEvent(new this.window.Event('hashchange'));
  }

  get localStorage() { return this.window.localStorage; }

  // A happy-dom Window holds timers, observers and native buffers; an undisposed one per
  // scenario grows without bound. Measured 2026-07-28: a wave whose own world.js never
  // disposed reached 13.6G RSS across ~45 scenarios and was OOM-killed by the kernel, which
  // ended the suite with a bare "Killed" and no summary line. NODE_OPTIONS
  // --max-old-space-size does NOT prevent this: the growth is outside V8's old space, so the
  // cap bounds the JS heap while the process still takes the box down. Disposal is the fix.
  async disposeApp() {
    const w = this.window;
    if (!w) return;
    this.window = undefined;
    this.document = undefined;
    if (w.happyDOM && typeof w.happyDOM.close === 'function') { await w.happyDOM.close(); return; }
    if (w.happyDOM && typeof w.happyDOM.abort === 'function') { await w.happyDOM.abort(); return; }
    if (typeof w.close === 'function') w.close();
  }
}

setWorldConstructor(AppWorld);

// Every scenario gets the real app. No scenario can pass without one.
Before(function () { this.loadApp(); });
// ...and every scenario gives it back.
After(async function () { await this.disposeApp(); });
JS

# OPTIONAL vendored rigging (methods-candidate A/B, 2026-07-26). Normally the roles derive
# RIGGING.md themselves on the greenfield fast path, and its content then varies per draw —
# which is exactly the variance a controlled composite-method test cannot carry. RIGGING_TEMPLATE
# fits the sim out with a fixed rigging so the two arms differ ONLY in the `## Methods` section.
# Unset = the original behaviour (roles derive it), so every prior pilot path is unchanged.
if [ -n "${RIGGING_TEMPLATE:-}" ]; then
  [ -f "$RIGGING_TEMPLATE" ] || { echo "SCAFFOLD: RIGGING_TEMPLATE not found: $RIGGING_TEMPLATE"; exit 1; }
  cp "$RIGGING_TEMPLATE" RIGGING.md
  # A registered rigging invokes task-runner entries, so the entries and the tool configs they need
  # ship with it: a method whose entry or config is missing fails on that, not on the code.
  if grep -q 'npm run ss:' RIGGING.md; then
    python3 - package.json "$HERE/assets/methods/todomvc.json" <<'PYX'
import json, sys
pkg = json.load(open(sys.argv[1])); pkg.setdefault("scripts", {}).update(json.load(open(sys.argv[2])))
json.dump(pkg, open(sys.argv[1], "w"), indent=2)
PYX
    mkdir -p .shipshape
    cp "$HERE/assets/methods/planks-typescript.yml" .shipshape/planks.yml
    sed -i 's/language: typescript/language: javascript/' .shipshape/planks.yml
    cp "$HERE/assets/gplintrc-default.json" .gplintrc
    printf '{\n  "files": { "includes": ["js/**", "features/**"] },\n  "linter": { "enabled": true }\n}\n' > biome.json
  fi
  echo "scaffold-todomvc: fitted out with vendored rigging $(basename "$RIGGING_TEMPLATE")"
fi

# node_modules for the eval path: same overlay contract as scaffold.sh. Symlink the
# shared toolkit for the green check, then leave an empty dir as the bwrap mountpoint.
if [ -n "${EVAL_SHARED_NM:-}" ] && [ -d "$EVAL_SHARED_NM/@cucumber" ]; then
  ln -sfn "$EVAL_SHARED_NM" node_modules
  # No features yet: cucumber exits 0 with "0 scenarios". That is the green baseline.
  npx cucumber-js >/dev/null 2>&1 || { echo "SCAFFOLD: cucumber not runnable"; exit 1; }
  [ -e "$EVAL_SHARED_NM/happy-dom" ] || echo "scaffold-todomvc: WARN happy-dom missing from shared toolkit" >&2
  rm -f node_modules && mkdir node_modules
else
  npm install --save-dev @cucumber/cucumber happy-dom >/dev/null 2>&1
  npx cucumber-js >/dev/null 2>&1 || { echo "SCAFFOLD: cucumber not runnable"; exit 1; }
fi

git init -q
git config user.name "Sim Operator"
git config user.email "sim@example.test"
git add -A
git commit -qm "todomvc: empty project with spec + template assets"
echo "scaffolded TodoMVC: $TARGET at $(git rev-parse --short HEAD), runner green (0 scenarios)"
