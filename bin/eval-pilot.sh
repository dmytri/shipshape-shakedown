#!/usr/bin/env bash
# Sequence a full Shipshape lifecycle over the eval atom: a NEW-sim pilot.
#
# The pilot layer over eval-leg.sh (see AGENTS.md "Pilot-capable by composition").
# One scaffolded sim carried through an operator-driven voyage of isolated pi legs,
# each reading the role skill(s) under test and acting on the SAME workspace, so a
# later role sees the durable artifacts an earlier role committed. Retires the old
# Claude-sonnet role-subagent + /clear pilot (scenarios/pilot.md) for doctrine that
# the pi/eval instrument can exercise on non-Claude baselines.
#
# Voyage (fixed): Captain (specs+watchbill) -> commit -> QM-assumes-rest (make
# executable, prove red, Crew implements, Boatswain custody) -> external oracle grade.
# QM assumes downstream roles in place because pi has no spawn tool — the doctrine's
# own "load role in place when operating without subagents" branch, native to pi.
#
# The grade is MODEL-FREE and independent of what scenarios the roles wrote: it runs
# the sim's own suite AND an external oracle check against src/tide.js directly.
#
# Usage:
#   eval-pilot.sh --wave <dir> --model <id> \
#     --skills-dir <candidate skills root> --yoink-skill <yoink skill dir> \
#     [--captain-task <f>] [--qm-task <f>] [--timeout-s 900] [--concurrency N-ignored]
set -euo pipefail
HERE="$(cd "$(dirname "$0")/.." && pwd)"
SCRATCH="${EVAL_SCRATCH:-$HERE/.eval-scratch}"
WAVE=""; MODEL=""; SKILLS_DIR=""; YOINK=""; TIMEOUT_S=900
CAP_TASK="$HERE/tasks/pilot/captain.task.md"
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
    --scratch) SCRATCH="$2"; shift 2;;
    *) echo "eval-pilot.sh: unknown arg '$1'" >&2; exit 2;;
  esac
done
[ -n "$WAVE" ] && [ -n "$MODEL" ] && [ -n "$SKILLS_DIR" ] && [ -n "$YOINK" ] || {
  echo "usage: eval-pilot.sh --wave <d> --model <id> --skills-dir <root> --yoink-skill <dir>" >&2; exit 2; }
[ -d "$SKILLS_DIR" ] || { echo "eval-pilot.sh: skills-dir '$SKILLS_DIR' missing" >&2; exit 2; }
for r in shipshape captain qm crew boatswain; do
  [ -f "$SKILLS_DIR/$r/SKILL.md" ] || { echo "eval-pilot.sh: skills-dir missing role '$r'" >&2; exit 2; }
done
[ -f "$YOINK/SKILL.md" ] || { echo "eval-pilot.sh: yoink-skill '$YOINK' has no SKILL.md" >&2; exit 2; }
[ -f "$CAP_TASK" ] && [ -f "$QM_TASK" ] || { echo "eval-pilot.sh: task template missing" >&2; exit 2; }

BASE="$SCRATCH/$WAVE"; WS="$BASE/sim"
rm -rf "$BASE"; mkdir -p "$BASE"

# Shared toolkit node_modules (same contract as eval-batch.sh): a read-only base the
# scaffold symlinks for its green check and each leg overlays. Build once, reuse.
SHARED_NM="$SCRATCH/.shared-nm"
if [ ! -e "$SHARED_NM/node_modules/.bin/biome" ]; then
  echo "eval-pilot[$WAVE]: building shared toolkit (one-time)…" >&2
  mkdir -p "$SHARED_NM"
  ( cd "$SHARED_NM" && [ -f package.json ] || npm init -y >/dev/null 2>&1
    npm install --no-fund --no-audit --save-dev \
      @cucumber/cucumber @dk/yoink c8 jsdoc knip @biomejs/biome >/dev/null 2>&1 \
    || npm install --no-fund --no-audit \
      @cucumber/cucumber "$HOME/yoink" c8 jsdoc knip @biomejs/biome >/dev/null 2>&1 )
fi
export EVAL_SHARED_NM="$SHARED_NM/node_modules"
[ -d "$EVAL_SHARED_NM/@cucumber" ] || { echo "eval-pilot[$WAVE]: shared toolkit FAILED to build" >&2; exit 3; }
echo "eval-pilot[$WAVE]: shared toolkit ready" >&2

# Scaffold ONE sim for the whole voyage.
if ! "$HERE/bin/scaffold.sh" "$WS" >"$BASE/scaffold.log" 2>&1; then
  echo "eval-pilot[$WAVE]: SCAFFOLD FAILED (see $BASE/scaffold.log)" >&2; exit 4; fi
