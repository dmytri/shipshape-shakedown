#!/usr/bin/env bash
# Run ONE pilot voyage over an EXISTING sim: Captain(operator-directed intent) ->
# commit -> QM-assumes-rest -> operator custody commit -> roles' own self-suite.
#
# The iterate primitive the operator (main session loop) drives per scenarios/pilot.md:
# scaffold + voyage 1 land the app, then each further voyage re-phrases the oracle's
# residual as PRODUCT intent to Captain and re-builds, until the oracle passes. The
# oracle grade itself is run separately by the operator (bin/oracle-grade.sh), so the
# roles never see it (quarantine). Legs bank as <wave>/v<N>-{captain,qm}.
#
# Operator custody: QM-assumes-Boatswain has been observed to finish without committing
# on large builds; to keep each voyage's work as the next voyage's base, this commits
# the post-QM working tree verbatim (roles' bytes, no edits) under the Sim Operator.
set -euo pipefail
HERE="$(cd "$(dirname "$0")/.." && pwd)"
SCRATCH="${EVAL_SCRATCH:-$HERE/.eval-scratch}"
WAVE=""; SIM=""; MODEL=""; SKILLS_DIR=""; YOINK=""; VOYAGE=""; CAP_TASK=""; TIMEOUT_S=1500; NO_REVERT=0
QM_TASK="$HERE/tasks/pilot/qm.task.md"
while [ $# -gt 0 ]; do
  case "$1" in
    --wave) WAVE="$2"; shift 2;;
    --sim) SIM="$2"; shift 2;;
    --model) MODEL="$2"; shift 2;;
    --skills-dir) SKILLS_DIR="$2"; shift 2;;
    --yoink-skill) YOINK="$2"; shift 2;;
    --voyage) VOYAGE="$2"; shift 2;;
    --captain-task) CAP_TASK="$2"; shift 2;;
    --qm-task) QM_TASK="$2"; shift 2;;
    --timeout-s) TIMEOUT_S="$2"; shift 2;;
    --no-revert) NO_REVERT=1; shift;;   # voyage 1 build: a partial build is not a regression
    *) echo "eval-voyage.sh: unknown arg '$1'" >&2; exit 2;;
  esac
done
[ -n "$WAVE" ] && [ -n "$SIM" ] && [ -n "$MODEL" ] && [ -n "$SKILLS_DIR" ] && [ -n "$VOYAGE" ] && [ -n "$CAP_TASK" ] || {
  echo "usage: eval-voyage.sh --wave <d> --sim <dir> --model <id> --skills-dir <root> [--yoink-skill <dir>] --voyage <N> --captain-task <file>" >&2; exit 2; }
# --yoink-skill is OPTIONAL: omit it to test a doctrine that does not use yoink (0.13.65+).
YEXTRA=(); [ -n "$YOINK" ] && YEXTRA=("$YOINK")
[ -d "$SIM/.git" ] || { echo "eval-voyage.sh: sim '$SIM' is not a git repo" >&2; exit 2; }
[ -f "$CAP_TASK" ] || { echo "eval-voyage.sh: captain-task '$CAP_TASK' missing" >&2; exit 2; }
export EVAL_SHARED_NM="${EVAL_SHARED_NM:-$SCRATCH/.shared-nm/node_modules}"
[ -d "$EVAL_SHARED_NM/@cucumber" ] || { echo "eval-voyage.sh: shared toolkit missing at $EVAL_SHARED_NM" >&2; exit 3; }

BASE="$SCRATCH/$WAVE"; mkdir -p "$BASE"
V="v$VOYAGE"
# Last-good commit before this voyage — a voyage that leaves the self-suite RED is reverted
# to here so a broken build never becomes the next voyage's base (learned v15: deepseek's
# render rewrite broke the app and operator-custody committed it, poisoning the base).
PREHEAD="$(git -C "$SIM" rev-parse HEAD)"

run_leg() {
  local name="$1" task="$2"; shift 2
  local out="$BASE/$name.out"; local skill_args=()
  for s in "$@"; do skill_args+=(--skill "$s"); done
  echo "eval-voyage[$WAVE/$V]: --- leg $name ($MODEL) ---"
  local legrc=0
  "$HERE/bin/eval-leg.sh" --model "$MODEL" --workspace "$SIM" --out "$out" \
       "${skill_args[@]}" --task-file "$task" --name "$name" --timeout-s "$TIMEOUT_S" \
       >"$BASE/$name.leg.log" 2>&1 || legrc=$?
  if [ "$legrc" = 0 ]; then
    "$HERE/bin/eval-bank.sh" --wave "$WAVE" --name "$name" --out "$out" --workspace "$SIM" --verdict PENDING >/dev/null 2>&1 || true
    echo "eval-voyage[$WAVE/$V]: leg $name banked (exit $(cat "$out/exit" 2>/dev/null))"
  else
    echo "eval-voyage[$WAVE/$V]: leg $name LEG FAILED (see $BASE/$name.leg.log)"
    "$HERE/bin/eval-bank.sh" --wave "$WAVE" --name "$name" --out "$out" --workspace "$SIM" --verdict LEG-FAILED >/dev/null 2>&1 || true
  fi
  # void/infra guard: eval-leg exit 4 = no session produced (bwrap overlay-mount exhausted under
  # disk pressure, or a void leg). Do NOT let the voyage proceed on a void leg and land as a
  # SILENT no-op that burns a voyage of the cap (qmax V6-V20, 2026-07-26). Abort with a distinct
  # code so the driver retries the voyage instead of counting it.
  if [ "$legrc" = 4 ] || grep -qE 'leg is void|overlay mount failed \(attempt 6\)' "$BASE/$name.leg.log" 2>/dev/null; then
    echo "eval-voyage[$WAVE/$V]: leg $name INFRA/VOID (overlay-mount/no session) — aborting voyage" >&2; exit 6
  fi
  # provider-error guard (if/fi form — the &&-idiom trips set -e when empty)
  local perr; perr="$(python3 - "$out/pi.stdout" <<'PY'
import json,sys
msg=""
try:
    for l in open(sys.argv[1],encoding="utf-8"):
        try: e=json.loads(l)
        except Exception: continue
        m=e.get("message") or {}
        if m.get("role")=="assistant" and m.get("stopReason")=="error": msg=m.get("errorMessage") or "error"
except Exception: pass
print(msg)
PY
)"
  if [ -n "$perr" ]; then echo "eval-voyage[$WAVE/$V]: leg $name PROVIDER ERROR: $perr" >&2; exit 5; fi
}

