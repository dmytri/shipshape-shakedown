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

# A frame is the RUNNER'S only if it points into the runner. Frames pointing at the app's own
# files are the most useful thing in the block and the agent can open them -- it wrote them.
#   at render (http://localhost:8884/examples/shakedown/js/app.js:130:42)   <- KEEP as js/app.js:130
#   at Keyboard.fireSimulatedEvent (.../cypress_runner.js:118974:27)        <- drop
FRAME = re.compile(r"^\s*at\s+")
RUNNER_FRAME = re.compile(r"cypress_runner\.js|webpack://|\.cy\.js|/cypress/|__cypress")
APP_URL = re.compile(r"https?://[^/]+/examples/[^/]+/")

# The runner's tutorial. `>` alone is NOT a tutorial marker: the app's own uncaught exception
# is printed as "> Failed to execute 'removeChild' ...", which is the single most valuable line
# in the whole block and precisely what a user pasting console output would paste. Only kill a
# `>` line when it is the runner quoting its own API at us.
TUTORIAL = re.compile(
    r"^\s*(Common situations why this happens|You can typically solve this|"
    r"From Your Spec Code|When Cypress detects uncaught errors|This behavior is configurable|"
    r"\(Results\)|>\s*`?cy\.)",
    re.I,
)
PATHY = re.compile(r"webpack://|\.cy\.js|/cypress/|cypress/e2e|__cypress|https?://on\.")
# the tutorial's rewrite examples are joined by a bare connector line ("to"), which otherwise
# lands at the end of the error text as a stray word.
BULLET = re.compile(r"^\s*(-\s+\S|to$|and$)")
SUMMARY = re.compile(r"^\s*\d+\s+(passing|failing|pending)\b", re.I)
ERRLINE = re.compile(r"^\s*(?:\w*Error|AssertionError|CypressError)\s*:\s*(.*)$")

# The runner's vocabulary -> what a person would write. `cy.find()` must NOT become `find()`:
# stripped of its prefix it is an unattributed function name the agent can mistake for
# something in its own code. cy.get/find/eq are all element lookups on a held subject; WHICH
# one ran is irrelevant to the fix.
# dk, 2026-07-31: "stick to the exact cypress error as much as possible." So this list is as
# SHORT as it can be. It touches only the tokens that name the runner or a file the agent
# cannot see. Every other word of the error -- the timeout, the cause, the DOM detachment, the
# assertion text -- passes through byte for byte.
#
# `cy.find()` cannot simply become `find()`: stripped of its prefix it is an unattributed
# function name the agent can mistake for something in its own code, which is a fresh goose
# chase. cy.get/find/eq/clear/type all appear in the corpus; naming the ACTION keeps the
# sentence true and grammatical without naming the tool.
VOICE = [
    (re.compile(r"`?\bcy\.(get|find|eq|first|last|children|parent|closest|filter)\([^)]*\)`?"),
     "the element lookup"),
    (re.compile(r"`?\bcy\.[a-zA-Z]+\([^)]*\)`?"), "the browser action"),
    (re.compile(r"\bCypressError\b"), "BrowserError"),
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
        # SKIP the runner's chatter line by line -- never terminate the entry on it. In the
        # uncaught-exception block the runner's explanation ("When Cypress detects uncaught
        # errors...") sits BETWEEN the app's error and the app's own stack frames, so
        # terminating there threw away the frames pointing at js/app.js:130 -- the most
        # actionable lines in the whole report.
        if TUTORIAL.match(line) or SUMMARY.match(line) or BULLET.match(line):
            continue
        if FRAME.match(line):
            # keep the app's own frames, stripped to a path the agent can open
            if RUNNER_FRAME.search(line):
                continue
            cur.setdefault("frames", []).append(APP_URL.sub("", line).strip())
            continue
        if PATHY.search(line):
            continue
        e = ERRLINE.match(line)
        if e:
            cur["desc"].append(e.group(1).strip())
        elif line.strip():
            # the app's own uncaught exception is printed quoted: "> Failed to execute ..."
            (cur["desc"] if cur["desc"] else cur["context"]).append(re.sub(r"^>\s*", "", line.strip()))
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
        out.append((section, behaviour.strip(), desc, e.get("frames", [])))
    return out


def render(raw):
    lines = []
    for i, (section, behaviour, desc, frames) in enumerate(report(raw), 1):
        head = f"  {i}) {section} — {behaviour}" if section else f"  {i}) {behaviour}"
        lines.append(head)
        lines.append("")
        lines.append(f"     {desc}")
        if frames:
            lines.append("")
            for f in frames[:6]:
                lines.append(f"       {f}")
        lines.append("")
    return "\n".join(lines).rstrip("\n")


if __name__ == "__main__":
    sys.stdout.write(render(sys.stdin.read()) + "\n")
