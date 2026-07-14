#!/usr/bin/env python3
"""Instrument 1: inbound context weight decomposition (EXACT, no tokenizer).

Usage: inbound.py <agent-transcript.jsonl> [legname]
       inbound.py --csv <transcript> [legname]     # machine-readable rows

Method. Per invocation the API reports
    context[n] = input_tokens + cache_creation_input_tokens + cache_read_input_tokens
which is the exact prompt size at that call. Therefore

    growth[n]    = context[n] - context[n-1]
    delivered[n] = growth[n] - output_tokens[n-1]

is exactly the number of tokens injected into context between the two calls -
tool results, skill-text injections, system reminders - whatever the channel.
No tokenizer is needed and nothing is inferred. `delivered` is then split among
the concrete blocks that landed in that gap, proportionally by character length.
The split is the only approximate step; every total remains exact.

The ledger. A token entering context at invocation k is re-read by every
invocation from k to N, so its RESIDENT COST is size * (N - k + 1). The floor
(system prompt + tool schemas + dispatch prompt) enters at k=1 and is therefore
paid N times. Summing resident cost over every block reproduces the total spend
    sum(context[n]) == floor*N + sum(resident)
which is asserted at the end. If it closes, the decomposition is sound.
"""
import json, sys, collections

CLASSES = ["floor", "doctrine_shared", "doctrine_role", "retrieval", "command",
           "write", "subagent", "reasoning", "other"]
DOCTRINE = ("doctrine_shared", "doctrine_role")

TOOL_CLASS = {
    "Read": "retrieval", "Grep": "retrieval", "Glob": "retrieval",
    "Bash": "command", "BashOutput": "command",
    "Edit": "write", "Write": "write", "NotebookEdit": "write",
    "Agent": "subagent", "Task": "subagent",
    "Skill": "other",  # the stub result; the real text lands as an injected message
}

# A doctrine skill body is injected as a plain user message. These markers appear
# in the shared Articles and in every role skill's own text.
DOCTRINE_MARKERS = (
    "Articles of Agreement",
    "Shipshape Controlled English",
    "Role contract",
    "Dispatch contract",
)


def load(path):
    recs = []
    with open(path) as fh:
        for line in fh:
            line = line.strip()
            if line:
                recs.append(json.loads(line))
    return recs


def classify_text_block(text, pending_skill):
    """A non-tool-result block injected into context.

    Doctrine text is injected as a plain message AFTER its Skill call, so the
    skill requested by the previous invocation names which body just landed.
    The shared Articles (`shipshape:shipshape`) are the file every role loads;
    a role skill is loaded by that role alone. Only the first is a shared cost.
    """
    if pending_skill == "shipshape:shipshape":
        return "doctrine_shared"
    if pending_skill and pending_skill.startswith("shipshape:"):
        return "doctrine_role"
    if any(m in text for m in DOCTRINE_MARKERS):
        return "doctrine_shared"      # doctrine by content, carrier unknown
    return "other"