# --- Captain (operator-directed intent) ---
sed "s#PROJECT_ROOT_PLACEHOLDER#$SIM#g" "$CAP_TASK" > "$BASE/$V-captain.task"
run_leg "$V-captain" "$BASE/$V-captain.task" "$SKILLS_DIR/shipshape" "$SKILLS_DIR/captain" "${YEXTRA[@]}"
git -C "$SIM" add -A >/dev/null 2>&1 || true
if [ -n "$(git -C "$SIM" status --porcelain)" ]; then
  git -C "$SIM" -c user.name="Sim Operator" -c user.email="sim@example.test" commit -qm "$V captain: specs + watchbill" || true
fi
BASE_COMMIT="$(git -C "$SIM" rev-parse HEAD)"
echo "eval-voyage[$WAVE/$V]: captain base $(git -C "$SIM" rev-parse --short HEAD)"

# --- QM-assumes-rest ---
sed -e "s#PROJECT_ROOT_PLACEHOLDER#$SIM#g" -e "s#BASE_COMMIT_PLACEHOLDER#$BASE_COMMIT#g" "$QM_TASK" > "$BASE/$V-qm.task"
run_leg "$V-qm" "$BASE/$V-qm.task" "$SKILLS_DIR/shipshape" "$SKILLS_DIR/qm" "$SKILLS_DIR/crew" "$SKILLS_DIR/boatswain" "${YEXTRA[@]}"

# --- operator custody: preserve the post-QM build verbatim ---
git -C "$SIM" add -A >/dev/null 2>&1 || true
if [ -n "$(git -C "$SIM" status --porcelain)" ]; then
  git -C "$SIM" -c user.name="Sim Operator" -c user.email="sim@example.test" commit -qm "$V build (operator custody)" || true
  echo "eval-voyage[$WAVE/$V]: operator-committed build $(git -C "$SIM" rev-parse --short HEAD)"
else
  echo "eval-voyage[$WAVE/$V]: build already committed by roles $(git -C "$SIM" rev-parse --short HEAD)"
fi

# --- roles' own self-suite ---
# The mountpoint is restored from a TRAP, not from the next line. A red or undefined self-suite
# exits cucumber non-zero, and under `set -o pipefail` that killed this script HERE (2026-07-26,
# methflash-b1 V2): the symlink survived, and bwrap cannot make an overlay mount on a symlink, so
# EVERY later leg died "Can't make overlay mount ... No such file or directory" and the driver
# read 4 void legs as disk/overlay pressure and stopped. The revert guard below was skipped in
# the same breath, so a regressed voyage could also have survived into the base. This is very
# likely the real cause of the qmax V6-V20 void-voyage grind that was attributed to disk.
echo "eval-voyage[$WAVE/$V]: === SELF-SUITE ==="
restore_nm(){ rm -f "$SIM/node_modules" 2>/dev/null || rm -rf "$SIM/node_modules" 2>/dev/null; mkdir -p "$SIM/node_modules"; }
trap restore_nm EXIT
rm -rf "$SIM/node_modules"; ln -s "$EVAL_SHARED_NM" "$SIM/node_modules"
# A non-zero suite is DATA here, not a script failure: capture it and judge it below.
( cd "$SIM" && npx cucumber-js 2>&1 | tail -6 ) > "$BASE/$V-selfsuite.txt" 2>&1 || true
cat "$BASE/$V-selfsuite.txt"
restore_nm

# Phase-1 gate as a REGRESSION guard: a red self-suite means this voyage broke the roles'
# own watchbill — revert the whole voyage so the base stays at the last green build. Skipped
# on --no-revert (voyage 1: a still-incomplete build is progress, not a regression to wipe).
if [ "$NO_REVERT" = "0" ] && grep -qE '[1-9][0-9]* failed' "$BASE/$V-selfsuite.txt"; then
  echo "eval-voyage[$WAVE/$V]: SELF-SUITE RED — reverting voyage to $PREHEAD (base not poisoned)"
  git -C "$SIM" reset --hard "$PREHEAD" >/dev/null 2>&1 || true
  echo "eval-voyage[$WAVE/$V]: VOYAGE-REGRESSED"
else
  echo "eval-voyage[$WAVE/$V]: VOYAGE-COMPLETE"
fi
