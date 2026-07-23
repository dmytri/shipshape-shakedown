#!/usr/bin/env bash
# Run ONE isolated pi eval leg and capture its raw evidence.
#
# The atom the eval rig composes: a probe is one leg, a pilot is many legs
# sequenced (see eval-pilot.sh). A baseline `pi` agent, on a chosen model, reads
# the real installed Shipshape role skill(s) and acts over a scaffolded sim; we
# capture everything raw (session JSONL, stdout/stderr, tree diff, git log) so
# the deterministic fold (eval-map.py) never needs to re-spend a model call.
#
# Isolation is total: a throwaway $HOME/XDG per leg (pi's own config/creds stay
# out of the real home), the sim workspace as cwd, --approve so non-interactive
# -p mode never derails into the confirm/ask loop (proven flake, 2026-07-23).
#
# Usage:
#   eval-leg.sh --model <id> --workspace <dir> --out <dir> \
#     --skill <path> [--skill <path>...] (--task <str> | --task-file <path>) \
#     [--provider openrouter] [--name <leg>] [--timeout-s 900]
#
# The OpenRouter key is read from $OPENROUTER_API_KEY, else mapped from
# ~/yoink/.env's HARNESS_OPENROUTER_API_KEY. Never printed.
set -euo pipefail

PI="${PI_BIN:-$HOME/jolly/node_modules/.bin/pi}"
PROVIDER="openrouter"
MODEL=""; WORKSPACE=""; OUT=""; TASK=""; TASKFILE=""; NAME=""; TIMEOUT_S=900
SKILLS=()

while [ $# -gt 0 ]; do
  case "$1" in
    --model)      MODEL="$2"; shift 2;;
    --provider)   PROVIDER="$2"; shift 2;;
    --workspace)  WORKSPACE="$2"; shift 2;;
    --out)        OUT="$2"; shift 2;;
    --skill)      SKILLS+=("$2"); shift 2;;
    --task)       TASK="$2"; shift 2;;
    --task-file)  TASKFILE="$2"; shift 2;;
    --name)       NAME="$2"; shift 2;;
    --timeout-s)  TIMEOUT_S="$2"; shift 2;;
    *) echo "eval-leg.sh: unknown arg '$1'" >&2; exit 2;;
  esac
done

[ -n "$MODEL" ]     || { echo "eval-leg.sh: --model required" >&2; exit 2; }
[ -n "$WORKSPACE" ] || { echo "eval-leg.sh: --workspace required" >&2; exit 2; }
[ -n "$OUT" ]       || { echo "eval-leg.sh: --out required" >&2; exit 2; }
[ -d "$WORKSPACE" ] || { echo "eval-leg.sh: workspace '$WORKSPACE' not a dir" >&2; exit 2; }
[ "${#SKILLS[@]}" -gt 0 ] || { echo "eval-leg.sh: at least one --skill required" >&2; exit 2; }
[ -x "$PI" ] || { echo "eval-leg.sh: pi not found/executable at $PI (set PI_BIN)" >&2; exit 2; }
if [ -n "$TASKFILE" ]; then
  [ -f "$TASKFILE" ] || { echo "eval-leg.sh: --task-file '$TASKFILE' missing" >&2; exit 2; }
  TASK="$(cat "$TASKFILE")"
fi
[ -n "$TASK" ] || { echo "eval-leg.sh: --task or --task-file required" >&2; exit 2; }
[ -n "$NAME" ] || NAME="$(basename "$OUT")"

# Fitting-out blocker, loud: an absent key must fail, never skip green.
if [ -z "${OPENROUTER_API_KEY:-}" ]; then
  if [ -f "$HOME/yoink/.env" ]; then
    OPENROUTER_API_KEY="$(grep -E '^HARNESS_OPENROUTER_API_KEY=' "$HOME/yoink/.env" | head -1 | cut -d= -f2-)"
  fi
fi
[ -n "${OPENROUTER_API_KEY:-}" ] || { echo "eval-leg.sh: no OPENROUTER_API_KEY (and none in ~/yoink/.env) — fitting-out blocker" >&2; exit 3; }

mkdir -p "$OUT"
FAKEHOME="$OUT/home"; SESSDIR="$OUT/session"
mkdir -p "$FAKEHOME/.config" "$FAKEHOME/.local/share" "$FAKEHOME/.cache" "$FAKEHOME/tmp" "$SESSDIR"

# Assemble --skill flags.
SKILL_ARGS=()
for s in "${SKILLS[@]}"; do
  [ -e "$s" ] || { echo "eval-leg.sh: --skill path '$s' missing" >&2; exit 2; }
  SKILL_ARGS+=(--skill "$s")
done

# Leg meta (banked with the raw so a fold knows what produced it).
python3 - "$OUT/leg.json" "$NAME" "$MODEL" "$PROVIDER" "$WORKSPACE" "$TIMEOUT_S" "${SKILLS[@]}" <<'PY'
import json, sys
out, name, model, provider, ws, timeout, *skills = sys.argv[1:]
json.dump({"name": name, "model": model, "provider": provider,
           "workspace": ws, "timeout_s": int(timeout), "skills": skills},
          open(out, "w"), indent=2)
PY

echo "eval-leg[$NAME]: $MODEL over $(basename "$WORKSPACE"), skills: ${SKILLS[*]##*/skills/}" >&2

