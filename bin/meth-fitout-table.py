#!/usr/bin/env python3
"""Baseline table for the fitting-out draws: per stack, per model, what one fit-out leg costs and
what it actually derived.

dk's convention: "results" means the METRICS TABLE — invocations, tool calls, tokens, price,
wall-clock, verdict, with totals. This renders that for `bin/meth-fitout.sh` waves and adds the two
columns the methods candidate exists for: how many methods the fit DERIVED, and how many of those
actually RAN when the operator executed them.

Usage: bin/meth-fitout-table.py [<wave-glob> ...]      default: methfit*
"""
import glob
import json
import os
import re
import subprocess
import sys

HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SCRATCH = os.environ.get("EVAL_SCRATCH", os.path.join(HERE, ".eval-scratch"))
METHODS = ("verify", "hygiene", "static", "regression", "rigging-proof")


def leg_metrics(sess):
    out = subprocess.run(["python3", os.path.join(HERE, "bin/eval-map.py"), sess],
                         capture_output=True, text=True).stdout
    m = re.search(r"turns=(\d+)\s+wall=([\d.]+)s\s+in=(\d+)\s+out=(\d+)\s+cache_read=(\d+)\s+cost=\$([\d.]+)", out)
    if not m:
        return None
    tools = 0
    try:
        for line in open(sess, errors="replace"):
            tools += len(re.findall(r'"(?:toolName|name)":\s*"(?:bash|read|write|edit|glob|grep)"', line))
    except Exception:
        pass
    return dict(turns=int(m.group(1)), wall=float(m.group(2)), tin=int(m.group(3)),
                tout=int(m.group(4)), cache=int(m.group(5)), cost=float(m.group(6)), tools=tools)


def rigging_facts(sim):
    r = os.path.join(sim, "RIGGING.md")
    f = dict(rigging=False, cmds=0, derived=0, none=0, yoink=0, backticked=0, values={})
    if not os.path.exists(r):
        return f
    text = open(r, errors="replace").read()
    f["rigging"] = True
    f["yoink"] = text.count("yoink")
    cmd_block = re.search(r"^## Commands\n(.*?)(?=^## )", text, re.S | re.M)
    if cmd_block:
        f["cmds"] = len([l for l in cmd_block.group(1).splitlines() if l.startswith("- ") and ": none" not in l])
    mblock = re.search(r"^## Methods\n(.*?)(?=^## )", text, re.S | re.M)
    if mblock:
        for line in mblock.group(1).splitlines():
            mm = re.match(r"- ([a-z-]+): *(.*)$", line.strip())
            if not mm:
                continue
            name, val = mm.group(1), mm.group(2).strip()
            f["values"][name] = val
            if val.strip("`").lower() in ("none", ""):
                f["none"] += 1
            else:
                f["derived"] += 1
                if val.startswith("`"):
                    f["backticked"] += 1
    return f


def audit_result(base):
    # A row for a leg still working is NOT a zero: this corpus's own rule is that an unfinished
    # leg's outcome is a function of when you look, so an in-progress draw is marked, never scored.
    log = os.path.join(base, "fitout.log")
    if not os.path.exists(log):
        return ""
    text = open(log, errors="replace").read()
    m = re.findall(r"RESULT: (\d+)/(\d+) derived methods run", text)
    if m:
        return f"{m[-1][0]}/{m[-1][1]}"
    return "RUNNING" if "FITOUT END" not in text else "-"


def main(argv):
    globs = argv or ["methfit*"]
    rows = []
    for g in globs:
        for d in sorted(glob.glob(os.path.join(SCRATCH, g))):
            if not os.path.isdir(d):
                continue
            wave = os.path.basename(d)
            sess = sorted(glob.glob(os.path.join(d, "fitout.out/session/*.jsonl")))
            if not sess:
                rows.append((wave, None, None, None))
                continue
            model = ""
            lg = os.path.join(d, "fitout.log")
            if os.path.exists(lg):
                mm = re.search(r"stack=(\S+) model=(\S+)", open(lg, errors="replace").read())
                model = f"{mm.group(1)}/{mm.group(2).split('/')[-1]}" if mm else ""
            rows.append((wave, model, leg_metrics(sess[0]), rigging_facts(os.path.join(d, "sim"))))

    hdr = ["wave", "stack/model", "turns", "tools", "fresh_in", "out", "cache", "cost", "wall", "cmds", "meth", "none", "RAN", "yoink"]
    w = [16, 14, 7, 7, 10, 8, 11, 9, 8, 6, 6, 6, 6, 6]
    print("".join(h.ljust(x) for h, x in zip(hdr, w)))
    tot = dict(turns=0, tools=0, tin=0, tout=0, cache=0, cost=0.0, wall=0.0)
    for wave, model, m, f in rows:
        if not m:
            print(f"{wave.ljust(16)}{(model or '').ljust(14)}(no session / running)")
            continue
        ran = audit_result(os.path.join(SCRATCH, wave))
        vals = [wave, model, m["turns"], m["tools"], f"{m['tin']:,}", f"{m['tout']:,}", f"{m['cache']:,}",
                f"${m['cost']:.4f}", f"{m['wall']:.0f}s", f["cmds"], f["derived"], f["none"], ran, f["yoink"]]
        print("".join(str(v).ljust(x) for v, x in zip(vals, w)))
        for k in tot:
            tot[k] += m[k]
    print("".join(str(v).ljust(x) for v, x in zip(
        ["TOTAL", "", tot["turns"], tot["tools"], f"{tot['tin']:,}", f"{tot['tout']:,}", f"{tot['cache']:,}",
         f"${tot['cost']:.4f}", f"{tot['wall']:.0f}s", "", "", "", "", ""], w)))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
