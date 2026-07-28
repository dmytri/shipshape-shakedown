#!/usr/bin/env bash
# Run ONE isolated pi eval leg and capture its raw evidence.
#
# The atom the eval rig composes: a probe is one leg, a pilot is many legs
# sequenced (see eval-pilot.sh). A baseline `pi` agent, on a chosen model, gets the
# Shipshape role skill(s) THE NORMAL WAY and acts over a scaffolded sim; we capture
# everything raw (session JSONL, stdout/stderr, tree diff, git log) so the
# deterministic fold (eval-map.py) never needs to re-spend a model call.
#
# NORMAL LAUNCH (dk 2026-07-24): no `--skill`, no tool allow/deny. Each `--skill <dir>`
# names a skill to INSTALL via the canonical `skills` CLI (`npx skills add dmytri/shipshape
# --skill '*'`, the shipshape README's own pi command; NOT `pi install`, which is for
# extensions). The leg stages the dirs and `skills add -g`s them into the isolated HOME's
# pi agent skills dir, then launches pi with NO --skill so pi DISCOVERS and loads them
# itself — the leg exercises the doctrine as a real pi user's session does.
#
# Isolation is total: a throwaway $HOME/XDG per leg (pi's own config/creds and the install
# stay out of the real home), the sim workspace as cwd, --approve to trust project-local
# files in headless -p mode (the equivalent of a user trusting their own project).
#
# Usage:
#   eval-leg.sh --model <id> --workspace <dir> --out <dir> \
#     --skill <path> [--skill <path>...] (--task <str> | --task-file <path>) \
#     [--provider openrouter] [--name <leg>] [--timeout-s 900]
#   (--skill <dir> = a skill directory to INSTALL for this leg; not passed to pi as a flag.)
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

# UNIFORM OUTPUT BUDGET (dk, 2026-07-28). pi takes `model.max_tokens ?? 4096` from provider
# metadata, and OpenRouter does not expose that field the way pi reads it — so xiaomi/mimo-v2.5
# and tencent/hy3 got 131072 while deepseek-v4-flash fell back to 4096. Every flash leg was
# running on a 32x tighter budget than its peers, which is a per-model handicap no doctrine
# caused: candidate Captain legs truncated 9/12 on flash and 0/12 elsewhere.
#
# The fix is NOT to raise flash. A tight budget is a FORCING FUNCTION: it exposes work that
# only completes by reasoning without bound, and it makes every arm comparable. Truncated
# Captain turns were spending ~16k characters mentally simulating render() to explain a failure
# their tier cannot reproduce — behaviour worth surfacing, not accommodating. So cap EVERY model
# at the same budget and let doctrine that cannot act within it show itself.
# 32768, chosen from measured peaks rather than taste (bin/peaks.py, 2026-07-28). Every
# PRODUCTIVE peak observed sits under it — cand-mimo v3-captain 28,295 ending in a write,
# ctrl-chy3 sw-final 31,665 ending in a bash run, cand-hy3 v2-qm 21,377 ending in reads — while
# the one pathological peak sits above: ctrl-cmimo v5-qm burned its full 131,072 on 564,744
# characters of thinking and emitted NO text and NO tool call. The cap does not cause that
# pathology, it only changes how it appears: a tight budget turns rumination into truncation
# (flash, 9 cut-off Captain legs), a generous one lets it finish as an expensive no-op. So the
# budget is set to admit deliberation that ENDS IN AN ACTION and to cut deliberation that does
# not, uniformly for every model.
# Override per run with EVAL_MAX_TOKENS; set 0 to disable the seeding entirely.
EVAL_MAX_TOKENS="${EVAL_MAX_TOKENS:-32768}"
if [ "$EVAL_MAX_TOKENS" != "0" ] && [ -f "$HOME/.pi/agent/models-store.json" ]; then
  mkdir -p "$FAKEHOME/.pi/agent"
  python3 - "$HOME/.pi/agent/models-store.json" "$FAKEHOME/.pi/agent/models-store.json" \
           "$EVAL_MAX_TOKENS" "$(date +%s%3N)" <<'PY' || true
import json, sys
src, dst, cap, now = sys.argv[1], sys.argv[2], int(sys.argv[3]), int(sys.argv[4])
try:
    store = json.load(open(src))
except Exception:
    sys.exit(0)
