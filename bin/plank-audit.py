#!/usr/bin/env python3
"""Traceability audit: does the code actually join to the spec?

usage: bin/plank-audit.py <sim-dir> [<sim-dir> ...]

dk, 2026-08-01: "the oracle doesn't measure the goal — 28/29 is just proof of completion, not
quality." Rigging is scaffolding. PLANKING is the goal, because it is what gives code-to-spec
traceability. So a wave needs this number beside its grade, or the shakedown keeps reporting
that the product works and calling that a result.

What it measures, per the Planking agreement's Form: a plank's text IS the step pattern string,
so a plank JOINS when it matches a live step definition exactly. Anything else is decoration.

Why a grep cannot do this (and why the projects' own checks miss it). The derived command in
R17 was:

    plank-inventory: `grep -rn '@planks\\|@planks-provisional' js css 2>/dev/null || true`

A token search lists plank strings; it cannot check that any of them joins anything -- and the
`|| true` means it can never fail. R17 passed its own plank check with 39 of 55 planks naming
nothing that exists, several of them free prose ("Do not persist editing state") which the Form
forbids outright. This is CAPTAIN.md's plank-inventory form/placement open item (2026-07-12),
which has been theoretical for three weeks, with a number on it at last.

Reference points, same fixture, all three scored 28/29 by the oracle:
    R13 (one session, $0.055)   0 planks over ~17 seams -- none of the goal
    R16 (two sessions, $0.602)  2 planks
    R17 (two sessions, $0.715)  56 planks, 16 real joins -- about a third of the goal
"""
import glob
import os
import re
import sys

PLANK = re.compile(r'@planks(?:-provisional)?\("([^"]+)"')
STEP = re.compile(r'(?:Given|When|Then)\(\s*[\'"]([^\'"]+)[\'"]')
# a step pattern is a sentence the runner matches; free prose with terminal punctuation or a
# dash-clause is the shape the Form forbids
PROSY = re.compile(r'[—–]|\.\s*$|^[A-Z][a-z]+ [a-z]+ [a-z]+ [a-z]+ [a-z]+ [a-z]+ [a-z]+')


def read(paths):
    for p in paths:
        try:
            yield open(p, errors="ignore").read()
        except OSError:
            continue


def impl_dirs(sim):
    """the rigging's declared implementation paths, else the conventional ones"""
    rg = os.path.join(sim, "RIGGING.md")
    dirs = []
    if os.path.isfile(rg):
        for line in open(rg, errors="ignore"):
            m = re.match(r"\s*-\s*implementation\s*:\s*(.+)", line, re.I)
            if m:
                v = m.group(1).strip().strip("`").strip()
                if v and v.lower() != "none":
                    dirs.append(v)
    return dirs or ["js", "src", "lib"]


def audit(sim):
    decl = impl_dirs(sim)
    code = []
    for d in decl:
        code += glob.glob(os.path.join(sim, d, "**", "*.js"), recursive=True)
        code += glob.glob(os.path.join(sim, d, "*.js"))
    planks = set()
    for text in read(sorted(set(code))):
        planks |= set(PLANK.findall(text))

    steps = set()
    for d in ("features", "specs"):
        for text in read(glob.glob(os.path.join(sim, d, "**", "*.js"), recursive=True)):
            steps |= set(STEP.findall(text))

    joined = planks & steps
    orphan = planks - steps
    unplanked = steps - planks
    prose = {p for p in orphan if PROSY.search(p)}
    # the declared implementation dirs holding no code at all is its own defect (B5): the
    # plank inventory then scans nothing and passes forever
    empty_decl = [d for d in decl if not glob.glob(os.path.join(sim, d, "**", "*.js"), recursive=True)
                  and not glob.glob(os.path.join(sim, d, "*.js"))]
    return dict(decl=decl, empty_decl=empty_decl, planks=len(planks), steps=len(steps),
                joined=len(joined), orphan=len(orphan), prose=len(prose),
                unplanked=len(unplanked),
                fidelity=(100 * len(joined) // len(planks)) if planks else 0,
                coverage=(100 * len(joined) // len(steps)) if steps else 0)


def main(sims):
    hdr = (f"{'sim':<26}{'planks':>7}{'steps':>7}{'joined':>8}{'orphan':>8}"
           f"{'prose':>7}{'unplanked':>10}{'fidelity':>9}{'coverage':>9}")
    print(hdr)
    print("-" * len(hdr))
    for s in sims:
        a = audit(s)
        name = os.path.basename(os.path.dirname(s.rstrip("/"))) or s
        print(f"{name:<26}{a['planks']:>7}{a['steps']:>7}{a['joined']:>8}{a['orphan']:>8}"
              f"{a['prose']:>7}{a['unplanked']:>10}{a['fidelity']:>8}%{a['coverage']:>8}%")
        if a["empty_decl"]:
            print(f"    ! declared implementation dir holds no code: {' '.join(a['empty_decl'])}"
                  f"  (plank-inventory scans nothing and passes forever)")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]) if len(sys.argv) > 1 else print(__doc__.splitlines()[2]) or 2)
