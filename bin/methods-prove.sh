#!/usr/bin/env bash
# Register a stack's methods in its own task runner, then PROVE each one by running it.
#
# Doctrine says a method that has never run is a claim, and the same standard binds the operator who
# writes a reference rigging. This scaffolds the stack, registers the entries (npm scripts, Poe tasks
# in pyproject.toml, cargo aliases), writes the RIGGING.md Methods block whose values invoke them,
# and runs every method, reporting each one's part labels and exit.
#
# usage: methods-prove.sh <js|ts|py|rs> [target-dir]
set -uo pipefail
HERE="$(cd "$(dirname "$0")/.." && pwd)"
STACK="${1:?usage: methods-prove.sh <js|ts|py|rs> [target]}"
SIM="${2:-/tmp/claude-1000/-home-exedev-shipshape-shakedown/53e4d3d2-8b20-4554-9b5f-0503134482fc/scratchpad/prove-$STACK}"
ENTRIES="$HERE/assets/methods/$STACK.json"
[ -f "$ENTRIES" ] || { echo "no method entries for stack '$STACK'"; exit 2; }

rm -rf "$SIM"
EVAL_SHARED_NM="$HERE/.eval-scratch/.shared-nm/node_modules" "$HERE/bin/scaffold-stack.sh" "$STACK" "$SIM" >/dev/null 2>&1 \
  || { echo "scaffold failed"; exit 3; }
cd "$SIM"
[ -e node_modules ] && rm -rf node_modules
ln -sfn "$HERE/.eval-scratch/.shared-nm/node_modules" node_modules

# A derived tool needs its config, or its method fails on the config rather than on the code. The
# fit writes them; this reference rigging writes the same ones.
cp "$HERE/assets/gplintrc-default.json" .gplintrc 2>/dev/null || true
case "$STACK" in
  js|ts) [ -f biome.json ] || printf '{\n  "files": { "includes": ["src/**", "features/**"] },\n  "linter": { "enabled": true }\n}\n' > biome.json;;
esac
mkdir -p .shipshape
case "$STACK" in
  ts) cp "$HERE/assets/methods/planks-typescript.yml" .shipshape/planks.yml;;
  py) cp "$HERE/assets/methods/planks-python.yml" .shipshape/planks.yml; cp "$HERE/assets/methods/steps-python.yml" .shipshape/steps.yml;;
  rs) cp "$HERE/assets/methods/planks-rust.yml" .shipshape/planks.yml;;
esac

# Register the plans where this stack keeps its tasks, and write the values that invoke them.
python3 - "$ENTRIES" "$STACK" "$SIM" <<'PY'
import json, os, sys
entries, stack, sim = json.load(open(sys.argv[1])), sys.argv[2], sys.argv[3]
names = [k.split(":", 1)[1] for k in entries]
if stack in ("js", "ts"):
    pkg = json.load(open(os.path.join(sim, "package.json")))
    pkg.setdefault("scripts", {}).update(entries)
    json.dump(pkg, open(os.path.join(sim, "package.json"), "w"), indent=2)
    value = lambda n: f"npm run ss:{n} --silent"
elif stack == "py":
    p = os.path.join(sim, "pyproject.toml")
    s = open(p).read()
    if "[tool.poe.tasks]" not in s:
        s = s.rstrip() + "\n\n[tool.poe.tasks]\n"
    # TOML literal strings: a plan carries both quote kinds, so a basic string breaks on the first
    # inner double quote, which is exactly what it did.
    q = "'" * 3
    s += "".join(f'"{k}" = {{ shell = {q}{v}{q} }}\n' for k, v in entries.items())
    open(p, "w").write(s)
    value = lambda n: f"uv run poe ss:{n}"
else:
    p = os.path.join(sim, ".cargo/config.toml")
    os.makedirs(os.path.dirname(p), exist_ok=True)
    open(p, "w").write("[alias]\n" + "".join(f'ss-{k.split(":",1)[1]} = "!{v}"\n' for k, v in entries.items()))
    value = lambda n: f"cargo ss-{n}"

ALL = ["prove", "verify", "sweep", "plank-join", "hygiene", "static", "discovery",
       "regression", "condemnation", "dead-code", "spec-lint", "install", "ship", "ship-verify"]
TAKES = {"prove": "SS_SCENARIO", "verify": "SS_SCENARIO", "condemnation": "SS_SCENARIO", "install": "SS_DEPENDENCY"}
lines = []
for n in ALL:
    if n not in names:
        lines.append(f"- {n}: none")
        continue
    v = value(n)
    lines.append(f"- {n}: `{TAKES[n] + '=\"{target}\" ' if n in TAKES else ''}{v}`".replace('{target}', "$" + TAKES[n] if n in TAKES else ""))
open(os.path.join(sim, "METHODS.block"), "w").write("## Methods\n\n" + "\n".join(lines) + "\n")
print("\n".join(lines))
PY

echo
echo "=== proving each method by running it (stack: $STACK)"
python3 - "$ENTRIES" "$STACK" "$SIM" <<'PY'
import json, os, re, subprocess, sys
entries, stack, sim = json.load(open(sys.argv[1])), sys.argv[2], sys.argv[3]
scen = {"js": "Next high tide after a given time", "ts": "Next high tide after a given time",
        "py": "Next high tide after a given time", "rs": "Next high tide after a given time"}[stack]
inv = {"js": "npm run {n} --silent", "ts": "npm run {n} --silent",
       "py": "uv run poe {n}", "rs": "cargo ss-{k}"}[stack]
env = dict(os.environ, SS_SCENARIO=scen, SS_DEPENDENCY="left-pad")
for k in entries:
    if k.endswith("install"):
        print(f"  {k.split(':')[1]:14s} skipped (would mutate the manifest)")
        continue
    cmd = inv.format(n=k, k=k.split(":", 1)[1])
    r = subprocess.run(["bash", "-lc", cmd], cwd=sim, capture_output=True, text=True, timeout=600, env=env)
    labels = re.findall(r'"label":"([a-z-]+)"', r.stdout)
    ok = "RAN " if labels else "FAIL"
    print(f"  {k.split(':')[1]:14s} {ok} parts={len(labels)} [{', '.join(labels)}] exit={r.returncode}")
PY
