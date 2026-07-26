#!/usr/bin/env bash
# Scaffold the tidewatch fixture for a NAMED STACK, un-fitted-out (no RIGGING.md).
#
# The fitting-out claim under test is that Shipwright derives the project's methods AND their
# MECHANISM from the stack (dk, 2026-07-26). A single Node/Cucumber fixture cannot test that: every
# derivation would be the same derivation. Each stack here carries the same tidewatch domain, the
# same two scenarios, and its own native runner, type checker, linter, and coverage tool, so the
# derived commands and methods must genuinely differ.
#
# usage: scaffold-stack.sh <js|ts|py> <target-dir>
set -euo pipefail
STACK="${1:?usage: scaffold-stack.sh <js|ts|py> <target-dir>}"
TARGET="${2:?usage: scaffold-stack.sh <js|ts|py> <target-dir>}"
HERE="$(cd "$(dirname "$0")/.." && pwd)"
case "$STACK" in
  js) SRC="$HERE/fixtures/tidewatch";;
  ts) SRC="$HERE/fixtures/tidewatch-ts";;
  py) SRC="$HERE/fixtures/tidewatch-py";;
  *) echo "scaffold-stack.sh: unknown stack '$STACK' (js|ts|py)" >&2; exit 2;;
esac
[ -d "$SRC" ] || { echo "scaffold-stack.sh: fixture missing at $SRC" >&2; exit 2; }

mkdir -p "$TARGET"
cp -r "$SRC/." "$TARGET/"
cd "$TARGET"
[ -f gitignore ] && mv gitignore .gitignore

case "$STACK" in
  js|ts)
    # Same overlay contract as scaffold.sh: symlink the shared toolkit to prove the runner, then
    # leave an empty dir as the bwrap mountpoint the leg overlays.
    if [ -n "${EVAL_SHARED_NM:-}" ] && [ -d "$EVAL_SHARED_NM/@cucumber" ]; then
      ln -sfn "$EVAL_SHARED_NM" node_modules
      npx cucumber-js >/dev/null 2>&1 || { echo "SCAFFOLD($STACK): cucumber not green"; exit 1; }
      rm -f node_modules && mkdir node_modules
    else
      npm install >/dev/null 2>&1
      npx cucumber-js >/dev/null 2>&1 || { echo "SCAFFOLD($STACK): cucumber not green"; exit 1; }
    fi
    ;;
  py)
    # A venv is built HERE, at scaffold time and at the sim's own absolute path, because a venv
    # carries that path inside it and does not survive a copy. Network is available at scaffold
    # time; the leg itself then needs none for the suite.
    python3 -m venv .venv >/dev/null 2>&1
    ./.venv/bin/pip install -q --disable-pip-version-check -r requirements.txt >/dev/null 2>&1 \
      || { echo "SCAFFOLD(py): pip install failed"; exit 1; }
    ./.venv/bin/behave >/dev/null 2>&1 || { echo "SCAFFOLD(py): behave not green"; exit 1; }
    ;;
esac

git init -q
git config user.name "Sim Operator"
git config user.email "sim@example.test"
git add -A
git commit -qm "tidewatch ($STACK): baseline, suite green, not fitted out"
echo "scaffolded tidewatch-$STACK: $TARGET at $(git rev-parse --short HEAD), suite green, no RIGGING.md"
