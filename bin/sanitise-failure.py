#!/usr/bin/env python3
"""Turn the acceptance runner's raw output into a user's bug report.

dk, 2026-07-31: the playbook must never mention the oracle, and certainly not an unseen
spec. The agent should be told what a person manually testing the app hit, as if they had
pasted it in. The header keeps "FIXED and CORRECT" -- you cannot change what the user did.

WHY THIS EXISTS (R9 evidence). The raw block pasted, per failure, roughly forty lines of
runner internals, including:

    From Your Spec Code:
        at Context.eval (webpack://todomvc/./cypress/e2e/spec.cy.js:737:29)

The playbook literally told the agent the failing test was ITS OWN spec, and named the file
and line -- for the one file the quarantine exists to hide. Both capped mimo cells then spent
their voyages hunting it ("lines 737 and 752" appears 35 times across their transcripts),
searching outward until `ls /home/exedev/shipshape-shakedown` returned `total 0`. Five of
eleven candidate voyages and four of twelve control voyages ended `stopReason: length` --
budget exhausted mid-hunt, ZERO edits made. Ten voyages flat at 26/29.

It also leaked the oracle's own server URL (http://localhost:8975) into a sandbox that runs
with --share-net.

KEPT: which behaviour broke, and the full description of what went wrong.
REMOVED: the runner's name, its stack frames, its tutorial, its API, its URLs, the pass
tally, and every reference to a spec file.
"""
import re
import sys

ENTRY = re.compile(r"^\s*(\d+)\)\s*(.*)$")
FRAME = re.compile(r"^\s*at\s+")
PATHY = re.compile(r"webpack://|\.cy\.js|/cypress/|cypress/e2e|localhost:\d+|https?://")
TUTORIAL = re.compile(
    r"^\s*(Common situations why this happens|You can typically solve this|"
    r"From Your Spec Code|>\s|\(Results\)|[-\s]*$)",
    re.I,
)
SUMMARY = re.compile(r"^\s*\d+\s+(passing|failing|pending)\b", re.I)
ERRLINE = re.compile(r"^\s*(?:\w*Error|AssertionError|CypressError)\s*:\s*(.*)$")

# The runner's vocabulary -> what a person would write. `cy.find()` must NOT become `find()`:
# stripped of its prefix it is an unattributed function name the agent can mistake for
# something in its own code. cy.get/find/eq are all element lookups on a held subject; WHICH
# one ran is irrelevant to the fix.
VOICE = [
    # handle the whole clause before the bare-command rule, or "`cy.find()` failed because"
    # renders as "the element I was interacting with failed because", which is not English.
    (re.compile(r"`?\bcy\.[a-zA-Z]+\([^)]*\)`?\s+failed because\b"),
     "the element I was interacting with was replaced because"),
    (re.compile(r"`?\bcy\.[a-zA-Z]+\([^)]*\)`?"), "the element I was interacting with"),
    (re.compile(r"\bThe subject is no longer attached to the DOM\b"),
     "The element I had is no longer attached to the page"),
    (re.compile(r"\bthe subject\b", re.I), "the element I had"),
    (re.compile(r"\bbut you tried to continue the command chain\b"),
     "and I could not carry on with it"),
    (re.compile(r",? and Cypress cannot requery the page after commands such as [^.]*\.", re.I), "."),
    (re.compile(r"\bCypress\b"), "the browser"),
    (re.compile(r"\bcypress\b"), "the browser"),
]

# "should allow me to mark items as complete" is already first person; drop the test-report
# auxiliary so it reads as a thing the user did.
BEHAVIOUR = [
    (re.compile(r"^should allow me to\s+", re.I), ""),
    (re.compile(r"^should\s+", re.I), ""),
]


def voice(text):
    for pat, rep in VOICE:
        text = pat.sub(rep, text)
    return re.sub(r"\s{2,}", " ", text).strip()


def report(raw):
    """raw runner block -> list of (section, behaviour, description)"""
    entries, cur = [], None
    for line in raw.splitlines():
        m = ENTRY.match(line)
        if m:
            if cur:
                entries.append(cur)
            cur = {"context": [], "desc": [], "done": False}
            continue
        if cur is None:
            continue
        # Once an entry reaches the runner's tutorial, EVERYTHING after it in that entry is
        # the runner teaching its API -- the heading, its bullet list, its worked examples,
        # its doc link, its stack frames. Matching only the heading let the bullets through
        # ("- Your JS framework re-rendered asynchronously"). Stop collecting until the next
        # numbered failure.
        if TUTORIAL.match(line) or SUMMARY.match(line):
            cur["done"] = True
            continue
        if cur.get("done") or FRAME.match(line) or PATHY.search(line):
            continue
        e = ERRLINE.match(line)
        if e:
            cur["desc"].append(e.group(1).strip())
        elif line.strip():
            (cur["desc"] if cur["desc"] else cur["context"]).append(line.strip())
    if cur:
        entries.append(cur)

    out = []
    for e in entries:
        ctx = [c.rstrip(":") for c in e["context"] if c.strip()]
        # ctx is the runner's describe-nesting: [suite, section..., behaviour]
        behaviour = ctx[-1] if ctx else "an action"
        section = ctx[-2] if len(ctx) > 1 else ""
        for pat, rep in BEHAVIOUR:
            behaviour = pat.sub(rep, behaviour)
        desc = voice(" ".join(e["desc"])) or "it did not work."
        out.append((section, behaviour.strip(), desc))
    return out


def render(raw):
    lines = []
    for i, (section, behaviour, desc) in enumerate(report(raw), 1):
        head = f"  {i}) {section} — {behaviour}" if section else f"  {i}) {behaviour}"
        lines.append(head)
        lines.append("")
        lines.append(f"     {desc}")
        lines.append("")
    return "\n".join(lines).rstrip("\n")


if __name__ == "__main__":
    sys.stdout.write(render(sys.stdin.read()) + "\n")
