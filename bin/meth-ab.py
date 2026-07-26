#!/usr/bin/env python3
"""A/B table over the composite-METHODS build-voyage draws (bin/meth-draw.sh).

Rolls every `methdraw-<arm>-<model>-<n>` wave into one table and separates the two questions the
candidate raises:

  ADOPTION  — did the role run a composite METHOD as a real plan (not just probe `yoink --help`)?
  COLLAPSE  — did the checkpoint's command set arrive in ONE invocation? Counted as the plank JOIN
              (plank-inventory and step-usage in one call) and as focused batching (foc1 vs focN).

Usage: bin/meth-ab.py [--scratch DIR]
"""
import glob
import json
import os
import re
import sys

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


def leg_stats(path):
    cmds = shell_calls(path)
    s = dict(calls=len(cmds), plan=0, probe=0, foc1=0, focN=0, broad=0, plnk=0, usage=0, join=0)
    for c in cmds:
        if "yoink" in c:
            # a real plan carries at least one --run; anything else is the model probing the tool
            (s.__setitem__("plan", s["plan"] + 1) if "--run" in c else s.__setitem__("probe", s["probe"] + 1))
        has_p, has_u = "@planks" in c, "format usage" in c
        s["plnk"] += has_p
        s["usage"] += has_u
        s["join"] += (has_p and has_u)
        if "cucumber" in c and "--dry-run" not in c:
            names = len(re.findall(r"--name\b", c))
            if names == 0:
                s["broad"] += 1
            else:
                alts = re.findall(r'--name\s+"([^"]*)"', c)
                s["focN" if (names > 1 or (alts and "|" in alts[0])) else "foc1"] += 1
    return s


def main(argv):
    scratch = os.path.join(HERE, ".eval-scratch")
    if "--scratch" in argv:
        scratch = argv[argv.index("--scratch") + 1]
    rows = []
    for d in sorted(glob.glob(os.path.join(scratch, "methdraw-*-*"))):
        if not os.path.isdir(d):
            continue
        wave = os.path.basename(d)
        m = re.match(r"methdraw-([bc])-([a-z0-9]+)-(\d+)$", wave)
        if not m:
            continue
        arm = "candidate" if m.group(1) == "c" else "control"
        model = m.group(2)
        legs = {}
        for leg in ("v1-captain", "v1-qm"):
            f = glob.glob(os.path.join(d, f"{leg}.out/session/*.jsonl"))
            legs[leg] = leg_stats(sorted(f)[0]) if f else None
        ss = ""
        p = os.path.join(d, "v1-selfsuite.txt")
        if os.path.exists(p):
            mm = re.search(r"(\d+) scenarios \(([^)]*)\)", open(p, errors="replace").read())
            ss = f"{mm.group(1)} ({mm.group(2)})" if mm else "?"
        rows.append((wave, arm, model, legs, ss))

    hdr = ["wave", "arm", "model", "self-suite", "QMcalls", "PLAN", "probe", "foc1", "focN", "broad", "plnk", "usage", "JOIN"]
    w = [24, 10, 6, 22, 8, 5, 6, 5, 5, 6, 5, 6, 5]
    print("".join(h.ljust(x) for h, x in zip(hdr, w)))
    agg = {}
    for wave, arm, model, legs, ss in rows:
        q = legs.get("v1-qm")
        if not q:
            print(f"{wave.ljust(24)}{arm.ljust(10)}{model.ljust(6)}NO QM SESSION")
            continue
        vals = [wave, arm, model, ss, q["calls"], q["plan"], q["probe"], q["foc1"], q["focN"], q["broad"], q["plnk"], q["usage"], q["join"]]
        print("".join(str(v).ljust(x) for v, x in zip(vals, w)))
        a = agg.setdefault((arm, model), dict(n=0, adopted=0, **{k: 0 for k in ("calls", "plan", "probe", "foc1", "focN", "broad", "plnk", "usage", "join")}))
        a["n"] += 1
        a["adopted"] += 1 if q["plan"] > 0 else 0
        for k in ("calls", "plan", "probe", "foc1", "focN", "broad", "plnk", "usage", "join"):
            a[k] += q[k]

    print("\n=== aggregate (QM build leg; adoption = draws running >=1 composite PLAN)")
    print("arm/model".ljust(22) + "draws".ljust(7) + "adopted".ljust(9) + "join/draw".ljust(11) + "foc1/draw".ljust(11) + "focN/draw".ljust(11) + "calls/draw")
    for (arm, model), a in sorted(agg.items()):
        n = a["n"]
        print(f"{arm+'/'+model:22s}{n:<7}{a['adopted']}/{n:<7}{a['join']/n:<11.1f}{a['foc1']/n:<11.1f}{a['focN']/n:<11.1f}{a['calls']/n:.1f}")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
