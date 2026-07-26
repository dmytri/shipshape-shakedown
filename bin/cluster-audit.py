#!/usr/bin/env python3
"""Per-checkpoint invocation audit over banked pi legs — the METHODS-candidate A/B instrument.

The methods candidate's claim is mechanistic: a composite method specified in RIGGING.md as ONE
yoink plan collapses a checkpoint's N shell round-trips into 1. Total-invocation deltas are noisy
across draws, so the proof has to be counted AT THE CHECKPOINT. This is that counter.

Usage:  bin/cluster-audit.py <wave> [<wave> ...]      # waves under data/ or .eval-scratch/
        bin/cluster-audit.py --leg <session.jsonl>

Per leg it reports:
  bash          every shell tool call in the session
  cuc           cucumber invocations
  foc1          focused runs naming exactly ONE scenario  (the fan-out tell — doctrine says
                "run the focused command over the whole target set in ONE invocation")
  focN          focused runs naming several scenarios     (the batched form)
  broad         whole-suite / whole-feature runs (no --name)
  plnk          plank-inventory runs (grep @planks)
  usage         step-usage runs (--format usage) — the C8 plank-join's other half
  join          calls carrying BOTH plank-inventory and step-usage (the C1/C8 cluster, batched)
  yoink         yoink plan invocations
  meth          invocations that name a composite method (verify/hygiene) — candidate arm only
"""
import json
import os
import re
import sys
import glob

HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def shell_calls(path):
    out = []
    with open(path, errors="replace") as fh:
        for line in fh:
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


def audit(cmds):
    r = dict(bash=len(cmds), cuc=0, foc1=0, focN=0, broad=0, plnk=0, usage=0, join=0, yoink=0, meth=0)
    for c in cmds:
        has_plnk = "@planks" in c
        has_usage = "--format usage" in c or "format usage" in c
        if has_plnk:
            r["plnk"] += 1
        if has_usage:
            r["usage"] += 1
        if has_plnk and has_usage:
            r["join"] += 1
        if "yoink" in c:
            r["yoink"] += 1
        if re.search(r"\b(verify|hygiene)\b", c) and "yoink" in c:
            r["meth"] += 1
        if "cucumber" in c:
            r["cuc"] += 1
            names = len(re.findall(r"--name\b", c))
            if "--dry-run" in c:
                continue
            if names == 1:
                # one --name may still carry an alternation regex listing several scenarios
                alts = re.findall(r'--name\s+"([^"]*)"', c)
                r["focN" if (alts and "|" in alts[0]) else "foc1"] += 1
            elif names > 1:
                r["focN"] += 1
            else:
                r["broad"] += 1
    return r


COLS = ["bash", "cuc", "foc1", "focN", "broad", "plnk", "usage", "join", "yoink", "meth"]


def render(rows, label):
    print(f"=== {label}")
    print("leg".ljust(26) + "".join(c.rjust(7) for c in COLS))
    tot = dict.fromkeys(COLS, 0)
    for name, r in rows:
        print(name.ljust(26) + "".join(str(r[c]).rjust(7) for c in COLS))
        for c in COLS:
            tot[c] += r[c]
    print("TOTAL".ljust(26) + "".join(str(tot[c]).rjust(7) for c in COLS))
    fan = tot["foc1"]
    print(f"  fan-out: {fan} single-scenario focused runs vs {tot['focN']} batched; "
          f"plank-join performed {tot['join']}x (step-usage run {tot['usage']}x)")
    print()
    return tot


def main(argv):
    if not argv:
        print(__doc__)
        return 2
    if argv[0] == "--leg":
        for p in argv[1:]:
            render([(os.path.basename(p), audit(shell_calls(p)))], p)
        return 0
    grand = {}
    for wave in argv:
        cands = [os.path.join(HERE, "data", wave), os.path.join(HERE, ".eval-scratch", wave), wave]
        rows = []
        for d in cands:
            files = sorted(glob.glob(os.path.join(d, "**", "*session.jsonl"), recursive=True))
            if files:
                for f in files:
                    rows.append((os.path.basename(f).replace(".session.jsonl", ""), audit(shell_calls(f))))
                break
        if not rows:
            print(f"=== {wave}: no session.jsonl found")
            continue
        grand[wave] = render(rows, wave)
    if len(grand) > 1:
        print("=== waves compared")
        print("wave".ljust(26) + "".join(c.rjust(7) for c in COLS))
        for w, t in grand.items():
            print(w.ljust(26) + "".join(str(t[c]).rjust(7) for c in COLS))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
