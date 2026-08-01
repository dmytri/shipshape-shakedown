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
# defect 17 (2026-08-01): the warden unlinked a LIVE leg's stdout because the file had not been
# written for IDLE_MIN -- a leg waiting on the provider looks idle. pi then wrote to a deleted
# inode: no live window, raw capture lost, and eval-leg's 429-retry grep silently dead.
grep -qE "name 'pi.stdout' -mmin \+\"?\$IDLE_MIN\"? -delete" "$HERE/bin/disk-warden.sh" && no "disk warden deletes live leg stdout by mtime" || ok "disk warden only unlinks stdout of FINISHED legs"
# two legs ran the full 3600s producing ZERO bytes (R11 candidate/mimo, R14 control/flash),
# an hour each. The watchdog kills a leg whose stdout has not grown, and the retry takes it.
grep -q 'NO OUTPUT for' "$HERE/bin/eval-leg.sh" && ok "stalled legs are killed and retried, not run to the 3600s timeout" || no "a stalled leg still costs a full hour"
# defect 14 (2026-07-29): `local a=$1 b=$a` aborts under set -u, which killed every voyage 2.
# Check the CLASS across every harness script, not just the one line that bit us.
python3 - "$HERE"/bin/*.sh <<'PY' && ok "no local self-reference (the defect-14 class)" || no "a local assignment reads a variable it assigns on the same line"
import re, sys
bad = []
for f in sys.argv[1:]:
    for n, line in enumerate(open(f, errors="ignore"), 1):
        m = re.match(r"\s*local\s+(.*)", line)
        if not m: continue
        # only the `local` command itself: a read after `;` is a separate command and is safe
        rest = m.group(1).split(";")[0]
        for part in re.finditer(r"(\w+)=", rest):
            v = part.group(1)
            if re.search(r"\$\{?%s\b" % re.escape(v), rest[part.end():]):
                bad.append(f"{f}:{n}: `local {v}=` is read later in the SAME local — unset under set -u")
for b in bad: print(b, file=sys.stderr)
sys.exit(1 if bad else 0)
PY
# dk, 2026-07-29: gplint config is part of fit-out grading — measured, never seeded.
grep -q 'FIT-OUT' "$R" && ok "fit-out grade recorded (gplintrc, rigging lint, gplint run)" || no "fit-out is not graded"
# Every flat-voyage cluster in the corpus had a playbook cause and every fix drove flats to zero
# (R9 mimo 10 flat -> R11 flat=0; R12 flat 3/1 -> R13 flat=0). The last known one: QM's report was
# thrown away, so a Captain never learned its watchbill had been rejected -- R16 sat flat 3 voyages.
grep -q 'qmreport' "$R" && ok "the previous QM's report reaches the next Captain" || no "QM's blockers are discarded by the harness"
# dk, 2026-08-01: Captain/Shipwright fit out and STOP; a FRESH QM session opens on that commit.
# Context isolation between roles is the mechanism under test -- one session wearing five hats
# wrote production code as "Step 1 (Crew work)" and the watchbill last, after its scenarios were
# already green (R13 control/flash: app+specs+steps+watchbill in ONE 870-line commit).
[ "$(grep -cE '^\s*leg "?v' "$R")" = 4 ] && ok "two sessions per voyage (Captain/Shipwright, then a fresh QM)" || no "the voyage is not split Captain -> QM"
grep -q 'SKILLS/shipwright' "$R" && ok "Shipwright is loaded (it owns fitting out)" || no "Shipwright absent — nobody owns deriving the rigging"
grep -q 'SKILLS/crew' "$R" && grep -qE 'leg "?v[0-9$]+-captain".*SKILLS/crew' "$R" && no "Captain leg carries Crew — production code is not Captain's" || ok "Captain leg carries no Crew/QM skills"
grep -qE '^[^#]*BASE_COMMIT="\$\(git -C "\$SIM" rev-parse HEAD\)"' "$R" && ok "BASE_COMMIT is read AFTER the Captain leg takes custody" || no "BASE_COMMIT is not derived from the Captain commit"
grep -qE 'Do not commit, push' "$R" "$HERE/tasks/pilot/captain-todomvc.task.md" && no "a pilot prompt still forbids the roles to commit" || ok "custody is the roles' business, not forbidden by the prompt"
# match across the prompt's line wrap, and ONLY in the prompts -- this check was green for a
# year because it was matching the phrase in a source COMMENT rather than in any prompt.
grep -qz 'assume that role[[:space:]]*in place' "$HERE/tasks/pilot/captain-todomvc.task.md" && grep -q 'assume that role' "$R" && ok "both prompts carry the no-spawn-tool fallback" || no "a prompt does not tell the agent to assume roles in place"
grep -qE '(python3|bin/)[^#]*rigging-conform' "$R" && no "fit-out grade keys on ## Methods — penalises the control arm" || ok "fit-out grade is vocabulary-neutral across arms"
[ -e "$HERE/.eval-scratch/.shared-nm/node_modules/.bin/gplint" ] && ok "gplint resolves from the shared toolkit (no registry round-trip)" || no "gplint missing from shared toolkit"

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
