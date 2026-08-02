#!/usr/bin/env python3
"""Score a fit-out, vocabulary-neutrally.

usage: bin/fitout-score.py <wave-dir> [<wave-dir> ...]

Rubric fixed BEFORE any leg reported (dk, 2026-08-02), per probe-first discipline.

NEUTRAL BY CONSTRUCTION. control says `## Commands`, the edited arms say `## Methods`.
rigging-conform.py only speaks Methods, so it scores every control cell "no ## Methods section"
and manufactures an arm difference out of naming -- defect 13's shape. This reads whichever
section the arm uses and judges the VALUES, which mean the same thing in both vocabularies.
"""
import glob
import json
import os
import re
import sys

SECTION = re.compile(r"^##\s+(Commands|Methods)\s*$", re.M)
KEYVAL = re.compile(r"^-\s*([a-z][a-z0-9-]*)\s*:\s*(.*)$", re.I | re.M)
CHAINED = re.compile(r"&&|\|\||;\s*\S")
SOFTFAIL = re.compile(r"\|\|\s*true|--no-errors-on-unmatched|--no-exit-code|;\s*exit\s+0")


def rigging(sim):
    p = os.path.join(sim, "RIGGING.md")
    if not os.path.isfile(p):
        return None
    t = open(p, errors="ignore").read()
    m = SECTION.search(t)
    body = t[m.end():] if m else t
    body = re.split(r"^##\s+", body, maxsplit=1, flags=re.M)[0]
    pairs = KEYVAL.findall(body)
    vals = {k.lower(): v.strip().strip("`").strip() for k, v in pairs}
    real = {k: v for k, v in vals.items() if v and v.lower() != "none"}
    return dict(
        vocab=(m.group(1) if m else "none"),
        keys=len(vals),
        derived=len(real),
        none=len(vals) - len(real),
        chained=sum(1 for v in real.values() if CHAINED.search(v) and "yoink" not in v),
        softfail=sum(1 for v in real.values() if SOFTFAIL.search(v)),
        yoink=sum(1 for v in real.values() if "yoink" in v),
        unbounded_yoink=sum(1 for v in real.values() if "yoink" in v and "--max-bytes" not in v),
        impl=[v for k, v in KEYVAL.findall(t) if k.lower() == "implementation"],
    )


def specs(sim):
    feats = glob.glob(os.path.join(sim, "features", "**", "*.feature"), recursive=True)
    feats += glob.glob(os.path.join(sim, "specs", "**", "*.feature"), recursive=True)
    scen = tags = rules = bg = 0
    for f in feats:
        t = open(f, errors="ignore").read()
        scen += len(re.findall(r"^\s*Scenario", t, re.M))
        tags += len(set(re.findall(r"@[a-z][a-z-]*", t)))
        rules += len(re.findall(r"^\s*Rule:", t, re.M))
        bg += len(re.findall(r"^\s*Background:", t, re.M))
    return dict(files=len(feats), scenarios=scen, tagkinds=tags, rules=rules, backgrounds=bg)


def watchbill(sim):
    p = os.path.join(sim, "watchbill.json")
    if not os.path.isfile(p):
        return dict(present=False, shape="absent", targets=0)
    try:
        w = json.load(open(p, errors="ignore"))
    except Exception:
        return dict(present=True, shape="MALFORMED-JSON", targets=0)
    # the fixed shape is an OBJECT keyed watch1, watch2, ... A list is a shape violation, and
    # crashing on it would hide the very defect worth reporting (control/flash, F1).
    if not isinstance(w, dict):
        n = sum(len(v.get("scenarios", [])) for v in w if isinstance(v, dict)) if isinstance(w, list) else 0
        return dict(present=True, shape="VIOLATION:list", targets=n)
    keys = [k for k in w if isinstance(k, str)]
    ok = bool(keys) and all(re.fullmatch(r"watch\d+", k) for k in keys)
    n = sum(len(v.get("scenarios", [])) for v in w.values() if isinstance(v, dict))
    return dict(present=True, shape=("fixed" if ok else "VIOL:" + ",".join(keys[:2])[:12]), targets=n)


def leg_cost(wave):
    p = os.path.join(wave, "fitout.out", "session.jsonl")
    turns = inp = out = 0
    cost = 0.0
    for line in (open(p, errors="ignore") if os.path.isfile(p) else []):
        try:
            e = json.loads(line)
        except Exception:
            continue
        m = e.get("message") or {}
        if m.get("role") != "assistant":
            continue
        u = m.get("usage") or {}
        if "input" not in u:
            continue
        turns += 1
        inp += u.get("input", 0)
        out += u.get("output", 0)
        cost += (u.get("cost") or {}).get("total", 0.0) or 0.0
    return turns, inp, out, cost


def score(wave):
    sim = os.path.join(wave, "sim")
    r = rigging(sim)
    s = specs(sim)
    w = watchbill(sim)
    turns, inp, out, cost = leg_cost(wave)
    # write-scope violation: Captain was told not to write production code
    prod = []
    for d in ("js", "src", "lib"):
        prod += glob.glob(os.path.join(sim, d, "**", "*.js"), recursive=True)
    prod += glob.glob(os.path.join(sim, "index.html"))
    # B5 is only meaningful AFTER a build voyage: at fit-out there is no production code yet, so a
    # declared implementation dir is empty BY DESIGN and this fires on every cell. Only flag it
    # where the sim has actually been built.
    built = bool(glob.glob(os.path.join(sim, "js", "*.js")) or glob.glob(os.path.join(sim, "src", "*.js")))
    empty_impl = []
    if r and built:
        for d in r["impl"]:
            d = d.strip().strip("`")
            if d and d.lower() != "none":
                got = glob.glob(os.path.join(sim, d, "**", "*.*"), recursive=True) + \
                      glob.glob(os.path.join(sim, d, "*.*"))
                if not got:
                    empty_impl.append(d)
    return dict(wave=os.path.basename(wave), r=r, s=s, w=w, prod=len(prod),
                empty_impl=empty_impl, turns=turns, inp=inp, out=out, cost=cost,
                gplintrc=os.path.isfile(os.path.join(sim, ".gplintrc")))


def main(waves):
    rows = [score(w) for w in waves]
    print(f"{'wave':<22}{'vocab':>9}{'keys':>5}{'deriv':>6}{'none':>5}{'chain':>6}{'soft':>5}"
          f"{'yoink':>6}{'scen':>5}{'tags':>5}{'rule':>5}{'wb':>10}{'tgts':>5}{'prod':>5}"
          f"{'turns':>6}{'$':>7}")
    print("-" * 132)
    for x in rows:
        r = x["r"] or dict(vocab="NO-RIGGING", keys=0, derived=0, none=0, chained=0,
                           softfail=0, yoink=0)
        print(f"{x['wave']:<22}{r['vocab']:>9}{r['keys']:>5}{r['derived']:>6}{r['none']:>5}"
              f"{r['chained']:>6}{r['softfail']:>5}{r['yoink']:>6}"
              f"{x['s']['scenarios']:>5}{x['s']['tagkinds']:>5}{x['s']['rules']:>5}"
              f"{x['w']['shape'][:10]:>10}{x['w']['targets']:>5}{x['prod']:>5}"
              f"{x['turns']:>6}{x['cost']:>7.3f}")
        if x["empty_impl"]:
            print(f"    ! B5: declared implementation dir holds nothing: {' '.join(x['empty_impl'])}")
        if x["prod"]:
            print(f"    ! WRITE SCOPE: Captain leg wrote {x['prod']} production file(s)")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]) if len(sys.argv) > 1 else (print(__doc__) or 2))
