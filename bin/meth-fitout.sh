#!/usr/bin/env bash
# ONE fitting-out draw: does Shipwright DERIVE stack-appropriate methods, unprompted?
#
# dk's requirement (2026-07-26): fitting out must create the project's methods for its stack, not
# merely be told to use a bundler. That is a claim about one leg, so it gets its own instrument
# rather than a whole pilot. The sim is `tidewatch` — real production code plus a cucumber suite and
# NO RIGGING.md, so doctrine routes fitting out to Shipwright (a greenfield tree with nothing to
# derive would route to Captain's fast path instead, which writes only the minimum values).
#
# The audit is executable, not a read: every derived method is RUN in the sim, because doctrine says
# a method that has never run is a claim, and the same standard binds the operator judging it.
#
# usage: meth-fitout.sh --wave <tag> --model <id> --skills-dir <root> [--timeout-s N]
set -uo pipefail
HERE="$(cd "$(dirname "$0")/.." && pwd)"
SCRATCH="${EVAL_SCRATCH:-$HERE/.eval-scratch}"
WAVE=""; MODEL="xiaomi/mimo-v2.5"; SKILLS_DIR=""; TIMEOUT_S=1200; STACK="js"
while [ $# -gt 0 ]; do
  case "$1" in
    --wave) WAVE="$2"; shift 2;;
    --model) MODEL="$2"; shift 2;;
    --skills-dir) SKILLS_DIR="$2"; shift 2;;
    --timeout-s) TIMEOUT_S="$2"; shift 2;;
    --stack) STACK="$2"; shift 2;;   # js|ts|py — the derivation must differ per stack
    *) echo "meth-fitout.sh: unknown arg '$1'" >&2; exit 2;;
  esac
done
[ -n "$WAVE" ] && [ -n "$SKILLS_DIR" ] || { echo "usage: meth-fitout.sh --wave <tag> --model <id> --skills-dir <root>" >&2; exit 2; }

BASE="$SCRATCH/$WAVE"; SIM="$BASE/sim"; LOG="$BASE/fitout.log"
rm -rf "$BASE"; mkdir -p "$BASE"
say(){ echo "[$(date -u +%FT%TZ)] $*" | tee -a "$LOG"; }

# A non-Node stack gets an EMPTY toolkit overlay. bwrap creates the node_modules mountpoint itself,
# so overlaying the JS toolkit into a Python sim would show the leg 160 JS packages and hand it a
# false stack signal — the one thing a per-stack derivation test must not do.
if [ "$STACK" = "py" ]; then
  # A skills-ONLY toolkit: carries the `skills` CLI (eval-leg needs it, and the npx cache is
  # VM-mortal) but no @cucumber, so eval-leg skips the node_modules overlay and a Python sim is
  # never shown 160 JS packages. An EMPTY toolkit starved the CLI and the leg died SILENTLY with
  # an empty log and rc=2 (2026-07-26) — the same silent-exit class as the npx-cache wipe.
  mkdir -p "$SCRATCH/.skillsonly-nm/node_modules"
  [ -x "$SCRATCH/.skillsonly-nm/node_modules/.bin/skills" ] || { say "skills-only toolkit missing the skills CLI"; exit 3; }
  export EVAL_SHARED_NM="$SCRATCH/.skillsonly-nm/node_modules"
else
  NM="$SCRATCH/.shared-nm-$WAVE"
  [ -d "$NM/node_modules" ] || { mkdir -p "$NM"; cp -a "$SCRATCH/.shared-nm/node_modules" "$NM/"; }
  export EVAL_SHARED_NM="$NM/node_modules"
fi

say "FITOUT START wave=$WAVE stack=$STACK model=$MODEL skills=$SKILLS_DIR"
"$HERE/bin/scaffold-stack.sh" "$STACK" "$SIM" >"$BASE/scaffold.log" 2>&1 || { say "SCAFFOLD FAILED"; exit 4; }
[ -f "$SIM/RIGGING.md" ] && { say "sim already fitted out — not a fitting-out draw"; exit 4; }

cat > "$BASE/task.md" <<EOF
You are the Shipshape Shipwright. Project root: $SIM.

This project has never been fitted out. Fit it out.

Proceed now without waiting for confirmation. Do not commit, push, or tag.
EOF

t0=$(date +%s)
"$HERE/bin/eval-leg.sh" --model "$MODEL" --workspace "$SIM" --out "$BASE/fitout.out" \
  --skill "$SKILLS_DIR/shipshape" --skill "$SKILLS_DIR/shipwright" \
  --task-file "$BASE/task.md" --name "fitout" --timeout-s "$TIMEOUT_S" >"$BASE/fitout.leg.log" 2>&1
rc=$?; t1=$(date +%s)
say "FITOUT LEG $((t1-t0))s rc=$rc"

"$HERE/bin/meth-fitout-audit.sh" "$BASE" 2>&1 | tee -a "$LOG"
say "FITOUT END wave=$WAVE"
echo FITOUT-DONE
