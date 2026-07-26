#!/usr/bin/env python3
"""Score a DERIVED RIGGING.md against the methods doctrine's own rules.

The point is a deterministic signal for doctrine iteration: a fit-out draw costs cents, so the
bottleneck is knowing exactly WHICH rule the derivation broke. Every check below is a rule the
candidate text states, so a violation names the line to fix rather than a vibe.

Usage: bin/rigging-conform.py <RIGGING.md> [...]        # or a wave dir / glob
"""
import glob
import os
import re
import sys

METHODS = ["verify", "hygiene", "static", "regression", "rigging-proof"]
# Which `## Commands` values each method composes, per the Methods table.
PARTS = {
    "verify": ["focused", "plank-inventory", "step-usage"],
    "hygiene": ["plank-inventory", "step-usage", "typecheck", "lint"],
    "static": ["discover", "typecheck", "lint"],
    "regression": ["coverage"],
    "rigging-proof": ["discover", "focused", "broad", "coverage", "step-usage", "plank-inventory", "typecheck", "lint"],
}


def section(text, name):
    m = re.search(rf"^## {name}\n(.*?)(?=^## |\Z)", text, re.S | re.M)
    return m.group(1) if m else ""


def kv(block):
    out = {}
    for line in block.splitlines():
        m = re.match(r"- ([A-Za-z][A-Za-z0-9-]*): *(.*)$", line.strip())
        if m:
            out.setdefault(m.group(1), []).append(m.group(2).strip())
    return out


def score(path):
    text = open(path, errors="replace").read()
    cmds = {k: v[0] for k, v in kv(section(text, "Commands")).items()}
    meth = {k: v[0] for k, v in kv(section(text, "Methods")).items()}
    viol, notes = [], []
    if not section(text, "Methods"):
        return ["no ## Methods section at all"], [], 0, 0

    def bare(v):
        return v.strip().strip("`").strip()

    def is_none(v):
        return bare(v).lower() in ("none", "")

    derivable = {k for k, v in cmds.items() if not is_none(v)}

    for name in METHODS:
        if name not in meth:
            viol.append(f"{name}: key missing")
            continue
        val, b = meth[name], bare(meth[name])
        if not val.startswith("`") and not is_none(val):
            viol.append(f"{name}: value not wrapped in backticks (Rigging shape)")
        expect = [p for p in PARTS[name] if p in derivable]
        # conformance substitutes for plank-inventory where the project derives it
        if "plank-inventory" in expect and "conformance" in derivable and "plank-inventory" not in derivable:
            expect = ["conformance" if p == "plank-inventory" else p for p in expect]
        if is_none(val):
            if len(expect) > 1:
                viol.append(f"{name}: reads none but {len(expect)} parts are derivable ({', '.join(expect)})")
            else:
                notes.append(f"{name}: none, correct ({len(expect)} derivable part)")
            continue
        if len(expect) <= 1:
            viol.append(f"{name}: derived a composite of {len(expect)} part(s); the rule says write none")
        if "yoink" not in b:
            viol.append(f"{name}: not a Yoink plan (a method value is one Yoink plan, every stack)")
        else:
            runs = len(re.findall(r"--run\b", b))
            if runs < 2:
                viol.append(f"{name}: yoink plan with {runs} --run part(s)")
            if len(re.findall(r"--label\b", b)) < runs:
                viol.append(f"{name}: {runs} parts but {len(re.findall(r'--label', b))} labels")
            if len(re.findall(r"--timeout\b", b)) < runs:
                viol.append(f"{name}: {runs} parts but {len(re.findall(r'--timeout', b))} timeouts")
            if "--max-bytes" not in b:
                viol.append(f"{name}: no --max-bytes bound")
        for p in expect:
            cv = bare(cmds.get(p, "none"))
            core = re.split(r"[|>]", cv)[0].strip()
            core = re.sub(r"^(npx|npm run|cargo|python3?|\./?\.venv/bin/)\s+", "", core).split()
            probe = core[0] if core else p
            if probe and probe not in b:
                viol.append(f"{name}: part {p} not composed verbatim (looked for '{probe}')")
        if name == "verify" and "{scenario}" not in b:
            viol.append("verify: lost the {scenario} placeholder")
    return viol, notes, len(meth), sum(1 for v in meth.values() if not is_none(v))


def main(argv):
    paths = []
    for a in argv:
        if os.path.isdir(a):
            paths += glob.glob(os.path.join(a, "**", "RIGGING.md"), recursive=True)
        else:
            paths += glob.glob(a)
    if not paths:
        print(__doc__)
        return 2
    worst = 0
    for p in sorted(paths):
        viol, notes, keys, derived = score(p)
        tag = p.replace(os.path.expanduser("~/shipshape-shakedown/"), "")
        print(f"=== {tag}  keys={keys} derived={derived} violations={len(viol)}")
        for v in viol:
            print(f"    X {v}")
        for n in notes:
            print(f"    . {n}")
        worst = max(worst, len(viol))
    return 1 if worst else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
