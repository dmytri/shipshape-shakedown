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
npm install --save-dev @cucumber/cucumber >/dev/null 2>&1
npx cucumber-js >/dev/null 2>&1 || { echo "FIXTURE NOT GREEN"; npx cucumber-js | tail -5; exit 1; }
rm -f logs/runs.log
git init -q
git config user.name "Sim Operator"
git config user.email "sim@example.test"
git add -A
git commit -qm "tidewatch: tide prediction baseline"
echo "scaffolded: $TARGET at $(git rev-parse --short HEAD), suite green"