for prov in store.values():
    if isinstance(prov, dict):
        for m in prov.get("models", []) or []:
            # SET, do not min(). min() lowers a model above the cap but leaves a model BELOW it
            # exactly as it was — which preserved the very handicap this exists to remove:
            # deepseek-v4-flash stayed at 4096 while mimo and hy3 moved to 32768, and a matrix
            # launched that way is not one experiment, it is two. Every model gets the SAME
            # number. (2026-07-28, caught in preflight of the R1 matrix and the run restarted.)
            if isinstance(m, dict) and m.get("maxTokens"):
                m["maxTokens"] = cap
        prov["checkedAt"] = now          # fresh, so pi does not refetch and overwrite the cap
json.dump(store, open(dst, "w"))
PY
fi

# The fixture's cucumber run-log ledger (features/support/runlog.js BeforeAll) writes
# to a `.instrument` dir in the sim's PARENT, OUTSIDE the project root — the deckstate
# run-record pattern. Under bwrap's --ro-bind / / that parent is read-only, so mkdirSync
# throws (EROFS/ENOENT), BeforeAll aborts, and the ENTIRE suite fails before any scenario
# runs — every leg (found 2026-07-23, workhorse x10: all 16 legs hit it; d10 produced
# nothing, sunk fighting it). Give ONLY this sibling dir a writable bind: the suite can
# run, and the cockpit/doctrine/fixture-source stay read-only (escape-damage still blocked).
INSTR="$(dirname "$WORKSPACE")/.instrument"; mkdir -p "$INSTR"

# Install skills the NORMAL way (dk 2026-07-24): NO --skill runtime flag. `pi install` is
# for EXTENSIONS; skills have their own canonical installer — the `skills` CLI (`npx skills
# add dmytri/shipshape --skill '*'`, the shipshape README's own pi command), which lands
# `<role>/SKILL.md` under the pi agent skills dir + a skills-lock.json, exactly as jolly (a
# real Shipshape-pi project) is set up. pi then DISCOVERS and loads them itself — the leg
# exercises the doctrine as a real pi user's session does. Stage the skill dirs as a source
# tree (skills/<name>/SKILL.md; the CLI takes a local path) and `skills add -g` into the
# isolated HOME so they install GLOBALLY (all roles available every leg, as a real user has
# it) and the sim tree stays clean. The staging holds ONLY skill dirs — no repo, no secrets.
# Resolve the `skills` CLI robustly: the shared toolkit (stable — installed by the pilot/
# batch scripts) first, then the npx cache (EPHEMERAL — evicted between runs, which broke a
# whole batch 2026-07-25), then $SKILLS_BIN override.
SKILLS_BIN="${SKILLS_BIN:-}"
[ -x "$SKILLS_BIN" ] || { [ -n "${EVAL_SHARED_NM:-}" ] && [ -x "$EVAL_SHARED_NM/.bin/skills" ] && SKILLS_BIN="$EVAL_SHARED_NM/.bin/skills"; }
[ -x "$SKILLS_BIN" ] || SKILLS_BIN="$(ls "$HOME"/.npm/_npx/*/node_modules/.bin/skills 2>/dev/null | head -1)"
[ -x "$SKILLS_BIN" ] || { echo "eval-leg.sh: 'skills' CLI not found (install into \$EVAL_SHARED_NM or set SKILLS_BIN)" >&2; exit 3; }
SKILLPKG="$OUT/skillsrc"; rm -rf "$SKILLPKG"; mkdir -p "$SKILLPKG/skills"
SKILLS_ABS=()
for s in "${SKILLS[@]}"; do
  [ -e "$s" ] || { echo "eval-leg.sh: --skill path '$s' missing" >&2; exit 2; }
  s="$(realpath "$s")"; SKILLS_ABS+=("$s")
  cp -r "$s" "$SKILLPKG/skills/$(basename "$s")"
done
# Local path => no network; installs into $FAKEHOME/.pi/agent/skills. Isolated HOME, so
# nothing leaks to the real config. `--agent pi` scopes to pi (not all 75 known agents).
env -i HOME="$FAKEHOME" XDG_CONFIG_HOME="$FAKEHOME/.config" \
    XDG_DATA_HOME="$FAKEHOME/.local/share" XDG_CACHE_HOME="$FAKEHOME/.cache" \
    TMPDIR="$FAKEHOME/tmp" PATH="$PATH" \
    "$SKILLS_BIN" add "$SKILLPKG" --skill '*' --agent pi --copy -g -y >"$OUT/skills-add.log" 2>&1 \
  || { echo "eval-leg[$NAME]: 'skills add' failed (see $OUT/skills-add.log)" >&2; exit 3; }

