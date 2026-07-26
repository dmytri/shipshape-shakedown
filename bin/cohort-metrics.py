import json, glob, os, sys, re, datetime as dt

def leg_metrics(D):
    tot = dict(inv=0, tc=0, tin=0, tout=0, cr=0, cost=0.0, reason=0)
    build_turns = 0
    for f in sorted(glob.glob(f"{D}/*.out/session.jsonl")):
        name = os.path.basename(os.path.dirname(f)).replace(".out", "")
        inv = 0
        for l in open(f, encoding="utf-8", errors="replace"):
            try: e = json.loads(l)
            except Exception: continue
            m = e.get("message") or {}
            if m.get("role") == "assistant":
                for p in m.get("content") or []:
                    if p.get("type") == "toolCall": tot["tc"] += 1
                u = m.get("usage") or {}
                if u:
                    inv += 1; tot["inv"] += 1
                    tot["tin"] += u.get("input", 0); tot["tout"] += u.get("output", 0)
                    tot["cr"] += u.get("cacheRead", 0); tot["reason"] += u.get("reasoning", 0)
                    c = u.get("cost") or 0
                    if isinstance(c, dict): c = c.get("total", 0) or 0
                    tot["cost"] += c
        if name.endswith("-qm"): build_turns = max(build_turns, inv)
    tot["build_turns"] = build_turns
    return tot

def driver_facts(D):
    log = f"{D}/driver.log"
    facts = dict(final="?", voyages=0, wall=0, planks="", start=None, end=None)
    if not os.path.exists(log): return facts
    lines = open(log, errors="replace").read().splitlines()
    def ts(l):
        m = re.match(r"\[([^\]]+)\]", l)
        try: return dt.datetime.fromisoformat(m.group(1).replace("Z", "+00:00")) if m else None
        except Exception: return None
    # active work-time = sum of reported leg durations (span would include overnight idle on resumes)
    active = 0
    for l in lines:
        if re.search(r"(^|\])\s*(V\d+ |SHIPWRIGHT\[)", l) or "build " in l:
            m = re.search(r"\b(\d+)s\b", l)
            if m: active += int(m.group(1))
    facts["wall"] = active
    for l in lines:
        m = re.search(r"final=(\d+)/29", l)
        if m: facts["final"] = m.group(1) + "/29"
        m = re.search(r"VOYAGE (\d+)", l)
        if m: facts["voyages"] = max(facts["voyages"], int(m.group(1)))
        if "SHIPWRIGHT[final]" in l:
            mm = re.search(r"planks=(\d+) on-seam=(\d+) hoisted=(\d+).*@captain=(\d+) @conformance=(\d+)", l)
            if mm: facts["planks"] = f"{mm.group(2)}/{mm.group(1)} on-seam, {mm.group(3)} hoisted | @cap={mm.group(4)} @conf={mm.group(5)}"
    return facts

def resolve(tag):
    # accept a bare tag (todomvc-<tag>), a full wave name (<tag>), or a path
    import os
    for cand in (tag, f".eval-scratch/{tag}", f".eval-scratch/todomvc-{tag}"):
        if os.path.isdir(cand): return cand
    return f".eval-scratch/todomvc-{tag}"  # default; will report empty if absent

for tag in sys.argv[1:]:
    D = resolve(tag)
    t = leg_metrics(D); f = driver_facts(D)
    print(f"=== {tag} ===")
    print(f"  final={f['final']} voyages_seen={f['voyages']} wall={f['wall']/60:.1f}min")
    print(f"  inv={t['inv']} toolcalls={t['tc']} build_turns(max qm)={t['build_turns']}")
    print(f"  tok_in={t['tin']:,} tok_out={t['tout']:,} (reason {t['reason']:,}) cache_read={t['cr']:,}")
    print(f"  cost=${t['cost']:.3f}")
    lat = f['wall']/t['inv'] if t['inv'] else 0
    print(f"  mean_latency/roundtrip={lat:.1f}s")
    print(f"  planking(final SW)={f['planks'] or '(no final SW)'}")
