#!/usr/bin/env python3
"""Build the MIDWAY arm: control doctrine with the candidate's Methods layer adopted.

Midway exists to bisect the candidate: it is control in every respect EXCEPT that it adopts the
methods layer. Adoption is not pure addition — the old command vocabulary the methods replace has
to come out, everywhere, or the arm carries both worlds at once. The first build did exactly that
by halves: it renamed focused/broad but left `plank-inventory` (8) and `step-usage` (18) standing
beside a Methods table that offers `plank-join`. Roles were then told to run commands that exist
in neither world, and that arm scored 18/29 — worse than BOTH arms it sits between, which is the
signature of an internally inconsistent text rather than a doctrine difference.

Substitutions are faithful to how the candidate expresses the same obligation:
    control "the `step-usage` command reports it"  ->  candidate "the `plank-join` method reports"
    control "a join `step-usage` already derives"  ->  candidate "a join `plank-join` already derives"
so both halves of the old join (inventory + usage) fold into the single `plank-join` method.

usage: build-midway.py [--check]     (--check verifies an existing build, changes nothing)
"""
import os
import re
import shutil
import sys

CONTROL = "/home/exedev/.claude/plugins/cache/dmytri-shipshape/shipshape/596fbf17be06/skills"
CANDIDATE = "experiments/methods-candidate/skills"
MIDWAY = "experiments/methods-midway/skills"
ROLES = ("shipshape", "captain", "qm", "crew", "boatswain", "shipwright")

# Sections ported wholesale from the candidate: the methods layer itself and the rigging contract
# that describes how a method value is read. Nothing else — every other section stays control's.
PORT = ["### Methods", "### Rigging read contract"]

# Old command vocabulary -> the method that replaces it. Longest first so a substring never eats
# a longer name.
SUBS = [
    # The rigging SECTION itself is renamed by the methods layer: control's RIGGING.md holds a
    # `## Commands` section, the candidate's holds `## Methods`. Leaving the old name behind is
    # the deeper half of a half-adoption — roles are then told the rigging has a section that the
    # ported read-contract says is called something else, so the rigging they READ and the rigging
    # they are told to WRITE disagree. That is the likeliest cause of the first midway build
    # scoring 18/29, below BOTH arms it brackets.
    (r"`## Commands`", "`## Methods`"),
    (r"## Commands\b", "## Methods"),
    (r"\bCommands section\b", "Methods section"),
    (r"`plank-inventory`", "`plank-join`"),
    (r"\bplank-inventory\b", "plank-join"),
    (r"`step-usage`", "`plank-join`"),
    (r"\bstep-usage\b", "plank-join"),
    (r"`focused`", "`prove`"),
    (r"\bfocused command\b", "prove method"),
    (r"\bfocused\b", "prove"),
    (r"`broad`", "`sweep`"),
    (r"\bbroad command\b", "sweep method"),
    (r"\bbroad\b", "sweep"),
]

STALE = ("focused", "broad", "plank-inventory", "step-usage")


def sections(text):
    parts = re.split(r"(?m)^(#{2,3} .+)$", text)
    return parts


def port_sections(target_text, source_text, headings):
    src_parts = sections(source_text)
    src = {src_parts[i].strip(): src_parts[i + 1] for i in range(1, len(src_parts), 2)}
    parts = sections(target_text)
    have = {parts[i].strip() for i in range(1, len(parts), 2)}
    out = [parts[0]]
    for i in range(1, len(parts), 2):
        head = parts[i].strip()
        out.append(parts[i])
        out.append(src[head] if head in headings and head in src else parts[i + 1])
        # a heading the target lacks is inserted after the rigging contract, where it belongs
        if head == "### Rigging read contract":
            for h in headings:
                if h in src and h not in have:
                    out.append(f"\n{h}\n")
                    out.append(src[h])
    return "".join(out)


def dedupe_artifacts(text):
    """Both halves of the old join map to one method; collapse the pairs that creates."""
    text = re.sub(r"`plank-join` and `plank-join`", "`plank-join`", text)
    text = re.sub(r"plank-join and plank-join", "plank-join", text)
    text = re.sub(r"`plank-join`, `plank-join`", "`plank-join`", text)
    return text


def check():
    bad = 0
    for role in ROLES:
        p = os.path.join(MIDWAY, role, "SKILL.md")
        if not os.path.exists(p):
            print(f"  MISSING {p}")
            bad += 1
            continue
        t = open(p).read()
        stale = {w: len(re.findall(rf"\b{re.escape(w)}\b", t)) for w in STALE}
        stale = {k: v for k, v in stale.items() if v}
        dup = len(re.findall(r"plank-join`? and `?plank-join", t))
        flag = ""
        if stale:
            flag += f"  STALE {stale}"
            bad += 1
        if dup:
            flag += f"  DUP x{dup}"
            bad += 1
        print(f"  {role:11s} {len(t):7d}b{flag}")
    m = open(os.path.join(MIDWAY, "shipshape", "SKILL.md")).read()
    print(f"  Methods section present: {'### Methods' in m}")
    print("  VERDICT:", "clean" if bad == 0 else f"{bad} problem(s)")
    return 1 if bad else 0


def build():
    if os.path.exists(MIDWAY):
        shutil.rmtree(os.path.dirname(MIDWAY))
    os.makedirs(os.path.dirname(MIDWAY), exist_ok=True)
    shutil.copytree(CONTROL, MIDWAY)
    # 1. port the methods layer into the shared skill
    sp = os.path.join(MIDWAY, "shipshape", "SKILL.md")
    ported = port_sections(open(sp).read(), open(os.path.join(CANDIDATE, "shipshape", "SKILL.md")).read(), PORT)
    open(sp, "w").write(ported)
    # 2. retire the replaced vocabulary in EVERY skill, not some
    for role in ROLES:
        p = os.path.join(MIDWAY, role, "SKILL.md")
        t = open(p).read()
        before = t
        for pat, rep in SUBS:
            t = re.sub(pat, rep, t)
        t = dedupe_artifacts(t)
        open(p, "w").write(t)
        n = sum(len(re.findall(rf"\b{re.escape(w)}\b", before)) for w in STALE)
        print(f"  {role:11s} retired {n} old-vocabulary references")
    print()
    return check()


if __name__ == "__main__":
    sys.exit(check() if "--check" in sys.argv else build())
