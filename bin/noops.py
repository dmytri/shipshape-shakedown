#!/usr/bin/env python3
"""Find and classify NO-OP legs and voyages, and attribute each to a layer.

Standing order (dk, 2026-07-28): track and investigate no-ops ALWAYS, and propose fixes in
playbook, harness or doctrine — especially doctrine. A harness or playbook workaround must
never mask a doctrine fault; the point is to understand the cause, not to hide it.

A no-op is a leg or voyage that consumed real budget and moved nothing. Three signatures,
each read from durable evidence only (session JSONL + driver.log), never from report prose:

  TRUNCATED   the leg's last turn has stopReason=length -> the response was CUT OFF, usually
              mid-thought. Exit code is still 0 and the driver still logs VOYAGE-COMPLETE, so
              this is invisible unless you look. Where reasoning tokens ~= the whole output
              budget, the leg spent its entire allowance thinking and never acted.
  NO-WRITE    the leg made zero write/edit tool calls. A Captain leg that authors nothing
              cannot produce a watchbill, so the QM leg that follows correctly reports "deck
              at rest" and the whole voyage is spent.
  NO-MOVE     the voyage's oracle score AND failing set are unchanged from the prior voyage.

Layer attribution is the point of the report:
  - TRUNCATED with reasoning ~= budget: harness sets no explicit output budget AND doctrine
    determines how much a role must emit per turn. A doctrine that costs ~2x output per turn
    is ~2x more likely to die against a fixed per-response ceiling. Report both.
  - NO-WRITE with a full turn count: playbook — the prompt names a stopping point but no
    artifact-shaped exit condition.
  - NO-MOVE with writes and a moving tree: the work was real but aimed wrong; look at the
    intent selection and at whether the tier can express the defect at all.

usage: bin/noops.py [<wave-glob> ...]        (default: .eval-scratch/P*-*)
"""
import glob
import json
import os
import re
import sys
from collections import Counter


def legs(wave):
    for out in sorted(glob.glob(os.path.join(wave, "*.out"))):
        name = os.path.basename(out)[:-4]
        sessions = glob.glob(os.path.join(out, "session", "*.jsonl"))
        if sessions:
            yield name, sessions[0]


def fold(path):
    """Return (turns, writes, tools, stop_reasons, last_output, last_reasoning)."""
    turns = writes = 0
    tools = Counter()
    stops = []
    last_out = last_reason = 0
    for line in open(path, encoding="utf-8", errors="replace"):
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
        turns += 1
        for part in msg.get("content") or []:
            if part.get("type") == "toolCall":
                tools[part.get("name")] += 1
                if part.get("name") in ("write", "edit"):
                    writes += 1
        if msg.get("stopReason"):
            stops.append(msg["stopReason"])
        usage = msg.get("usage") or {}
        if usage:
            last_out = usage.get("output", last_out)
            last_reason = usage.get("reasoning", last_reason)
    return turns, writes, tools, stops, last_out, last_reason


def voyage_moves(wave):
    """Oracle score per voyage line, in order, from the driver log."""
    log = os.path.join(wave, "driver.log")
    if not os.path.exists(log):
        return []
    scores = []
    for line in open(log, encoding="utf-8", errors="replace"):
        m = re.search(r"oracle (\d+)/(\d+)", line)
        if m:
            scores.append(int(m.group(1)))
    return scores


def main(argv):
    patterns = argv[1:] or [".eval-scratch/P*-*"]
    waves = [w for p in patterns for w in sorted(glob.glob(p)) if os.path.isdir(w)]
    grand = Counter()
    for wave in waves:
        rows = []
        for name, session in legs(wave):
            turns, writes, tools, stops, out, reason = fold(session)
            flags = []
            if "length" in stops:
                pct = (reason / out * 100) if out else 0
                flags.append(f"TRUNCATED(out={out},reasoning={pct:.0f}%)")
            if writes == 0 and turns:
                flags.append("NO-WRITE")
            if flags:
                rows.append((name, turns, writes, sum(tools.values()), " ".join(flags)))
                for f in flags:
                    grand[f.split("(")[0]] += 1
        scores = voyage_moves(wave)
        stalls = sum(1 for a, b in zip(scores, scores[1:]) if a == b)
        if rows or stalls:
            print(f"\n=== {os.path.basename(wave)} — trajectory {scores or '-'}")
            if stalls:
                print(f"    NO-MOVE voyages: {stalls}")
                grand["NO-MOVE"] += stalls
            for name, turns, writes, calls, flags in rows:
                print(f"    {name:16s} turns={turns:3d} writes={writes:2d} calls={calls:3d}  {flags}")
    print("\n=== totals ===")
    for k, v in sorted(grand.items(), key=lambda kv: -kv[1]):
        print(f"    {k:12s} {v}")
    if not grand:
        print("    none")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
