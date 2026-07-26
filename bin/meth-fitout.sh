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
WAVE=""; MODEL="xiaomi/mimo-v2.5"; SKILLS_DIR=""; TIMEOUT_S=1200
while [ $# -gt 0 ]; do
  case "$1" in
    --wave) WAVE="$2"; shift 2;;
    --model) MODEL="$2"; shift 2;;
    --skills-dir) SKILLS_DIR="$2"; shift 2;;
    --timeout-s) TIMEOUT_S="$2"; shift 2;;
    *) echo "meth-fitout.sh: unknown arg '$1'" >&2; exit 2;;
  esac
done
[ -n "$WAVE" ] && [ -n "$SKILLS_DIR" ] || { echo "usage: meth-fitout.sh --wave <tag> --model <id> --skills-dir <root>" >&2; exit 2; }

BASE="$SCRATCH/$WAVE"; SIM="$BASE/sim"; LOG="$BASE/fitout.log"
rm -rf "$BASE"; mkdir -p "$BASE"
say(){ echo "[$(date -u +%FT%TZ)] $*" | tee -a "$LOG"; }

NM="$SCRATCH/.shared-nm-$WAVE"
[ -d "$NM/node_modules" ] || { mkdir -p "$NM"; cp -a "$SCRATCH/.shared-nm/node_modules" "$NM/"; }
export EVAL_SHARED_NM="$NM/node_modules"

say "FITOUT START wave=$WAVE model=$MODEL skills=$SKILLS_DIR"
"$HERE/bin/scaffold.sh" "$SIM" >"$BASE/scaffold.log" 2>&1 || { say "SCAFFOLD FAILED"; exit 4; }
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
say "FITOUT LEG ${t1-t0}s rc=$rc"

R="$SIM/RIGGING.md"
if [ ! -f "$R" ]; then say "RESULT: no RIGGING.md written — fitting out produced no rigging"; echo FITOUT-DONE; exit 0; fi
say "RIGGING.md written ($(wc -l <"$R") lines)"
if ! grep -q '^## Methods' "$R"; then
  say "RESULT: NO ## Methods SECTION — methods were not derived"
  echo FITOUT-DONE; exit 0
fi

# Every derived method, run in the sim. A method is a claim until it runs.
rmdir "$SIM/node_modules" 2>/dev/null; ln -sfn "$EVAL_SHARED_NM" "$SIM/node_modules"
n=0; ran=0
while IFS= read -r line; do
  name=$(printf '%s' "$line" | sed -n 's/^- \([a-z-]*\):.*/\1/p')
  val=$(printf '%s' "$line" | sed -n 's/^- [a-z-]*: *`\(.*\)`$/\1/p')
  [ -n "$name" ] || continue
  if [ -z "$val" ] || printf '%s' "$line" | grep -q ': *none'; then say "  method $name: none"; continue; fi
  n=$((n+1))
  # {scenario} is a placeholder: substitute the sim's own spec so the run is real.
  run=${val//\{scenario\}/features/tides.feature}
  out="$BASE/method-$name.out"
  ( cd "$SIM" && timeout 300 bash -c "$run" ) >"$out" 2>&1
  mrc=$?
  parts=$(grep -cE '^(== |--yoink|Content-Disposition)' "$out" 2>/dev/null)
  if [ "$mrc" -le 1 ] && [ -s "$out" ]; then ran=$((ran+1)); say "  method $name: RAN (exit $mrc, $(wc -c <"$out") bytes, $parts part markers)"
  else say "  method $name: FAILED (exit $mrc) -> $out"; fi
done < <(sed -n '/^## Methods/,/^## /p' "$R" | grep '^- ')
rm -f "$SIM/node_modules"; mkdir -p "$SIM/node_modules"
say "RESULT: ${ran}/${n} derived methods run clean; mechanism: $(grep -c 'yoink' "$R" || true) yoink refs in rigging"
say "FITOUT END wave=$WAVE"
echo FITOUT-DONE
