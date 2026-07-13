#!/usr/bin/env bash
# Summarize a toy project's instrumented suite executions (features/support/runlog.js hook).
# Usage: runs.sh <project-dir> [skip-first-N]
# Prints total executing runs and a uniq -c of argv shapes after the skipped prefix.
# Fixture v2 sinks the log out-of-tree at <parent>/.instrument/<tree>/runs.log
# (roles wiped in-tree logs/ as scratch); pre-v2 trees fall back to logs/runs.log.
set -euo pipefail
D="${1:?usage: runs.sh <project-dir> [skip-first-N]}"
SKIP="${2:-0}"
D="$(cd "$D" && pwd)"
L="$(dirname "$D")/.instrument/$(basename "$D")/runs.log"
[ -f "$L" ] || L="$D/logs/runs.log"
[ -f "$L" ] || { echo "no runs.log"; exit 0; }
echo "total executing runs: $(wc -l < "$L")"
awk -v s="$SKIP" 'NR>s' "$L" | sed 's/.*"argv":\[//;s/\]}//' | sort | uniq -c | sort -rn
