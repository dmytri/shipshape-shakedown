# Instrument findings, methods-candidate session (2026-07-26)

1. **Toolkit yoink was 0.1.17 and has no `--run` flag form.** Composite rigging methods are
   written in the flag form; a stale toolkit fails PER COMMAND inside a leg ("unknown option:
   --run"), invisible in the driver log. Presence checks cannot see it. FIXED: toolkit upgraded to
   0.2.0 and `eval-drive-todomvc.sh` now RUNS the flag form as its guard, upgrading if it fails.

2. **`--oracle-correct` hands Captain an EMPTY failure block when the page never serves.** A build
   with no `index.html` makes the oracle time out on wait-on, so the grade is `UNPARSEABLE` with
   zero failing titles: `correction_intent` pastes nothing between its rulers and the voyage is a
   guaranteed no-op. Caught IN FLIGHT on methflash-c1 v2 (the leg was killed, the arm resumed from
   voyage 2). FIX: route to the existing `page` intent when the prior grade is UNPARSEABLE or the
   sim has no `index.html`. Applied to `bin/.drive-patched.sh` for the live resume; to be landed in
   the canonical driver once the parallel arm finishes (editing a running bash script is unsafe —
   bash reads scripts incrementally).

3. **`run_shipwright` has no infra-retry, unlike `run_voyage`.** methflash-c1's first Shipwright
   pass went void on a transient `bwrap: Can't make overlay mount` (6 attempts) and the planking
   measurement was simply lost — the driver logged `planks=18 on-seam=0 hoisted=18` from the
   PRE-EXISTING tree, which reads as a Shipwright result and is not one. Two fixes owed: a bounded
   infra-retry around the Shipwright leg, and a distinct `VOID` marker in that log line so a void
   pass can never be read as a planking verdict.

4. **Transient overlay-mount failure still occurs with per-wave dedicated toolkits.** Both arms hit
   it once (c1 sw-prebuild void, b1 V3 retried and recovered) on separate `--overlay-src`
   lowerdirs, with 73G free — so the documented "use dedicated node_modules copies" mitigation
   reduces but does not eliminate it. The voyage-level retry is what makes it survivable.

5. **OPERATOR ERROR, kept visible: `pkill -f methflash-c1` killed my own watchers.** Every watcher
   and the Monitor carried the wave name in its command line, so the pattern matched them too
   (exit 144 = SIGTERM). Same class as the corpus's `pgrep`-matched-a-sibling hazard, this time
   self-inflicted from the operator side. Kill by PID or process group, never by a `-f` pattern
   that the watching machinery itself contains.

## HEADLINE FINDING (not the candidate's, found while auditing it): the pilot playbook has been
## contaminating every oracle-correction voyage, and Captain crosses doctrine's one ABSOLUTE
## boundary on essentially all of them

**Tree evidence, 86 correction voyages across 14 waves and 9 models** (`v*-captain.tree.diff`,
production = `js/`, `index.html`, `css/`):

| wave | captain wrote production / correction voyages |
|---|---|
| todomvc-mimo | **4/4** |
| todomvc-mimo2 | **2/2** |
| todomvc-glm, glm52, dpro | 2/2, 2/2, 1/1 |
| methflash-b1 (this session, control arm, 0.13.65) | **2/2** |
| todomvc-newsim-02 | 2/4 |
| todomvc-ds / hy3 / kimi / mm / qwen | 5/10, 2/4, 2/4, 2/4, 2/3 |
| todomvc-qmax | 1/29 (most of its voyages were void) |
| **todomvc-newsim-01** (older primed playbook) | **0/15** |
| TOTAL | 29/86 overall; ~100% in every wave run under the current `--oracle-correct` template |

Doctrine (`shipshape/SKILL.md`): *"One boundary holds absolutely: outside the Perturbation
policy's narrow, named exception, Captain never writes production code. That is the guarantee
these Articles exist to protect, and it always routes through a durable spec to QM and Crew."*

**The operator provokes it.** The correction template's closing line is *"Make the smallest product
change that resolves the named cause"*, addressed to Captain. `newsim-01`'s 0/15 is the isolation:
its playbook told Captain to author and STOP.

**Why this matters more than the candidate.** On these voyages Captain fixes the app, so QM opens,
finds no watchbill, and reports *"deck at rest"* in 3 shell calls (methflash-b1 v3-qm: 24 session
lines, 91s whole voyage; mimo v4/v5-qm: 2 shell calls each). **So the corpus's 28/29 grades past
voyage 1 largely measure ONE model in ONE role, not the role chain** — and any conformance reading
off those legs (planking, write custody, hand-off) has no denominator. It also explains the
"draw-unstable planking" note: the roles that plank were never dispatched.

**Two separable claims, and only the first is established here:**
1. ESTABLISHED (tree): under the current playbook, Captain writes production code on ~every
   correction voyage, and the downstream roles are consequently skipped.
2. NOT ESTABLISHED: whether doctrine *should* have held anyway. A real user CAN say "just fix it",
   and doctrine's answer is that Captain routes it through a spec regardless. Testing that is a
   BEHAVIOURAL question and owes a probe with a control arm (probe-first rule), not a text edit.

**Deliberately NOT fixed this session.** Changing the correction template mid-comparison would
break the Phase-3 apples-to-apples against the mimo baseline, which was itself run under the
contaminating template. Routed to dk with the numbers.
