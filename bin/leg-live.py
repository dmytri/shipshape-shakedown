#!/usr/bin/env python3
"""Watch a leg while it runs.

usage: bin/leg-live.py <leg.out-dir> [tail-messages]

Reads pi.stdout, which is written LIVE. Until 2026-08-02 this was impossible: the disk warden
deleted pi.stdout whenever the file had not been written for IDLE_MIN, and a leg thinking or
blocked on the provider looks exactly that idle -- so the capture of a running leg was unlinked
out from under it (defect 17, caught as `/proc/<pi>/fd/1 -> pi.stdout (deleted)`). Every stall
this session therefore cost a full 3600s timeout to discover. With the warden keyed on
$OUT/exit instead, a leg can be read while it works.

The stream is 98% `message_update` streaming deltas. This renders only completed work --
message_end and tool_execution_* -- which is what a human wants to see.
"""
import json
import os
import sys


def render(path, tail=25):
    events = []
    for line in open(path, errors="ignore"):
        line = line.strip()
        if not line:
            continue
        try:
            e = json.loads(line)
        except Exception:
            continue
        t = e.get("type")
        if t == "message_end":
            m = e.get("message") or {}
            if m.get("role") != "assistant":
                continue
            for p in (m.get("content") or []):
                k = p.get("type")
                if k == "text" and (p.get("text") or "").strip():
                    events.append(("SAID", p["text"].strip()))
                elif k == "thinking" and (p.get("thinking") or "").strip():
                    events.append(("THINK", p["thinking"].strip()))
                elif k == "toolCall":
                    a = p.get("arguments") or {}
                    events.append(("CALL " + str(p.get("name")), json.dumps(a)))
        elif t == "tool_execution_end":
            r = e.get("result")
            r = r if isinstance(r, str) else json.dumps(r)
            events.append(("RESULT", (r or "")[:300]))
    return events[-tail:]


def main(argv):
    d = argv[0]
    p = d if d.endswith(".stdout") else os.path.join(d, "pi.stdout")
    if not os.path.isfile(p):
        print(f"no live stdout at {p}", file=sys.stderr)
        return 1
    tail = int(argv[1]) if len(argv) > 1 else 25
    size = os.path.getsize(p)
    print(f"### {p}  ({size:,} bytes live)\n")
    for kind, body in render(p, tail):
        body = body if len(body) < 700 else body[:700] + " …"
        print(f"--- {kind} ---")
        print(body)
        print()
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]) if len(sys.argv) > 1 else (print(__doc__) or 2))
