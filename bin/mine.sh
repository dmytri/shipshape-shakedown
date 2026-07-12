#!/usr/bin/env bash
# Per-invocation audit of a subagent task transcript (Claude Code task JSONL).
# Usage: mine.sh <transcript.output> [legname]
# Columns: leg, invocation#, time, cache_read, output_tokens, tools(commands truncated)
# Summary line: invocations, total cache_read, total output, wall.
set -euo pipefail
F="${1:?usage: mine.sh <transcript.jsonl> [legname]}"
LEG="${2:-$(basename "$F" .output)}"
jq -rs --arg leg "$LEG" '
  [ .[] | select(.type=="assistant") ] | group_by(.message.id) | sort_by(.[0].timestamp)
  | to_entries | map(. as $e | {
      n: ($e.key+1),
      t: $e.value[0].timestamp[11:19],
      cr: ($e.value[0].message.usage.cache_read_input_tokens//0),
      out: ([$e.value[].message.usage.output_tokens//0]|max),
      tools: ([$e.value[].message.content[]? | select(.type=="tool_use")
               | if .name=="Bash" then "Bash:" + (.input.command | gsub("cd /[^ ]+ +&& +";"") | gsub("\n";" ") | .[0:70])
                 else .name + ":" + ((.input.file_path // "" | tostring) | split("/")[-1]) end]
              | join(" ||| "))
    })
  | (.[] | "\($leg)\t\(.n)\t\(.t)\t\(.cr)\t\(.out)\t\(.tools // "FINAL")"),
    "SUMMARY\t\($leg)\tinvocations=\(length)\tcache_read=\(map(.cr)|add)\tout=\(map(.out)|add)\twall=\(.[0].t) to \(.[-1].t)"
' "$F"