echo "eval-pilot[$WAVE]: scaffolded $WS at $(git -C "$WS" rev-parse --short HEAD)"

# Did a leg fail to produce ANY model work because the provider errored (e.g. a 402
# insufficient-credits, a rate-limit, an auth reject)? pi exits 0 and writes an empty
# assistant turn with stopReason "error", so the only honest signal is in the session.
# Prints the provider error message if found, empty otherwise.
leg_provider_error() {
  local out="$1"
  [ -f "$out/pi.stdout" ] || { echo ""; return; }
  python3 - "$out/pi.stdout" <<'PY'
import json, sys
msg = ""
for line in open(sys.argv[1], encoding="utf-8"):
    try: e = json.loads(line)
    except Exception: continue
    m = e.get("message") or {}
    if m.get("role") == "assistant" and m.get("stopReason") == "error":
        msg = m.get("errorMessage") or "error (no message)"
print(msg)
PY
}

# Run one leg over the shared sim, bank it. $1=name $2=task-file $3..=skill dirs.
# Sets PILOT_BLOCKED to the provider error message when a leg errored with no work.
PILOT_BLOCKED=""
run_leg() {
  local name="$1" task="$2"; shift 2
  local out="$BASE/$name.out"
  local skill_args=()
  for s in "$@"; do skill_args+=(--skill "$s"); done
  echo "eval-pilot[$WAVE]: --- leg $name ($MODEL) ---"
  if "$HERE/bin/eval-leg.sh" --model "$MODEL" --workspace "$WS" --out "$out" \
       "${skill_args[@]}" --task-file "$task" --name "$name" \
       --timeout-s "$TIMEOUT_S" >"$BASE/$name.leg.log" 2>&1; then
    "$HERE/bin/eval-bank.sh" --wave "$WAVE" --name "$name" --out "$out" \
       --workspace "$WS" --verdict PENDING >/dev/null 2>&1 || true
    echo "eval-pilot[$WAVE]: leg $name banked (exit $(cat "$out/exit" 2>/dev/null))"
  else
    echo "eval-pilot[$WAVE]: leg $name LEG FAILED (see $BASE/$name.leg.log)"
    "$HERE/bin/eval-bank.sh" --wave "$WAVE" --name "$name" --out "$out" \
       --workspace "$WS" --verdict LEG-FAILED >/dev/null 2>&1 || true
  fi
  local perr; perr="$(leg_provider_error "$out")"
  if [ -n "$perr" ]; then
    PILOT_BLOCKED="$perr"
    echo "eval-pilot[$WAVE]: leg $name PROVIDER ERROR (no model work): $perr" >&2
  fi
}

# Abort the voyage cleanly when the provider blocked a leg — a void voyage must not be
# graded (an empty grade reads as a real NOT-CLEAR). Records a BLOCKED marker and stops.
abort_if_blocked() {
  [ -n "$PILOT_BLOCKED" ] || return 0
  local G="$HERE/data/$WAVE"; mkdir -p "$G"
  {
    echo "# pilot BLOCKED: $WAVE  model=$MODEL  $(date -u +%FT%TZ)"
    echo "# no model work was produced — the provider errored on the leg(s)."
    echo "# provider error: $PILOT_BLOCKED"
    echo "# the instrument ran correctly (scaffold, isolation, capture, fold all fired);"
    echo "# resolve the external blocker and re-run the same command."
  } > "$G/BLOCKED.txt"
  cp "$G/BLOCKED.txt" "$BASE/BLOCKED.txt" 2>/dev/null || true
  echo "eval-pilot[$WAVE]: === BLOCKED ==="
  sed 's/^/  /' "$G/BLOCKED.txt"
  echo "PILOT-BLOCKED"
  exit 5
}

# ---- Voyage ----
# Leg 1: Captain — specs + watchbill only.
sed "s#PROJECT_ROOT_PLACEHOLDER#$WS#g" "$CAP_TASK" > "$BASE/captain.task"
run_leg captain "$BASE/captain.task" \
  "$SKILLS_DIR/shipshape" "$SKILLS_DIR/captain" "$YOINK"
abort_if_blocked

# Commit Captain's artifacts as the durable base the QM leg derives from.
git -C "$WS" add -A >/dev/null 2>&1 || true
if [ -n "$(git -C "$WS" status --porcelain)" ]; then
  git -C "$WS" commit -qm "captain: specs + watchbill for next-low-tide voyage" || true
