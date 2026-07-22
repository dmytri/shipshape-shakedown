#!/usr/bin/env bash
# Assert that probe fixtures still conform to INSTALLED doctrine.
#
# The gap this closes (dk ruled 2026-07-22): fixtures are pinned to the doctrine
# version they were written against, and nothing re-checks them when doctrine
# moves. Three confirmed instances of a fixture drifting out from under a probe
# WHILE THE PROBE KEPT REPORTING SUCCESS - tw3's corrupted foul-catch, the
# double-faulted plank-join example whose probe 0.13.34's commit message cites as
# evidence, and a fixture command doctrine's own hook denies. Every one was caught
# by a role agent or a state assertion, never by the harness.
#
# The oracle for command legality is doctrine's OWN hook, fed a synthetic payload.
# Reimplementing its rules here would just be a second thing to drift.
#
# Usage: fixture-check.sh [built-state-dir]
#   With no argument, runs the static checks only (checks 1 and 2).
#   With a bin/probe-states.sh target dir, also runs the plank join (check 3).
#
# Exit non-zero when a fixture must not be used. Step 0 of any probe, after
# bin/preflight.sh.
set -uo pipefail

HERE="$(cd "$(dirname "$0")/.." && pwd)"
FX="$HERE/fixtures"
TARGET="${1:-}"
FAIL=0

ok()   { printf 'OK             %s\n' "$1"; }
bad()  { printf 'FAIL           %s\n' "$1"; FAIL=1; }
note() { printf '               %s\n' "$1"; }

# The installed plugin, resolved the same way bin/preflight.sh resolves it - a
# dangling installPath is a live failure mode and parity passing does not prove
# the plugin loaded.
REG="$HOME/.claude/plugins/installed_plugins.json"
PLUGIN=$(jq -r '.plugins["shipshape@dmytri-shipshape"][0].installPath // empty' "$REG" 2>/dev/null)
if [ -z "$PLUGIN" ] || [ ! -d "$PLUGIN/hooks/scripts" ]; then
  echo "FAIL           cannot resolve installed plugin hooks; run bin/preflight.sh" >&2
  exit 1
fi

echo "=== fixture check (against $PLUGIN) ==="

# --- 1. No fixture configures a command doctrine's own hooks deny -------------
# fixtures/probe-states/RIGGING.md:27 once named `grep -rn "@planks" src`, which
# bash-custody.sh denies path-blind by design, silently taxing every
# plank-inventory leg one invocation for as long as the grep rule had shipped.
CUSTODY="$PLUGIN/hooks/scripts/bash-custody.sh"
cmds_checked=0
while IFS= read -r line; do
  # `- name: `cmd`` in a RIGGING.md Commands section. `none` is not a command.
  cmd=$(printf '%s' "$line" | sed -n 's/^- [a-z-]*: `\(.*\)`$/\1/p')
  [ -z "$cmd" ] && continue
  [ "$cmd" = "none" ] && continue
  # Every role that runs fitted commands is under command custody.
  for role in qm crew boatswain shipwright; do
    payload=$(jq -cn --arg c "$cmd" --arg r "shipshape:$role" \
      '{tool_name:"Bash",agent_type:$r,tool_input:{command:$c}}')
    if msg=$(printf '%s' "$payload" | sh "$CUSTODY" 2>&1 >/dev/null); then :; else
      bad "RIGGING.md command denied for $role: $cmd"
      note "  hook says: $msg"
    fi
  done
  cmds_checked=$((cmds_checked + 1))
done < <(grep -h '^- [a-z-]*: `' "$FX"/probe-states/RIGGING.md "$FX"/tidewatch/RIGGING.md 2>/dev/null)
[ "$FAIL" -eq 0 ] && ok "$cmds_checked fitted commands legal under command custody"

# --- 2. No operator prose inside a fixture ------------------------------------
# 3 of 4 legs on the last probe correctly stripped a fixture comment that cited
# CAPTAIN.md and carried dated operator rationale - a Captain/QM bulkhead
# violation the operator introduced one hour after writing up the meta-finding
# that warns about it. A fixture carries the technical fact only.
#
# COMMENT LINES IN SOURCE ONLY. The first version of this check scanned every
# line of every fixture file for a date and failed on the tide timestamps that
# ARE the fixture's domain data - a check that fires on correct fixtures is worse
# than no check, so the scope is the place the real contamination lived: prose a
# role reads as instruction. Gherkin and JSON data are excluded; harness identity
# is what leaks, not a date.
# The keyword test applies to the CONTENT ONLY, never the file:line prefix. The
# first version matched the prefix and failed every comment in the tree, because
# this repo's own path contains "shakedown" - the same shape of bug as the date
# regex above, caught the same way: by reading what it actually printed.
leak=0
while IFS= read -r hit; do
  bad "operator prose in fixture comment: $hit"
  leak=1