# The isolated, CONTAINED run. bwrap gives pi a READ-ONLY view of the whole VM
# and writable access to ONLY the sim workspace, the fake HOME, and the capture
# dir — so a leg that wanders (they do) can READ but can NEVER WRITE the cockpit,
# the source fixture, doctrine, or a consumer repo. Detection alone let an escaped
# leg clobber AGENTS.md and the fixture (2026-07-23); this makes that impossible.
# --approve neutralises the confirm derail; --mode json writes the session to SESSDIR.
PI_ARGS=(-p "$TASK" --provider "$PROVIDER" --model "$MODEL" --approve --mode json
         "${SKILL_ARGS[@]}" --session-dir "$SESSDIR")
ENVV=(HOME="$FAKEHOME" XDG_CONFIG_HOME="$FAKEHOME/.config"
      XDG_DATA_HOME="$FAKEHOME/.local/share" XDG_CACHE_HOME="$FAKEHOME/.cache"
      TMPDIR="$FAKEHOME/tmp" PATH="$PATH" OPENROUTER_API_KEY="$OPENROUTER_API_KEY")
set +e
if command -v bwrap >/dev/null 2>&1; then
  BW=(bwrap --ro-bind / / --dev /dev --proc /proc
      --bind "$WORKSPACE" "$WORKSPACE" --bind "$OUT" "$OUT" --bind "$FAKEHOME" "$FAKEHOME"
      --share-net --chdir "$WORKSPACE" --clearenv)
  for kv in "${ENVV[@]}"; do BW+=(--setenv "${kv%%=*}" "${kv#*=}"); done
  timeout "${TIMEOUT_S}s" "${BW[@]}" "$PI" "${PI_ARGS[@]}" >"$OUT/pi.stdout" 2>"$OUT/pi.stderr"
  EXIT=$?
else
  echo "eval-leg[$NAME]: WARN bwrap missing — running UNCONTAINED (repo-damage risk)" >&2
  env -i "${ENVV[@]}" timeout "${TIMEOUT_S}s" "$PI" "${PI_ARGS[@]}" >"$OUT/pi.stdout" 2>"$OUT/pi.stderr"
  EXIT=$?
fi
set -e
echo "$EXIT" > "$OUT/exit"

# Capture the session JSONL at a stable name for the fold.
SF="$(find "$SESSDIR" -name '*.jsonl' | sort | tail -1 || true)"
if [ -n "$SF" ]; then cp "$SF" "$OUT/session.jsonl"; fi

# Tree facts: what the leg did to the sim (the affordance evidence). Keep the
# FULL patch, not just the stat — evaluating the QUALITY of the @planks/@captain
# artifacts a model produced needs the real content, and the workspace itself is
# scratch that dies with the VM, so the patch is the only durable copy.
git -C "$WORKSPACE" add -A >/dev/null 2>&1 || true
git -C "$WORKSPACE" status --porcelain > "$OUT/tree.status" 2>/dev/null || true
git -C "$WORKSPACE" diff --cached --stat > "$OUT/tree.diffstat" 2>/dev/null || true
git -C "$WORKSPACE" -c core.pager=cat diff --cached > "$OUT/tree.diff" 2>/dev/null || true
git -C "$WORKSPACE" reset -q >/dev/null 2>&1 || true
git -C "$WORKSPACE" log --oneline -10 > "$OUT/git.log" 2>/dev/null || true
# The agent's own rendered stdout (final report + narration) kept verbatim; the
# session JSONL is the structured transcript, this is the human-readable form.
# Both are banked so a later evaluator has maximum detail.

# Containment check: did the leg wander OUT of the sim into a real repo on the VM?
# A leg that inspects ~/shipshape (doctrine), the cockpit, or a consumer repo is
# not inspecting the sim, so its verdict is invalid and must be excluded from any
# clear-rate. The skill dirs live under .claude and never match these repo names.
if [ -f "$OUT/session.jsonl" ]; then
  ESC="$(python3 - "$OUT/session.jsonl" <<'PY'
import json, sys, re
# Scan only the model's OWN tool calls (bash/read/ls/find args), never the task
# prompt echo, for access to a real repo on the VM outside the sim.
pat = re.compile(r'/home/[a-z]+/(?:shipshape|shipshape-shakedown|jolly|yoink|swamp)[a-zA-Z0-9_-]*')
hits = set()
for line in open(sys.argv[1], encoding='utf-8'):
    try:
        e = json.loads(line)
    except Exception:
        continue
    m = e.get('message') or {}
    if m.get('role') != 'assistant':
        continue
    for p in m.get('content') or []:
        if p.get('type') == 'toolCall':
            hits.update(pat.findall(json.dumps(p.get('arguments', {}))))
print(' '.join(sorted(hits)))
PY
)"
  if [ -n "$ESC" ]; then
    echo "$ESC" > "$OUT/escaped"
    echo "eval-leg[$NAME]: ESCAPED the sim — touched: $ESC (leg INVALID for clear-rate)" >&2
  fi
fi

if [ "$EXIT" -eq 124 ]; then
  echo "eval-leg[$NAME]: TIMED OUT after ${TIMEOUT_S}s (exit 124)" >&2
elif [ "$EXIT" -ne 0 ]; then
  echo "eval-leg[$NAME]: pi exit $EXIT (see $OUT/pi.stderr)" >&2
fi
[ -n "$SF" ] || { echo "eval-leg[$NAME]: NO session jsonl produced — leg is void" >&2; exit 4; }
echo "eval-leg[$NAME]: captured -> $OUT (exit $EXIT)" >&2
