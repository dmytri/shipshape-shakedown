#!/usr/bin/env bash
# Pilot preflight. Run BEFORE scaffolding anything; ordered step 0 of scenarios/pilot.md.
#
# Exists because two pilots died to conditions this script checks in one second:
#   #6 (2026-07-21) - root filesystem hit 100% mid-run, twice destroying the
#      project tree. Cause was ~5.6GB of scratchpad dirs left by PRIOR sessions
#      plus an unsparse oracle clone. Run filed INCOMPLETE.
#   #7 (2026-07-21) - graded against an UNPATCHED oracle under a non-mandated
#      framework name. Manufactured three phantom failures, sent two false
#      findings, and cost an extra fix voyage. The patch step is documented in
#      fixtures/oracle/README.md and scenarios/pilot.md never referenced it.
#
# Both were obligations with no act. This is the act.
set -uo pipefail
HERE="$(cd "$(dirname "$0")/.." && pwd)"
fail=0; warn=0
say() { printf '%-14s %s\n' "$1" "$2"; }

echo "=== pilot preflight ==="

# --- disk: the #6 killer -----------------------------------------------------
avail_k=$(df -Pk / | awk 'NR==2{print $4}')
avail_g=$(awk -v k="$avail_k" 'BEGIN{printf "%.1f", k/1048576}')
if   [ "$avail_k" -lt 3145728 ]; then say FAIL "/ has ${avail_g}G free - need >=3G. Pilot #6 died at 0.1G."; fail=1
elif [ "$avail_k" -lt 6291456 ]; then say WARN "/ has ${avail_g}G free - tight; a pilot + oracle wants ~2G."; warn=1
else say OK "/ has ${avail_g}G free"; fi

# --- stale scratchpads: what actually filled the disk ------------------------
SCRATCH_ROOT="/tmp/claude-1000"
if [ -d "$SCRATCH_ROOT" ]; then
  total=$(du -sm "$SCRATCH_ROOT" 2>/dev/null | awk '{print $1}')
  n=$(find "$SCRATCH_ROOT" -maxdepth 3 -type d -name scratchpad 2>/dev/null | wc -l)
  if [ "${total:-0}" -gt 2048 ]; then
    say WARN "${total}M across ${n} scratchpad dir(s) - prior sessions accumulate; consider pruning"
    warn=1
  else
    say OK "${total:-0}M across ${n} scratchpad dir(s)"
  fi
fi

# --- doctrine deck -----------------------------------------------------------
if [ -d "$HOME/shipshape" ]; then
  dirty=$(git -C "$HOME/shipshape" status --porcelain | wc -l)
  [ "$dirty" -eq 0 ] && say OK "~/shipshape clean" || { say FAIL "~/shipshape dirty ($dirty)"; fail=1; }
  git -C "$HOME/shipshape" fetch -q origin 2>/dev/null
  ahead=$(git -C "$HOME/shipshape" rev-list --count origin/main..HEAD 2>/dev/null || echo 0)
  [ "$ahead" -eq 0 ] && say OK "~/shipshape level with origin" || { say FAIL "~/shipshape ahead by $ahead - push first"; fail=1; }

  repo_v=$(sed -n 's/.*"version": "\([^"]*\)".*/\1/p' "$HOME/shipshape/.plugin/plugin.json" | head -1)
  inst_v=$(sed -n '/shipshape@dmytri-shipshape/,/}/s/.*"version": "\([^"]*\)".*/\1/p' "$HOME/.claude/plugins/installed_plugins.json 2>/dev/null" 2>/dev/null | head -1)
  [ -z "$inst_v" ] && inst_v=$(grep -A6 '"shipshape@dmytri-shipshape"' "$HOME/.claude/plugins/installed_plugins.json" 2>/dev/null | sed -n 's/.*"version": "\([^"]*\)".*/\1/p' | head -1)
  if [ "$repo_v" = "$inst_v" ]; then say OK "plugin $inst_v == repo $repo_v"
  else say FAIL "installed $inst_v != repo $repo_v - reinstall"; fail=1; fi

  # The registry can name a directory that was never created, and everything
  # else still reads correct: right version, right commit, right timestamp,
  # parity passes. Only the path is missing, so the plugin loads NOTHING - no
  # skills, no agents, no hooks - while the session looks installed. Live
  # 2026-07-21: an install wrote installPath .../shipshape/0.13.50 when the
  # content sat at .../shipshape/daf0443ae342; every shipshape:* agent type
  # and skill silently vanished, and the only visible symptom was their
  # absence from a registry nobody reads. A wave could run "on the installed
  # channel" serving nothing. Check the path, not just the manifest.
  inst_path=$(grep -A6 '"shipshape@dmytri-shipshape"' "$HOME/.claude/plugins/installed_plugins.json" 2>/dev/null | sed -n 's/.*"installPath": "\([^"]*\)".*/\1/p' | head -1)
  if [ -z "$inst_path" ]; then
    say FAIL "no installPath in the plugin registry - reinstall"; fail=1
  elif [ -d "$inst_path/skills" ] && [ -d "$inst_path/hooks" ]; then
    say OK "installPath resolves ($(basename "$inst_path"))"
  else
    say FAIL "installPath $inst_path is MISSING skills/ or hooks/ - the plugin loads nothing despite a correct-looking manifest. Reinstall: yes | npx plugins add dmytri/shipshape"; fail=1
  fi

  # session snapshot: plugin resolution pins at PROCESS start, not conversation
  inst_epoch=$(date -d "$(grep -A6 '"shipshape@dmytri-shipshape"' "$HOME/.claude/plugins/installed_plugins.json" 2>/dev/null | sed -n 's/.*"installedAt": "\([^"]*\)".*/\1/p' | head -1)" +%s 2>/dev/null || echo 0)
  # Walk up to the owning `claude` process - $PPID is this shell, whose start
  # time says nothing about when plugin resolution was snapshotted.
  p=$$; proc_epoch=0
  while [ "$p" -gt 1 ]; do
    case "$(ps -o comm= -p "$p" 2>/dev/null)" in
      *claude*) proc_epoch=$(date -d "$(ps -o lstart= -p "$p" 2>/dev/null)" +%s 2>/dev/null || echo 0); break ;;
    esac
    p=$(ps -o ppid= -p "$p" 2>/dev/null | tr -d ' '); [ -z "$p" ] && break
  done
  if [ "$inst_epoch" -gt 0 ] && [ "$proc_epoch" -gt 0 ] && [ "$inst_epoch" -gt "$proc_epoch" ]; then
    say FAIL "install POSTDATES this session - plugin snapshot is STALE (serves the old version to subagents). RESTART before dispatching any role."; fail=1
  else
    say OK "session snapshot postdates install"
  fi
fi

# --- the #7 killer: oracle contract ------------------------------------------
if [ -d "$HERE/fixtures/oracle" ]; then
  say OK "fixtures/oracle present"
  echo
  echo "  ORACLE CONTRACT - apply AFTER cloning, BEFORE the first grading run:"
  for p in "$HERE"/fixtures/oracle/*.patch; do
    echo "    git -C <oracle-clone> apply $p"
  done
  echo "    serve the build at  examples/shakedown/"
  echo "    grade with          --env framework=shakedown"
  echo "  (pilot #7 skipped this and manufactured 3 phantom failures)"
  echo
else
  say FAIL "fixtures/oracle missing"; fail=1
fi

echo "=== $( [ $fail -ne 0 ] && echo "BLOCKED - fix the FAILs above" || { [ $warn -ne 0 ] && echo "clear, with warnings" || echo "clear"; } ) ==="
exit $fail