# Leg meta (banked with the raw so a fold knows what produced it).
python3 - "$OUT/leg.json" "$NAME" "$MODEL" "$PROVIDER" "$WORKSPACE" "$TIMEOUT_S" "$EVAL_MAX_TOKENS" "${SKILLS[@]}" <<'PY'
import json, sys
# max_tokens is recorded per leg so a later reader can tell what budget a result was produced
# under. A peak near the cap means the budget shaped the run; a peak far below means it did not.
out, name, model, provider, ws, timeout, maxtok, *skills = sys.argv[1:]
json.dump({"name": name, "model": model, "provider": provider,
           "workspace": ws, "timeout_s": int(timeout), "max_tokens": int(maxtok),
           "skills": skills},
          open(out, "w"), indent=2)
PY

echo "eval-leg[$NAME]: $MODEL over $(basename "$WORKSPACE"), skills: ${SKILLS[*]##*/skills/}" >&2

# The isolated, CONTAINED run — launched NORMALLY: no --skill (skills come from the install
# above, by discovery), no tool allow/deny. --approve trusts project-local files (the headless
# equivalent of a real user trusting their project); --mode json writes the session to SESSDIR.
PI_ARGS=(-p "$TASK" --provider "$PROVIDER" --model "$MODEL" --approve --mode json
         --session-dir "$SESSDIR")
ENVV=(HOME="$FAKEHOME" XDG_CONFIG_HOME="$FAKEHOME/.config"
      XDG_DATA_HOME="$FAKEHOME/.local/share" XDG_CACHE_HOME="$FAKEHOME/.cache"
      TMPDIR="$FAKEHOME/tmp" PATH="$PATH" OPENROUTER_API_KEY="$OPENROUTER_API_KEY"
      # Go resolves modules from a SHARED read-only cache under /opt (already --ro-bind-try'd),
      # the analogue of the shared node_modules and the cargo registry. Nothing is vendored
      # (dk, 2026-07-27), and a leg's build cache stays in its own XDG_CACHE_HOME.
      GOMODCACHE="/opt/gotools/pkg/mod" GOFLAGS="-mod=mod"
      # HEAP CAP (2026-07-27). A pilot suite reached 12.6G RSS and the kernel OOM-killed it on
      # this 16G swapless box, taking the voyage's only evidence with it: the suite output ended
      # "Killed" with no summary line, so the readout was unknown and the voyage was scored on
      # nothing. The known cause class is an assertion over circular happy-dom DOM nodes (a
      # naive deep-equal serialises the whole tree). A capped heap turns that into "JavaScript
      # heap out of memory" INSIDE the leg — legible, attributable, and something a role can
      # engineer out per the Verification agreement — instead of a silent kernel kill that can
      # also take out sibling waves or the operator's own session.
      NODE_OPTIONS="--max-old-space-size=2048")
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
  # Skills are installed into $FAKEHOME/.pi/agent/skills (the $FAKEHOME bind covers it) and
  # discovered from the fake HOME — no per-skill bind, no --skill. The original skill sources
  # are NOT exposed; only the operator-authored copy (staged under $OUT/skillsrc) is.
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
  # Retry the transient bwrap overlay-mount failure ("Can't make overlay mount"), which hits
  # intermittently when several parallel legs overlay the same shared node_modules lowerdir
  # (2026-07-25). The failure means the leg never started, so a retry is safe and usually wins.
  # Also retry a transient provider RATE-LIMIT (429): the leg produced no useful work, so
  # back off and retry (upstream throttling, e.g. minimax-m3 via Parasail, 2026-07-25).
  for attempt in 1 2 3 4 5 6; do
    timeout "${TIMEOUT_S}s" "${BW[@]}" "$PI" "${PI_ARGS[@]}" >"$OUT/pi.stdout" 2>"$OUT/pi.stderr"
    EXIT=$?
    if grep -q "Can't make overlay mount\|Unable to create overlay" "$OUT/pi.stderr" 2>/dev/null; then
      echo "eval-leg[$NAME]: overlay mount failed (attempt $attempt) — retrying in ${attempt}s" >&2; sleep "$attempt"; continue
    fi
    if grep -q '"stopReason":"error"' "$OUT/pi.stdout" 2>/dev/null && grep -qiE '429|rate-?limit|temporarily rate|Provider returned error' "$OUT/pi.stdout" 2>/dev/null; then
      echo "eval-leg[$NAME]: provider rate-limited/error (attempt $attempt) — backing off $((attempt*15))s" >&2; sleep $((attempt*15)); continue
    fi
    break
  done
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
