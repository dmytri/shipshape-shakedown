#!/usr/bin/env python3
"""Fold a pi eval leg's session JSONL into a role-phased affordance map.

PURE over captured files — no model calls, no network — so it is re-runnable
against banked raw and testable on a committed fixture (data/eval-fixture/).
This is the live sibling of doctrine-sections.py: where that prices doctrine
statically, this reports where a baseline agent actually spent its budget and
which role skill it was following when it did.

Usage:
  eval-map.py <leg-dir-or-session.jsonl> [more...]   # per-leg map + roll-up
  eval-map.py --json <...>                            # machine-readable

Session schema (pi 0.81, --mode json session file), locked 2026-07-23:
  line {"type":"message","message":{role, content:[part...], usage?}}
  role in {user, assistant, toolResult}
  assistant.usage = {input,output,cacheRead,cacheWrite,reasoning,totalTokens,cost:{total,...}}
  content part types: thinking | toolCall{name,arguments} | text
  a role-skill load shows as a `read` toolCall whose path ends in SKILL.md.
"""
import json
import os
import re
import sys

# Role skills a Shipshape agent may read-and-follow. Order is only for display.
ROLES = ["shipshape", "captain", "qm", "crew", "boatswain", "shipwright"]


def role_of_path(path):
    """The Shipshape role a read SKILL.md path names, or None."""
    if not path or "SKILL.md" not in path:
        return None
    # .../skills/<role>/SKILL.md  — take the dir holding SKILL.md.
    parts = re.split(r"[/\\]", path)
    try:
        i = parts.index("SKILL.md")
    except ValueError:
        return None
    parent = parts[i - 1] if i > 0 else ""
    parent = parent.lower()
    return parent if parent in ROLES else None


def session_path(target):
    """Resolve a leg dir or a jsonl path to the session file."""
    if os.path.isdir(target):
        # Prefer a captured session.jsonl; else the newest *.jsonl under it.
        direct = os.path.join(target, "session.jsonl")
        if os.path.isfile(direct):
            return direct
        found = []
        for root, _dirs, files in os.walk(target):
            for f in files:
                if f.endswith(".jsonl"):
                    found.append(os.path.join(root, f))
        return sorted(found)[-1] if found else None
    return target if os.path.isfile(target) else None


def read_turns(session_file):
    """Every assistant model invocation, in order, as the agent recorded it.

    An assistant message with no usage is not an accounted invocation and is
    skipped — a leg whose agent recorded no usage yields an empty list, which
    the caller reddens rather than reporting a cost of zero.
    """
    turns = []
    with open(session_file, encoding="utf-8") as fh:
        for line in fh:
            line = line.strip()
            if not line:
                continue
            try:
                ev = json.loads(line)
            except json.JSONDecodeError:
                continue
            if ev.get("type") != "message":
                continue
            msg = ev.get("message") or {}
            if msg.get("role") != "assistant":
                continue
            usage = msg.get("usage")
            if not isinstance(usage, dict) or "input" not in usage or "output" not in usage:
                continue
            tools, skill_loads = [], []
            for part in msg.get("content") or []:
                if part.get("type") != "toolCall":
                    continue
                name = part.get("name", "?")
                args = part.get("arguments") or {}
                tools.append({"name": name, "args": args})
                if name == "read":
                    role = role_of_path(args.get("path", ""))
                    if role:
                        skill_loads.append(role)
            cost = usage.get("cost") or {}
            turns.append({
                "turn": len(turns),
                "input": usage.get("input", 0),
                "output": usage.get("output", 0),
                "cache_read": usage.get("cacheRead", 0),
                "total_tokens": usage.get("totalTokens", 0),
                "cost": cost.get("total", 0) or 0,
                "tools": tools,
                "skill_loads": skill_loads,
            })
    return turns


# A tool-call signature = name + its salient argument, for flail detection.
def _sig(tool):
    a = tool.get("args") or {}
    key = a.get("path") or a.get("command") or a.get("prompt") or ""
    return (tool["name"], str(key)[:80])


