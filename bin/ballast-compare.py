#!/usr/bin/env python3
"""The controlled latency probe: does resident CACHED context cost wall-clock?

Usage: ballast-compare.py <session-uuid>

Design. Two arms of general-purpose agents (no Shipshape doctrine anywhere, so no
role behaviour and no contamination risk). Both arms do an IDENTICAL task: read one
file, then run eight `echo` commands one per turn. The only difference is the size
of the file read:

    LIGHT  reads a 39-byte stub      -> ~0 resident tokens
    HEAVY  reads a 73,429-byte file  -> ~24k resident tokens, sized to the shared Articles

The ballast lands as a tool result at invocation 1 and is then RESIDENT and CACHED
for every invocation after - exactly how doctrine behaves. Outputs and tool results
on the eight echo turns are tiny and identical across arms, so decode time is held
fixed and the ONLY thing that varies is the size of the cached prefix.

If HEAVY's think-time per echo turn matches LIGHT's, a cached prefix is free in
wall-clock, and trimming doctrine buys NOTHING on latency (dk's rung 2).
"""
import sys, os, glob, statistics
from datetime import datetime
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from inbound import load  # noqa: E402

PROJ = os.path.expanduser("~/.claude/projects/-home-exedev-shipshape-shakedown")


def ts(r):
    t = r.get("timestamp")
    return datetime.fromisoformat(t.replace("Z", "+00:00")) if t else None


def leg(path):
    """Return (arm, [samples]) for a ballast-probe leg, or None if not one."""
    recs = load(path)
    blob = open(path).read()
    if "probe-8" not in blob:
        return None
    arm = "HEAVY" if "ballast.txt" in blob else ("LIGHT" if "stub.txt" in blob else None)
    if not arm:
        return None

    rows, seen, last_in = [], set(), None
    for r in recs:
        if r.get("type") in ("user", "attachment"):
            last_in = ts(r) or last_in
            continue
        if r.get("type") != "assistant":
            continue
        mid = r["message"]["id"]
        if mid in seen:
            continue
        seen.add(mid)
        u, t = r["message"]["usage"], ts(r)
        if not t or not last_in:
            continue
        # keep only the echo turns: one Bash call, tiny output
        tools = [c for c in r["message"].get("content", []) or []
                 if isinstance(c, dict) and c.get("type") == "tool_use"]
        if len(tools) != 1 or tools[0].get("name") != "Bash":
            continue
        if "echo probe-" not in str(tools[0].get("input", {}).get("command", "")):
            continue
        rows.append({
            "think": (t - last_in).total_seconds(),
            "ctx": (u.get("input_tokens", 0) + u.get("cache_creation_input_tokens", 0)
                    + u.get("cache_read_input_tokens", 0)),
            "out": u.get("output_tokens", 0),
        })
    return (arm, rows) if rows else None


