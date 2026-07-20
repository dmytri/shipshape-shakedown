#!/usr/bin/env python3
"""Check probe fixtures against CURRENT doctrine.

Fixtures are versioned against doctrine and nothing has ever checked that they still mean
what they meant. On 2026-07-20 that cost six separate instances in one session, every one
caught by a role agent or an ad-hoc assertion and none by the harness:

  1. 8 planks frozen in the pre-0.13.34 keyword form, malformed by construction since 0.13.34
  2. tw3 silently stopped testing its own subject, and the foul was RECORDED AS A SUCCESS
  3. the plank-join probe example double-faulted, so its "only the join can see it" design failed
  4. a seam-2 state whose dependency was installed but consumed by nothing (read as dead, not held)
  5. `ms` chosen as a probe dependency while npm hoists it in via cucumber->debug
  6. watchbill.json in the wrong shape entirely

The hard part is not detection, it is INTENT: probe states are deliberately defective. So every
deliberate defect is declared in fixtures/probe-states/expected-defects.json, and this script
fails two ways:

  DRIFT       - a defect that is not declared. The fixture rotted under the probe.
  DEAD ARM    - a declared defect that is no longer a defect. The probe silently lost an arm and
                will now report success while testing nothing. This is the tw4 case: a uniform
                plank repair would have made the beyond-diff plank well-formed and left "zero
                over-correction" as a marker that could never fail.

Usage: fixture-check.py <built-states-dir>   (run it after bin/probe-states.sh or designs/*/states.sh)
"""
import json
import os
import re
import subprocess
import sys

HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MANIFEST = os.path.join(HERE, "fixtures", "probe-states", "expected-defects.json")

STEPDEF = re.compile(r'^\s*(?:Given|When|Then)\(\s*(["\'])(.+?)\1', re.M)
PLANK = re.compile(r'@planks\(\s*"(.+?)"\s*\)')

problems = []   # (tree, severity, message)


def add(tree, sev, msg):
    problems.append((tree, sev, msg))


def step_patterns(tree):
    """Every step-definition pattern declared in the tree. Parsed, not run: a fixture state may
    legitimately be red, and `cucumber --dry-run` reports nothing useful when a require() fails."""
    pats = set()
    for root, dirs, files in os.walk(tree):
        dirs[:] = [d for d in dirs if d not in ("node_modules", ".git")]
        for f in files:
            if f.endswith(".js"):
                try:
                    src = open(os.path.join(root, f), encoding="utf-8").read()
                except OSError:
                    continue
                pats.update(m.group(2) for m in STEPDEF.finditer(src))
    return pats


def planks(tree):
    """(plank string, repo-relative file) for every @planks in the implementation directory."""
    out = []
    src_dir = os.path.join(tree, "src")
    for root, dirs, files in os.walk(src_dir):
        dirs[:] = [d for d in dirs if d not in ("node_modules", ".git")]
        for f in files:
            if not f.endswith(".js"):
                continue
            path = os.path.join(root, f)
            try:
                text = open(path, encoding="utf-8").read()
            except OSError:
                continue
            for m in PLANK.finditer(text):
                out.append((m.group(1), os.path.relpath(path, tree)))
    return out


def declared_for(manifest, name):
    return manifest["trees"].get(name, [])


def check_planks(tree, name, declared):
    """Every plank is a current step-definition pattern, unless declared malformed on purpose."""
    pats = step_patterns(tree)
    if not pats:
        return
    expected = {d["target"] for d in declared if d["kind"] == "plank-no-match"}
    seen_bad = set()

    for plank, rel in planks(tree):
        if plank in pats:
            if plank in expected:
                add(name, "DEAD ARM",
                    f"plank {plank!r} in {rel} is DECLARED malformed but now MATCHES a step "
                    f"definition. The probe arm it serves is dead: it can no longer fail. "
                    f"Either restore the defect or delete its entry and the arm that used it.")
            continue
        seen_bad.add(plank)
        if plank not in expected:
            hint = ""
            if re.match(r'^(Given|When|Then) ', plank):
                hint = (" It carries a leading keyword, retired in 0.13.34 - this is the exact "
                        "drift that made 8 fixture planks malformed by construction.")
            add(name, "DRIFT",
                f"plank {plank!r} in {rel} matches NO step-definition pattern and is not "
                f"declared in expected-defects.json.{hint}")

    for want in expected - seen_bad:
        add(name, "DEAD ARM",
            f"declared malformed plank {want!r} is not present in this tree at all. "
            f"The declaration is stale, or the state stopped building the arm.")


