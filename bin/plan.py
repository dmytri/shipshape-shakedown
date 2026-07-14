#!/usr/bin/env python3
"""The retrieval plan: how many invocations did the leg spend WITHOUT needing inference?

Usage: plan.py <session-uuid> [...]      fleet view
       plan.py --leg <agent.jsonl>       one leg, invocation by invocation

A model invocation is justified only when inference is REQUIRED to decide what comes
next. Two shapes fail that test, and both are measured here:

  OPENING BLOCK   The leading invocations that only load doctrine and read the fixed
                  opening files. Every role does this, identically, every leg. No
                  inference decides any of it - it is a deterministic retrieval block
                  paid as serial round trips.

  INDEPENDENT RUN Consecutive invocations issuing only read-only retrievals where NO
                  call consumes the previous call's output. They could have been issued
                  together in one turn. A retrieval that does not depend on another
                  retrieval's result is not a reason to spend a turn.

The dependency test is deliberately conservative: if an invocation's arguments quote
any token that appeared in the previous tool result, the run BREAKS and those calls are
never counted as mergeable. So the saving reported here is a FLOOR, not a target.

What this does NOT license: speculative merging. Fetching five files because two might
be needed saves invocations (rung 3) but adds resident context re-read on every later
invocation - and resident context has a measured latency cost (+0.84s per ~24k tokens,
METRICS). Merge what the plan retrieves ANYWAY. Never merge on spec.
"""
import sys, os, re, glob, collections
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from inbound import load, decompose  # noqa: E402

PROJ = os.path.expanduser("~/.claude/projects/-home-exedev-shipshape-shakedown")

# Files every role reads in its Opening, by doctrine. Fixed, every leg, no inference.
OPENING_FILES = ("AGENTS.md", "RIGGING.md", "CAPTAIN.md", "SKILL.md", "templates.md")

# Commands that only observe. A command that mutates can never be merged blindly.
READONLY = re.compile(
    r"^\s*(git\s+(status|log|diff|show|branch|rev-parse|ls-files|cat-file)"
    r"|ls|cat|grep|rg|wc|find|head|tail|jq|stat|file|realpath|basename|dirname"
    r"|sed\s+-n|awk)\b")


def readonly(t):
    if t["name"] in ("Read", "Grep", "Glob"):
        return True
    if t["name"] != "Bash":
        return False
    cmd = str(t["input"].get("command", ""))
    if any(x in cmd for x in (">", ">>", "rm ", "mv ", "cp ", "mkdir", "touch", "git add",
                              "git commit", "git checkout", "npm", "npx")):
        return False
    return all(READONLY.match(p.strip()) for p in re.split(r"&&|\|\||;", cmd) if p.strip())


def opening_only(t):
    if t["name"] == "Skill":
        return True
    if t["name"] == "Read":
        return any(k in str(t["input"].get("file_path", "")) for k in OPENING_FILES)
    return False


def results_by_id(recs):
    out = {}
    for r in recs:
        if r.get("type") != "user":
            continue
        for c in (r["message"].get("content") or []):
            if isinstance(c, dict) and c.get("type") == "tool_result":
                body = c.get("content")
                out[c.get("tool_use_id")] = body if isinstance(body, str) else ""
    return out


def analyse(path):
    recs = load(path)
    d = decompose(recs, os.path.basename(path))
    if not d or d["N"] < 3:
        return None
    res = results_by_id(recs)
    invs = d["invs"]

    # 1. the opening block
    opening = 0
    for e in invs:
        if e["tools"] and all(opening_only(t) for t in e["tools"]):
            opening += 1
        else:
            break

    # 2. independent read-only runs
    runs, run, prev_out = [], 0, ""
    for e in invs:
        ts = e["tools"]
        if not ts or not all(readonly(t) for t in ts):
            if run > 1:
                runs.append(run)
            run, prev_out = 0, ""
            continue
        args = " ".join(str(t["input"].get("file_path") or t["input"].get("command") or "")
                        for t in ts)
        toks = re.findall(r"[\w./-]{6,}", args)
        dependent = bool(prev_out) and any(w in prev_out for w in toks)
        if dependent:
            if run > 1:
                runs.append(run)
            run = 1
        else:
            run += 1
        prev_out = " ".join(res.get(t["id"], "") for t in ts)[:8000]
    if run > 1:
        runs.append(run)

    calls = collections.Counter(len(e["tools"]) for e in invs)
    return {"N": d["N"], "opening": opening, "runs": runs,
            "mergeable": sum(r - 1 for r in runs), "calls": calls,
            "leg": os.path.basename(path)[6:14]}


def main(sessions):
    rows, calls = [], collections.Counter()
    for s in sessions:
        for f in sorted(glob.glob(f"{PROJ}/{s}/subagents/agent-*.jsonl")):
            a = analyse(f)
            if a:
                rows.append(a)
                calls.update(a["calls"])
    if not rows:
        sys.exit("no legs")

    print(f"{'LEG':<10} {'INV':>4} {'OPENING':>8} {'MERGEABLE':>10} {'RUNS':>16} {'WASTE':>7}")
    print("-" * 60)
    for a in rows:
        waste = a["opening"] - 1 + a["mergeable"]     # the opening still costs ONE invocation
        print(f"{a['leg']:<10} {a['N']:>4} {a['opening']:>8} {a['mergeable']:>10} "
              f"{str(sorted(a['runs'], reverse=True)[:4]):>16} {100*waste/a['N']:>6.0f}%")

    N = sum(a["N"] for a in rows)
    op = sum(a["opening"] for a in rows)
    mg = sum(a["mergeable"] for a in rows)
    waste = sum(a["opening"] - 1 + a["mergeable"] for a in rows)
    tot = sum(calls.values())

    print(f"\nTOOL CALLS PER INVOCATION")
    for k in sorted(calls):
        print(f"   {k}: {calls[k]:>4}  ({100*calls[k]/tot:>4.1f}%)")

    print(f"\n{len(rows)} legs / {N} invocations")
    print(f"   opening block          {op:>4}  ({100*op/N:>4.1f}%)  - deterministic, no inference needed")
    print(f"   independent merge runs {mg:>4}  ({100*mg/N:>4.1f}%)  - none consumed the prior result")
    print(f"   COMPILABLE WASTE       {waste:>4}  ({100*waste/N:>4.1f}%)  - removable at ZERO quality risk")
    print(f"\n   (waste = opening collapsed to ONE invocation + independent runs merged.")
    print(f"    A conservative FLOOR: the read-only detector is strict and the dependency")
    print(f"    test breaks any run whose argument quotes the previous result.)")


if __name__ == "__main__":
    if "--leg" in sys.argv:
        a = analyse(sys.argv[sys.argv.index("--leg") + 1])
        print(a)
    else:
        args = [x for x in sys.argv[1:] if not x.startswith("--")]
        if not args:
            args = [os.path.basename(p) for p in glob.glob(f"{PROJ}/*") if os.path.isdir(p)]
        main(args)
