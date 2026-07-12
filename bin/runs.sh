#!/usr/bin/env bash
# Summarize a toy project's instrumented suite executions (features/support/runlog.js hook).
# Usage: runs.sh <project-dir> [skip-first-N]
# Prints total executing runs and a uniq -c of argv shapes after the skipped prefix.
set -euo pipefail
D="${1:?usage: runs.sh <project-dir> [skip-first-N]}"
SKIP="${2:-0}"
L="$D/logs/runs.log"
[ -f "$L" ] || { echo "no runs.log"; exit 0; }
echo "total executing runs: $(wc -l < "$L")"
awk -v s="$SKIP" 'NR>s' "$L" | sed 's/.*"argv":\[//;s/\]}//' | sort | uniq -c | sort -rn
