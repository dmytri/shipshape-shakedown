#!/bin/sh
# Capture the raw SubagentStop payload the runtime actually sends, then exit 0.
#
# Why this exists: guard-silence is equally consistent with "the guard ran and
# correctly passed" and "the guard never ran at all". The whole 0.13.49 fix rests
# on two payload field names - agent_transcript_path and background_tasks -
# established once by a throwaway hook last session and never re-confirmed. If
# either name is wrong, background-custody.sh silently does nothing live while
# every check the harness has still reads correct. That is the dangling-installPath
# failure shape, and it is why this run does not accept replay evidence alone.
#
# Never blocks, never denies, adds no doctrine. Harness instrumentation only.
OUT="${BGACT_CAPTURE:-/tmp/bgact-payloads.jsonl}"
payload=$(cat)
printf '%s\n' "$payload" >> "$OUT"
exit 0
