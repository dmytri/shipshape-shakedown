#!/usr/bin/env python3
"""Peak single-response output per model per run, against the budget in force.

Standing instrument (dk, 2026-07-28). The output budget must be the SAME for every model, and
we must know what each run actually peaked at — otherwise a result silently depends on a cap
nobody chose. pi takes `model.max_tokens ?? 4096` from provider metadata, so before this was
fixed deepseek-v4-flash ran at 4096 while mimo and hy3 ran at 131072: every flash result in
both arms was produced under a 32x tighter budget than its peers, and candidate Captain legs
truncated 9/12 on flash against 0/12 everywhere else.

Read this alongside bin/noops.py: a TRUNCATED leg is one whose peak HIT the cap, and that is a
run whose shape the budget decided rather than the doctrine.

Columns:
  cap        the budget the leg recorded in leg.json (0/None = unseeded, pi's own default)
  peak       the largest single-response output seen in the leg
  at-cap     turns that ended with stopReason=length (i.e. cut off mid-generation)
  headroom   how far the peak sat below the cap; near zero means the cap was binding

usage: peaks.py [<wave-glob> ...]      (default: .eval-scratch/P*-* and data/gen-*/*)
"""
import glob
import json
import os
import sys
from collections import defaultdict


def leg_sessions(wave):
    """Yield (leg_name, session_path, leg_json_path) for both live and banked layouts."""
    for out in sorted(glob.glob(os.path.join(wave, "*.out"))):
        name = os.path.basename(out)[:-4]
        s = glob.glob(os.path.join(out, "session", "*.jsonl")) or \
            glob.glob(os.path.join(out, "session.jsonl"))
        if s:
            yield name, s[0], os.path.join(out, "leg.json")
    for s in sorted(glob.glob(os.path.join(wave, "*.session.jsonl"))):
        name = os.path.basename(s)[: -len(".session.jsonl")]
        yield name, s, os.path.join(wave, name + ".leg.json")


def fold(session):
    peak = 0
    at_cap = 0
    model = None
    for line in open(session, encoding="utf-8", errors="replace"):
        line = line.strip()
        if not line:
            continue
        try:
            rec = json.loads(line)
        except Exception:
            continue
        msg = rec.get("message") or {}
        if msg.get("role") != "assistant":
            continue
        model = model or msg.get("model")
        peak = max(peak, (msg.get("usage") or {}).get("output", 0) or 0)
        if msg.get("stopReason") == "length":
            at_cap += 1
    return peak, at_cap, model


def main(argv):
    patterns = argv[1:] or [".eval-scratch/P*-*", "data/gen-*/*"]
    waves = [w for p in patterns for w in sorted(glob.glob(p)) if os.path.isdir(w)]
    rows = defaultdict(lambda: {"peak": 0, "at_cap": 0, "legs": 0, "caps": set()})
    for wave in waves:
        wname = os.path.basename(wave)
        for name, session, legjson in leg_sessions(wave):
            peak, at_cap, model = fold(session)
            cap = None
            try:
                cap = json.load(open(legjson)).get("max_tokens")
                model = model or json.load(open(legjson)).get("model")
            except Exception:
                pass
            key = (wname, model or "?")
            r = rows[key]
            r["peak"] = max(r["peak"], peak)
            r["at_cap"] += at_cap
            r["legs"] += 1
            r["caps"].add(cap)
    if not rows:
        print("no legs found")
        return 0
    print(f"{'wave':22s} {'model':26s} {'legs':>5s} {'cap':>7s} {'peak':>7s} {'at-cap':>7s} {'headroom':>9s}")
    for (wave, model), r in sorted(rows.items()):
        caps = {c for c in r["caps"] if c}
        cap = str(sorted(caps)[0]) if len(caps) == 1 else ("mixed" if caps else "unset")
        head = (sorted(caps)[0] - r["peak"]) if len(caps) == 1 else ""
        flag = "  <-- BUDGET WAS BINDING" if r["at_cap"] else ""
        print(f"{wave:22s} {model:26s} {r['legs']:5d} {cap:>7s} {r['peak']:7d} {r['at_cap']:7d} "
              f"{str(head):>9s}{flag}")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
