#!/usr/bin/env bash
# Canonical Shipshape deck-state hash (Wake policy, 0.13.8+).
# Usage: deckstate.sh [repo-dir]
set -euo pipefail
cd "${1:-.}"
GIT_INDEX_FILE="$(mktemp)" bash -c 'git read-tree HEAD && git add -A . && git write-tree'
