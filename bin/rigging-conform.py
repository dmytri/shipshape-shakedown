#!/usr/bin/env python3
"""Score a DERIVED RIGGING.md against the methods doctrine (v3: commands gone, 13 methods).

The point is a deterministic signal for doctrine iteration: a fit-out draw costs cents, so the
bottleneck is knowing exactly WHICH rule the derivation broke. Every check is a rule the candidate
states, so a violation names the line to fix rather than leaving a vibe.

Usage: bin/rigging-conform.py <RIGGING.md|dir|glob> ...
"""
import glob
import json
import os
import re
import sys

METHODS = ["prove", "verify", "sweep", "plank-join", "hygiene", "static", "discovery",
           "regression", "condemnation", "dead-code", "spec-lint", "install", "ship", "ship-verify"]
TAKES_SCENARIO = {"prove", "verify", "condemnation"}
TAKES_DEPENDENCY = {"install"}
# Methods whose parts run verification and therefore carry the tag exclusions.
VERIFYING = {"prove", "verify", "sweep", "static", "discovery", "regression", "condemnation"}


SOFT_FAIL = re.compile(r"--no-strict\b|--exit-zero\b|--no-exit-code\b|\|\|\s*true\b|--soft-fail\b|&&\s*echo\b|\|\s*grep -q\b")


def _excludes(cmd):
    """The tag exclusions, however this runner spells them: cucumber tags, pytest markers, or a
    CUCUMBER_FILTER_TAGS environment value."""
    return ("not @captain" in cmd) or ("not captain" in cmd) or ("CUCUMBER_FILTER_TAGS" in cmd)


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


def task_runner_body(sim, value):
    """A method value may be a short task-runner invocation; the PLAN lives in the entry it names.
    Resolve npm scripts, Make targets and Just recipes so the plan can be checked where it lives."""
    m = re.search(r"npm run ([\w:.-]+)", value)
    if m:
        pkg = os.path.join(sim, "package.json")
        if os.path.exists(pkg):
            try:
                return json.load(open(pkg)).get("scripts", {}).get(m.group(1), "")
            except Exception:
                return ""
    # Poe the Poet tasks live in pyproject.toml, invoked as `uv run poe <task>` or `poe <task>`.
    m = re.search(r"\bpoe\s+([\w:.-]+)", value)
    if m:
        pp = os.path.join(sim, "pyproject.toml")
        if os.path.exists(pp):
            t = open(pp, errors="replace").read()
            mm = re.search(rf'"?{re.escape(m.group(1))}"?\s*=\s*(?:\{{[^}}]*?(?:shell|cmd)\s*=\s*)?(\'\'\'|"""|"|\')((?:\\.|(?!\1).)*)\1',
                           t, re.S)
            if mm:
                return mm.group(2)
    m = re.search(r"\b(?:make|just)\s+([\w:.-]+)", value)
    if m:
        for f in ("Makefile", "justfile", "Justfile"):
            p2 = os.path.join(sim, f)
            if os.path.exists(p2):
                t = open(p2, errors="replace").read()
                mm = re.search(rf"^{re.escape(m.group(1))}:.*?\n((?:\s+.*\n)+)", t, re.M)
                if mm:
                    return mm.group(1)
    m = re.search(r"cargo ([\w-]+)", value)
    if m:
        p2 = os.path.join(sim, ".cargo/config.toml")
        if os.path.exists(p2):
            t = open(p2, errors="replace").read()
            mm = re.search(rf"{re.escape(m.group(1))}\s*=\s*(.+)", t)
            if mm:
                return mm.group(1)
    return ""


def score(path):
    sim = os.path.dirname(path)
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
            # A Gherkin linter is available on every stack, so an unlinted spec surface is a
            # fitting-out fault rather than a stack limit (dk, 2026-07-26).
            if name == "spec-lint":
                viol.append("spec-lint: none, but a Gherkin linter is always available (gplint)")
            notes.append(name)
            continue
        derived += 1
        if not val.startswith("`"):
            viol.append(f"{name}: value not in backticks")
        body = b if "yoink" in b else (task_runner_body(sim, b) or b)
        # SCORING ONLY, deliberately not doctrine (dk, 2026-07-26): a single-command method is
        # accepted, since the wrapper separates parts and one part has nothing to separate from. The
        # TEXT still states the plan flat, because naming the exception primes roles to take it.
        # Two or more commands chained without a plan is still a violation: statuses collapse.
        if "yoink" not in body:
            chained = len(re.findall(r"&&|;\s*\S|\|\|", body))
            if chained:
                viol.append(f"{name}: {chained + 1} commands chained without a Yoink plan; their statuses collapse")
            # A bare single invocation has no plan shape to check: skip the plan checks and judge
            # only what still applies, the parameter and the tag exclusions.
            if name in TAKES_SCENARIO and not any(t in body + val for t in ("SS_SCENARIO", "{scenario}")):
                viol.append(f"{name}: takes a target set but names neither $SS_SCENARIO nor a placeholder")
            if name in TAKES_DEPENDENCY and not any(t in body + val for t in ("SS_DEPENDENCY", "{dependency}")):
                viol.append(f"{name}: takes a package but names neither $SS_DEPENDENCY nor a placeholder")
            if SOFT_FAIL.search(body):
                viol.append(f"{name}: carries a soft-fail flag, so a red reads as a pass")
            if name in VERIFYING and not _excludes(body):
                viol.append(f"{name}: a verifying part without the tag exclusions")
            continue
        b = body
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
        # Parameters ride as inline environment values now, so the reference is $SS_SCENARIO in the
        # plan; the older {scenario} placeholder is accepted for a rigging written before that.
        raw = meth[name]
        if name in TAKES_SCENARIO and not any(t in b + raw for t in ("SS_SCENARIO", "{scenario}")):
            viol.append(f"{name}: takes a target set but names neither $SS_SCENARIO nor a placeholder")
        if name in TAKES_DEPENDENCY and not any(t in b + raw for t in ("SS_DEPENDENCY", "{dependency}")):
            viol.append(f"{name}: takes a package but names neither $SS_DEPENDENCY nor a placeholder")
        if SOFT_FAIL.search(b):
            viol.append(f"{name}: carries a soft-fail flag, so a red reads as a pass")
        if name in VERIFYING and not _excludes(b):
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
