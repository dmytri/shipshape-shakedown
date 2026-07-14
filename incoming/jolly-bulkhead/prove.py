#!/usr/bin/env python3
"""Prove the search-exclusion custody guard.

Splices the candidate guard into a copy of the installed Shipshape bash-custody
hook, then drives BOTH the installed hook and the patched hook with synthetic
PreToolUse payloads. Exit 2 = deny, exit 0 = allow.

Nothing outside the scratchpad is written.
"""
import json
import os
import shutil
import subprocess
import sys

S = os.path.dirname(os.path.abspath(__file__))
PLUGIN = "/home/exedev/.claude/plugins/marketplaces/dmytri-shipshape"
ORIG = os.path.join(PLUGIN, "hooks", "scripts", "bash-custody.sh")
PATCHED = os.path.join(S, "bash-custody-patched.sh")

# --- splice the guard in, right after the notecheck deny block -------------
src = open(ORIG).read().splitlines(keepends=True)
guard = open(os.path.join(S, "guard.sh")).read()

start = next(i for i, l in enumerate(src) if 'case "$notecheck" in' in l)
end = next(i for i, l in enumerate(src[start:], start) if l.strip() == "esac")
patched = src[: end + 1] + [guard] + src[end + 1 :]
open(PATCHED, "w").write("".join(patched))
os.chmod(PATCHED, 0o755)

# syntax check
if subprocess.run(["sh", "-n", PATCHED]).returncode != 0:
    sys.exit("patched hook has a syntax error")

NOTES = "CAPTAIN" + ".md"  # never a literal token in this file's source

# --- the matrix ------------------------------------------------------------
# (label, command, must_deny)
BYPASS = [  # proven to reach the notes file
    ("rg --glob",            "rg -l --glob '*.md' -e . .", True),
    ("rg --no-ignore",       "rg -l --no-ignore -e . .", True),
    ("rg shell-glob path",   "rg -l -e . *.md", True),
    ("grep -r bare",         "grep -rl -e . .", True),
    ("grep -r --include",    "grep -rl --include=*.md -e . .", True),
    ("grep shell-glob",      "grep -l -e . *.md", True),
]
SAFE = [  # proven unable to reach the notes file -- must stay usable
    ("rg plain",             "rg -l -e . .", False),
    ("rg -t md",             "rg -l -t md -e . .", False),
    ("rg --hidden",          "rg -l --hidden -e . .", False),
    ("rg pattern in dir",    "rg -n 'deriveRecipeIdentifiers' src/", False),
    ("grep on named file",   "grep -n 'focused' RIGGING.md", False),
    ("rg piped to grep",     "rg -l -e . src/ | grep -v test", False),
    ("ordinary build",       "npm run typecheck", False),
    ("cucumber focused",     "npx cucumber-js -p all features/x.feature", False),
]
NAMED = [  # the existing literal-token guard must still hold
    ("cat the notes",        "cat " + NOTES, True),
]


def run(hook, command, role="shipshape:qm"):
    payload = {
        "agent_type": role,
        "tool_name": "Bash",
        "tool_input": {"command": command, "description": "search"},
        "transcript_path": "/tmp/transcript.jsonl",
    }
    p = subprocess.run(
        [hook], input=json.dumps(payload), capture_output=True, text=True
    )
    return p.returncode, (p.stderr or "").strip()


def show(title, rows):
    print(f"\n=== {title} ===")
    print(f"{'vector':<22} {'installed':<12} {'patched':<12} verdict")
    print("-" * 68)
    ok = True
    for label, cmd, must_deny in rows:
        rc_o, _ = run(ORIG, cmd)
        rc_p, msg = run(PATCHED, cmd)
        d_o = "DENY" if rc_o == 2 else "allow"
        d_p = "DENY" if rc_p == 2 else "allow"
        good = (rc_p == 2) == must_deny
        ok = ok and good
        print(f"{label:<22} {d_o:<12} {d_p:<12} {'ok' if good else 'FAIL'}")
    return ok


a = show("BYPASS VECTORS (installed hook must allow; patched must deny)", BYPASS)
b = show("SAFE FORMS (both must allow -- searching must stay usable)", SAFE)
c = show("NAMED ACCESS (existing literal guard must still deny)", NAMED)

print("\n--- sample recovery message from the patched hook ---")
print(run(PATCHED, "grep -rn --include=*.md 'foo' .")[1])

print("\n--- roles: guard applies to internal roles only ---")
for role in ("shipshape:qm", "shipshape:crew", "shipshape:shipwright", "shipshape:captain"):
    rc, _ = run(PATCHED, "grep -rl -e . .", role=role)
    print(f"  {role:<24} {'DENY' if rc == 2 else 'allow'}")

print("\nRESULT:", "ALL PASS" if (a and b and c) else "FAILURES PRESENT")
sys.exit(0 if (a and b and c) else 1)
