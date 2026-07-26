#!/usr/bin/env python3
"""Did the role RUN the method for the job, or reach past it? (dk's criterion (a))

A method invocation is legible: it is the plan `RIGGING.md` carries for that method. An ad hoc reach
is the project's own tooling invoked directly - the runner, the linter, the type checker, coverage,
the annotation scan, the usage report - outside any plan. Reads, git and one-off searches are ad hoc
by rule and are not counted against the role.

Usage: bin/meth-use-audit.py <probe-dir> [...]
"""
import glob
import json
import os
import re
import sys

# Project tooling, by the job it belongs to. A bare invocation of one of these is a reach past the
# method whose job it is.
TOOLING = [
    (r"\bcucumber-js\b(?!.*--dry-run)|\bbehave\b(?!.*--dry-run)|cargo test|\bpytest\b", "runner", "prove/verify/sweep/regression"),
    (r"--dry-run", "dry-run", "discovery/static/plank-join"),
    (r"@planks", "annotation scan", "plank-join/hygiene"),
    (r"\bjsdoc\b|ast-grep", "annotation scan", "plank-join/hygiene"),
    (r"\btsc\b|cargo check|\bmypy\b", "type check", "hygiene/static/condemnation"),
    (r"\bbiome\b|\beslint\b|\bruff\b|clippy|gplint|cargo fmt", "lint", "hygiene/static/condemnation/spec-lint"),
    (r"\bc8\b|llvm-cov|coverage run|tarpaulin", "coverage", "regression"),
    (r"npm install|pip install|cargo add|rustup component add", "install", "install"),
]


def shell_calls(path):
    out = []
    for line in open(path, errors="replace"):
        line = line.strip()
        if not line:
            continue
        try:
            obj = json.loads(line)
        except Exception:
            continue

        def walk(x):
            if isinstance(x, dict):
                for k, v in x.items():
                    if k in ("command", "cmd") and isinstance(v, str):
                        out.append(v)
                    else:
                        walk(v)
            elif isinstance(x, list):
                for v in x:
                    walk(v)

        walk(obj)
    return out


def methods_of(sim):
    r = os.path.join(sim, "RIGGING.md")
    if not os.path.exists(r):
        return {}
    text = open(r, errors="replace").read()
    m = re.search(r"^## Methods\n(.*?)(?=^## )", text, re.S | re.M)
    if not m:
        return {}
    out = {}
    for line in m.group(1).splitlines():
        mm = re.match(r"- ([a-z-]+): *(.*)$", line.strip())
        if mm and mm.group(2).strip().strip("`").lower() != "none":
            out[mm.group(1)] = mm.group(2).strip().strip("`")
    return out


def signature(plan):
    """A few distinctive fragments of a plan, so an invocation can be matched to its method."""
    return [f for f in re.findall(r"--run '([^']{6,90})'", plan)]


def audit(base):
    sim = os.path.join(base, "sim")
    sess = sorted(glob.glob(os.path.join(base, "*.out/session/*.jsonl")))
    if not sess:
        print(f"=== {os.path.basename(base)}: NO SESSION")
        return
    cmds = shell_calls(sess[0])
    meths = methods_of(sim)
    ran, adhoc = {}, []
    for c in cmds:
        if "yoink" in c and "--run" in c:
            hit = None
            for name, plan in meths.items():
                sig = signature(plan)
                if sig and sum(1 for f in sig if f[:40] in c) >= max(1, len(sig) - 1):
                    hit = name
                    break
            ran.setdefault(hit or "unnamed-plan", 0)
            ran[hit or "unnamed-plan"] += 1
            continue
        for pat, what, owner in TOOLING:
            if re.search(pat, c):
                adhoc.append((what, owner, re.sub(r"\s+", " ", c.strip())[:90]))
                break
    print(f"=== {os.path.basename(base)}  shell calls={len(cmds)}  methods in rigging={len(meths)}")
    print(f"    METHODS RUN : {', '.join(f'{k} x{v}' for k, v in ran.items()) if ran else 'NONE'}")
    if adhoc:
        print(f"    REACHED PAST THE METHOD ({len(adhoc)}):")
        for what, owner, c in adhoc[:8]:
            print(f"      - {what} (belongs to {owner}): {c}")
    else:
        print("    reached past the method: none")
    committed = os.path.exists(os.path.join(sim, ".git"))
    if committed:
        import subprocess
        n = subprocess.run(["git", "-C", sim, "log", "--oneline"], capture_output=True, text=True).stdout.strip().splitlines()
        dirty = subprocess.run(["git", "-C", sim, "status", "--porcelain"], capture_output=True, text=True).stdout.strip()
        print(f"    commits={len(n)} tree={'dirty' if dirty else 'clean'}")


def main(argv):
    if not argv:
        print(__doc__)
        return 2
    for a in argv:
        for d in sorted(glob.glob(a)):
            audit(d)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
