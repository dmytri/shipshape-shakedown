#!/usr/bin/env python3
"""Generate inert ballast for the controlled latency probe.

Usage: make-ballast.py <target-tokens> > ballast.txt

The ballast must (a) occupy the context like doctrine does, (b) mean nothing, and
(c) tokenize like English prose rather than like a repeated string, so the cached
prefix it creates is comparable to a real doctrine prefix. Deterministic seed, so
the probe is reproducible.
"""
import sys, random

W = ("harbour lantern rope canvas timber ballast cargo compass anchor rudder mast keel "
     "beacon channel current tide fathom knot pennant quay sail hull bow stern deck "
     "north south east west morning evening steady quiet grey open wide long narrow "
     "iron oak salt water wind cloud stone sand shore reef bay cove inlet strait")
WORDS = W.split()

CHARS_PER_TOKEN = 3.05          # measured: 74,255 chars -> ~24,060 tokens on the real file


def main(target_tokens):
    rnd = random.Random(20260714)
    target_chars = int(target_tokens * CHARS_PER_TOKEN)
    out = ["HARNESS BALLAST - INERT. This appendix carries no instructions, no facts, and\n"
           "no relevance to the task. It exists only to occupy context. Ignore it entirely.\n\n"]
    n = len(out[0])
    i = 0
    while n < target_chars:
        i += 1
        line = f"{i:05d}. " + " ".join(rnd.choice(WORDS) for _ in range(random.Random(i).randint(9, 16))) + ".\n"
        out.append(line)
        n += len(line)
    sys.stdout.write("".join(out))


if __name__ == "__main__":
    main(int(sys.argv[1]) if len(sys.argv) > 1 else 24060)
