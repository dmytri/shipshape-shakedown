#!/usr/bin/env bash
# NEW-way TodoMVC pilot: the acceptance tier on the pi/eval instrument.
#
# Sibling of eval-pilot.sh (tidewatch), but builds a full TodoMVC app from the
# vendored spec+template and grades it against the UPSTREAM Cypress oracle
# (bin/oracle-grade.sh, operator-side, quarantined). Single voyage by default:
# Captain (specs+watchbill) -> commit as durable base -> QM-assumes-rest (build the
# app, self-suite green, Crew+Boatswain in place) -> roles' own suite -> oracle N/29.
#
# Retires the old sonnet/clear TodoMVC pilot (scenarios/pilot.md) for pi baselines.
# The oracle stays byte-identical to that pilot: same pinned clone, same 2 patches,
# same framework name `shakedown`, so grades are comparable across both eras.
set -euo pipefail
HERE="$(cd "$(dirname "$0")/.." && pwd)"
SCRATCH="${EVAL_SCRATCH:-$HERE/.eval-scratch}"
WAVE=""; MODEL=""; SKILLS_DIR=""; YOINK=""; TIMEOUT_S=1500; ORACLE_PORT=8873
CAP_TASK="$HERE/tasks/pilot/captain-todomvc.task.md"
QM_TASK="$HERE/tasks/pilot/qm.task.md"
while [ $# -gt 0 ]; do
  case "$1" in
    --wave) WAVE="$2"; shift 2;;
    --model) MODEL="$2"; shift 2;;
    --skills-dir) SKILLS_DIR="$2"; shift 2;;
    --yoink-skill) YOINK="$2"; shift 2;;
    --captain-task) CAP_TASK="$2"; shift 2;;
    --qm-task) QM_TASK="$2"; shift 2;;
    --timeout-s) TIMEOUT_S="$2"; shift 2;;
    --oracle-port) ORACLE_PORT="$2"; shift 2;;
    --scratch) SCRATCH="$2"; shift 2;;
    *) echo "eval-pilot-todomvc.sh: unknown arg '$1'" >&2; exit 2;;
  esac
done
[ -n "$WAVE" ] && [ -n "$MODEL" ] && [ -n "$SKILLS_DIR" ] && [ -n "$YOINK" ] || {
  echo "usage: eval-pilot-todomvc.sh --wave <d> --model <id> --skills-dir <root> --yoink-skill <dir>" >&2; exit 2; }
[ -d "$SKILLS_DIR" ] || { echo "eval-pilot-todomvc.sh: skills-dir '$SKILLS_DIR' missing" >&2; exit 2; }
for r in shipshape captain qm crew boatswain; do
  [ -f "$SKILLS_DIR/$r/SKILL.md" ] || { echo "eval-pilot-todomvc.sh: skills-dir missing role '$r'" >&2; exit 2; }
done
[ -f "$YOINK/SKILL.md" ] || { echo "eval-pilot-todomvc.sh: yoink-skill has no SKILL.md" >&2; exit 2; }
[ -d "$SCRATCH/oracle-clone/cypress" ] || { echo "eval-pilot-todomvc.sh: oracle clone missing at $SCRATCH/oracle-clone (clone+patch first)" >&2; exit 3; }

BASE="$SCRATCH/$WAVE"; WS="$BASE/sim"
rm -rf "$BASE"; mkdir -p "$BASE"

# Shared toolkit, TodoMVC flavour: cucumber + yoink + happy-dom (the DOM tier). Reuse
# the eval-batch store and ADD happy-dom if absent (the gate is @cucumber + happy-dom).
SHARED_NM="$SCRATCH/.shared-nm"
if [ ! -e "$SHARED_NM/node_modules/@cucumber" ] || [ ! -e "$SHARED_NM/node_modules/happy-dom" ]; then
  echo "eval-pilot-todomvc[$WAVE]: ensuring toolkit (cucumber + happy-dom + yoink)…" >&2
  mkdir -p "$SHARED_NM"
  ( cd "$SHARED_NM" && [ -f package.json ] || npm init -y >/dev/null 2>&1
    npm install --no-fund --no-audit --save-dev \
      @cucumber/cucumber @dk/yoink happy-dom c8 jsdoc knip @biomejs/biome >/dev/null 2>&1 \
    || npm install --no-fund --no-audit \
      @cucumber/cucumber "$HOME/yoink" happy-dom c8 jsdoc knip @biomejs/biome >/dev/null 2>&1 )
