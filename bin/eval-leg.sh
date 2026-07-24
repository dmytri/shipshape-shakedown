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
# Key resolution, cockpit-first (dk 2026-07-24): an explicit env var wins; else the
# cockpit's OWN gitignored .env (so the harness owns its credential, not the consumer
# repo); else the ~/yoink/.env consumer fallback, kept for back-compat. .env carries
# OPENROUTER_API_KEY=...; ~/yoink/.env carries HARNESS_OPENROUTER_API_KEY=...
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
if [ -z "${OPENROUTER_API_KEY:-}" ] && [ -f "$REPO_ROOT/.env" ]; then
  OPENROUTER_API_KEY="$(grep -E '^OPENROUTER_API_KEY=' "$REPO_ROOT/.env" | head -1 | cut -d= -f2-)"
fi
if [ -z "${OPENROUTER_API_KEY:-}" ] && [ -f "$HOME/yoink/.env" ]; then
  OPENROUTER_API_KEY="$(grep -E '^HARNESS_OPENROUTER_API_KEY=' "$HOME/yoink/.env" | head -1 | cut -d= -f2-)"
fi
[ -n "${OPENROUTER_API_KEY:-}" ] || { echo "eval-leg.sh: no OPENROUTER_API_KEY (not in env, cockpit .env, or ~/yoink/.env) — fitting-out blocker" >&2; exit 3; }

mkdir -p "$OUT"
FAKEHOME="$OUT/home"; SESSDIR="$OUT/session"
mkdir -p "$FAKEHOME/.config" "$FAKEHOME/.local/share" "$FAKEHOME/.cache" "$FAKEHOME/tmp" "$SESSDIR"

# The fixture's cucumber run-log ledger (features/support/runlog.js BeforeAll) writes
# to a `.instrument` dir in the sim's PARENT, OUTSIDE the project root — the deckstate
# run-record pattern. Under bwrap's --ro-bind / / that parent is read-only, so mkdirSync
# throws (EROFS/ENOENT), BeforeAll aborts, and the ENTIRE suite fails before any scenario
# runs — every leg (found 2026-07-23, workhorse x10: all 16 legs hit it; d10 produced
# nothing, sunk fighting it). Give ONLY this sibling dir a writable bind: the suite can
# run, and the cockpit/doctrine/fixture-source stay read-only (escape-damage still blocked).
INSTR="$(dirname "$WORKSPACE")/.instrument"; mkdir -p "$INSTR"

# Assemble --skill flags. Resolve to ABSOLUTE paths: the leg runs chdir'd into the sim
# under a tight bind, so a relative skill path would not resolve, and each skill dir is
# bind-mounted read-only BY ABSOLUTE PATH (so nothing else under experiments/ is exposed).
SKILL_ARGS=(); SKILLS_ABS=()
for s in "${SKILLS[@]}"; do
  [ -e "$s" ] || { echo "eval-leg.sh: --skill path '$s' missing" >&2; exit 2; }
  s="$(realpath "$s")"
  SKILLS_ABS+=("$s"); SKILL_ARGS+=(--skill "$s")
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

# The isolated, CONTAINED run. --approve neutralises the confirm derail; --mode json
# writes the session to SESSDIR.
PI_ARGS=(-p "$TASK" --provider "$PROVIDER" --model "$MODEL" --approve --mode json
         "${SKILL_ARGS[@]}" --session-dir "$SESSDIR")
ENVV=(HOME="$FAKEHOME" XDG_CONFIG_HOME="$FAKEHOME/.config"
      XDG_DATA_HOME="$FAKEHOME/.local/share" XDG_CACHE_HOME="$FAKEHOME/.cache"
      TMPDIR="$FAKEHOME/tmp" PATH="$PATH" OPENROUTER_API_KEY="$OPENROUTER_API_KEY")
