#!/usr/bin/env python3
"""Did the role DO ITS JOB? Tree facts after a role probe, per role.

The methods candidate is a large rewrite of working doctrine, and current doctrine has real results
behind it, so the bar is not "methods were used" but "the job still got done, at least as well".
This reads the sim after the leg and answers that from the tree, never from the role's report.

Usage: bin/meth-outcome.py <probe-dir> ...
"""
import glob
import json
import os
import re
import subprocess
import sys


def git(sim, *args):
    return subprocess.run(["git", "-C", sim, *args], capture_output=True, text=True).stdout.strip()


def suite(sim, nm):
    """Run the roles' own suite the operator's way, so the answer is the tree's, not the report's."""
    link = os.path.join(sim, "node_modules")
    had = os.path.islink(link) or os.path.isdir(link)
    if not os.path.islink(link):
        if os.path.isdir(link) and not os.listdir(link):
            os.rmdir(link)
        if not os.path.exists(link):
            os.symlink(nm, link)
    out = subprocess.run(["npx", "cucumber-js"], cwd=sim, capture_output=True, text=True, timeout=300).stdout
    m = re.search(r"(\d+) scenarios? \(([^)]*)\)", out)
    if os.path.islink(link):
        os.unlink(link)
        os.makedirs(link, exist_ok=True)
    return m.group(0) if m else "?"


def role_of(base):
    for r in ("boatswain", "qm", "crew"):
        if glob.glob(os.path.join(base, f"{r}.out")):
            return r
    return "?"


def audit(base, nm):
    sim = os.path.join(base, "sim")
    if not os.path.isdir(sim):
        print(f"=== {os.path.basename(base)}: no sim")
        return
    role = role_of(base)
    commits = len(git(sim, "log", "--oneline").splitlines())
    dirty = git(sim, "status", "--porcelain")
    changed = git(sim, "diff", "--name-only", "HEAD~1") if commits > 1 else ""
    src = len([f for f in changed.splitlines() if f.startswith("src/")])
    spec = len([f for f in changed.splitlines() if f.endswith(".feature")])
    supp = len([f for f in changed.splitlines() if "support" in f or "step" in f])
    planks = len(re.findall(r"@planks", open(os.path.join(sim, "src/tide.js")).read())) if os.path.exists(os.path.join(sim, "src/tide.js")) else 0
    has_low = "nextLowTide" in open(os.path.join(sim, "src/tide.js")).read() if os.path.exists(os.path.join(sim, "src/tide.js")) else False
    ss = suite(sim, nm)
    # write-custody: did the role write outside its scope?
    foul = ""
    if role == "qm" and src:
        foul = "QM WROTE PRODUCTION"
    if role == "crew" and (spec or supp):
        foul = "CREW WROTE SPECS/VERIFICATION"
    if role == "boatswain" and src > 0 and commits > 1:
        foul = ""  # boatswain commits the role-advanced diff; production in the commit is expected
    print(f"=== {os.path.basename(base)} [{role}]  commits={commits} tree={'dirty' if dirty else 'clean'} "
          f"suite: {ss} | production seam present={has_low} planks={planks} | {foul}")


def main(argv):
    nm = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), ".eval-scratch/.shared-nm/node_modules")
    for a in argv:
        for d in sorted(glob.glob(a)):
            try:
                audit(d, nm)
            except Exception as e:
                print(f"=== {os.path.basename(d)}: audit error {e}")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
