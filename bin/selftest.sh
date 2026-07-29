#!/usr/bin/env bash
# Prove the harness before spending a pilot on it. No model calls, no credits.
#
# Every wasted run this session came from a harness fault that only surfaced mid-pilot, hours
# and dollars in: a budget that reached one model, a self-suite blind to specs/, a fit-out whose
# revert destroyed RIGGING.md, a grader that stripped the CSS the page links, an unmeasured
# grade recorded as 0/29. Each was findable in seconds from a fixture — nobody looked, because
# there was nothing to look with. This is that thing.
#
# usage: bin/selftest.sh          (exit 0 = safe to launch, non-zero = do not run a pilot)
set -uo pipefail
HERE="$(cd "$(dirname "$0")/.." && pwd)"
T="${TMPDIR:-/tmp}/shipshape-selftest.$$"
NM="$HERE/.eval-scratch/.shared-nm/node_modules"
pass=0; fail=0
ok(){ printf "  \033[32mPASS\033[0m %s\n" "$1"; pass=$((pass+1)); }
no(){ printf "  \033[31mFAIL\033[0m %s — %s\n" "$1" "${2:-}"; fail=$((fail+1)); }
mkdir -p "$T"; trap 'rm -rf "$T"' EXIT

echo "=== fixture ==="
if bash "$HERE/bin/scaffold-todomvc.sh" "$T/sim" >"$T/scaffold.log" 2>&1; then ok "scaffold runs"; else no "scaffold runs" "see $T/scaffold.log"; fi
[ -f "$T/sim/features/support/world.js" ] && ok "harness shipped" || no "harness shipped"
[ -f "$T/sim/assets/app-spec.md" ] && ok "spec shipped" || no "spec shipped"
[ ! -f "$T/sim/RIGGING.md" ] && ok "no RIGGING.md scaffolded (roles derive it)" || no "RIGGING.md must NOT be scaffolded"

echo "=== harness behaviour (the defect-6 guard) ==="
ln -sfn "$NM" "$T/sim/node_modules"
mkdir -p "$T/sim/features" "$T/sim/js"
cat > "$T/sim/features/smoke.feature" <<'EOF'
Feature: smoke
  Scenario: the app is loaded
    Then the page has a new-todo input
EOF
mkdir -p "$T/sim/features/step_definitions"
cat > "$T/sim/features/step_definitions/steps.js" <<'STEPS'
const { Then } = require('@cucumber/cucumber');
const assert = require('node:assert');
Then('the page has a new-todo input', function () {
  assert.ok(this.document.querySelector('.new-todo'));
});
STEPS
run_suite(){ ( cd "$T/sim" && timeout 120 npx cucumber-js features 2>&1 ); }
out=$(run_suite)
echo "$out" | grep -q 'does not exist' && ok "missing page fails LOUD" || no "missing page fails loud" "$(echo "$out" | tail -2 | tr '\n' ' ')"
cp "$T/sim/assets/app-template.index.html" "$T/sim/index.html"; : > "$T/sim/js/app.js"
echo "$(run_suite)" | grep -q 'is empty' && ok "empty app fails LOUD" || no "empty app fails loud"
printf "document.addEventListener('DOMContentLoaded',function(){document.querySelector('.new-todo').setAttribute('data-ok','1');});\n" > "$T/sim/js/app.js"
echo "$(run_suite)" | grep -qE '1 scenario \(1 passed\)' && ok "real app passes" || no "real app passes"

echo "=== oracle grader ==="
g="$T/grade.txt"
timeout 400 bash "$HERE/bin/oracle-grade.sh" --build "$T/sim" --out "$g" --clone "$HERE/.eval-scratch/oracle-clone" --port 8999 >"$T/grade.log" 2>&1
grep -q '^GRADE:' "$g" 2>/dev/null && ok "grader emits a GRADE line" || no "grader emits a GRADE line" "$(tail -2 "$T/grade.log" 2>/dev/null | tr '\n' ' ')"
grep -q 'served linked dependency' "$T/grade.log" && ok "grader serves the css the page links" || no "grader serves linked css"
timeout 60 bash "$HERE/bin/oracle-grade.sh" --build "$T/sim" --out "$T/g2.txt" --clone "$T/no-such-clone" --port 8999 >"$T/g2.log" 2>&1
grep -q 'not found' "$T/g2.log" && ok "grader REFUSES a broken clone (no score-shaped lie)" || no "grader refuses a broken clone"

echo "=== driver guards (static) ==="
R="$HERE/bin/pilot-run.sh"
grep -q 'echo "ERR ERR"' "$R" && ok "unmeasured grade returns ERR, not a fake 0/29" || no "unmeasured grade still becomes a number"
grep -q 'GRADE UNMEASURED' "$R" && ok "run STOPS on an unmeasured grade" || no "run does not stop on unmeasured grade"
[ "$(grep -cE 'git -C "\$SIM" (add|commit|reset|checkout|clean)' "$R")" = 0 ] && ok "harness makes NO git writes (it reads the repo, never edits it)" || no "harness still writes to the roles' repo"
grep -q 'run_shipwright' "$R" && no "operator-dispatched Shipwright pass still present" || ok "no operator-dispatched Shipwright passes"
grep -q 'PRODUCED NO SESSION' "$R" && ok "a leg with no session stops the run (not scored)" || no "void leg is not detected"
grep -q 'never a gate' "$R" && ok "self-suite observed, never used to revert" || no "self-suite still gates"
grep -qE 'features specs|for r in features specs' "$R" && ok "self-suite finds specs/ or features/" || no "self-suite spec-path handling missing"
grep -q 'NM_UPPER' "$HERE/bin/eval-leg.sh" && ok "node_modules persists per wave (a role's install survives)" || no "persistent node_modules missing"
grep -q 'modelOverrides' "$HERE/bin/eval-leg.sh" && ok "output budget applied via models.json (the mechanism pi honours)" || no "budget override missing"

echo "=== arms ==="
for arm in control candidate midway; do
  case $arm in
    control) d=/home/exedev/.claude/plugins/cache/dmytri-shipshape/shipshape/596fbf17be06/skills ;;
    candidate) d="$HERE/experiments/methods-candidate/skills" ;;
    midway) d="$HERE/experiments/methods-midway/skills" ;;
  esac
  [ -d "$d/shipshape" ] && ok "$arm skills present" || no "$arm skills present"
done
python3 "$HERE/bin/build-midway.py" --check >/dev/null 2>&1 && ok "midway build is clean (no hybrid vocabulary)" || no "midway build is a hybrid"

echo "=== capacity ==="
free_g=$(df -Pk / | awk 'NR==2{printf "%d",$4/1048576}')
[ "$free_g" -ge 10 ] && ok "disk ${free_g}G" || no "disk ${free_g}G" "under 10G"
pgrep -f disk-warden >/dev/null && ok "disk warden running" || no "disk warden not running"

echo
printf "  %d passed, %d failed — %s\n" "$pass" "$fail" "$([ "$fail" -eq 0 ] && echo 'SAFE TO LAUNCH' || echo 'DO NOT RUN A PILOT')"
exit $([ "$fail" -eq 0 ] && echo 0 || echo 1)