fi
export EVAL_SHARED_NM="$SHARED_NM/node_modules"
[ -d "$EVAL_SHARED_NM/@cucumber" ] && [ -d "$EVAL_SHARED_NM/happy-dom" ] || {
  echo "eval-pilot-todomvc[$WAVE]: toolkit incomplete (need cucumber + happy-dom)" >&2; exit 3; }
echo "eval-pilot-todomvc[$WAVE]: toolkit ready (cucumber + happy-dom + yoink)" >&2

if ! "$HERE/bin/scaffold-todomvc.sh" "$WS" >"$BASE/scaffold.log" 2>&1; then
  echo "eval-pilot-todomvc[$WAVE]: SCAFFOLD FAILED (see $BASE/scaffold.log)" >&2; exit 4; fi
echo "eval-pilot-todomvc[$WAVE]: scaffolded $WS at $(git -C "$WS" rev-parse --short HEAD)"

# --- provider-error detection (shared shape with eval-pilot.sh) ---
leg_provider_error() {
  local out="$1"; [ -f "$out/pi.stdout" ] || { echo ""; return; }
  python3 - "$out/pi.stdout" <<'PY'
import json, sys
msg=""
for line in open(sys.argv[1],encoding="utf-8"):
    try: e=json.loads(line)
    except Exception: continue
    m=e.get("message") or {}
    if m.get("role")=="assistant" and m.get("stopReason")=="error":
        msg=m.get("errorMessage") or "error (no message)"
print(msg)
PY
}
PILOT_BLOCKED=""
run_leg() {
  local name="$1" task="$2"; shift 2
  local out="$BASE/$name.out"; local skill_args=()
  for s in "$@"; do skill_args+=(--skill "$s"); done
  echo "eval-pilot-todomvc[$WAVE]: --- leg $name ($MODEL, timeout ${TIMEOUT_S}s) ---"
  if "$HERE/bin/eval-leg.sh" --model "$MODEL" --workspace "$WS" --out "$out" \
       "${skill_args[@]}" --task-file "$task" --name "$name" \
       --timeout-s "$TIMEOUT_S" >"$BASE/$name.leg.log" 2>&1; then
    "$HERE/bin/eval-bank.sh" --wave "$WAVE" --name "$name" --out "$out" \
       --workspace "$WS" --verdict PENDING >/dev/null 2>&1 || true
    echo "eval-pilot-todomvc[$WAVE]: leg $name banked (exit $(cat "$out/exit" 2>/dev/null))"
  else
    echo "eval-pilot-todomvc[$WAVE]: leg $name LEG FAILED (see $BASE/$name.leg.log)"
    "$HERE/bin/eval-bank.sh" --wave "$WAVE" --name "$name" --out "$out" \
       --workspace "$WS" --verdict LEG-FAILED >/dev/null 2>&1 || true
  fi
  local perr; perr="$(leg_provider_error "$out")"
  [ -n "$perr" ] && { PILOT_BLOCKED="$perr"; echo "eval-pilot-todomvc[$WAVE]: leg $name PROVIDER ERROR: $perr" >&2; }
}
abort_if_blocked() {
  [ -n "$PILOT_BLOCKED" ] || return 0
  local G="$HERE/data/$WAVE"; mkdir -p "$G"
  { echo "# pilot BLOCKED: $WAVE model=$MODEL $(date -u +%FT%TZ)"; echo "# provider error: $PILOT_BLOCKED"; } > "$G/BLOCKED.txt"
  echo "eval-pilot-todomvc[$WAVE]: === BLOCKED === $PILOT_BLOCKED"; echo "PILOT-BLOCKED"; exit 5
}

