#!/usr/bin/env python3
"""Render an eval wave's draws as a table — from BANKED data only (survives VM).

The scratch sim trees die with the VM, so this reads the durable banked layer:
`*.session.jsonl` (turns/wall/cost via eval-map) and `*.tree.diff` (the artifacts
the leg wrote: @planks / @captain). Verdict CLEAR = wrote @planks AND >=1 @captain.

Usage:
  eval-table.py                 # newest data/eval-* wave
  eval-table.py <wave>          # a named wave dir under data/ (e.g. eval-workhorse-x10)
  eval-table.py --list          # list available waves
"""
import glob
import json
import os
import re
import subprocess
import sys

HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DATA = os.path.join(HERE, "data")


def waves():
    return sorted(
        (d for d in glob.glob(os.path.join(DATA, "eval-*")) if os.path.isdir(d)),
        key=lambda d: os.path.getmtime(d),
    )


def fold(session):
    try:
        out = subprocess.run(
            ["python3", os.path.join(HERE, "bin", "eval-map.py"), "--json", session],
            capture_output=True, text=True,
        ).stdout
        d = json.loads(out)
        return d[list(d)[0]]
    except Exception:
        return {"n_turns": 0, "wall_s": 0, "cost": 0}


def artifacts(tree_diff):
    """(@planks count, @captain count) from added lines in the banked patch,
    SCOPED to the right files: @planks only in production src, @captain only in
    .feature files. Otherwise a report saying '@captain scenarios written: 0' or
    an AGENTS.md mentioning @planks would be miscounted as real artifacts."""
    if not os.path.isfile(tree_diff):
        return 0, 0
    planks = caps = 0
    curfile = ""
    for line in open(tree_diff, encoding="utf-8", errors="replace"):
        if line.startswith("+++ b/"):
            curfile = line[6:].strip()
            continue
        if not line.startswith("+") or line.startswith("+++"):
            continue
        if re.search(r"(^|/)src/.*\.(js|ts|py|rb|go)$", curfile):
            planks += len(re.findall(r"@planks\(", line))
        if curfile.endswith(".feature"):
            caps += len(re.findall(r"@captain\b", line))
    return planks, caps


def main(argv):
    if "--list" in argv:
        for w in waves():
            print("  " + os.path.basename(w))
        return 0
    named = [a for a in argv if not a.startswith("-")]
    if named:
        wave = os.path.join(DATA, named[0])
    else:
        ws = waves()
        if not ws:
            print("no eval waves in data/")
            return 1
        wave = ws[-1]
    if not os.path.isdir(wave):
        print(f"no such wave: {wave}")
        return 1

    print(f"=== {os.path.basename(wave)} (banked) ===")
    rows = []
    for sess in sorted(glob.glob(os.path.join(wave, "*.session.jsonl"))):
        name = os.path.basename(sess).replace(".session.jsonl", "")
        dm = re.search(r"-d(\d+)$", name)
        draw = dm.group(1) if dm else "-"
        model = re.sub(r"-d\d+$", "", name)
        a = fold(sess)
        p, c = artifacts(sess.replace(".session.jsonl", ".tree.diff"))
        cl = p > 0 and c > 0
        rows.append((model, draw, cl, a["n_turns"], a.get("wall_s", 0), a["cost"], p, c))

    if not rows:
        print("  (no banked legs yet)")
        return 0
    print(f"  {'model':<28}{'draw':>4}{'verdict':>9}{'inv':>5}{'wall':>7}{'cost$':>8}{'plank':>6}{'@cap':>5}")
    for m, dr, cl, inv, wall, cost, p, c in rows:
        v = "CLEAR" if cl else "no"
        print(f"  {m:<28}{dr:>4}{v:>9}{inv:>5}{wall:>7.0f}{cost:>8.3f}{p:>6}{c:>5}")

    from collections import defaultdict
    by = defaultdict(list)
    for m, dr, cl, *_ , in [(r[0], r[1], r[2]) for r in rows]:
        by[m].append(cl)
    tot = sum(r[5] for r in rows)
    print("\n  clear-rate:")
    for m, cs in by.items():
        print(f"    {m:<28}{sum(cs)}/{len(cs)}")
    print(f"  total cost: ${tot:.2f} over {len(rows)} legs")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
