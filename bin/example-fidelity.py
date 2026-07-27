#!/usr/bin/env python3
"""Did the fit use the doctrine's worked example, or reinvent it?

dk's expectation (2026-07-26): a JavaScript or Python fit should reproduce the worked example in the
Shipwright derivation notes essentially verbatim, since it is given; a TypeScript or Rust fit should
adapt it, applying that stack's deltas correctly. Conformance alone cannot see the difference: a fit
that reinvents a passable set scores zero violations while ignoring the example it was handed.

Usage: bin/example-fidelity.py <stack> <sim-dir>
"""
import json
import os
import re
import sys

HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SKILL = os.path.join(HERE, "experiments/methods-candidate/skills/shipwright/SKILL.md")

# The tool tokens each stack's example carries. Fidelity is judged on these, not on whitespace: a fit
# may name its own paths, but the tools and the shape are the example's.
EXPECT = {
    "js": {"plank-join": [".shipshape"], "prove": ["cucumber-js", "SS_SCENARIO", "not @captain"], "hygiene": ["typecheck", "lint"],
           "regression": ["c8"], "dead-code": ["knip"], "spec-lint": ["gplint"], "install": ["npm install", "SS_DEPENDENCY"],
           "discovery": ["--dry-run", "not @captain"]},
    "py": {"plank-join": [".shipshape"], "prove": ["pytest", "SS_SCENARIO", "not captain"], "hygiene": ["mypy", "ruff"],
           "regression": ["--cov"], "dead-code": ["vulture"], "spec-lint": ["gplint"], "install": ["uv add", "SS_DEPENDENCY"],
           "discovery": ["--collect-only", "not captain"]},
    "ts": {"plank-join": [".shipshape"], "prove": ["cucumber-js", "tsx", "SS_SCENARIO", "not @captain"], "hygiene": ["tsc", "biome"],
           "regression": ["c8"], "dead-code": ["knip"], "spec-lint": ["gplint"], "install": ["SS_DEPENDENCY"],
           "discovery": ["--dry-run", "not @captain"]},
    # A token may be a tuple: any one of it satisfies the method. cargo-llvm-cov and cargo-machete are
    # not installable in this sim, and doctrine's answer for an uninstallable tool is `none` plus a
    # named gap - so `none` counts here exactly as the tool would.
    "go": {"plank-join": [".shipshape"], "prove": ["go test", "SS_SCENARIO", "~@captain"], "hygiene": [("staticcheck", "golangci-lint"), "go vet"],
           "regression": ["-cover"], "dead-code": [("deadcode", "staticcheck")], "spec-lint": ["gplint"],
           "install": [("go get", "go install"), "SS_DEPENDENCY"],
           "discovery": [("godog.definitions", "ast-grep", "none")]},
    "rs": {"plank-join": [".shipshape"], "prove": ["cargo test", "SS_SCENARIO"], "hygiene": ["cargo check", "clippy"],
           "regression": [("llvm-cov", "tarpaulin")], "dead-code": [("machete", "udeps")],
           "spec-lint": ["gplint"], "install": ["SS_DEPENDENCY"],
           "discovery": [("no-run", "dry-run")]},
}


def entries(sim):
    """Every method value this sim's rigging carries.

    Methods live in RIGGING.md itself (dk, 2026-07-27): the value IS the plan, so there is one list
    and no runner file to reconcile. A rigging in the superseded registered shape still parses here,
    and its short value simply fails the tool-token check, which is what a refit should report.
    """
    out = {}
    rig = os.path.join(sim, "RIGGING.md")
    if not os.path.exists(rig):
        return out
    block = re.search(r"^## Methods\s*\n(.*?)(?=^## |\Z)", open(rig, errors="replace").read(), re.S | re.M)
    if not block:
        return out
    for m in re.finditer(r"^- ([a-z][\w-]*):\s*(.+?)\s*$", block.group(1), re.M):
        out[m.group(1)] = m.group(2).strip().strip("`")
    return out


def main(argv):
    if len(argv) < 2:
        print(__doc__)
        return 2
    stack, sim = argv[0], argv[1]
    exp = EXPECT.get(stack, {})
    got = entries(sim)
    if not got:
        print(f"{stack}: NO ENTRIES registered in any task runner")
        return 1
    faithful = missing = 0
    for meth, tokens in exp.items():
        body = got.get(meth)
        if body is None and any(isinstance(t, tuple) and "none" in t for t in tokens):
            faithful += 1          # written `none` for a tool this environment cannot install
            continue
        if body is None:
            print(f"  {meth:13s} ENTRY ABSENT")
            missing += 1
            continue
        lack = [t if isinstance(t, str) else "/".join(t) for t in tokens
                if not (t in body if isinstance(t, str) else any(a in body for a in t))]
        if lack:
            print(f"  {meth:13s} diverges: missing {', '.join(lack)}")
            missing += 1
        else:
            faithful += 1
    plans = sum(1 for b in got.values() if "yoink" in b and "--run" in b)
    print(f"{stack}: {faithful}/{len(exp)} methods match the example's tools; {plans}/{len(got)} entries are plans")
    return 0 if missing == 0 else 1


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