def check_watchbill(tree, name):
    """Doctrine: watchbill.json holds ONLY ordered watch objects watch1..watchN, each with only
    `scenarios`. (shipshape/SKILL.md, Watchbill policy)"""
    path = os.path.join(tree, "watchbill.json")
    if not os.path.exists(path):
        return
    try:
        wb = json.load(open(path, encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        add(name, "DRIFT", f"watchbill.json does not parse: {exc}")
        return
    if not isinstance(wb, dict):
        add(name, "DRIFT", "watchbill.json is not an object of watch entries")
        return
    for key, val in wb.items():
        if not re.fullmatch(r"watch\d+", key):
            add(name, "DRIFT",
                f"watchbill.json key {key!r} is not watch1..watchN. Doctrine: 'contains only "
                f"ordered watch objects named watch1, watch2, and onward'.")
            continue
        if not isinstance(val, dict) or set(val) != {"scenarios"}:
            add(name, "DRIFT",
                f"watchbill.json {key!r} must contain only 'scenarios'; found "
                f"{sorted(val) if isinstance(val, dict) else type(val).__name__}.")


def check_rigging_commands(tree, name):
    """A RIGGING command the plugin's own bash-custody hook denies is a command no role can run.
    The hook denies ANY recursive grep (it never reads the ignore artifact), so a fixture that
    configures one taxes every leg an invocation before it falls back to rg."""
    path = os.path.join(tree, "RIGGING.md")
    if not os.path.exists(path):
        return
    for line in open(path, encoding="utf-8"):
        if not line.startswith("- "):
            continue
        for cmd in re.findall(r"`([^`]+)`", line):
            if re.search(r"\bgrep\b", cmd) and re.search(r"(^|\s)-[A-Za-z]*r", cmd):
                slot = line[2:].split(":", 1)[0]
                add(name, "DRIFT",
                    f"RIGGING.md '{slot}' is {cmd!r}: a recursive grep, which the plugin's "
                    f"bash-custody hook DENIES outright. Use `rg` instead.")


def check_dependencies(tree, name, declared):
    """A dependency recorded under ## Dependencies but absent, or held below stable, is a real
    probe subject - but only when it is DECLARED and actually CONSUMED. An unconsumed dependency
    reads to a role as dead (invites removal), not held (invites upgrade), which is what voided
    8 legs of the 0.13.40 seam-2 run."""
    rig = os.path.join(tree, "RIGGING.md")
    if not os.path.exists(rig):
        return
    text = open(rig, encoding="utf-8").read()
    block = re.search(r"^## Dependencies\s*$(.*?)(^## |\Z)", text, re.M | re.S)
    if not block:
        return
    recorded = re.findall(r"^- dependency:\s*(\S+)\s*$", block.group(1), re.M)
    declared_dep = {d["target"] for d in declared
                    if d["kind"] in ("dependency-recorded-not-installed", "dependency-behind-stable")}

    for dep in recorded:
        if dep.startswith("@cucumber"):
            continue
        installed = os.path.isdir(os.path.join(tree, "node_modules", dep))
        if not installed and dep not in declared_dep:
            add(name, "DRIFT",
                f"dependency {dep!r} is recorded in RIGGING.md but not installed, and that is "
                f"not declared. Either it is drift, or a probe arm nobody wrote down.")
        if dep in declared_dep:
            used = subprocess.run(
                ["grep", "-rl", "--exclude-dir=node_modules", "--exclude-dir=.git", dep,
                 os.path.join(tree, "src")],
                capture_output=True, text=True).stdout.strip()
            if not used:
                add(name, "DEAD ARM",
                    f"dependency {dep!r} is a declared probe subject but NOTHING IN src CONSUMES "
                    f"IT. A role reads that as a dead dependency to remove, not a held one to "
                    f"upgrade, so the arm tests nothing. This exact defect voided 8 legs on "
                    f"2026-07-20.")


def check_hoisting(tree, name, declared):
    """A dependency declared ABSENT must not be resolvable anyway. npm hoists transitive deps to
    the tree root, so `ms` (via cucumber->debug->ms) resolved fine while RIGGING called it missing."""
    for d in declared:
        if d["kind"] != "dependency-recorded-not-installed":
            continue
        dep = d["target"]
        if os.path.isdir(os.path.join(tree, "node_modules", dep)):
            add(name, "DEAD ARM",
                f"dependency {dep!r} is declared ABSENT but IS present in node_modules - almost "
                f"certainly hoisted as a transitive of another package. The state is not red for "
                f"the reason it claims. Choose a dependency with no other path into the tree.")


def main():
    if len(sys.argv) != 2:
        sys.exit(__doc__)
    target = sys.argv[1]
    if not os.path.isdir(target):
        sys.exit(f"not a directory: {target}")
    manifest = json.load(open(MANIFEST, encoding="utf-8"))

    trees = sorted(d for d in os.listdir(target)
                   if os.path.isdir(os.path.join(target, d, ".git")))
    if not trees:
        sys.exit(f"no built states found under {target} - run the states script first")

    for name in trees:
        tree = os.path.join(target, name)
        declared = declared_for(manifest, name)
        check_planks(tree, name, declared)
        check_watchbill(tree, name)
        check_rigging_commands(tree, name)
        check_dependencies(tree, name, declared)
        check_hoisting(tree, name, declared)

    print(f"fixture-check: {len(trees)} states checked ({', '.join(trees)})")
    if not problems:
        print("ALL CONFORM - every deliberate defect is declared, and every declared defect is "
              "still a defect.")
        return 0

    drift = [p for p in problems if p[1] == "DRIFT"]
    dead = [p for p in problems if p[1] == "DEAD ARM"]
    for tree, sev, msg in problems:
        print(f"\n  [{sev}] {tree}: {msg}")
    print(f"\nfixture-check FAILED: {len(drift)} drift, {len(dead)} dead arm(s).")
    print("DRIFT    = the fixture rotted under the probe.")
    print("DEAD ARM = the probe still runs and still reports success, but tests nothing.")
    return 1


if __name__ == "__main__":
    sys.exit(main())