done < <(grep -rn -E '^[[:space:]]*(//|/\*|\*)' "$FX/probe-states" "$FX/tidewatch" \
           --include='*.js' 2>/dev/null \
         | awk -F: 'BEGIN{IGNORECASE=1}
             { content = ""; for (i = 3; i <= NF; i++) content = content (i>3 ? ":" : "") $i }
             content ~ /CAPTAIN\.md|METRICS\.md|shakedown|probe arm|the operator|doctrine/ { print }')
[ "$leak" -eq 0 ] && ok "no operator prose in fixture source comments"

# --- 3. Plank / step-usage join ----------------------------------------------
# tw3's corrupted verdict: 8 planks carried the pre-0.13.34 keyword-bearing form,
# which 0.13.34 made a non-matching string, so they were malformed BY
# CONSTRUCTION on every 0.13.34+ run while the probe reported success.
#
# tw6 NO-MATCHes BY DESIGN - its state is "4 undefined scenarios; QM authors
# verification", so no pattern is reported yet and its planks are
# correct-by-construction for step definitions that do not exist. Expected
# outcomes are declared per state, so "matches" is not blindly the pass.
#
# DECLARED defects come from fixtures/probe-states/expected-defects.json, which
# already specified this check's contract and was never implemented. Its rule is
# BIDIRECTIONAL and sharper than a match/no-match table: an UNDECLARED no-match is
# drift (the fixture rotted), and a DECLARED no-match that now MATCHES is a probe
# that silently lost an arm. That second direction is the tw4 case - a uniform
# plank repair would have made the beyond-diff malformed plank well-formed and
# left "zero over-correction" as a marker that could never fail.
#
# KNOWN LIMITATION, stated because this harness's failures are silent ones: the
# bound set comes from `step-usage`, and cucumber's usage-json omits a step
# definition that no scenario exercises. So a declared no-match can heal by
# gaining an UNUSED definition and this check will not see it. Verified, not
# assumed - a `{date}` definition was added to tw4 and did not appear in
# usage-json. Narrow (an unused definition joins the plank to nothing a run
# touches) and the same class the fixture's own RIGGING.md already declares for
# plank-inventory: a text search cannot verify form or placement.
REGISTRY="$FX/probe-states/expected-defects.json"
if [ -n "$TARGET" ]; then
  [ -f "$REGISTRY" ] || { bad "no expected-defects.json; declared defects unknowable"; }
  for dir in "$TARGET"/tidewatch*; do
    [ -d "$dir" ] || continue
    tw=$(basename "$dir")
    planks=$(grep -rho '@planks("[^"]*")' "$dir/src" 2>/dev/null \
             | sed 's/@planks("//; s/")$//' | sort -u)
    [ -z "$planks" ] && continue   # a state with no planks is not fitted; not this check's business
    steps=$( (cd "$dir" && npx cucumber-js --dry-run --format usage-json \
             --tags "not @captain and not @shipwright" 2>/dev/null) \
             | jq -r '.[].pattern' 2>/dev/null | sort -u)
    [ -z "$steps" ] && { bad "$tw: step-usage reported no patterns"; continue; }

    declared=$(jq -r --arg t "$tw" \
      '.trees[$t]//[] | map(select(.kind=="plank-no-match") | .target) | .[]' \
      "$REGISTRY" 2>/dev/null | sort -u)
    unbound=$(comm -23 <(printf '%s\n' "$planks") <(printf '%s\n' "$steps"))

    # Direction 1: unbound but never declared -> the fixture rotted under the probe.
    undeclared=$(comm -23 <(printf '%s\n' "$unbound" | grep -v '^$' | sort -u) \
                          <(printf '%s\n' "$declared" | grep -v '^$' | sort -u))
    # Direction 2: a declared no-match that is no longer an unbound plank -> the
    # probe lost an arm. Tested against BOTH routes it can heal by, because the
    # first version of this test only caught one and passed the tw4 case it exists
    # for: the step definition can appear (the plank now binds), OR the plank text
    # itself can be repaired away, in which case the declared string binds nothing
    # and matching against bound patterns sees nothing wrong. What the registry
    # asserts is that this exact plank stays MALFORMED AND PRESENT, so the test is
    # membership in the unbound set, not membership in the bound set.
    healed=$(comm -23 <(printf '%s\n' "$declared" | grep -v '^$' | sort -u) \
                      <(printf '%s\n' "$unbound" | grep -v '^$' | sort -u))

    if [ -n "$undeclared" ]; then
      bad "$tw: UNDECLARED plank no-match - fixture drift:"
      printf '%s\n' "$undeclared" | sed 's/^/                 /'
    fi
    if [ -n "$healed" ]; then
      bad "$tw: DECLARED no-match is no longer unbound - this probe arm is dead:"
      printf '%s\n' "$healed" | sed 's/^/                 /'
      note "  a marker that cannot fail is not a marker; see expected-defects.json"
    fi
    if [ -z "$undeclared" ] && [ -z "$healed" ]; then
      nd=$(printf '%s\n' "$declared" | grep -c '[^[:space:]]')
      ok "$tw plank join conforms ($(printf '%s\n' "$planks" | wc -l) planks, $nd declared no-match)"
    fi
  done
else
  note "plank join skipped - pass a built-state dir to run check 3"
fi

if [ "$FAIL" -eq 0 ]; then echo "=== clear ==="; else echo "=== FIXTURES NOT FIT ==="; fi
exit "$FAIL"
