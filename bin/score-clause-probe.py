#!/usr/bin/env python3
"""Score the clause probe: what each Captain leg ADDED, never what the base already had.

The base sim (frozen R6-mid-mimo HEAD) already ships 55 scenarios, 4 of them structural. A
scorer that counts scenarios present would credit every arm with the base's own work and report
a difference where there is none — the same "measure the artifact, not the assumption" error
that cost this session several hours. So: diff each leg's sim against the base and score only
the delta.

Rubric (fixed in clauseprobe/RUBRIC.md before any leg ran):
  1. STRUCTURAL  did the leg author >=1 scenario asserting a property of the SOURCE?
  2. scenarios authored (count)
  3. watchbill entry made for it?

Decision rule: a variant works at >=3/5 STRUCTURAL while baseline is <=1/5; if midway-minus
matches midway-why, ship the deletion alone; if all three land within one draw, the clause is
not the blocker and the proposal is dropped.
"""
import glob
import json
import os
import re
import sys

P = "/tmp/claude-1000/-home-exedev-shipshape-shakedown/414c2a8e-87ed-4355-a18a-68b6fa320200/scratchpad/clauseprobe"
STRUCTURAL = re.compile(
    r"guard|does not call|contains|checks |source|re-entran|must not|detach|parentNode|"
    r"call pattern|boundary|arity|literal", re.I)


def scenarios(root):
    out = set()
    for f in glob.glob(root + "/features/*.feature") + glob.glob(root + "/specs/*.feature"):
        try:
            txt = open(f, encoding="utf-8", errors="replace").read()
        except OSError:
            continue
        for t in re.findall(r"(?m)^\s*Scenario(?: Outline)?:\s*(.+)$", txt):
            out.add(t.strip())
    return out


def watchbill(root):
    try:
        return json.load(open(os.path.join(root, "watchbill.json")))
    except Exception:
        return None


def main():
    base = scenarios(P + "/base")
    print(f"  base sim ships {len(base)} scenarios (excluded from every score)\n")
    print(f"  {'arm':14s} {'draw':5s} {'authored':9s} {'structural':11s} {'watchbill':10s} titles")
    summary = {}
    for arm in ("midway", "midway-minus", "midway-why"):
        hits = 0
        drawn = 0
        for d in (1, 2, 3, 4, 5):
            sim = f"{P}/sim-{arm}-d{d}"
            if not os.path.isdir(sim):
                continue
            drawn += 1
            added = scenarios(sim) - base
            struct = sorted(t for t in added if STRUCTURAL.search(t))
            wb = watchbill(sim)
            wb_has = "yes" if wb and any(
                STRUCTURAL.search(json.dumps(v)) for v in (wb.values() if isinstance(wb, dict) else [])
            ) else "no"
            if struct:
                hits += 1
            shown = "; ".join(s[:52] for s in struct[:2]) or "-"
            print(f"  {arm:14s} d{d:<4d} {len(added):9d} {len(struct):11d} {wb_has:10s} {shown}")
        summary[arm] = (hits, drawn)
    print("\n  === STRUCTURAL rate (rubric item 1) ===")
    for arm, (hits, drawn) in summary.items():
        print(f"    {arm:14s} {hits}/{drawn}")
    base_hits = summary.get("midway", (0, 0))[0]
    verdict = []
    for arm in ("midway-minus", "midway-why"):
        h, n = summary.get(arm, (0, 0))
        if n and h >= 3 and base_hits <= 1:
            verdict.append(f"{arm} WORKS ({h}/{n} vs baseline {base_hits})")
    if not verdict:
        print("\n  VERDICT: no variant clears the bar — the clause is not the blocker; drop the proposal.")
    else:
        print("\n  VERDICT: " + "; ".join(verdict))
        mh = summary.get("midway-minus", (0, 0))[0]
        wh = summary.get("midway-why", (0, 0))[0]
        if mh >= wh:
            print("           midway-minus matches or beats midway-why -> SHIP THE DELETION ALONE.")
        else:
            print("           only midway-why clears it -> the reason is load-bearing.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
