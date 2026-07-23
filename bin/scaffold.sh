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
# node_modules for the eval path (EVAL_SHARED_NM set by eval-batch.sh): the leg gets
# an ISOLATED node_modules at runtime via a bwrap overlay — the shared toolkit as a
# READ-ONLY base with a per-leg tmpfs writable upper (eval-leg.sh, bwrap 0.11.2). So a
# leg `npm install`s whatever it wants with ZERO shared corruption and ZERO persistent
# disk (one 138MB base total, not per-leg; the hardlink `cp -al` version corrupted the
# shared store on any install, proven 2026-07-23). Here we only need a green baseline
# check + an empty mountpoint: symlink to shared for the check (read-only; npx resolves
# through it), then leave an empty node_modules dir for --tmp-overlay to mount onto.
if [ -n "${EVAL_SHARED_NM:-}" ] && [ -d "$EVAL_SHARED_NM/@cucumber" ]; then
  ln -sfn "$EVAL_SHARED_NM" node_modules
  npx cucumber-js >/dev/null 2>&1 || { echo "FIXTURE NOT GREEN"; npx cucumber-js | tail -5; exit 1; }
  rm -f node_modules && mkdir node_modules
else
  npm install --save-dev @cucumber/cucumber >/dev/null 2>&1
  npx cucumber-js >/dev/null 2>&1 || { echo "FIXTURE NOT GREEN"; npx cucumber-js | tail -5; exit 1; }
fi
rm -rf "$(dirname "$(pwd)")/.instrument/$(basename "$(pwd)")"
git init -q
git config user.name "Sim Operator"
git config user.email "sim@example.test"
git add -A
git commit -qm "tidewatch: tide prediction baseline"
echo "scaffolded: $TARGET at $(git rev-parse --short HEAD), suite green"
