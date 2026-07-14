#!/usr/bin/env python3
"""Size every section of the shared Articles, and price it per role-leg.

Usage: doctrine-sections.py [path-to-shared-SKILL.md]

Instrument 1 shows what doctrine COSTS. This shows what the cost is made OF:
each top-level section of the shared skill, its share of the file, and what it
costs to keep it resident across a leg's invocations.

This is a COST inventory and nothing else. It says NOTHING about whether a
section earns its place - a rule can be load-bearing precisely because it
prevented something that therefore never appears in a transcript. Consumption
is instrument 3's question. Nothing here condemns anything.
"""
import sys, os, re, collections

DEFAULT = os.path.expanduser(
    "~/.claude/plugins/cache/dmytri-shipshape/shipshape/8e7cf2504ecb/skills/shipshape/SKILL.md")

# Measured, not assumed: two independent legs (Boatswain, Shipwright) each put the
# shared Articles at ~24.0k tokens against a 74,255-byte file. See METRICS.md.
MEASURED_TOKENS = 24_060

# Mean invocations per leg, by role (bin/inbound-fleet.py, 14 legs @ v0.13.23).
LEG_INV = {"Crew": 10, "Boatswain": 15, "QM": 20, "Shipwright": 26, "Captain": 11}


def sections(path):
    """Split on '## ' headings; return [(title, chars)] in file order."""
    text = open(path).read()
    parts = re.split(r"^## +(.+)$", text, flags=re.M)
    out = [("(preamble)", len(parts[0]))]
    for i in range(1, len(parts), 2):
        out.append((parts[i].strip(), len(parts[i]) + len(parts[i + 1])))
    return out, len(text)


def main(path):
    secs, total_chars = sections(path)
    tok_per_char = MEASURED_TOKENS / total_chars

    print(f"SHARED ARTICLES  {os.path.basename(os.path.dirname(path))}/SKILL.md")
    print(f"  {total_chars:,} chars  ~{MEASURED_TOKENS:,} tokens (measured live, 2 independent legs)")
    print(f"  every role loads this file in full, on every leg, before it does anything\n")

    w = max(len(t) for t, _ in secs)
    print(f"{'SECTION':<{w}} {'CHARS':>7} {'~TOKENS':>8} {'SHARE':>6} {'COST/CREW-LEG':>14} {'COST/QM-LEG':>12}")
    print("-" * (w + 52))
    for title, chars in sorted(secs, key=lambda s: -s[1]):
        tok = round(chars * tok_per_char)
        print(f"{title:<{w}} {chars:>7,} {tok:>8,} {100*chars/total_chars:>5.1f}% "
              f"{tok*LEG_INV['Crew']:>14,} {tok*LEG_INV['QM']:>12,}")

    print()
    print("COST/<role>-LEG = section tokens x that role's mean invocations per leg:")
    print("  the section is re-read on every invocation, so this is what one leg pays to carry it.")
    print(f"  mean invocations per leg: " + ", ".join(f"{r} {n}" for r, n in LEG_INV.items()))
    print()
    print("This is a COST inventory. It does not measure whether a section is USED, and a")
    print("section that prevented a fault leaves no trace in any transcript. Nothing here")
    print("condemns anything: instrument 3 measures consumption, and a probe follows that.")


if __name__ == "__main__":
    main(sys.argv[1] if len(sys.argv) > 1 else DEFAULT)
