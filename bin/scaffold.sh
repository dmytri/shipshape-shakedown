#!/usr/bin/env bash
# Scaffold an instrumented toy project for a Shipshape shakedown.
# Usage: scaffold.sh <target-dir>
# Creates the tidewatch fixture, installs cucumber, verifies green, makes the baseline commit.
set -euo pipefail
TARGET="${1:?usage: scaffold.sh <target-dir>}"
HERE="$(cd "$(dirname "$0")/.." && pwd)"
mkdir -p "$TARGET"
cp -r "$HERE/fixtures/tidewatch/." "$TARGET/"
mv "$TARGET/gitignore" "$TARGET/.gitignore"
cd "$TARGET"
mkdir -p logs
# Disk-robust: symlink a shared cucumber node_modules when the caller provides one
# (EVAL_SHARED_NM, set by eval-batch.sh), so N legs don't each npm-install ~50MB.
# Falls back to a real install when unset (the normal shakedown path).
if [ -n "${EVAL_SHARED_NM:-}" ] && [ -d "$EVAL_SHARED_NM/@cucumber" ]; then
  # Hardlink copy (same fs): shares data blocks so disk cost is ~directory
  # entries, but behaves as a real node_modules (npx/cucumber resolve normally,
  # unlike a symlinked node_modules).
  cp -al "$EVAL_SHARED_NM" node_modules
else
  npm install --save-dev @cucumber/cucumber >/dev/null 2>&1
fi
npx cucumber-js >/dev/null 2>&1 || { echo "FIXTURE NOT GREEN"; npx cucumber-js | tail -5; exit 1; }
rm -rf "$(dirname "$(pwd)")/.instrument/$(basename "$(pwd)")"
git init -q
git config user.name "Sim Operator"
git config user.email "sim@example.test"
git add -A
git commit -qm "tidewatch: tide prediction baseline"
echo "scaffolded: $TARGET at $(git rev-parse --short HEAD), suite green"
