# Rubric: does 0.13.49's hook actually block the background stall, live?

**Fixed 2026-07-22 BEFORE any leg was dispatched.** Discharges CAPTAIN.md's one live
order. 0.13.49 shipped 2026-07-21 with zero live evidence: it was verified only by
replaying four banked transcripts through its own awk. It has never run as a hook.

## Why this and not more text

Two wordings have failed on this class (0.13.48's prohibition, 0.13.50's named act —
NULL at n=6/arm with the mechanism confirmed 12/12). The standing conclusion is that
text is the wrong instrument and the next candidate is machinery. This is that
candidate.

## Arms

**Single arm: installed plugin channel, 0.13.50 skills + 0.13.49 hook live.** Legs are
dispatched as `shipshape:qm` agent types so the plugin's SubagentStop hooks fire.

There is no same-run control, and that is a stated limit, not an oversight. The primary
markers below are **per-leg correctness properties of the guard**, each true or false on
one leg's own evidence — they need no comparator. Only the secondary outcome marker (M5)
is a rate, and its comparator is a **declared prior, not a control**: the banked
0.13.50 arm (`data/bgact-0.13.50/`, t1-t6) ran the same fixture, same text, same model,
same 220s window, differing only in that no hook fired. **3/6 clean, and 3 stalls.**
Cross-run comparison is weaker than same-run and is reported as such.

## State

`tidewatch13` from `bin/probe-states.sh`, forced 220s settling window
(`fixtures/probe-states/slow_steps.js`), verified >220s wall before any leg runs. The
watchbill is a tier tag, so the enumeration sweep — the slow thing — is the leg's own
first act. Boundary-crossing is by omission: a leg that does not raise the foreground
budget WILL cross it.

## n, model, ordering

**n = 4 QM legs, dispatched SERIALLY**, sonnet pinned on every leg. Serial because the
previous probe established that background task ids and the process table are
session-wide and parallel legs cross-contaminate (aug1 killed a PID it found via
`ps aux`). Any leg that escalates above sonnet is void.

## Channel verification

Empirical, never by timestamp, and never by plugin parity — parity passed while the
plugin served nothing (the dangling-installPath finding). The first dispatched leg's raw
transcript is marker-grepped for the 0.13.50-unique string `first raises that budget for
the run`. Zero hits = stale snapshot = the run is void and reports as such.

Pre-checked before dispatch: installed `SKILL.md` carries that string (1 hit) and
carries the 0.13.48 string `runs it detached and resumes on its exit signal` 0 times;
the installed hook is byte-identical to `~/shipshape` HEAD.

## PRIMARY markers — the four fixed in CAPTAIN.md, each binary, per leg

- **M1 — fires on its OWN task.** Where a leg ends its turn holding a task IT launched,
  the guard blocks the stop and its message names THAT task id. Evidenced from the
  leg's own transcript (the launch line) and the guard message.
- **M2 — does NOT fire on a foreign task.** The 07-21 defect fired on a task the leg
  never launched, poisoned into the session transcript by the operator mining a
  sibling. **Tested deliberately, not merely hoped for:** between legs the operator
  mines the previous leg's transcript with `jq`, reproducing the exact pollution vector
  — a launch announcement quoted verbatim into the session file. A guard message on a
  later leg naming a PRIOR leg's task id fails M2.
- **M3 — a part-way read does not clear the block.** Where a leg reads its own output
  file mid-flight and stops while the runtime still reports the task `running`, the
  guard still blocks. This is the branch aug2 escaped through and the reason 0.13.49
  intersects `background_tasks` status with the transcript.
- **M4 — a clean leg passes untouched.** A leg that sets a covering timeout, or that
  consumes to the summary line, stops with no guard message. A guard that blocks a
  clean leg is a false positive and is a finding against 0.13.49.

**M1 and M3 are only testable on legs that actually stall.** Legs that take the act and
run clean test M4 only. Per the previous probe's own correction, **the denominator for
M1/M3 is stalling legs, not dispatched legs**, and if zero legs stall the hook is
untested on its blocking path and this run says so rather than claiming a pass.

## SECONDARY marker — outcome, recorded, not the verdict

**M5 — does the block RESCUE the leg?** A blocked stop feeds the guard message back to
the role. Does it then consume the output and file a clean Final report, or block, flail
and stop again? Re-entrancy means the second stop passes by design, so the guard gets
exactly one intervention per leg. **A guard that fires correctly and rescues nothing is
a correct guard and a failed remedy**, and this rubric will say both.

Also recorded: invocations, cache, wall, `bin/runs.sh` executing runs, whether the leg
reached a commit, and whether it took the named act.

## Observation horizon — DECLARED IN ADVANCE, per the binding method debt

"Did it deadlock" is a function of when you look. Every earlier rate in this corpus for
this class is a snapshot with no observation time recorded.

**Horizon: last leg's stop + 36 minutes.** Same interval the 0.13.50 probe declared and
waited out, chosen so the two runs' recovery figures are comparable. Readings are taken
and TIMESTAMPED at the horizon; an earlier reading may be recorded but is not the
result. Nothing is scored before the horizon passes.

## Decision rule, fixed now

- **M1-M4 all hold on their testable legs** → 0.13.49 is validated as machinery, on live
  evidence, and the corpus records it as the first thing to move this class.
- **Any of M1-M4 fails** → 0.13.49 does not clear live validation. Routes to dk before
  anything ships. A false positive (M4) is the most serious failure available here,
  because it breaks legs that were doing nothing wrong.
- **M1-M4 hold, M5 rescues nothing** → the guard is correct and insufficient. The class
  stays open and the next candidate is runtime resumption, not another guard.
- **Zero legs stall** → the blocking path is untested. Reported as untested. The prior's
  3/6 stall rate makes this unlikely but it is not impossible, and a fabricated pass
  here would be worse than an honest gap.

## Limits, stated in advance

- n=4, single arm, cross-run comparator. Small.
- QM legs only. The cross-role rider is already discharged (t1's nested Boatswain hit
  the same fault unprompted) so it is not re-owed here.
- A stalled leg leaks its suite process and load accumulates across the run. Orphans are
  killed between legs **by PID from the leg's own tree**, never by a broad `pkill -f`
  pattern — that is a recorded operator error from the last session and it may have
  reached another session.
- This probe cannot explain the unexplained resumption (4/7 vs 0/3). It is not trying to.
