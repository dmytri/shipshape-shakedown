#!/usr/bin/env bash
# Audit ONE fitting-out draw's derived methods, and RUN every one of them.
#
# Separate from meth-fitout.sh so a draw's audit can be re-run without spending another leg (the
# first version's parser required backticked values and a draw that wrote them bare read as
# all-`none` — an instrument bug that would have been reported as a doctrine failure).
#
# usage: meth-fitout-audit.sh <wave-dir>          e.g. .eval-scratch/methfit-3
set -uo pipefail
HERE="$(cd "$(dirname "$0")/.." && pwd)"
BASE="${1:?usage: meth-fitout-audit.sh <wave-dir>}"
SIM="$BASE/sim"; R="$SIM/RIGGING.md"
SCRATCH="${EVAL_SCRATCH:-$HERE/.eval-scratch}"
NM="$SCRATCH/.shared-nm-$(basename "$BASE")"; [ -d "$NM/node_modules" ] || NM="$SCRATCH/.shared-nm"
say(){ echo "[audit] $*"; }

[ -f "$R" ] || { say "no RIGGING.md — fitting out produced no rigging"; exit 0; }
say "RIGGING.md $(wc -l <"$R") lines; backticked command values: $(grep -cE '^- [a-z-]+: *`' "$R")"
grep -q '^## Methods' "$R" || { say "NO ## Methods SECTION — methods were not derived"; exit 0; }

rmdir "$SIM/node_modules" 2>/dev/null || rm -f "$SIM/node_modules" 2>/dev/null
ln -sfn "$NM/node_modules" "$SIM/node_modules"
n=0; ran=0; nones=0
while IFS= read -r line; do
  name=$(printf '%s' "$line" | sed -n 's/^- \([a-z-]*\):.*/\1/p')
  [ -n "$name" ] || continue
  # value with OPTIONAL surrounding backticks — a draw may write either, and the shape's backtick
  # rule is a separate conformance question from whether the method itself is sound.
  val=$(printf '%s' "$line" | sed 's/^- [a-z-]*: *//; s/^`//; s/`$//')
  case "$val" in
    none|None|NONE|"") say "  $name: none"; nones=$((nones+1)); continue;;
  esac
  n=$((n+1))
  run=${val//\{scenario\}/features/tides.feature}
  run=${run//\{Scenario\}/features/tides.feature}
  out="$BASE/method-$name.out"
  ( cd "$SIM" && timeout 300 bash -c "$run" ) >"$out" 2>&1
  mrc=$?
  parts=$(grep -cE '^(== |--yoink|Content-Disposition: form-data; name="metadata")' "$out" 2>/dev/null || true)
  # A method "ran" when the invocation completed and its parts are separately legible. A non-zero
  # exit is not failure per se: a part like plank-inventory greps and legitimately exits 1 on no
  # match, which is exactly why doctrine wants per-part status rather than one collapsed code.
  if [ "$mrc" -lt 124 ] && [ -s "$out" ] && [ "${parts:-0}" -ge 2 ]; then
    ran=$((ran+1)); say "  $name: RAN ($parts parts legible, exit $mrc, $(wc -c <"$out") bytes)"
  else
    say "  $name: FAILED (exit $mrc, $parts parts, $(wc -c <"$out") bytes) -> $out"
  fi
done < <(sed -n '/^## Methods/,/^## [A-Z]/p' "$R" | grep '^- ')
rm -f "$SIM/node_modules"; mkdir -p "$SIM/node_modules"
say "RESULT: $ran/$n derived methods run with parts legible; $nones written none; mechanism: $(grep -c yoink "$R" || true) yoink refs"