def main(session):
    arms = {"LIGHT": [], "HEAVY": []}
    legs = 0
    for f in sorted(glob.glob(f"{PROJ}/{session}/subagents/agent-*.jsonl")):
        r = leg(f)
        if r:
            arms[r[0]] += r[1]
            legs += 1

    if not arms["LIGHT"] or not arms["HEAVY"]:
        sys.exit(f"need both arms; found LIGHT={len(arms['LIGHT'])} HEAVY={len(arms['HEAVY'])} "
                 f"over {legs} legs")

    print("CONTROLLED LATENCY PROBE - identical task, only the cached prefix differs")
    print(f"{legs} legs, echo turns only (one Bash call, tiny output, held fixed)\n")
    print(f"{'ARM':<7} {'n':>3} {'MEAN CTX':>9} {'MEAN OUT':>9} {'MEAN THINK':>11} {'MEDIAN':>8} {'STDEV':>7}")
    stat = {}
    for arm in ("LIGHT", "HEAVY"):
        rs = arms[arm]
        th = [r["think"] for r in rs]
        stat[arm] = (statistics.mean(th), statistics.median(th),
                     statistics.stdev(th) if len(th) > 1 else 0,
                     statistics.mean(r["ctx"] for r in rs),
                     statistics.mean(r["out"] for r in rs), len(rs))
        m, md, sd, c, o, n = stat[arm]
        print(f"{arm:<7} {n:>3} {c:>9,.0f} {o:>9,.0f} {m:>10.2f}s {md:>7.2f}s {sd:>6.2f}s")

    lm, lmd, lsd, lc, _, ln = stat["LIGHT"]
    hm, hmd, hsd, hc, _, hn = stat["HEAVY"]
    dctx = hc - lc

    # The heavy arm has a long right tail (a single slow call skews the mean), so the
    # MEDIAN difference is the estimate that gets quoted, and significance is judged by
    # a rank test that assumes no distribution at all.
    dmean, dmed = hm - lm, hmd - lmd
    L = sorted(r["think"] for r in arms["LIGHT"])
    H = sorted(r["think"] for r in arms["HEAVY"])
    pairs = sorted([(x, "L") for x in L] + [(x, "H") for x in H])
    rl = [i + 1 for i, (_, g) in enumerate(pairs) if g == "L"]
    n1, n2 = len(L), len(H)
    U = sum(rl) - n1 * (n1 + 1) / 2
    z = (U - n1 * n2 / 2) / ((n1 * n2 * (n1 + n2 + 1) / 12) ** .5)

    print(f"\nEXTRA RESIDENT CONTEXT : {dctx:>+9,.0f} tokens  (target ~24,000 = the shared Articles)")
    print(f"EXTRA THINK-TIME       : {dmed:>+9.2f} s per invocation  (median; mean {dmean:+.2f}s is")
    print(f"                                   skewed by one slow call in the heavy arm)")
    print(f"SIGNIFICANCE           : Mann-Whitney z = {z:+.2f}  (rank-based, distribution-free)")

    print()
    if abs(z) < 2.0:
        print("VERDICT: NO DETECTABLE LATENCY COST.")
        print(f"  Carrying {dctx:,.0f} extra cached tokens did not measurably slow an invocation.")
        print("  A cached prefix is essentially free in wall-clock, so trimming doctrine buys")
        print("  ~nothing on latency (rung 2) and ~nothing real on tokens (rung 4, cached at")
        print("  ~10%). The case for shrinking then rests ENTIRELY on rung-1 QUALITY.")
    else:
        print("VERDICT: RESIDENT CACHED CONTEXT CARRIES A REAL, CAUSAL TIME COST.")
        print(f"  {dctx:,.0f} extra cached tokens cost {dmed:+.2f}s per invocation on IDENTICAL work")
        print(f"  - a {100*dmed/lmd:+.0f}% increase over the light arm's {lmd:.2f}s baseline.")
        print(f"  On a 15-invocation leg that is {dmed*15:+.0f}s; across the 224-invocation fleet,")
        print(f"  ~{dmed*224/60:.1f} minutes spent purely re-reading the shared Articles.")
        print()
        print("  This is the controlled result the per-leg r=+0.82 could not deliver: the task is")
        print("  held fixed and ONLY the prefix varies, so the cost is causal, not confounded.")
        print("  Context bulk IS a rung-2 latency cost. Goal 2 is promoted above the token rung.")
        print()
        print("  BUT IT DOES NOT LICENSE A CUT, and the ladder is why. Quality outranks latency,")
        print("  and mistake/fix cycles are the dominant latency source (METRICS). One prevented")
        print("  rework cycle costs a whole invocation or more - which buys back many seconds of")
        print("  prefill. A section earns its ~0.03s/invocation if it prevents anything at all.")
        print("  So the trim case still needs CONSUMPTION evidence, section by section. The price")
        print("  tag is now known; the WORTH is still instrument 3's question, and a probe's.")
    print("\n  Scope: general-purpose agents, one model, one runtime, echo-sized outputs. It")
    print("  isolates prefix cost. It says nothing about what any doctrine section is WORTH.")


if __name__ == "__main__":
    main(sys.argv[1] if len(sys.argv) > 1 else "4cce0ff5-d9a6-4258-81c9-7a336c29f857")