def analyse(session_file):
    """One leg's affordance map + derived signals."""
    turns = read_turns(session_file)
    if not turns:
        return {"turns": [], "empty": True}

    # Flail signal, harness-agnostic: a `confirm`/`ask_question` round-trip in
    # non-interactive mode (should never happen with --approve — its presence
    # says the runner or the model derailed), and an immediate repeat of the
    # exact same tool signature (spinning on the same act).
    confirm_turns, repeat_turns = [], []
    prev_sigs = set()
    for t in turns:
        sigs = {_sig(x) for x in t["tools"]}
        if any(x["name"] in ("confirm", "ask_question") for x in t["tools"]):
            confirm_turns.append(t["turn"])
        if sigs & prev_sigs:
            repeat_turns.append(t["turn"])
        prev_sigs = sigs

    # Role-load sequence: the order the agent read role skills in. This is the
    # "did it read the right skill at the right moment" affordance, observed.
    role_sequence = []
    for t in turns:
        for role in t["skill_loads"]:
            if not role_sequence or role_sequence[-1][1] != role:
                role_sequence.append((t["turn"], role))

    return {
        "session": session_file,
        "empty": False,
        "turns": turns,
        "n_turns": len(turns),
        "tokens_in": sum(t["input"] for t in turns),
        "tokens_out": sum(t["output"] for t in turns),
        "cache_read": sum(t["cache_read"] for t in turns),
        "cost": round(sum(t["cost"] for t in turns), 6),
        "roles_loaded": sorted({r for _n, r in role_sequence}),
        "role_sequence": role_sequence,
        "confirm_turns": confirm_turns,
        "repeat_turns": repeat_turns,
    }


def print_leg(name, a):
    print(f"\n=== {name} ===")
    if a["empty"]:
        print("  RED: agent recorded no usage — a leg that reports no model "
              "invocation cannot report a cost of zero.")
        return
    print(f"  turns={a['n_turns']}  in={a['tokens_in']}  out={a['tokens_out']}  "
          f"cache_read={a['cache_read']}  cost=${a['cost']:.4f}")
    seq = " -> ".join(f"{r}@t{n}" for n, r in a["role_sequence"]) or "(no role SKILL.md read)"
    print(f"  role reads: {seq}")
    print(f"  roles loaded: {', '.join(a['roles_loaded']) or 'NONE'}")
    if a["confirm_turns"]:
        print(f"  ! confirm/ask round-trips at turns {a['confirm_turns']} "
              f"(runner should pass --approve; these turns are harness noise, not doctrine)")
    if a["repeat_turns"]:
        print(f"  ~ repeated tool signature at turns {a['repeat_turns']} (possible flail)")
    print("  per-turn (turn: in/out/cache $cost  tools):")
    for t in a["turns"]:
        tools = ", ".join(x["name"] for x in t["tools"]) or "-"
        print(f"    t{t['turn']:<2} {t['input']:>6}/{t['output']:<5} {t['cache_read']:>6} "
              f"${t['cost']:.4f}  {tools}")


def main(argv):
    as_json = False
    targets = []
    for arg in argv:
        if arg == "--json":
            as_json = True
        else:
            targets.append(arg)
    if not targets:
        print(__doc__)
        return 2

    results = {}
    for target in targets:
        sf = session_path(target)
        name = os.path.basename(target.rstrip("/"))
        if not sf:
            results[name] = {"empty": True, "error": f"no session jsonl under {target}"}
            continue
        results[name] = analyse(sf)

    if as_json:
        # Drop the heavy per-turn tool args from the JSON roll-up; keep the map.
        slim = {}
        for name, a in results.items():
            s = dict(a)
            s.pop("turns", None)
            slim[name] = s
        print(json.dumps(slim, indent=2))
        return 0

    for name, a in results.items():
        print_leg(name, a)
    # Roll-up across legs (a pilot is many legs).
    real = [a for a in results.values() if not a.get("empty")]
    if len(real) > 1:
        print("\n=== roll-up ===")
        print(f"  legs={len(real)}  turns={sum(a['n_turns'] for a in real)}  "
              f"in={sum(a['tokens_in'] for a in real)}  out={sum(a['tokens_out'] for a in real)}  "
              f"cost=${sum(a['cost'] for a in real):.4f}")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
