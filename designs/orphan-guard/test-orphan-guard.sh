#!/usr/bin/env bash
# Replay test for the orphan-guard PROTOTYPE against REAL transcripts from
# the record, plus synthetic edge cases. Positive case = the only live
# reproduction of the orphan class in the last ~6 runs.
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"
GUARD="$HERE/orphan-guard.sh"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
pass=0; fail=0

run() { # name expected_exit transcript agent_type [stop_hook_active]
  local name="$1" want="$2" tr="$3" at="${4:-shipshape:qm}" sha="${5:-false}"
  local payload
  payload=$(printf '{"agent_type":"%s","transcript_path":"%s","stop_hook_active":%s}' "$at" "$tr" "$sha")
  local out; out=$(printf '%s' "$payload" | sh "$GUARD" 2>&1); local got=$?
  if [ "$got" = "$want" ]; then
    pass=$((pass+1)); printf 'PASS  %-46s exit=%s\n' "$name" "$got"
  else
    fail=$((fail+1)); printf 'FAIL  %-46s want=%s got=%s\n      %s\n' "$name" "$want" "$got" "$out"
  fi
}

P33=/home/exedev/.claude/projects/-home-exedev-shipshape-shakedown/f5ef97d4-5ead-4f48-9551-630a5ec962d6/subagents
P35=/home/exedev/.claude/projects/-home-exedev-shipshape-shakedown/998fa6ea-9f2b-4002-b2fa-695dce0f5a5b/subagents

# ---- REAL case 1: the 0.13.33 tw13 ORPHAN, truncated at its actual stop.
# The role backgrounded the broad sweep (b5zoyl7wi), ToolSearched for
# Monitor, never called it, ran `true`, and ended the turn. Operator
# rescued it 8m26s later. Truncate immediately before the rescue read.
ORPH="$P33/agent-a7ba07f4a27f9beaa.jsonl"
if [ -f "$ORPH" ]; then
  cut=$(grep -n 'b5zoyl7wi' "$ORPH" | sed -n '2p' | cut -d: -f1)
  head -n $((cut-1)) "$ORPH" > "$TMP/orphan.jsonl"
  run "REAL 0.13.33 tw13 orphan at its stop" 2 "$TMP/orphan.jsonl"
  # Full transcript (post-rescue) must NOT block: the output was read.
  run "REAL 0.13.33 tw13 after operator rescue" 0 "$ORPH"
else
  echo "SKIP  0.13.33 orphan transcript absent"
fi

# ---- REAL case 2: this session's clean tw13. Same probe, same state,
# 0.13.35. Backgrounded bpczcw513 and READ it in-turn.
CLEAN="$P35/agent-a26c0c7c289e5aa7b.jsonl"
[ -f "$CLEAN" ] && run "REAL 0.13.35 tw13 clean (consumed by Read)" 0 "$CLEAN" \
  || echo "SKIP  0.13.35 tw13 transcript absent"

# ---- REAL case 3: the plankfix Crew consumed its background output by
# `cat`, not Read, after the runtime blocked its `sleep 30; cat` chain.
CAT="$P35/agent-a5788e163de8427a6.jsonl"
[ -f "$CAT" ] && run "REAL 0.13.35 Crew (consumed by cat)" 0 "$CAT" \
  || echo "SKIP  plankfix Crew transcript absent"

# ---- REAL case 4: legs that never backgrounded anything must pass.
for leg in a3779803812ab5fa6 a7d42268e3e858140 a0dde102bdf97f9cd \
           a5f1f019e423b4ab4 a7760589dd61a830b a161f87ab089bd5c5; do
  [ -f "$P35/agent-$leg.jsonl" ] && run "REAL no-background leg ${leg:0:8}" 0 "$P35/agent-$leg.jsonl"
done

# ---- SYNTHETIC: an Agent child left live is NOT this fault. Its
# completion resumes the parent via task-notification (observed live,
# 0.13.35 tw13 resumed itself twice). Must NOT block.
cat > "$TMP/agentchild.jsonl" <<'EOF'
{"type":"assistant","message":{"content":[{"type":"tool_use","name":"Agent","input":{"prompt":"x"}}]}}
{"type":"user","message":{"content":[{"type":"tool_result","content":"Async agent launched successfully.\nagentId: a57c5da9166701090 (internal ID - do not mention to user.)\nThe agent is working in the background. You will be notified automatically when it completes."}]}}
EOF
run "SYNTH live Agent child (not the fault)" 0 "$TMP/agentchild.jsonl"

# ---- SYNTHETIC: re-entrancy guard.
run "SYNTH stop_hook_active short-circuits" 0 "${TMP}/orphan.jsonl" "shipshape:qm" "true"

# ---- SYNTHETIC: non-shipshape agent is out of scope.
run "SYNTH foreign agent_type ignored" 0 "${TMP}/orphan.jsonl" "general-purpose"

# ---- SYNTHETIC: missing/unreadable transcript fails open, never blocks.
run "SYNTH absent transcript fails open" 0 "$TMP/nope.jsonl"

# ---- SYNTHETIC: two backgrounds, only one consumed -> block.
cat > "$TMP/partial.jsonl" <<'EOF'
{"type":"user","message":{"content":[{"type":"tool_result","content":"moved to the background (ID: aaa111). Output is being written to: /t/tasks/aaa111.output"}]}}
{"type":"user","message":{"content":[{"type":"tool_result","content":"moved to the background (ID: bbb222). Output is being written to: /t/tasks/bbb222.output"}]}}
{"type":"assistant","message":{"content":[{"type":"tool_use","name":"Read","input":{"file_path":"/t/tasks/aaa111.output"}}]}}
EOF
run "SYNTH 2 backgrounded, 1 consumed -> block" 2 "$TMP/partial.jsonl"

echo
echo "pass=$pass fail=$fail"
[ "$fail" -eq 0 ]