def decompose(recs, leg):
    # Order assistant messages into invocations, grouped by message.id.
    inv_order, inv = [], {}
    for i, r in enumerate(recs):
        if r.get("type") != "assistant":
            continue
        mid = r["message"]["id"]
        if mid not in inv:
            inv[mid] = {"id": mid, "first_idx": i, "last_idx": i, "ts": r.get("timestamp", ""),
                        "usage": r["message"]["usage"], "model": r["message"].get("model", "?"),
                        "out": 0, "tools": []}
            inv_order.append(mid)
        e = inv[mid]
        e["last_idx"] = i
        e["out"] = max(e["out"], r["message"]["usage"].get("output_tokens", 0))
        for c in r["message"].get("content", []) or []:
            if isinstance(c, dict) and c.get("type") == "tool_use":
                e["tools"].append({"id": c.get("id"), "name": c.get("name"), "input": c.get("input", {})})

    invs = [inv[m] for m in inv_order]
    if not invs:
        return None
    N = len(invs)

    for e in invs:
        u = e["usage"]
        e["ctx"] = (u.get("input_tokens", 0) + u.get("cache_creation_input_tokens", 0)
                    + u.get("cache_read_input_tokens", 0))

    # tool_use_id -> tool name, for attributing results back to their call
    tool_by_id = {t["id"]: t for e in invs for t in e["tools"]}

    # Blocks landing in the gap between invocation n-1 and n, from the raw records.
    def gap_blocks(lo, hi, pending_skill):
        out = []
        for r in recs[lo + 1:hi]:
            t = r.get("type")
            if t == "user":
                content = r["message"].get("content")
                if isinstance(content, str):
                    out.append((classify_text_block(content, pending_skill), len(content), "msg"))
                else:
                    for c in content or []:
                        if not isinstance(c, dict):
                            continue
                        if c.get("type") == "tool_result":
                            body = c.get("content")
                            body = body if isinstance(body, str) else json.dumps(body)
                            tool = tool_by_id.get(c.get("tool_use_id"), {})
                            name = tool.get("name", "?")
                            out.append((TOOL_CLASS.get(name, "other"), max(len(body), 1), name))
                        elif c.get("type") == "text":
                            txt = c.get("text", "")
                            out.append((classify_text_block(txt, pending_skill), max(len(txt), 1), "msg"))
            elif t == "attachment":
                body = json.dumps(r.get("attachment", {}))
                out.append((classify_text_block(body, pending_skill), max(len(body), 1), "attach"))
        return out

    # ledger[k] = tokens ENTERING context at invocation k, by class.
    ledger = [collections.Counter() for _ in range(N)]
    ledger[0]["floor"] = invs[0]["ctx"]  # system prompt + tool schemas + dispatch

    # Per-gap facts. A Skill call injects its doctrine body into the NEXT
    # invocation's context, but that body is not reliably written to the
    # transcript as a message - so it cannot be attributed by content. It is
    # attributed by the call instead: price the ordinary tool results at the
    # leg's own observed char->token rate, and give doctrine the residual.
    gaps = []
    unattributed = 0
    for n in range(1, N):
        delivered = invs[n]["ctx"] - invs[n - 1]["ctx"] - invs[n - 1]["out"]
        ledger[n]["reasoning"] += invs[n - 1]["out"]   # prior output is resident now
        if delivered <= 0:
            unattributed += delivered                 # compaction / cache reset
            continue
        skills = [t["input"].get("skill") for t in invs[n - 1]["tools"] if t["name"] == "Skill"]
        skill = skills[0] if skills else None
        blocks = gap_blocks(invs[n - 1]["last_idx"], invs[n]["first_idx"], skill)
        # the Skill stub result ("Launching skill: x") is a carrier, not content
        blocks = [b for b in blocks if not (b[2] == "Skill")]
        gaps.append({"n": n, "delivered": delivered, "skill": skill, "blocks": blocks})

    # char->token rate, measured only on gaps with no skill injection in them
    plain = [g for g in gaps if not g["skill"]]
    pc = sum(sum(b[1] for b in g["blocks"]) for g in plain)
    pt = sum(g["delivered"] for g in plain)
    rate = (pt / pc) if pc > 500 else 0.30      # tokens per char; fallback ~3.3 chars/tok

    for g in gaps:
        n, delivered, blocks = g["n"], g["delivered"], g["blocks"]
        if g["skill"]:
            # ordinary results priced at the observed rate; doctrine takes the rest
            other_chars = sum(b[1] for b in blocks)
            other_tok = min(round(rate * other_chars), delivered)
            assigned = 0
            for i, (cls, chars, _s) in enumerate(blocks):
                share = (other_tok - assigned if i == len(blocks) - 1
                         else round(other_tok * chars / other_chars) if other_chars else 0)
                ledger[n][cls] += share
                assigned += share
            doc = delivered - other_tok
            cls = ("doctrine_shared" if g["skill"] == "shipshape:shipshape" else "doctrine_role")
            ledger[n][cls] += doc
            continue
        total_chars = sum(b[1] for b in blocks)
        if not blocks or total_chars == 0:
            ledger[n]["other"] += delivered
            continue
        assigned = 0
        for i, (cls, chars, _s) in enumerate(blocks):
            share = delivered - assigned if i == len(blocks) - 1 else round(delivered * chars / total_chars)
            ledger[n][cls] += share
            assigned += share

    # last invocation's own output is produced, never re-read: not an inbound cost.

    # Resident cost: a block entering at k is re-read at k..N-1  ->  (N - k) reads.
    resident = collections.Counter()
    for k in range(N):
        reads = N - k
        for cls, tok in ledger[k].items():
            resident[cls] += tok * reads

    total_paid = sum(e["ctx"] for e in invs)
    return {"leg": leg, "N": N, "invs": invs, "ledger": ledger, "resident": resident,
            "total_paid": total_paid, "unattributed": unattributed,
            "models": collections.Counter(e["model"] for e in invs)}


