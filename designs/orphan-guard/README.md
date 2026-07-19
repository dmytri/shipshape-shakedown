# Orphan class: the mechanical fix, designed and shown — NOT shipped

Written 2026-07-19 (opus session) discharging queue item 2, "design it and SHOW it,
do not ship it." Nothing here has been written into `~/shipshape`, no version bumped,
nothing installed. dk rules; this is the artifact to rule on.

## The headline: the fix on the board would not have fired

dk's standing disposition (2026-07-15) was: *if this is ever worth a mechanical fix,
deny the WAIT CLASS in the hook, never Monitor alone — whack-a-mole, pilot-#3-proven.*
That disposition should now be **rejected on evidence, not merely deferred**.

The only live reproduction of the orphan class in the last ~6 runs is the 0.13.33
efficiency battery's tw13 leg (banked `data/battery-0.13.33/tw13-slow-census-ORPHAN…`).
Its raw transcript survives. Its **complete** command list is:

```
ls -la …/tidewatch13
cd … && cat RIGGING.md && echo …
cd … && npx cucumber-js --tags …          <- auto-backgrounded at the ~2m cap (ID: b5zoyl7wi)
true                                       <- last act before the stop
cat …/tasks/b5zoyl7wi.output | tail -300   <- 8m26s later, AFTER the operator rescued it
… (post-rescue work)
```

There is **no wait command anywhere in it.** No `pgrep`, no `kill -0`, no sleep loop,
no transcript-result grep. The role ran `ToolSearch select:Monitor` — it *reached for*
Monitor — and then never called it. It ran `true` and ended its turn.

A PreToolUse wait-class deny inspects commands. This fault executed no command to deny.
**The proposed fix does not fire on the only observed instance of the fault it targets.**

Two further facts weaken it independently:

- The runtime already denies part of the class below Shipshape. `sleep 30; cat …` was
  blocked by the harness itself twice this session, with the message *"To wait for a
  condition, use Monitor with an until-loop … Do not chain shorter sleeps."* Shipshape
  denying it again adds nothing.
- The class self-corrected in 5 of ~6 runs, including this session's 0.13.35 tw13 on the
  identical probe state.

## What the fault actually is

Not "a role runs a wait command." **A role ends its turn while a backgrounded command's
output has never been read.** A background completion cannot resume a finished agent
chain, so the turn deadlocks silently and only an operator can rescue it.

The correct control surface is therefore the **stop**, not the command.

## The design: a SubagentStop guard

`orphan-guard.sh` in this directory. It blocks the stop, never a command, so it cannot
break a legitimate command — the exact failure mode the wait-class deny was warned for.

- Fires on `SubagentStop`, which carries `agent_type`; the human-facing main loop carries
  none and is out of reach, as with `planks-check.sh`.
- Scans the transcript for background launches (`moved to the background (ID: …)`,
  naming `tasks/<id>.output`) and for any later mention of that id — a `Read`, a
  `cat`/`tail`, or the completion notification. Any launch with no later mention blocks
  the stop with exit 2 and the reason.
- **Agent children are deliberately excluded.** An Agent spawn's result carries `agentId:`,
  never a task output path. Its completion *does* resume the parent by task-notification,
  so a turn ending on a live Agent child self-heals — observed live this session, tw13
  resumed itself twice with no operator touch. This exclusion is also doctrine-backed:
  `shipshape/SKILL.md:360` explicitly sanctions ending a turn with several agents live.
- `stop_hook_active` re-entrancy guard: it nudges **once**, then lets the role stop. It is
  a nudge, never a trap.
- Fails **open** on an absent/unreadable transcript or changed runtime wording — a
  wording drift silently stops enforcement, it never breaks a voyage.

**It adds no doctrine.** The rule is already stated, verbatim and precisely, at
`shipshape/SKILL.md:354`: *"A role never ends its turn waiting: not on a background
command… A verification run whose output the role has not read is not evidence and counts
as never run."* The 0.13.33 orphan was a violation of stated doctrine, not a doctrine gap.
That is the cleanest case a hook can have: it mechanises existing text.

Line 358 even asks for it in so many words: *"A runtime that spawns roles SHOULD carry
this rule as machinery, resuming a role on the signal it waits for, so a turn cannot end
holding live work. A skill-only agent holds it by discipline, and discipline alone has
been observed to fail here."*

## Test evidence: 15/15, on real transcripts, not synthetic only

`test-orphan-guard.sh` replays the record itself. The two decisive rows:

| Case | Source | Want | Got |
|---|---|---|---|
| 0.13.33 tw13 orphan, truncated at its real stop | real transcript | block | **block** |
| 0.13.35 tw13 clean, same probe state | real transcript | pass | **pass** |
| 0.13.33 tw13 after operator rescue | real transcript | pass | pass |
| Crew consuming by `cat`, not `Read` | real transcript | pass | pass |
| 6 no-background legs this session | real transcripts | pass | pass ×6 |
| live Agent child | synthetic | pass | pass |
| re-entrancy / foreign agent / absent transcript | synthetic | pass | pass ×3 |
| 2 backgrounded, 1 consumed | synthetic | block | block |

Zero false positives across **ten real role legs**. It discriminates the orphan from the
clean run of the *same probe on the same state*, which is the discrimination that matters.

## Honest limitations, stated

1. **Plugin channel only.** Hooks do not reach the skills-vendor channel yoink uses
   (opencode, no hooks). Same standing limitation as `planks-check.sh`. Doctrine text
   already covers both channels; this only hardens one.
2. **Depends on runtime wording** for the backgrounding message. Mitigated by matching
   three phrasings and by failing open.
3. **One nudge only.** A role determined to stop will stop on the second attempt. This is
   deliberate; the alternative is a trap.
4. **Thin sample.** One reproduction, one clean pass on the same state.

## Recommendation

**Reject** the PreToolUse wait-class deny outright — it does not fire on the observed
fault, and the runtime already covers part of its ground. Take it off the board rather
than carrying it forward another cycle.

**Ship the SubagentStop guard only if** dk wants the 0.13.33 failure mode mechanically
closed. It is cheap, precise, tested against the real record, adds no doctrine text, and
mechanises an Article that already asks for exactly this machinery. The case against it is
sample size, not design.

My own read: it is worth shipping, because the cost of the fault is asymmetric — one
orphan costs an operator rescue and ~10 idle minutes (pilot #2 lost a whole voyage), while
the guard costs one nudge in the rare case and nothing at all in every other leg, proven
across ten. But this is a judgment call on a thin sample and it is dk's to make.
