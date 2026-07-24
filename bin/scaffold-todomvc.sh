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
MD

cat > package.json <<'JSON'
{
  "name": "todomvc-shakedown",
  "version": "0.1.0",
  "private": true,
  "scripts": { "test": "cucumber-js" },
  "devDependencies": { "@cucumber/cucumber": "*", "happy-dom": "*" }
}
JSON

printf 'node_modules\n' > .gitignore

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