def report(d):
    N, invs = d["N"], d["invs"]
    print(f"LEG {d['leg']}   invocations={N}   models={dict(d['models'])}")
    print(f"{'inv':>3} {'time':>8} {'context':>9} {'growth':>8} {'out':>6}  entering")
    prev = 0
    for n, e in enumerate(invs):
        growth = e["ctx"] - prev if n else e["ctx"]
        entering = ", ".join(f"{c}:{t/1000:.1f}k" for c, t in d["ledger"][n].most_common() if t > 300)
        print(f"{n+1:>3} {e['ts'][11:19]:>8} {e['ctx']:>9,} {growth:>+8,} {e['out']:>6,}  {entering}")
        prev = e["ctx"]

    print()
    print(f"{'class':<12} {'entered':>10} {'share':>7}   {'RESIDENT (re-read)':>18} {'share':>7}")
    entered = collections.Counter()
    for k in range(N):
        entered.update(d["ledger"][k])
    tot_e = sum(entered.values()) or 1
    tot_r = sum(d["resident"].values()) or 1
    for cls in CLASSES:
        e, r = entered.get(cls, 0), d["resident"].get(cls, 0)
        if not e and not r:
            continue
        print(f"{cls:<12} {e:>10,} {100*e/tot_e:>6.1f}%   {r:>18,} {100*r/tot_r:>6.1f}%")
    print(f"{'TOTAL':<12} {tot_e:>10,} {100:>6.1f}%   {tot_r:>18,} {100:>6.1f}%")

    # The identity: resident cost must reproduce the metered spend.
    drift = tot_r - d["total_paid"]
    ok = "CLOSES" if abs(drift) <= max(50, 0.001 * d["total_paid"]) else "*** DRIFT ***"
    print()
    print(f"metered spend  sum(context[n]) = {d['total_paid']:,}")
    print(f"ledger resident cost           = {tot_r:,}   ({ok}, drift {drift:+,})")
    if d["unattributed"]:
        print(f"note: {d['unattributed']:+,} tokens of negative growth (compaction/cache reset)")

    shared = d["resident"].get("doctrine_shared", 0)
    role = d["resident"].get("doctrine_role", 0)
    floor = d["resident"].get("floor", 0)
    work = sum(d["resident"].get(c, 0) for c in ("retrieval", "command", "write", "subagent", "reasoning"))
    shared_in = sum(d["ledger"][k]["doctrine_shared"] for k in range(N))
    role_in = sum(d["ledger"][k]["doctrine_role"] for k in range(N))
    print()
    print(f"HEADLINE  doctrine  {100*(shared+role)/tot_r:>5.1f}% of inbound spend "
          f"({shared_in + role_in:,} tok loaded, re-read across {N} invocations)")
    print(f"            shared Articles {100*shared/tot_r:>5.1f}%  ({shared_in:,} tok - every role pays this)")
    print(f"            role skill      {100*role/tot_r:>5.1f}%  ({role_in:,} tok)")
    print(f"          floor     {100*floor/tot_r:>5.1f}%  ({invs[0]['ctx']:,} tok re-read {N}x)")
    print(f"          THE JOB   {100*work/tot_r:>5.1f}%  <- everything the leg actually retrieved, ran and reasoned")
    print(f"          mean context/invocation = {d['total_paid']//N:,}")


def csv_rows(d):
    print("leg,class,entered_tokens,resident_tokens,invocations,total_paid")
    entered = collections.Counter()
    for k in range(d["N"]):
        entered.update(d["ledger"][k])
    for cls in CLASSES:
        if entered.get(cls, 0) or d["resident"].get(cls, 0):
            print(f"{d['leg']},{cls},{entered.get(cls,0)},{d['resident'].get(cls,0)},{d['N']},{d['total_paid']}")


if __name__ == "__main__":
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    as_csv = "--csv" in sys.argv
    if not args:
        sys.exit(__doc__)
    path = args[0]
    leg = args[1] if len(args) > 1 else path.split("/")[-1].replace(".jsonl", "")
    d = decompose(load(path), leg)
    if d is None:
        sys.exit(f"{leg}: no assistant invocations")
    (csv_rows if as_csv else report)(d)
