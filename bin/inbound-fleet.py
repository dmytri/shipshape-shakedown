#!/usr/bin/env python3
"""Fleet view for instrument 1: inbound weight across every role-agent leg.

Usage: inbound-fleet.py <session-uuid> [<session-uuid> ...]
       inbound-fleet.py --all              # every session for this project

One row per leg, plus a per-role roll-up. Role and sim tree are read from the
leg's dispatch prompt (the first user message), so nothing is hand-labelled.
"""
import sys, os, re, glob, collections
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from inbound import load, decompose  # noqa: E402

PROJ = os.path.expanduser("~/.claude/projects/-home-exedev-shipshape-shakedown")
ROLE_RE = re.compile(r"\b(Captain|Quartermaster|QM|Crew|Boatswain|Shipwright)\b")
TREE_RE = re.compile(r"(tidewatch|todopilot|fastpath|probe)[0-9a-z]*", re.I)
WORK = ("retrieval", "command", "write", "subagent", "reasoning")


def skill_role(recs):
    """The role skill this leg loaded, e.g. Skill(shipshape:boatswain) -> Boatswain."""
    for r in recs:
        if r.get("type") != "assistant":
            continue
        for c in r["message"].get("content", []) or []:
            if isinstance(c, dict) and c.get("type") == "tool_use" and c.get("name") == "Skill":
                s = (c.get("input", {}).get("skill") or "")
                name = s.split(":")[-1]
                if name and name != "shipshape":       # the shared Articles name no role
                    return name
    return None


def dispatch_header(recs):
    for r in recs:
        if r.get("type") == "user":
            c = r["message"].get("content")
            if isinstance(c, str):
                return c
            for b in c or []:
                if isinstance(b, dict) and b.get("type") == "text":
                    return b.get("text", "")
    return ""


def main(sessions):
    rows = []
    for s in sessions:
        for f in sorted(glob.glob(f"{PROJ}/{s}/subagents/agent-*.jsonl")):
            recs = load(f)
            d = decompose(recs, os.path.basename(f))
            if not d or d["N"] < 3:      # skip stubs / aborted spawns
                continue
            hdr = dispatch_header(recs)
            # The role is whichever role skill the leg loaded - definitive, and it
            # survives a dispatch prompt that never names the role in prose.
            role = skill_role(recs) or (ROLE_RE.search(hdr).group(1) if ROLE_RE.search(hdr) else "?")
            role = "QM" if role.lower() in ("qm", "quartermaster") else role.title()
            tree = (TREE_RE.search(hdr).group(0).lower() if TREE_RE.search(hdr) else "?")
            r = d["resident"]
            tot = sum(r.values()) or 1
            rows.append({
                "tree": tree, "role": role, "N": d["N"], "paid": d["total_paid"],
                "floor": r["floor"], "shared": r["doctrine_shared"], "role_sk": r["doctrine_role"],
                "work": sum(r[k] for k in WORK), "tot": tot,
                "shared_in": sum(d["ledger"][k]["doctrine_shared"] for k in range(d["N"])),
                "role_in": sum(d["ledger"][k]["doctrine_role"] for k in range(d["N"])),
            })

    if not rows:
        sys.exit("no legs found")

    hdr = (f"{'LEG':<13} {'ROLE':<10} {'INV':>3} {'FLOOR':>9} {'SHARED':>9} {'ROLESKILL':>9} "
           f"{'THE JOB':>9} {'TOTAL':>10} {'MEANCTX':>8} {'JOB%':>6}")
    print(hdr)
    print("-" * len(hdr))
    for x in sorted(rows, key=lambda r: (r["role"], r["tree"])):
        print(f"{x['tree']:<13} {x['role']:<10} {x['N']:>3} {x['floor']:>9,} {x['shared']:>9,} "
              f"{x['role_sk']:>9,} {x['work']:>9,} {x['paid']:>10,} {x['paid']//x['N']:>8,} "
              f"{100*x['work']/x['tot']:>5.1f}%")

    print()
    print("PER-ROLE ROLL-UP   (loaded = tokens read once; the cost is loaded x invocations)")
    print(f"{'ROLE':<10} {'LEGS':>4} {'INV':>5} {'SHARED LOADED':>14} {'ROLE LOADED':>12} "
          f"{'TOTAL PAID':>12} {'DOCTRINE%':>10} {'JOB%':>7}")
    by = collections.defaultdict(list)
    for x in rows:
        by[x["role"]].append(x)
    for role, xs in sorted(by.items()):
        paid = sum(x["paid"] for x in xs)
        doc = sum(x["shared"] + x["role_sk"] for x in xs)
        work = sum(x["work"] for x in xs)
        tot = sum(x["tot"] for x in xs) or 1
        sh = sum(x["shared_in"] for x in xs) // len(xs)
        rl = sum(x["role_in"] for x in xs) // len(xs)
        print(f"{role:<10} {len(xs):>4} {sum(x['N'] for x in xs):>5} {sh:>14,} {rl:>12,} "
              f"{paid:>12,} {100*doc/tot:>9.1f}% {100*work/tot:>6.1f}%")

    paid = sum(x["paid"] for x in rows)
    shared = sum(x["shared"] for x in rows)
    role_sk = sum(x["role_sk"] for x in rows)
    floor = sum(x["floor"] for x in rows)
    work = sum(x["work"] for x in rows)
    tot = sum(x["tot"] for x in rows) or 1
    print()
    print(f"FLEET  {len(rows)} legs / {sum(x['N'] for x in rows)} invocations / {paid:,} tokens read")
    print(f"       shared Articles {100*shared/tot:>5.1f}%   role skills {100*role_sk/tot:>5.1f}%   "
          f"harness floor {100*floor/tot:>5.1f}%   THE JOB {100*work/tot:>5.1f}%")
    print()
    print("Instrument 1 measures COST, never WORTH. A doctrine section can be load-bearing")
    print("precisely because it PREVENTED something. These numbers nominate; they never condemn.")


if __name__ == "__main__":
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    if "--all" in sys.argv or not args:
        args = [os.path.basename(p) for p in glob.glob(f"{PROJ}/*") if os.path.isdir(p)]
    main(args)