fi
BASE_COMMIT="$(git -C "$WS" rev-parse HEAD)"
echo "eval-pilot[$WAVE]: captain base commit $BASE_COMMIT ($(git -C "$WS" rev-parse --short HEAD))"
git -C "$WS" -c core.pager=cat show --stat HEAD > "$BASE/captain.commit.stat" 2>&1 || true

# Leg 2: QM-assumes-rest — make executable, prove red, Crew implements, Boatswain custody.
sed -e "s#PROJECT_ROOT_PLACEHOLDER#$WS#g" -e "s#BASE_COMMIT_PLACEHOLDER#$BASE_COMMIT#g" \
  "$QM_TASK" > "$BASE/qm.task"
run_leg qm "$BASE/qm.task" \
  "$SKILLS_DIR/shipshape" "$SKILLS_DIR/qm" "$SKILLS_DIR/crew" "$SKILLS_DIR/boatswain" "$YOINK"
abort_if_blocked

# ---- Grade (model-free, external oracle) ----
# The grade probes for the ABSENCE of work (a red suite, an unexported function), so its
# commands legitimately return non-zero; drop set -e for the section so a NOT-CLEAR grade
# is recorded rather than aborting the script (found 2026-07-24: node oracle exit 1 under
# set -e killed the grade before it was written).
set +e
echo "eval-pilot[$WAVE]: === GRADE ==="
GRADE="$BASE/grade.txt"
{
  echo "# pilot grade: $WAVE  model=$MODEL  $(date -u +%FT%TZ)"
  echo "# candidate skills: $SKILLS_DIR (+ yoink $YOINK)"
  echo
  echo "## git log (voyage commits)"
  git -C "$WS" log --oneline -8 2>&1
  echo
  echo "## final tree status (uncommitted after QM leg, if any)"
  git -C "$WS" status --porcelain 2>&1 | head -30
  echo
} > "$GRADE"

# The suite needs node_modules; provide the shared toolkit read-only for the grade run.
# The leg's bwrap overlay leaves an EMPTY node_modules dir behind; replace it with a
# symlink (ln -sfn onto an existing dir would nest the link inside it, not replace it).
rm -rf "$WS/node_modules"; ln -s "$EVAL_SHARED_NM" "$WS/node_modules"
{
  echo "## suite (npx cucumber-js, whole sim)"
  ( cd "$WS" && npx cucumber-js 2>&1 | tail -25 )
  echo
  echo "## external oracle: nextLowTide against src/tide.js"
  node -e '
    const path=require("path"); const ws=process.argv[1];
    let mod, tides, pass=true, notes=[];
    try { mod = require(path.join(ws,"src","tide.js")); } catch(e){ console.log("FAIL load tide.js:",e.message); process.exit(3); }
    try { tides = require(path.join(ws,"data","tides.json")); } catch(e){ console.log("FAIL load tides.json:",e.message); process.exit(3); }
    const fn = mod.nextLowTide;
    if (typeof fn !== "function") { console.log("FAIL: nextLowTide not exported"); process.exit(2); }
    try {
      const r = fn(tides, "2026-07-12T05:00:00Z");
      const okTime = r && r.time === "2026-07-12T10:30:00Z";
      const okH = r && Number(r.height) === 0.8;
      const okType = !r || r.type === "low";
      if (okTime && okH && okType) notes.push("PASS next-low-tide -> 10:30Z@0.8");
      else { pass=false; notes.push("FAIL next-low-tide got "+JSON.stringify(r)); }
    } catch(e){ pass=false; notes.push("FAIL next-low-tide threw: "+e.message); }
    try {
      let threw=false;
      try { fn(tides, "2026-07-12T23:00:00Z"); } catch(e){ threw=true; notes.push("PASS no-upcoming-low-tide error: "+JSON.stringify(e.message)); }
      if (!threw){ pass=false; notes.push("FAIL no-upcoming-low-tide did not throw"); }
    } catch(e){ pass=false; notes.push("FAIL error-path: "+e.message); }
    console.log(notes.join("\n"));
    console.log(pass ? "ORACLE: CLEAR" : "ORACLE: NOT-CLEAR");
    process.exit(pass?0:1);
  ' "$WS" 2>&1
  echo "oracle_exit=$?"
} >> "$GRADE"
rm -f "$WS/node_modules"; mkdir -p "$WS/node_modules"

cp "$GRADE" "$HERE/data/$WAVE/grade.txt" 2>/dev/null || true
echo "eval-pilot[$WAVE]: grade ->"
sed 's/^/  /' "$GRADE"
echo "eval-pilot[$WAVE]: COMPLETE. Banked data/$WAVE/ ; folds: data/$WAVE/*.map.txt ; grade: data/$WAVE/grade.txt"
echo "PILOT-COMPLETE"
