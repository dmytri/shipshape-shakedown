#!/usr/bin/env python3
"""Per-wave economy: speed, price, latency, tokens. Reads banked or live wave dirs.

usage: bin/wave-economy.py <wave> [<wave> ...]        (names under .eval-scratch/ or data/)

A grade says whether the product works. It says nothing about what the run cost, and two
cells with the same grade can differ by an order of magnitude -- R9's mimo cells burned
twelve voyages to reach a score the same arms now reach in two. This prints the other half.
"""
import json
import re
import os
import sys
from datetime import datetime

ROOTS = (".eval-scratch", "data")


def find(wave):
    for r in ROOTS:
        d = os.path.join(r, wave)
        if os.path.isdir(d):
            return d
    return None


def legs(d):
    """banked layout is <wave>/vN.session.jsonl, live is <wave>/vN.out/session.jsonl"""
    out = []
    for name in sorted(os.listdir(d)):
        p = os.path.join(d, name, "session.jsonl")
        if os.path.isfile(p):
            out.append(p)
        elif name.endswith(".session.jsonl"):
            out.append(os.path.join(d, name))
    return out


def fold(path):
    inp = outp = cr = cw = reas = 0
    cost = 0.0
    turns = 0
    first = last = None
    for line in open(path, errors="ignore"):
        line = line.strip()
        if not line:
            continue
        try:
            e = json.loads(line)
        except Exception:
            continue
        ts = e.get("timestamp")
        if ts:
            first = first or ts
            last = ts
        m = e.get("message") or {}
        if m.get("role") != "assistant":
            continue
        u = m.get("usage")
        if not isinstance(u, dict) or "input" not in u:
            continue
        turns += 1
        inp += u.get("input", 0)
        outp += u.get("output", 0)
        cr += u.get("cacheRead", 0)
        cw += u.get("cacheWrite", 0)
        reas += u.get("reasoning", 0)
        cost += (u.get("cost") or {}).get("total", 0.0) or 0.0
    return dict(turns=turns, inp=inp, out=outp, cache_read=cr, cache_write=cw,
                reasoning=reas, cost=cost, first=first, last=last)


def secs(a, b):
    try:
        fmt = "%Y-%m-%dT%H:%M:%S"
        pa = datetime.strptime(a[:19], fmt)
        pb = datetime.strptime(b[:19], fmt)
        return max(0, int((pb - pa).total_seconds()))
    except Exception:
        return 0


def wave(name):
    d = find(name)
    if not d:
        return None
    tot = dict(turns=0, inp=0, out=0, cache_read=0, cache_write=0, reasoning=0, cost=0.0)
    wall = 0
    ls = legs(d)
    for p in ls:
        f = fold(p)
        for k in tot:
            tot[k] += f[k]
        if f["first"] and f["last"]:
            wall += secs(f["first"], f["last"])
    # grade + voyages from the driver log
    grade, voyages = "?", 0
    # wave.log and driver.log are the SAME lines -- reading both double-counts every voyage.
    for cand in (os.path.join(d, "wave.log"), os.path.join(d, "driver.log")):
        if not os.path.isfile(cand):
            continue
        for line in open(cand, errors="ignore"):
            if re.search(r"oracle \d+/", line):
                voyages += 1
            if "final=" in line:
                grade = line.split("final=")[1].strip()
        break
    tot.update(wave=name, legs=len(ls), wall=wall, grade=grade, voyages=voyages)
    return tot


def main(names):
    rows = [w for w in (wave(n) for n in names) if w]
    if not rows:
        print("no waves found", file=sys.stderr)
        return 1
    hdr = (f"{'wave':<26}{'grade':>7}{'voy':>5}{'turns':>7}{'wall':>8}"
           f"{'in':>10}{'out':>8}{'cacheR':>10}{'$':>9}{'$/voy':>8}{'s/voy':>7}")
    print(hdr)
    print("-" * len(hdr))
    for r in rows:
        v = max(r["voyages"], 1)
        print(f"{r['wave']:<26}{r['grade']:>7}{r['voyages']:>5}{r['turns']:>7}"
              f"{r['wall']//60:>6}m "
              f"{r['inp']:>10,}{r['out']:>8,}{r['cache_read']:>10,}"
              f"{r['cost']:>9.3f}{r['cost']/v:>8.3f}{r['wall']//v:>7}")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]) if len(sys.argv) > 1 else main([]))