# ---- Voyage ----
sed "s#PROJECT_ROOT_PLACEHOLDER#$WS#g" "$CAP_TASK" > "$BASE/captain.task"
run_leg captain "$BASE/captain.task" "$SKILLS_DIR/shipshape" "$SKILLS_DIR/captain" "$YOINK"
abort_if_blocked

git -C "$WS" add -A >/dev/null 2>&1 || true
if [ -n "$(git -C "$WS" status --porcelain)" ]; then
  git -C "$WS" commit -qm "captain: specs + watchbill for TodoMVC build" || true
fi
BASE_COMMIT="$(git -C "$WS" rev-parse HEAD)"
echo "eval-pilot-todomvc[$WAVE]: captain base commit $(git -C "$WS" rev-parse --short HEAD)"

sed -e "s#PROJECT_ROOT_PLACEHOLDER#$WS#g" -e "s#BASE_COMMIT_PLACEHOLDER#$BASE_COMMIT#g" \
  "$QM_TASK" > "$BASE/qm.task"
run_leg qm "$BASE/qm.task" \
  "$SKILLS_DIR/shipshape" "$SKILLS_DIR/qm" "$SKILLS_DIR/crew" "$SKILLS_DIR/boatswain" "$YOINK"
abort_if_blocked

# ---- Phase 1: the roles' OWN suite (self-watchbill) ----
set +e
echo "eval-pilot-todomvc[$WAVE]: === SELF-SUITE (roles' own scenarios) ==="
GRADE="$BASE/grade.txt"
{
  echo "# TodoMVC pilot grade: $WAVE  model=$MODEL  $(date -u +%FT%TZ)"
  echo "# candidate: $SKILLS_DIR (+ yoink $YOINK)"
  echo; echo "## voyage commits"; git -C "$WS" log --oneline -10
  echo; echo "## build tree (app files)"; git -C "$WS" ls-files | grep -vE '^(assets/|features/|node_modules/)' | head -40
  echo; echo "## self-suite (roles' own cucumber)"
} > "$GRADE"
rm -rf "$WS/node_modules"; ln -s "$EVAL_SHARED_NM" "$WS/node_modules"
( cd "$WS" && npx cucumber-js 2>&1 | tail -12 ) >> "$GRADE" 2>&1
rm -f "$WS/node_modules"; mkdir -p "$WS/node_modules"

# ---- Phase 2: the UPSTREAM Cypress oracle (out-of-band, quarantined) ----
echo "eval-pilot-todomvc[$WAVE]: === ORACLE GRADE (upstream Cypress) ==="
{ echo; echo "## upstream oracle (Cypress, framework=shakedown)"; } >> "$GRADE"
"$HERE/bin/oracle-grade.sh" --build "$WS" --out "$BASE/oracle-grade.txt" \
   --clone "$SCRATCH/oracle-clone" --port "$ORACLE_PORT" >>"$GRADE" 2>&1 || \
   echo "(oracle-grade returned nonzero — see detail)" >> "$GRADE"
{ echo; echo "## oracle detail"; cat "$BASE/oracle-grade.txt" 2>/dev/null; } >> "$GRADE"

cp "$GRADE" "$HERE/data/$WAVE/grade.txt" 2>/dev/null || true
[ -f "$BASE/oracle-grade.txt" ] && cp "$BASE/oracle-grade.txt" "$HERE/data/$WAVE/oracle-grade.txt" 2>/dev/null || true
echo "eval-pilot-todomvc[$WAVE]: grade ->"; sed 's/^/  /' "$GRADE" | tail -30
echo "eval-pilot-todomvc[$WAVE]: COMPLETE. Banked data/$WAVE/"
echo "PILOT-COMPLETE"
