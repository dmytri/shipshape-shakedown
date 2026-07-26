#!/usr/bin/env python3
"""Score a DERIVED RIGGING.md against the methods doctrine (v3: commands gone, 13 methods).

The point is a deterministic signal for doctrine iteration: a fit-out draw costs cents, so the
bottleneck is knowing exactly WHICH rule the derivation broke. Every check is a rule the candidate
states, so a violation names the line to fix rather than leaving a vibe.

Usage: bin/rigging-conform.py <RIGGING.md|dir|glob> ...
"""
import glob
import os
import re
import sys

METHODS = ["prove", "verify", "sweep", "plank-join", "hygiene", "static", "discovery",
           "regression", "condemnation", "dead-code", "spec-lint", "install", "ship", "ship-verify"]
TAKES_SCENARIO = {"prove", "verify", "condemnation"}
TAKES_DEPENDENCY = {"install"}
# Methods whose parts run verification and therefore carry the tag exclusions.
VERIFYING = {"prove", "verify", "sweep", "static", "discovery", "regression", "condemnation"}


def section(text, name):
    m = re.search(rf"^## {re.escape(name)}\n(.*?)(?=^## |\Z)", text, re.S | re.M)
    return m.group(1) if m else ""


def values(block):
    out = {}
    for line in block.splitlines():
        m = re.match(r"- ([A-Za-z][A-Za-z0-9-]*): *(.*)$", line.strip())
        if m:
            out.setdefault(m.group(1), m.group(2).strip())
    return out


def score(path):
    text = open(path, errors="replace").read()
    viol, notes = [], []
    if "## Commands" in text:
        viol.append("carries a ## Commands section; commands are gone")
    mblock = section(text, "Methods")
    if not mblock:
        return ["no ## Methods section: every method is a required value"], [], 0, 0
    meth = values(mblock)

    def bare(v):
        return v.strip().strip("`").strip()

    def is_none(v):
        return bare(v).lower() in ("none", "")

    derived = 0
    for name in METHODS:
        if name not in meth:
            viol.append(f"{name}: key missing (required value)")
            continue
        val = meth[name]
        b = bare(val)
        if is_none(val):
            notes.append(name)
            continue
        derived += 1
        if not val.startswith("`"):
            viol.append(f"{name}: value not in backticks")
        if "yoink" not in b:
            viol.append(f"{name}: not a Yoink plan (a value that is not a Yoink plan is not a method)")
            continue
        runs = len(re.findall(r"--run\b", b))
        labels = len(re.findall(r"--label\b", b))
        timeouts = len(re.findall(r"--timeout\b", b))
        if runs < 1:
            viol.append(f"{name}: Yoink invocation with no --run part")
        if labels < runs:
            viol.append(f"{name}: {runs} parts but {labels} --label")
        if timeouts < runs:
            viol.append(f"{name}: {runs} parts but {timeouts} --timeout")
        if "--max-bytes" not in b:
            viol.append(f"{name}: no --max-bytes bound")
        if name in TAKES_SCENARIO and "{scenario}" not in b:
            viol.append(f"{name}: missing the {{scenario}} placeholder")
        if name in TAKES_DEPENDENCY and "{dependency}" not in b:
            viol.append(f"{name}: missing the {{dependency}} placeholder")
        if name in VERIFYING and "not @captain" not in b:
            viol.append(f"{name}: a verifying part without the tag exclusions")
    extras = [k for k in meth if k not in METHODS and not re.match(r"(sweep|regression)-", k)]
    for e in extras:
        viol.append(f"{e}: not a method the Methods section names")
    return viol, notes, len(meth), derived


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
        print(f"=== {p}  keys={keys} derived={derived} none={len(notes)} violations={len(viol)}")
        for v in viol:
            print(f"    X {v}")
        if notes:
            print(f"    . none: {', '.join(notes)}")
        worst = max(worst, len(viol))
    return 1 if worst else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
