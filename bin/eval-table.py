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
        ti = a.get("tokens_in", 0)
        ca = a.get("cache_read", 0)
        hit = (100 * ca / (ti + ca)) if (ti + ca) else 0
        rows.append((model, draw, cl, a["n_turns"], a.get("n_tools", 0),
                     ti, a.get("tokens_out", 0), ca, hit,
                     a.get("wall_s", 0), a["cost"], p, c))

    if not rows:
        print("  (no banked legs yet)")
        return 0
    # FULL metric row (dk standing rule: report token USAGE, not only cached — show
    # fresh input AND cache hit-rate, because a model whose provider caches poorly
    # bills far more fresh input for the same context. cost$ is real OpenRouter spend).
    print(f"  {'model':<26}{'draw':>4}{'verd':>6}{'inv':>4}{'tools':>6}"
          f"{'tok_in':>9}{'tok_out':>8}{'cache':>10}{'hit%':>5}{'wall':>6}{'cost$':>8}{'plnk':>5}{'@cap':>5}")
    T = dict(inv=0, tools=0, ti=0, to=0, ca=0, cost=0.0)
    for m, dr, cl, inv, tools, ti, to, ca, hit, wall, cost, p, c in rows:
        v = "CLEAR" if cl else "no"
        print(f"  {m:<26}{dr:>4}{v:>6}{inv:>4}{tools:>6}"
              f"{ti:>9,}{to:>8,}{ca:>10,}{hit:>4.0f}%{wall:>5.0f}s{cost:>8.4f}{p:>5}{c:>5}")
        T['inv'] += inv; T['tools'] += tools; T['ti'] += ti; T['to'] += to
        T['ca'] += ca; T['cost'] += cost
    ht = (100 * T['ca'] / (T['ti'] + T['ca'])) if (T['ti'] + T['ca']) else 0
    print(f"  {'TOTAL':<26}{'':>4}{'':>6}{T['inv']:>4}{T['tools']:>6}"
          f"{T['ti']:>9,}{T['to']:>8,}{T['ca']:>10,}{ht:>4.0f}%{'':>6}{T['cost']:>8.4f}")

    from collections import defaultdict
    by = defaultdict(list)
    for r in rows:
        by[r[0]].append(r[2])
    print("\n  clear-rate:")
    for m, cs in by.items():
        print(f"    {m:<26}{sum(cs)}/{len(cs)}")
    print(f"  total cost: ${T['cost']:.4f} over {len(rows)} legs  "
          f"(fresh tok_in {T['ti']:,} vs cache {T['ca']:,} = {ht:.0f}% cached)")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