set +e
if command -v bwrap >/dev/null 2>&1; then
  # MINIMAL read exposure (dk 2026-07-23). NOT `--ro-bind / /`: that left the ENTIRE VM
  # readable, so a leg could read the cockpit (CAPTAIN.md), OTHER candidates under
  # experiments/ (a control leg reading the treatment skill = silent A/B contamination),
  # other legs' data/, and consumer secrets (~/yoink/.env holds the API key). Now nothing
  # under /home is bound wholesale: the leg sees ONLY the runtime (/usr + node/npm), pi's
  # own dep tree, the specific --skill dirs under test, and its sim/HOME/capture. The
  # cockpit, sibling experiments, other legs, and every consumer repo are INVISIBLE.
  PI_NM="$(cd "$(dirname "$PI")/.." && pwd)"   # pi's node_modules root (pi + its deps)
  BW=(bwrap
      --ro-bind /usr /usr --ro-bind /etc /etc
      --symlink usr/bin /bin --symlink usr/sbin /sbin
      --symlink usr/lib /lib --symlink usr/lib64 /lib64
      --ro-bind-try /opt /opt --ro-bind-try /run /run
      --proc /proc --dev /dev
      --ro-bind "$PI_NM" "$PI_NM")
  for s in "${SKILLS_ABS[@]}"; do BW+=(--ro-bind "$s" "$s"); done
  BW+=(--bind "$WORKSPACE" "$WORKSPACE" --bind "$OUT" "$OUT" --bind "$FAKEHOME" "$FAKEHOME"
       --bind "$INSTR" "$INSTR")
  # Isolated node_modules via overlay: the shared toolkit ($EVAL_SHARED_NM, from
  # eval-batch) as a READ-ONLY base + a per-leg tmpfs writable upper. The leg installs
  # anything it wants into the upper; the shared store never mutates and nothing persists
  # to disk (bwrap 0.11.2). scaffold.sh leaves an empty node_modules dir as the mountpoint.
  if [ -n "${EVAL_SHARED_NM:-}" ] && [ -d "$EVAL_SHARED_NM/@cucumber" ]; then
    BW+=(--overlay-src "$EVAL_SHARED_NM" --tmp-overlay "$WORKSPACE/node_modules")
  fi
  BW+=(--share-net --chdir "$WORKSPACE" --clearenv)
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
# clear-rate.
#
# The leg's OWN bound subtrees are NOT escapes and must be whitelisted, or every
# legitimate in-sim path false-flags (2026-07-24, first full-lifecycle pilot): the
# sim workspace lives UNDER the cockpit repo (…/shipshape-shakedown/.eval-scratch/…),
# and the `--skill` dirs live under the cockpit (experiments/<cand>/skills) and the
# consumer repo (~/yoink/skills) — all three match the repo regex. bwrap exposes only
# the bound skill LEAVES, so listing their parent `…/skills/` dir reveals nothing but
# the leg's own skills either; whitelist the parent too. Anything still matching after
# the whitelist is a genuine reach into a repo the leg was never given.
if [ -f "$OUT/session.jsonl" ]; then
  ESC="$(python3 - "$OUT/session.jsonl" "$WORKSPACE" "$OUT" "$INSTR" "${SKILLS_ABS[@]}" <<'PY'
import json, sys, re, os
session, ws, out, instr, *skills = sys.argv[1:]
# Allowlist: the leg's own bound subtrees (and each skill's parent, since bwrap only
# exposes the bound leaves under it). Longest-first so nested prefixes strip cleanly.
allow = [ws, out, instr] + list(skills) + [os.path.dirname(s) for s in skills]
allow = sorted(set(a for a in allow if a), key=len, reverse=True)
pat = re.compile(r'/home/[a-z]+/(?:shipshape|shipshape-shakedown|jolly|yoink|swamp)[a-zA-Z0-9_-]*')
hits = set()
for line in open(session, encoding='utf-8'):
    try:
        e = json.loads(line)
    except Exception:
        continue
    m = e.get('message') or {}
    if m.get('role') != 'assistant':
        continue
    for p in m.get('content') or []:
        if p.get('type') == 'toolCall':
            s = json.dumps(p.get('arguments', {}))
            for a in allow:            # blank the leg's own bound paths before matching
                s = s.replace(a, '')
            hits.update(pat.findall(s))
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
