#!/bin/sh
# PROTOTYPE — NOT SHIPPED. Design artifact for dk's ruling on the orphan class.
# Lives in the shakedown cockpit, NOT in ~/shipshape: doctrine gets committed
# only after a ruling.
#
# Shipshape background-work custody. SubagentStop guard.
#
# The fault: a role ends its turn while a backgrounded command's output has
# never been read. A background completion cannot resume a finished agent
# chain, so the turn deadlocks silently and only an operator can rescue it
# (pilot #2 2026-07-13; efficiency battery 0.13.33 tw13, 8m26s dead).
#
# This guard blocks the STOP, not the command. It denies no command and so
# breaks no legitimate command, which is the failure mode a PreToolUse
# wait-class deny was warned for (dk's whack-a-mole disposition 2026-07-15,
# pilot-#3-proven). It also fires on the observed fault shape, which that
# deny would not: the 0.13.33 reproduction ran NO wait command at all — it
# ToolSearched for Monitor, never called it, ran `true`, and stopped.
#
# Role identity: the runtime names the finishing subagent as agent_type.
# The main-loop Stop event carries none, so the operator seat is out of
# reach here, as with planks-check.sh.

payload=$(cat)

# Re-entrancy: a blocked stop re-enters this hook. Never block twice.
case "$payload" in
  *'"stop_hook_active":true'*|*'"stop_hook_active": true'*) exit 0 ;;
esac

role=$(printf '%s' "$payload" | sed -n 's/.*"agent_type":[[:space:]]*"shipshape:\([a-z]*\)".*/\1/p')
[ -z "$role" ] && exit 0

transcript=$(printf '%s' "$payload" | sed -n 's/.*"transcript_path":[[:space:]]*"\([^"]*\)".*/\1/p')
[ -n "$transcript" ] && [ -f "$transcript" ] || exit 0

# One JSONL event per line, so line order is event order and no JSON parse
# is needed: the task id is a distinctive literal token.
#
# A launch line is a tool_result announcing that a command went to the
# background; it names the output file as tasks/<id>.output. An Agent
# spawn is NOT a launch — its result carries "agentId:", never a task
# output path — because an Agent child's completion DOES resume its
# parent through the task-notification, so a turn ending on a live Agent
# child self-heals (observed 2026-07-19 tw13) and is not this fault.
#
# Consumption is any later line naming that id: a Read of the output
# file, a cat/tail of it, or the completion notification itself.
unconsumed=$(awk '
  /moved to the background|running in background|is being written to/ {
    s = $0
    while (match(s, /tasks\/[A-Za-z0-9_-]+\.output/)) {
      tok = substr(s, RSTART + 6, RLENGTH - 13)
      if (!(tok in launched)) { launched[tok] = NR }
      s = substr(s, RSTART + RLENGTH)
    }
    next
  }
  {
    for (tok in launched) {
      if (launched[tok] < NR && index($0, tok)) delete launched[tok]
    }
  }
  END {
    for (tok in launched) printf "%s ", tok
  }
' "$transcript")

if [ -n "$unconsumed" ]; then
  echo "Shipshape background custody: this turn backgrounded work whose output was never read (task$(printf '%s' "$unconsumed" | tr -s ' ' | sed 's/ $//' | sed 's/^/ /')). A background completion cannot resume a finished turn, so ending here deadlocks it silently. Read the output file to its summary line, then end the turn. Wait on output files, never on process names." >&2
  exit 2
fi

exit 0
