#!/usr/bin/env bash
# One round of the fit-out matrix: stacks x models, scored, as a table.
#
# The target (dk, 2026-07-26): deepseek-v4-flash, mimo and hy3 all at 100% - every method the
# Methods section names derived, conformant to the rigging read contract, and actually running. Each
# round is one command so iteration is cheap; flash goes first because it is the cheap canary, and a
# round only moves to the costlier models once flash is clean.
#
# usage: fit-matrix.sh <tag> <model-alias>... [--stacks js,ts,py,rs]
set -uo pipefail
HERE="$(cd "$(dirname "$0")/.." && pwd)"
TAG="${1:?usage: fit-matrix.sh <tag> <model-alias>...}"; shift
STACKS="js,ts,py,rs,go"
MODELS=()
while [ $# -gt 0 ]; do
  case "$1" in
    --stacks) STACKS="$2"; shift 2;;
    *) MODELS+=("$1"); shift;;
  esac
done
[ "${#MODELS[@]}" -gt 0 ] || MODELS=(flash)
alias_of() { case "$1" in
  flash) echo "deepseek/deepseek-v4-flash";;
  mimo)  echo "xiaomi/mimo-v2.5";;
  hy3)   echo "tencent/hy3";;
  *)     echo "$1";;
esac; }

launch() {
  local st="$1" m="$2" w="M-$TAG-$st-$m" to=1800
  [ "$m" = "hy3" ] && to=2700
  [ "$st" = "rs" ] && to=$((to + 900))
  [ "$st" = "go" ] && to=$((to + 300))
  setsid bash -c "$HERE/bin/meth-fitout.sh --wave $w --stack $st --model $(alias_of "$m") --skills-dir $HERE/experiments/methods-candidate/skills --timeout-s $to" \
    > "$HERE/.eval-scratch/$w.nohup" 2>&1 &
  disown
}

IFS=',' read -ra SS <<< "$STACKS"
for m in "${MODELS[@]}"; do for st in "${SS[@]}"; do launch "$st" "$m"; sleep 4; done; done
echo "launched ${#SS[@]} stacks x ${#MODELS[@]} models as M-$TAG-*"

# Wait, then score. Raw is pruned per draw as it lands, not at the end: one leg's raw reached 18G
# and took the disk to ENOSPC mid-round (2026-07-26), voiding two draws.
total=$(( ${#SS[@]} * ${#MODELS[@]} ))
for i in $(seq 1 240); do
  done_n=$(grep -l "FITOUT END" "$HERE"/.eval-scratch/M-$TAG-*/fitout.log 2>/dev/null | wc -l)
  find "$HERE/.eval-scratch" -name pi.stdout -size +200M -exec sh -c ': > "$1"' _ {} \; 2>/dev/null
  [ "$done_n" -ge "$total" ] && break
  sleep 30
done

printf '\n%-18s %-7s %-9s %-9s %-9s %-10s %s\n' wave stack derived violations ran fidelity verdict
pass=0
for w in "$HERE"/.eval-scratch/M-$TAG-*/; do
  n=$(basename "$w"); st=$(echo "$n" | cut -d- -f3)
  r="$w/sim/RIGGING.md"
  if [ ! -f "$r" ]; then printf '%-18s %-7s %s\n' "$n" "$st" "NO RIGGING"; continue; fi
  line=$(python3 "$HERE/bin/rigging-conform.py" "$r" 2>/dev/null | head -1)
  d=$(echo "$line" | grep -o "derived=[0-9]*" | cut -d= -f2)
  v=$(echo "$line" | grep -o "violations=[0-9]*" | cut -d= -f2)
  ran=$(grep -o "RESULT: [0-9]*/[0-9]*" "$w/fitout.log" 2>/dev/null | tail -1 | sed 's/RESULT: //')
  fid=$(python3 "$HERE/bin/example-fidelity.py" "$st" "$w/sim" 2>/dev/null | tail -1 | grep -o "[0-9]*/[0-9]* methods" | cut -d" " -f1)
  ok="no"; [ "${v:-9}" = "0" ] && [ -n "$ran" ] && [ "${ran%%/*}" = "${ran##*/}" ] && { ok="PASS"; pass=$((pass+1)); }
  printf '%-18s %-7s %-9s %-9s %-9s %-10s %s\n' "$n" "$st" "${d:-?}" "${v:-?}" "${ran:-?}" "${fid:-?}" "$ok"
done
echo "PASS $pass of $total"
