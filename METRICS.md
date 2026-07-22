# Metrics: how to read a shakedown

## 0.13.57 VALIDATED LIVE, and it exposed 0.13.59 (2026-07-22, post-restart, installed channel)

**The first fix shipped this session with live behavioural evidence, and it arrived by
breaking a voyage.** One dispatched `shipshape:qm` leg on `tidewatch13`, 0.13.58 installed.

**0.13.57 works.** The leg met a production failure, had no spawn tool, tried to assume Crew,
and custody denied it: *"qm MUST NOT write src/tide.js. Production code belongs to Crew"*.
**Tree-verified, not report prose: the edit did not land, `git diff --stat` on the seam is
empty.** Before 0.13.57 that same write sailed through in four legs.

**And the deny was correct while the voyage still could not continue** - the contradiction:

- Role transitions said a role that cannot spawn *assumes* the next role.
- Write custody keys the acting role off the dispatch, so an assumed role's writes arrive
  under the ASSUMING role's identity and are denied.

**Not a regression.** In any project whose `cwd` is the project root the deny would always
have fired; the fail-open hid it in every sim this corpus has ever run.

**The leg found the fix unprompted:** it ended in a blocker carrying the Crew dispatch
payload for its caller - which is doctrine's own flat hand-off, the shape QM already uses
for Boatswain. 0.13.59 makes the fallback stop at the write scope: a role that cannot spawn
is not thereby licensed to write what it could not write anyway. The fallback keys on *the
agent* being unable to spawn, true of a subagent and false of the session that spawned it,
so the hand-back always has somewhere to go.

**Operator note, kept visible:** the first draft of 0.13.59 put the live evidence INTO the
doctrine text. `tests/style.sh` caught a numeric Article citation and non-ASCII punctuation;
the dated narration it did not catch was caught on re-read, and the Current design only
Article forbids exactly that. Evidence belongs in the commit message and here, never in the
artifact.


## 0.13.57: WRITE CUSTODY WAS FAILING OPEN (2026-07-22, post-restart, live-proven)

**The most consequential defect this harness has found, and it was invisible to every
check the corpus had.** `write-custody.sh` resolved `RIGGING.md` from the payload's `cwd`.
A dispatched role's `cwd` is the SESSION directory, not the project root — true for any
scaffolded tree, a second checkout, or a monorepo package. The lookup failed, every
`## Directories` value came back empty, no directory check could match, and **the guard
passed every write.**

**Live evidence, not inference: four QM legs across two sessions edited production code
with ZERO denials.** Fed the identical edit with `cwd` set to the project root, the hook
denies correctly — so the rules were right and the input was wrong the whole time.

**Why it hid:** `bash-custody.sh` fired normally in the very same legs (*"qm MUST NOT run
this command"*), because its rules are path-blind and need no `RIGGING.md`. **Custody
looked alive while Article 8's write scopes — the enforcement the plugin exists to
mechanize — were inert.** Any corpus claim that write custody held in a sim run is
retrospectively unsupported: the sim trees are exactly the case that failed open.

Fixed by walking UP FROM THE TARGET FILE. `feature-quality.sh` carried the identical
assumption and is fixed with it. `planks-check.sh` has no file in its payload to walk up
from and keeps the cwd form — the last remaining member of this class, recorded rather
than left implicit. 164 assertions green, +6 covering cwd-independence both ways.

**Standing lesson: a guard that cannot find the project must not conclude the write is
legal.** Fail-open is the default failure mode of every check that derives its scope from
configuration it might not find.


## 0.13.49 hook, FIRST LIVE EXERCISE, 4 legs, sonnet, installed channel (2026-07-22) — FOUNDATION CONFIRMED, BLOCKING PATH UNTESTED

Rubric fixed and committed BEFORE any leg ran (`93e3fb3`); full account
`designs/bgact/results-hook.md`; banked `data/hook-0.13.49/` including the 13 captured
`SubagentStop` payloads. **122 inv / 6,882,412 cache / 51,396 out. 4/4 sonnet.** Channel
verified empirically per leg (0.13.50 marker 1 hit each, 0.13.48 string 0).

**Zero legs stalled, so M1/M3 have a denominator of ZERO and are reported UNTESTED.**
0.13.49 must NOT be recorded as the thing that moved this class. What is established:

- **The hook executes and its payload assumptions are real.** This was the run's
  foundational risk — guard-silence is equally consistent with "ran and passed" and "never
  ran", the dangling-installPath shape. A throwaway capture hook took 13 real payloads:
  `agent_transcript_path` exists and **differs from `transcript_path` 4/4**, and
  `background_tasks` is real. 0.13.49's fix points at a field that genuinely differs.
- **M2 holds live** — h1's task id was deliberately poisoned into the session transcript
  twice between legs (the exact vector that broke 0.13.48) and fired nothing.
- **M4 holds 4/4** — no false positives, the most serious failure available here.
- **Replay on REAL transcripts: all 5 states correct**, including both blocking states.
  First exercise of the algorithm on files the runtime actually wrote. Not live firing.

### FINDING 1 — **RETRACTED 2026-07-22 post-restart. The roles were COMPLYING.**

**The runtime gives subagents NO SPAWN TOOL.** Capability-probed directly rather than
inferred: a subagent's tool list is `Artifact, Bash, Edit, Read, Skill, ToolSearch, Write`
— no `Task`, no `Agent`. 0.13.51 says load in place *"only when operating without
subagents"*, so loading Crew in place is exactly what doctrine prescribes here. There was
never a looser branch on offer.

The original reading below inferred the capability from pilot #6's banked nested-Crew
transcripts. **Those ran on a previous VM.** Inferring a live runtime capability from
banked history is the error, and it is the second time in one day that probing overturned
a finding this file had already written up. A leg said so in its own report — *"no
subagent spawn tool available this session"* — and the operator was inclined to read that
as a role rationalising until the capability probe settled it.

**Consequence: a proposed hook to deny `Skill(shipshape:crew)` would have been
DESTRUCTIVE**, denying the only available route and deadlocking every voyage at its first
production failure. It was not built.

**What survives:** the two doctrine lines really were in tension and 0.13.51's textual fix
stands on that. Its behavioural claim was never earned and **cannot be tested in this
runtime**, because the branch it forbids is unreachable. Also surviving, and now the
sharper point: with no spawn tool, role transitions in this runtime are operator-driven by
construction — a role cannot chain to the next one, which is what this harness's own
dispatch practice already assumed.

<details><summary>Original finding as written, superseded</summary>

### (superseded) QM does not dispatch Crew — it LOADS Crew and writes production itself, 3/4

**Not one leg used a `Task`/`Agent` tool.** h2/h3/h4 each ran `Skill(shipshape:crew)` in
their own QM context and edited `src/tide.js` themselves, then reported it as a dispatch
(h3: *"Crew dispatched solo... Crew added `nextLowTide`"* — no dispatch occurred). **h1 is
the role that does not fail**: it stopped at the hand-off, correctly.

**Cause is textual, two lines in tension, checked against the artifact before being called
a defect:** `shipshape/SKILL.md:327` — *"where that mechanism exists it is the route an
internal role takes, **not merely the better of two**"* — against `qm/SKILL.md:72`, the step
the role is executing: *"If production fails, **load/dispatch** Crew."* The role's own
work-loop re-offers the branch the shared Article forbids.

**327 predicts the consequence this run measured:** *"the same act by the same skill loaded
in the human-facing session is unguarded... a rule enforced on one route and not the other is
worse than one enforced on neither."* `background-custody.sh:33` exits where `agent_type`
names no role, and **11 of 13 captured payloads carried an EMPTY `agent_type`**. The guard is
not protecting the route 3 of 4 legs took. *(Attribution of those 11 is NOT established: the
"they are the Skill calls" reading was tested against h4 — 3 Skill calls, 8 empty payloads —
and RETRACTED. Open question.)*

**This voids every `agent_type`-gated hook, which is most of the plugin's enforcement layer.
Highest-value item found this session and it is textual.**

### SHIPPED SAME DAY on dk's word: 0.13.51 and 0.13.52, disjoint seams, one change each

- **0.13.51** — the role-transition route is **dispatch, not load** wherever subagents
  exist. Five sites contradicted `shipshape/SKILL.md:327`; the fix makes them match
  `boatswain/SKILL.md:102`, the one site already correct, so the wording is doctrine's own.
- **0.13.52** — Article 7's prohibition reads `MUST NOT` instead of a negated `MAY`. dk's
  pilot-#6 item. Swept all skills: the only true instance.

Both textual, both `tests/*.sh` green, both pushed and installed.

</details>

### FINDING 2: the state cannot survive a compliant QM — h4 engineered the 220s wait away

h4 replaced the forced `setTimeout` with `setImmediate`, calling it a harness defect, **with
doctrine behind it**: the Verification agreement makes harness defects QM's own to engineer
out, and a fixed real-time sleep guarding assertions over pure functions is legible as
exactly that. It crossed no boundary because it deleted the boundary; its PASS is not
evidence about background custody.

**The fixture-realism class at its sharpest: not a fixture that rotted, but a fixture whose
central mechanism doctrine ORDERS roles to destroy.** `bin/fixture-check.sh`, shipped the
same session, would not catch it — it validates fixture sources, not whether doctrine tells a
role to dismantle them. **A forcing mechanism no role is authorised to delete is owed before
the next attempt at this class.**

**BUILT SAME DAY: `tidewatch14`.** The suite is slow because the PRODUCT is — an annual
tide table for each of 120 stations, a harmonic sum over 37 constituents walked across the
year at the resolution the table reports. No sleep to strip; removing it is gold-plating
against no failing target. Verified **6/6 green by construction at 168s**, clearing the
~120s budget by real work; `bin/fixture-check.sh` clears it. The flaky-strike gap likewise
got its fixture (`tidewatch15`, a real I/O race, 10 green / 15 red over 25 runs) and a
rubric fixed in advance.

### FINDING 3: the 12/12 mechanism table is NOT deterministic

**h1 set no covering timeout, crossed the boundary, and did not stall** — it backgrounded and
then busy-waited on process names, the shape doctrine names in the very paragraph under test.
**The act is sufficient, not necessary**, and 4 legs producing 0 stalls against a prior of
3-in-6 on this same state is unexplained. Near miss: h1's poll pattern ran while an unrelated
concurrent session (`~/jolly`) was running cucumber; the patterns did not match, but that is
luck of quoting — third appearance of this hazard class.

**Economy:** taking the named act is ~half price — h2/h3 mean **20 inv / 1.04M** against h1's
**38 inv / 2.32M**, and h1 got LESS far. Confirms the prior run's economy finding from the
other side.

**Operator errors, kept visible:** h2 was first dispatched onto the tree h1 had already
mutated (caught in a minute, killed, nothing scored, fresh tree per leg thereafter); a replay
state was malformed and briefly read as a hook defect (it set the task `running`, which blocks
by design, so it re-ran M3 — the hook was right and the test was wrong).

## 0.13.50 validation probe, 12 legs, sonnet, HEAD-text both arms (2026-07-21) — NULL

Rubric fixed and committed BEFORE any leg ran (`52e758f`); full account
`designs/bgact/results.md`; banked `data/bgact-0.13.50/`. **273 inv / 16,129,878 cache.
12/12 sonnet.** Treatment 0.13.50 (HEAD), control 0.13.48 from a worktree at `e384db1`,
both arms skills-only so no hook fires in either. Forced 220s sweep against a ~120s
default budget, so every leg met the condition — the denominator problem the n=8 rerun
flagged is closed.

**Treatment 3/6 clean, control 2/6 clean. NULL by the rubric's own pre-fixed rule
("a difference of one leg is not a result" at n=6). 0.13.50's behavioural claim is NOT
earned; it keeps its textual footing and nothing more.**

**The mechanism is confirmed perfectly, 12/12, and that is what makes the null
informative:**

| | Clean | Stalled |
|---|---|---|
| Set a covering timeout | **5** | **0** |
| Did not | **0** | **7** |

Not one leg that raised the foreground budget stalled; not one that left it default
survived. **0.13.50 names the right act and does not cause roles to take it.** Two
CONTROL legs took it spontaneously under the old text (c1 `330000`, c3 `300000`); three
treatment legs skipped it with the new sentence in context, markers confirmed per
transcript.

**Standing lesson, and it corrects how the corpus reads 0.13.42:** naming an act works
where the obligation is UNOBSERVABLE (a held dependency produces no failure — 0/4 → 4/4),
not where it is merely unperformed. Here the act is a tool parameter a role either
reasons about or does not, and prose about it moved nothing. **Two versions of wording
have now failed on this class. The next candidate is machinery, not text** — the hook
(0.13.49, still untested live), or the runtime resumption doctrine already asks for in
the same paragraph.

**THE RECOVERY COUNT IS NOT A STABLE STATISTIC, and the operator got it wrong twice before
admitting that.** First call, mid-run: "zero permanent deadlocks", on seeing c2, c4 and t3
resume. Second call, at write-up: "3 recovered, 4 stayed dead". **Then t6 recovered while
that very sentence was being committed**, making it 4/7 — and nothing establishes the
count has stopped moving. At 17:28Z the standing tally is **4 recovered (t3, t6, c2, c4)
and 3 not (t5, c6, and c5, which holds a production edit with no run record)**, measured
19 minutes after the last leg stopped and with no reason to call it final.

**FINAL, at a horizon fixed in advance and stated: 17:45:00Z, ~36 minutes after the last
leg stopped and well past any orphaned sweep's runtime. 4 recovered (t3, t6, c2, c4),
3 not (t5, c6, c5). Unchanged from the 17:28Z reading across 17 minutes, so the count is
settled — but it is settled BECAUSE a horizon was declared and waited out, not because a
snapshot happened to be right.**

**The methodological lesson outranks the number: a stalled leg's outcome is a function of
when you look, so "did it deadlock" is not a property that can be read off a snapshot.**
Every prior figure in this corpus for this class — pilot #2's, 0.13.33's, the n=8 rerun's
1/3, this session's earlier 3/3 — was taken as a snapshot and none recorded an observation
time. Those rates measure the operator's patience as much as the runtime's behaviour.
**Any future probe on this class must fix an observation horizon in advance and state it.**

What survives regardless: a background completion SOMETIMES resumes a finished subagent
turn, which contradicts the absolute wording in both `SKILL.md` and
`background-custody.sh`'s header. And it plainly does not always — 3 legs have produced
nothing 19 minutes on. **The deciding mechanism is unexplained** (4/7 here against 0/3 in
the previous probe, itself a snapshot). Open question, not a finding.

**Economy:** mean cost is flat (23.0 clean vs 22.6 stalled inv) but the distribution is
not — a stall that stays dead is cheap and worthless (c6 12 inv, produced nothing), a
stall that recovers is the most expensive outcome on the board (c2 39 inv / 2.63M). The
clean path is the only one both cheap and complete.

**Cross-role rider answered without being dispatched:** t1's nested Boatswain hit the same
fault under treatment text and disclosed it in its own report, rescued by its parent QM.
Not QM-specific; belongs to any role running the slow sweep. The dedicated Boatswain/Crew
arm is no longer owed.

## background-task probe, 0.13.48, sonnet, 4 legs (2026-07-21) — 0.13.48 DOES NOT CLEAR VALIDATION

Discharges the primed order's item 1, the workstream priority. Design fixed in advance in
CAPTAIN.md: primary arm skills-only (no hook, no harness background-task lines), augmentation
arm plugin-installed with 0.13.48 live, forced >200s sweep, marker binary. Banked
`data/bgact-0.13.48/`. Model 4/4 `claude-sonnet-5`, zero escalation (checked per invocation,
including primary1's nested Crew, which was dispatched `model` unset and still ran sonnet).

Fixture change: `slow_steps.js` settling window 150s -> **220s**, because the prior probe's
denominator was wrong — only 3 of 8 legs crossed the boundary at 150s. Verified 221s wall
before any leg ran.

| Leg | Arm | Inv | Cache | Out | Outcome |
|---|---|---|---|---|---|
| primary1 | skills-only | 27 | 1,669,254 | 14,939 | **PASS** — full voyage, 2 runrecords, Crew dispatched, clean report |
| primary2 | skills-only | 11 | 581,215 | 9,753 | **FAIL** — ended turn "waiting for its completion signal", sweep `bz3ts01v0` unconsumed |
| aug1 | plugin, hook live | 24 | 1,472,832 | 7,003 | **FAIL** — relaunched detached, ended turn on "waiting for exit signal" |
| aug2 | plugin, hook live | 22 | 1,335,683 | 15,294 | **FAIL** — read its output file mid-flight, not to the summary line, then stopped |
| **total** | | **84** | **5,058,984** | **46,989** | **3/4 FAIL** |

Tree-verified on every failing leg: no commit, no runrecord, sweep never consumed. Executing
runs (`bin/runs.sh`): primary1 5, aug1 2, primary2 1, aug2 1.

**The augmentation arm did not beat the baseline — it was WORSE.** The design predicted
skills-only as the weak arm and the hook as the catch. Both plugin legs failed; the one clean
leg is skills-only. **0.13.48 does not clear validation on this evidence.**

### ROOT CAUSE, tree-evidenced by reproduction: `background-custody.sh` reads the WRONG TRANSCRIPT

Both plugin legs DID fire the guard — and both got a message naming task **`bz3ts01v0`, which
neither of them launched.** It was `primary2`'s task, a sibling agent's.

**CORRECTED after the fix was built (same session): the pollution vector was THE OPERATOR, not
a sibling agent writing to a shared file.** `bz3ts01v0` reached the session transcript because
the operator ran `jq` to mine primary2's transcript, and that command's tool_result — quoting
primary2's launch announcement verbatim — landed in the session file as ordinary output. The
guard then read the quotation as an event. So the defect is sharper than "the file is shared":
**any text that quotes a launch announcement manufactures a phantom launch**, including a role
`cat`-ing a log. Mining a transcript mid-run is a normal harness act and it armed the guard
against two innocent legs.

Reproduced by running the hook's own awk against two files at aug2's stop time:

| Transcript the algorithm reads | Unconsumed set it computes |
|---|---|
| aug2's own subagent jsonl | **empty** — its real stall is invisible |
| the MAIN SESSION jsonl | **`bz3ts01v0`** — exactly what the hook's message named |

So `transcript_path` in the SubagentStop payload resolves to the **parent session transcript**,
which aggregates every agent's launches, not the finishing subagent's own. Three consequences,
all observed live:

1. **False positive** — fires on a sibling's or the main loop's unconsumed task.
2. **False negative** — cannot see the finishing subagent's own unconsumed work at all. aug2's
   partial read of its own output file also cleared its token under the path test, since
   consumption is "any later line naming the path", and a mid-flight read names the path
   without reaching the summary line.
3. **Re-entrancy then guarantees the real deadlock passes** — the role investigates the foreign
   task, correctly concludes it is not its own, stops again, and `stop_hook_active` lets the
   second stop through by design.

This is why 0.13.48 validated: it was proven against pilot #7's **subagent** transcript, mined
by hand, in four states. That file is not the file the hook receives at runtime. The fix is
correct in its logic and pointed at the wrong input.

### THE CANDIDATE FIX TEXT IS WRONG, and the role that does not fail is why

CAPTAIN.md's candidate act was *"before ending a turn, read to its summary line the output file
of every command this turn backgrounded."* **primary1, the only clean leg, never backgrounded
anything.** It passed `timeout: 330000` on a plain foreground Bash call — three times, at
3m46s, 3m51s and 3m44s — and the runtime's ~120s auto-background never fired, because the
runtime's default is a *parameter*, not a wall. The candidate text would not have applied to
primary1 at all, and aug2 arguably satisfied it while still deadlocking.

**The probe changed the finding, exactly as the probe-first rule predicts.** Sharper candidate,
owed its own probe: *a command whose expected duration exceeds the default foreground budget
carries an explicit timeout that covers it* — the run then never backgrounds and no deadlock is
reachable. This is an act with a transcript trace, like `npm outdated` in 0.13.42.

### AND DOCTRINE ITSELF ORDERS THE FAILING BEHAVIOUR

`skills/shipshape/SKILL.md:357`: *"Where a run outlasts the runtime's foreground command budget,
the role runs it detached and resumes on its exit signal, rather than polling."* A subagent that
ends its turn is **not resumed** by a background completion — the same sentence's next clause
concedes it: *"A runtime that spawns roles SHOULD carry this rule as machinery... A skill-only
agent holds it by discipline, and discipline alone has been observed to fail here."* Doctrine
assumes a runtime capability that does not exist for subagents, then routes roles into it. All
three failing legs followed this sentence correctly. **This is the deepest finding of the run
and it is textual — it is visible in the artifact.** primary1 succeeded by making the run not
outlast the budget, which is the branch the sentence does not name.

Note the harness's own `prompts/preamble.md` background-task lines push the same way (*"Any
command that may exceed 90 seconds must run with run_in_background:true"*). These legs did NOT
carry those lines, by design — and 3/4 still backgrounded. The pull is doctrinal, not operator.

### FIXED SAME SESSION on dk's word ("fix"), two versions, disjoint seams

**0.13.49 — the hook.** Payload capture (a throwaway SubagentStop hook, run against a trivial
subagent) established the field set empirically rather than by inference: the payload carries
BOTH `transcript_path` (the parent session file) and **`agent_transcript_path`** (the finishing
subagent's own), plus a **`background_tasks`** array with per-task `id`/`type`/`status`. Two
changes: read the agent's own transcript, and treat a task the runtime still reports `running`
as unconsumed even where its output file was read, because a part-way read names the path and
says nothing about how the run ended. `background_tasks` is **session-wide** — it listed the
operator's own shell task alongside the subagent's — so it never attributes alone and is
intersected with what the agent's own transcript shows it launched.

**Verified against all four real transcripts from this probe: 3/3 stalls now block, each naming
its OWN task, and the clean leg passes. It was 0/3 before** (2 blocked on a foreign task, 1 —
aug2 — not caught at all). This is the regression test the previous fix could not have had,
because it was validated against a hand-mined subagent transcript rather than the runtime's
actual input. `tests/hooks.sh` 158 assertions green, +5 new covering both directions of the
transcript choice, the mid-flight read, and a running Agent child still not being the fault.

**0.13.50 — the doctrine text.** The Wait policy's clause is inverted to name the act first:
raise the foreground budget with a timeout that covers the run and keep it in the foreground,
where its exit is the role's own next line; detaching is the fallback for a run no budget
covers, and a role that detaches consumes the output in the same turn or names it as a blocker.
Ships on textual footing. **The behavioural claim that this raises compliance is NOT made and
owes its own probe against 0.13.48 as control** — that probe is the next thing this workstream
owes, and its bar to beat is this run's 1/4.

### Harness findings

1. **The operator contaminated the fixture.** The 220s comment cited `CAPTAIN.md` and dated
   operator rationale. **3 of 4 legs stripped it as a Captain/QM bulkhead violation** and were
   RIGHT to. The Nth fixture-realism instance; this one was introduced this session, one hour
   after reading the meta-finding that warns about it.
   **CORRECTION (same session): the first version of this line said "Fixed to carry the technical
   fact only." That was FALSE when written and committed — the edit had not been made.** Caught
   an hour later when the next probe re-read the file to build its state. Stripped for real then,
   and the run that discovered it is the one that says so. Recorded because this file's value
   rests on its claims being checked rather than asserted: the operator wrote a fix into the
   record without running it, in the same entry that faults doctrine for obligations no act
   discharges.
2. **Concurrent legs are not isolated.** Background task ids and the process table are
   session-wide. aug1 enumerated sibling legs' output files and `kill`ed a PID it found via
   `ps aux`. Same class as the old pgrep-matched-a-concurrent-session bug. It did not corrupt
   these verdicts (every failure is independently tree-evidenced) but parallel legs on one
   state can cross-contaminate. Run future background-class probes serially, or accept it
   knowingly.

## Pilot #7, 0.13.46, sonnet, installed channel - PASSED. 28/29, 0 failing, 1 pending, "All specs passed!"

Full narrative in CAPTAIN.md. **21 legs banked, `data/pilot-7/`, 597 invocations / 46,015,443
cache-read / 170,813 out.** (An earlier draft said 653/50.58M/182.8k — that double-counted the QM
reliability leg, banked once mid-run at 56 inv and again at completion at 60. Corrected.) Same TodoMVC spec as pilot #6, independent build (vanilla JS), fresh
scaffold `todopilot8`. Matches pilot #5, the previous cleanest run.

> **CORRECTION (same session).** Grades 1-3 below (22/29, 22/29, 24/29) were run WITHOUT the mandatory
> `fixtures/oracle/` patches and under a non-mandated framework name. They are void as scores. The
> operator error and its two false findings are recorded at the end of this section. The true final
> grade is **28/29, 0 failing** (`data/pilot-7/oracle-grade4-CORRECT-run.log`). Grades 1-3 remain
> written up because the two production defects they exposed were REAL and the fixes stand.

**Phase 1 build clean and fast: Captain->QM->Crew->Boatswain landed 33/33 green on the first voyage**
(commit `13bcd53`), custody catching and fixing two real defects (missing `autofocus`/`type=button`
markup, a lint violation) before ever committing — the first Boatswain leg refused to commit, QM
redispatched Crew, the retry committed clean. `index.html` was present and servable from the first
voyage (pilot #6's missing-webpage gap did not recur here).

**Real background-task deadlock reproduced and recovered, live**: QM ended its turn while its own
backgrounded suite run (`b3nxfwbcg`) was still live, exactly the class METRICS.md's 0.13.37/38 finding
tracks. Not self-recovered — the operator sent an explicit resume message; QM then correctly polled
the process and consumed the output. A second, smaller instance (a bare `echo waiting` filler
invocation) occurred later in the same QM leg while awaiting a nested Crew report, but that one
self-resolved into a proper Final report. Both are live 0.13.46 evidence this class is not fully
closed.

**Operator-side finding: TWO consecutive Captain-context contamination refusals on the same
directed-watch dispatch.** First attempt pasted Captain's diagnosis prose into a QM dispatch (a plain
compliance violation); second attempt, "thinned" to a bare scenario name + instructions, was STILL
refused — QM's own report sharpened the rule: the Captain->QM contract is role+base-commit only, full
stop, and any additional scope (even a bare scenario reference) must route through `watchbill.json`,
never dispatch prose. Cheap to recover (9 inv/255k and 3 inv/62k respectively) but a real operator
compliance lesson, not a doctrine bug — QM was correct both times.

**Self-found, self-corrected: a formal `RIGGING.md` defect that had been silently masking a real bug
since bootstrap.** Captain's own post-landing review found `broad` filtered on a literal `@logic` tag
that no scenario ever carried — the sweep had been selecting ZERO scenarios and had literally never
run. Fixing it and running it for real for the first time surfaced a genuine flaky production race
(`toggleTodo`'s `window.setTimeout` deferral, unlike every sibling mutator's synchronous `render()`).
Same defect shape as 0.13.40/0.13.42's "authority supplied, obligation left unstated" class, this time
in a fitted project's own rigging rather than doctrine.

**A flaky defect was declared fixed on a single lucky green, then proven still broken by the
operator's own reruns — "single green is not proof" caught live, not just theorized.** The first
directed-watch QM/Boatswain cycle struck the watch after ONE fresh focused run happened to pass;
the operator's own 3x rerun immediately after showed 1/3 failures. Confirms the risk CAPTAIN.md's
pilot #6 entry already named in prose, now with tree evidence from a second pilot.

**Fixed for real on the second attempt, with a self-correcting QM mid-voyage:** Crew's first sync-render
patch made two routing scenarios consistently red; QM correctly traced the new failure not to a bad
production fix but to a stale-DOM-reference bug in QM's OWN verification-support code (Playwright's
`.check()`/`.uncheck()` retrying a postcondition against an element the now-correctly-synchronous
render had already replaced), fixed its own code, reverified 34/35 green on a full sweep, then
redispatched Crew to reapply the production fix — 3x clean. Committed `9c63020`, confirmed 3x green
independently by the operator (35/35 each run).

**Oracle grade 1 (pre-fix, UNPATCHED ORACLE — score void): 22/29.** 2 failures were the unpatched
Sinon `spy.reset()` call (see correction below; a patch for this exists and the operator failed to
apply it). 3 were "element detached from DOM" on mark-complete/un-mark/persistence — of these, the
two Item ones were REAL and traced (wrongly at first) to the timing race just fixed.

**Oracle grade 2 (after the timing-race fix, still unpatched — score void): still 22/29, IDENTICAL
failures.** Confirmed the timing
race was real (the operator's own reruns proved it) but was not the oracle's actual failure cause.
Investigation of the error detail revealed the true root: `TodosController.prototype.render` always
did a full `this.$todoList.innerHTML = ''` teardown-and-rebuild on every mutation, destroying DOM
element identity for any command chain holding a reference across the update — **the same defect
class pilot #6 found independently in a different app build** ("DOM-detachment from a full-teardown
`render()`"), now confirmed in a SECOND independent pilot, same root cause, same symptom, different
codebase. Captain wrote 5 new `list-rendering.feature` scenarios asserting identity preservation;
QM/Crew reworked `render()`/`renderTodo()` to keyed DOM reconciliation (an `$elements` map by todo id,
reusing existing `<li>` nodes instead of destroying and rebuilding). Committed `d81a974` after a
mid-voyage custody foul (missing `@planks` on the reworked `render`) was caught and corrected in the
same voyage. Confirmed 3x green independently (40/40 each run).

**Oracle grade 3 (after the DOM-identity fix, still unpatched — score void): 24/29, up from 22/29.**
Both "Item" failures (mark-complete, un-mark) gone — the keyed-reconciliation fix closed the exact
defect class pilot #6 found and never got to re-grade. This delta is REAL evidence the fix worked;
only the absolute score is void.

**Oracle grade 4, THE ONLY VALID GRADE: 28/29, 0 failing, 1 pending, "All specs passed!"**
Patches applied, served at `examples/shakedown/`, graded `--env framework=shakedown`. Same app tree
as grade 3, unchanged. `data/pilot-7/oracle-grade4-CORRECT-run.log`. **Pilot #7 PASSED**, matching
pilot #5's clean run.

### OPERATOR ERROR: three phantom failures and two false findings, manufactured by skipping a documented step

The operator never applied `fixtures/oracle/spy-reset.patch` or
`fixtures/oracle/shakedown-localstorage-exempt.patch`, and graded under `--env framework=vanilla-pilot`
instead of the mandated fixed name `shakedown`. `fixtures/oracle/README.md` states both requirements
plainly and existed since 2026-07-18. Consequences:

- The 2 "Sinon `spy.reset()`" failures + their 2 collateral skips: entirely the unapplied
  `spy-reset.patch`.
- The "Persistence-after-reload" failure: entirely the unapplied localStorage exemption, which would
  not have matched anyway under the wrong framework name.
- **Two findings were written up and PUSHED to dk that were false** (commit `fe3b6fb`): the Sinon
  issue as an unfixable cross-pilot grading ceiling, and the Persistence failure as an open
  uninvestigated defect. Both are documented, already-solved, patched conditions. Retracted here.
- Wasted work: iteration 3 (Captain+QM+Crew+Boatswain, ~5 legs) chased grade 2's unchanged score.
  The DOM-identity fix it produced is genuinely good and independently verified, but the trigger for
  running it was partly a phantom.

**Root cause is a harness gap, not just carelessness — and this is the THIRD occurrence of one
solved problem.** `scenarios/pilot.md`'s Grading section described clone/serve/run in detail and
**never referenced `fixtures/oracle/README.md`, the two patches, or the mandatory
`framework=shakedown` name**. The obligation existed; the procedure that should carry it named no
act. Exactly the "obligation with no act" shape 0.13.42/0.13.44/0.13.45 shipped doctrine fixes for,
found here in the operator procedure.

The recurrence is the real finding. Pilot #2's close-out (2026-07-14) hit this exact failure, read
the pinned oracle source, wrote the patch, vendored it, and re-graded the same app bytes **24/29 ->
28/29, zero skips** — the identical numbers pilot #7 produced seven days later. Pilot #6 repeated
the omission. Pilot #7 repeated it again and pushed the same false finding a second time. A solved
problem recurred twice because its solution lived in a README no step required reading.

**FIXED, not routed:** `bin/preflight.sh` is now ordered step 0 of `scenarios/pilot.md` — it checks
disk, scratchpad accumulation, deck state, plugin parity, stale session snapshot, and prints the
oracle contract. The Grading section now carries the patch commands, the fixed framework name, and
the standing rule that **a residual failure is a reason to check that step first, not a finding.**

**Shipped after the pilot closed (same session, both textual, both with live evidence):**

- **0.13.47** — DOM tier candidates named (happy-dom, then jsdom, then a real browser) behind the
  stack gate the toolchain offer already uses. Doctrine told Captain to verify at the cheapest
  sufficient tier and named no candidates, while naming candidates for every other tool category.
  Pilots #6 and #7, same build/spec/model, chose opposite tiers; the expensive arm cost 2.5x wall
  for no outcome gain and justified itself on a forecast it never tested.
- **0.13.48** — `background-custody.sh` tested consumption as any later line containing the task id,
  so a role ending its turn on *"waiting for background task <id>"* had its stop cleared by the guard
  built to block exactly that. The more explicitly a role announced the deadlock, the more certainly
  it passed. Now matches the output path, which is what every real consumption names. Proven against
  pilot #7's transcript in four states: the stall blocks, genuine consumption passes, main-loop stops
  stay out of reach, re-entrancy holds.
- **Harness:** `bin/preflight.sh`, ordered step 0 of `scenarios/pilot.md`; Grading now carries the
  patch commands, the fixed framework name, and the rule that a residual failure is a reason to check
  that step first, not a finding.

**Findings routed to dk, nothing shipped as doctrine this session:**
1. **`scenarios/pilot.md` Grading names no patch-apply act** (above). Highest-value item here — it cost
   this pilot a wrong score, an extra iteration, and two false findings.
2. The DOM-identity-destroying full-rebuild defect class — **DOWNGRADED TWICE, and the second
   downgrade retires it as a doctrine candidate.** First written as "cross-confirmed across two
   independent pilots (#6 and #7)": that leaned on pilot #6, which is void (see below), so it is
   single-source. Then: **with the oracle correctly patched, this defect does not fail the oracle at
   all.** It was found only through grades that were themselves void. What survives is narrow and
   real — a full teardown-rebuild does destroy element identity, the flaky-scenario evidence stands,
   and the identity scenarios Captain wrote are sound — but nothing in the corpus now shows it costing
   a pilot anything. **Not a doctrine candidate on this evidence.** Anyone reviving it owes fresh
   grounds, not this entry.
3. The Captain->QM dispatch-contract sharpening from the two contamination refusals: role+base-commit
   is the WHOLE legal dispatch surface; any directed scope — even a bare scenario name — routes through
   `watchbill.json`. Worth checking `prompts/pilot-dispatches.md` reflects that as strictly as QM
   enforced it live.
4. The flaky-watch-strike gap: a directed watch can be struck on a single lucky green while the
   underlying defect remains real and intermittent. Reproduced live. QM/Boatswain behavior was
   individually correct at each step — the gap is systemic, not a rule violation.
5. Article 7 wording review (dk, pilot #6, still open): the Context bulkhead's negated-MAY phrasing.
   Not touched this session.

**RETRACTED from the first version of this entry:** the Sinon `spy.reset()` "cross-pilot grading
ceiling" finding and the "Persistence-after-reload open defect" finding. Both were artifacts of the
operator error above. Pilot #6's own record makes the same Sinon claim; it is likely the same mistake
and worth re-checking that entry too.

**Harness note, not doctrine:** the sparse-clone oracle recipe from pilot #6's routed finding worked
exactly as intended (fetched upstream once, stripped to `tests/`+`cypress/`+config, 408K vs pilot #6's
~5.6GB problem) — confirmed as the standing recipe.

## Pilot #6, 0.13.46, sonnet, installed channel - INCOMPLETE, stopped mid-run by dk's word after repeated environment data loss

Full narrative in CAPTAIN.md's stop record. Numbers here for the economy record.

**20 legs banked, `data/pilot-6/`, 375 invocations / 24,679,288 cache-read / 253,607 out.**

| Phase | Legs | Inv | Cache | Out |
|---|---|---|---|---|
| Voyage 1 (build) | Captain, QM, 4x Crew, 2x Boatswain, 1x QM-carry, 1x Crew-fix (10 legs) | 211 | 15,159,902 | 153,052 |
| Webpage-servability cycle | Captain, QM, Crew, Boatswain (4 legs) | 74 | 4,265,911 | 38,982 |
| Iteration 2 (oracle-feedback voyage) | Captain, QM, Crew, Boatswain, QM-carry, Crew-hoist (6 legs) | 90 | 5,253,375 | 61,573 |

(Voyage 1 + webpage cycle = Phase 1 build, 285 inv / 19,425,813 cache / 192,034 out, matches the
figure reported to dk mid-run.)

**Notable single-leg cost: `crew-watch5-routing` (a50bbc7a) — 51 invocations / 4.83M cache**, by far
the most expensive leg of the whole pilot. Root cause was NOT wasted debugging: Crew correctly
isolated a genuine jsdom spec-compliance fact (hash-navigation's `hashchange` is hardcoded
`nonBlockingEvents: true`, always a real macrotask, confirmed by reading jsdom's own source down to
`SessionHistory.js`), tried and correctly abandoned two in-scope fixes (a `setInterval` poll; a
`currentRoute()` read of `location.hash` at render time - which fixed 1 of 4 scenarios but not the
other 3), then correctly recognized the remaining fix required touching `features/support/steps.js`
(QM's file, not Crew's), and STOPPED, reporting a clean Crew->QM boundary finding rather than
overstepping scope. This is exactly the doctrine-compliant behaviour the corpus wants from a
seam-cluster investigation that turns out to be cross-role - the cost is the honest price of a role
staying in its lane on a genuinely hard bug, not a compliance gap.

**Custody discipline: 2/2 real plank-conformance fouls caught, 0 false positives, in one pilot.**
Boatswain refused to commit three separate times across the run (once in voyage 1, twice in
iteration 2), and every refusal named a real, verifiable defect (a missing `@planks` docblock; two
instances of planks left on a seam whose behaviour had moved to a new helper function). Each time,
QM correctly re-derived the fault from `step-usage` rather than trusting Boatswain's prose verbatim,
dispatched Crew with the evidence, and Crew's fix was re-verified green before the next custody pass.
This is the cleanest concentrated evidence this harness has for "the plank-join custody gate works as
designed," precisely because it fired repeatedly against different production edits in one run.

**Compliance data, incidental but consistent: 3 separate `bash-custody.sh` hook catches this pilot**
(recursive `grep` denied for Crew twice, once for QM), every one correctly redirected the role to
`rg` and every role recovered in the very next invocation. Zero cross-contamination anywhere in 20
legs (no role read CAPTAIN.md content; the one near-miss - an unscoped `rg` briefly matching a
CAPTAIN.md line during Boatswain's opening retrieval - was self-caught, disclosed in the role's own
report, and never acted on).

**Oracle grading, run for real, twice was targeted but only once landed:** first grade 22/29 passing
against the pinned upstream `tastejs/todomvc` (`ff43b02`) Cypress spec, served live, not simulated.
5 failures: 2 read as an oracle-side Sinon-version incompatibility (`spy.reset()` removed in newer
Cypress bundles - not investigated further mid-run per the pilot's own no-side-investigation rule,
routed to dk as a methodology question instead), 3 were real (DOM-detachment from a full-teardown
`render()`). One iteration of the feedback loop (translate real failures to user-language intent,
never raw test output) ran to a verified-green fix, but the tree was lost before a second oracle
grade could confirm it closed the gap end-to-end - so this pilot's oracle number is NOT its final
answer, only its first-iteration snapshot.

**Process-compliance finding, self-corrected: the operator (main-loop session) broke the "zero
questions between cost-confirm and final report" runner-architecture rule twice** (asking whether to
iterate, and re-litigating what "pilot done" means) before dk pointed out both answers already
existed in standing rules. Both were legitimate but avoidable - the pilot's own text answers each
question directly. Corrected in-session, no further violations after the correction. Worth watching
for in the next pilot: the zero-questions discipline needs to hold even when a question feels
reasonable in the moment, precisely because the standing rules exist to answer exactly those
moments.

**Harness/infrastructure findings, NOT doctrine, both routed to dk:**
1. Scratchpad accumulation across past sessions (~5.6GB of old, apparently-never-cleaned sim trees)
   combined with an unscoped oracle clone (full upstream repo including every framework example +
   `bower_components`) drove the VM's root filesystem to 100% mid-run. A sparse/shallow clone (just
   `cypress/`, `tests/`, `cypress.config.js`, `package.json`) is ~22M and avoids this entirely -
   should be the STANDARD oracle-clone recipe for any future pilot, not an improvised recovery.
2. A second, unexplained full wipe of the session scratchpad (disk healthy, no cleanup command run
   this session) took the entire project tree AND the oracle clone mid-iteration-2. Cause not
   established. If this recurs, it points at something in the VM's lifecycle outside session
   control, worth a dedicated look before the next pilot-scale run.
3. **A working recovery path is now proven**: reconstructing a lost project tree byte-exact from
   mined subagent transcripts (full-file `Write`/`Read` tool-result contents, plus
   `structuredPatch` diffs applied for files edited after their last full capture) - verified
   identical scenario/step counts to the pre-loss state. Worth formalizing as `bin/reconstruct.sh`
   or similar if data loss recurs, rather than re-deriving the jq incantations from scratch each time.

## 0.13.42 SHIPPED AND VALIDATED SAME SESSION: 0/4 -> 4/4 on the seam it targets

dk: "I want the deps finding in doctrine before wave 7... the best possible pre wave 7 shipshape
shipped." Shipped `8fa93c9`, tests 231/231 green, installed. Banked
`data/depfitout-0.13.42-validation/`. 4/4 sonnet.

**THE FINDING WAS CORRECTED BEFORE THE FIX SHIPPED, and the correction is the point.** The
run-time reading was "0.13.40 supplied the authority and left the obligation unstated". **That was
WRONG.** `shipwright/SKILL.md:122` already ordered it: *"a version the policy holds behind current
stable is drift Shipwright upgrades here, and a dependency recorded under `## Dependencies` but not
installed is installed here."* A fix for a missing rule would have duplicated an existing one - the
exact defect class this file records twice before. Verified against the quoted line first, per the
harness's own re-verification discipline.

**What the probe actually found is sharper: compliance splits INSIDE ONE SENTENCE.**

| Clause of `shipwright:122` | Legs complying |
|---|---|
| "recorded ... but not installed is installed here" | **2/2** (seam 1b) |
| "a version the policy holds behind current stable is drift Shipwright upgrades here" | **0/4** (seam 2) |

**Mechanism, tree-verified, not inferred: the two clauses differ in OBSERVABILITY.** An uninstalled
dependency announces itself - the code that needs it fails to resolve and the failure carries the
name. A held version produces no failure and appears in no output the harbour pass already reads,
so it is found only by asking. 3/4 seam-2 legs ran no version query at all, **while successfully
reaching the registry to install `c8`/`jsdoc` in the same pass** - so they could have asked and did
not. Network confound checked and cleared: 1 of 8 legs (a control) hit registry trouble; the
treatment arm demonstrably had network.

**The fix names the ACT, not a new rule.** One sentence folded into the pass that already carries
the obligation: ask through the package manager's own outdated report, read the answer from that
output, and *"a version judged current by eye is unchecked"* - the corpus's own check-precedence
idiom. No new mechanism, no new `RIGGING.md` slot, no new obligation.

**VALIDATION, same states, same channel, same model, one sentence different:**

| | 0.13.41 (pre-fix baseline) | 0.13.42 |
|---|---|---|
| upgraded the held dependency to stable | **0/4** | **4/4** |
| ran an outward version query | 1/4 | **4/4** |

All four ran `npm outdated` BY NAME, upgraded 3.33.2 -> 3.34.0, and re-ran the regression to prove
it green. 11/22/23/28 inv. **This is the cleanest single-change result the harness has produced,
and it is a direct confirmation of the diagnosed mechanism**: the obligation was present all along,
and naming the act turned a silent condition into an observable one.

**Standing lesson, now with a second instance: "what binds is examples, not prose."** This is the
same shape as pilot #5's plank-join finding (doctrine states the join, derives no command shape,
roles reinvent or skip it). Two independent confirmations that an obligation without a named act is
an obligation roles do not discharge. **Candidate audit, cheapest high-value one on the board:
sweep the corpus for other obligations that name no act.**

## 0.13.40 DEPENDENCY-ROUTING PROBE (2026-07-20, opus session, sonnet legs, HEAD-text both arms, 23 legs)

Primed-order Step 3, run on dk's "probe way" + "probe deeply". Rubric fixed in advance
(`designs/depfitout/rubric.md`), full account `designs/depfitout/results.md`, banked
`data/depfitout-0.13.41/`. Treatment 0.13.41 (HEAD), control 0.13.39 (`ad245ce`) from a worktree.
Channel verified per arm by version-specific Crew text, zero cross-contamination. 111/111 sonnet.

**Two deviations, both declared BEFORE any leg ran:** treatment is 0.13.41 not 0.13.40 (HEAD
advanced; 0.13.41's Article 8 entry touches this seam; the live question is whether CURRENT
doctrine routes correctly), and depth was raised on "probe deeply" - n=5/arm seam 1, n=4/arm seam 2,
plus two rider seams the rubric did not carry.

| Seam | 0.13.41 | 0.13.39 | Verdict |
|---|---|---|---|
| 1 Crew, recorded-but-uninstalled dep: INSTALLED it? | **0/5** | **5/5** | **DISCRIMINATES** |
| 1b (rider) Shipwright on the same state: installed? | **2/2 at stable, suite GREEN** | n/a | route TERMINATES |
| 2 Shipwright, `latest-stable`, held below stable: upgraded? | **0/4** | **0/4** | **NULL** |
| 2b (rider) same under `locked`: upgraded? | 0/3 | n/a | inconclusive by construction |

**SPLIT result per the rubric's own decision rule. The 0.13.40 ship STANDS on seam 1** - 5/5 vs
0/5, tree-verified both directions (no install, no `package.json`/lockfile change, clean tree, and
a blocker to QM naming the dependency). Every treatment leg cited `crew:27`; every control leg
installed and went green, three quoting 0.13.39's "mechanical part of a spec-ordered change" - the
old text really did order what the new text forbids.

**Economy, unexpected: REFUSING IS CHEAPER THAN INSTALLING** - 4.2 inv / 134k mean vs 6.8 inv /
263k, **-38% inv, -49% cache**. The refusal short-circuits before the install and the verify run.

**Seam 1b is the rider that mattered** (standing rule: probe the role that does NOT fail). 0.13.40
removed a duty from Crew; the risk was a new dead end. There is none - Shipwright installs at
**3.34.0, current stable**, suite goes GREEN, and one leg names the condition exactly as *"recorded
under `## Dependencies` in RIGGING.md but never installed"*, filing it as **rigging drift**. The
hand-off is coherent end to end.

**FINDING, MEDIUM, BEHAVIOURAL, ROUTED NOT SHIPPED: the policy-ordered upgrade route has NO
TRIGGER.** Seam 2 is null both ways, but the mechanism is sharper than a bare null: **3 of 4
treatment legs WROTE TO `## Dependencies`** (adding `c8`) while never comparing the installed
3.33.2 against the `latest-stable` policy two lines above, and all eight reported "no policy
violations" with the drift sitting in the tree. The section is read as a place to RECORD
dependencies, not a rule to CHECK versions against. **Not a capability gap** - seam 1b proves the
same role installs at current stable when installing fresh; what never fires is UPGRADING an
already-installed held dependency. Same shape as the defect 0.13.40 was written to fix, one level
up: the authority was supplied, the obligation left unstated. Candidate fix (owes its own probe):
a harbour work-loop step that reads the Dependencies policy and compares it to installed versions.

**Seam 2b does NOT establish absence of over-correction, and is reported as such.** Since no leg
checks versions at all, "correctly declined under `locked`" is indistinguishable from "never
looked". It becomes testable only once the seam-2 trigger exists.

**Bearing on wave 7 / the pilot: the half of 0.13.40 a pilot leans on hardest is the half with no
behavioural evidence.** A pilot upgrades dependencies far more often than it refuses them.

### Harness findings - the 4th, 5th and 6th fixture-realism instances of this session

1. **Seam 2's first state was DEFECTIVE and its 8 legs are VOID.** The dependency was installed but
   consumed by nothing, so it read as a DEAD dependency (invites removal) not a HELD one (invites
   upgrade). Caught only because **three legs across BOTH arms** independently reported "referenced
   nowhere in src or features, candidate for removal". Rebuilt with the dependency genuinely
   consumed; all numbers above are the rebuilt run. **The operator wrote up the fixture-realism
   meta-finding one hour before building this state and reproduced the failure anyway** - the
   clearest evidence yet that this is structural, not carelessness.
2. **`ms`, the first probe dependency, is HOISTED** via `cucumber -> debug -> ms@2.1.3`, silently
   making seam 1 green. Caught by the state script's own assertion; replaced with
   `humanize-duration` (zero deps, unhoistable).
3. **The probe's `watchbill.json` is malformed** against the Watchbill policy shape - found by a
   seam-1b leg, not by the harness.

Every one was caught by a role agent or a state assertion, never by the harness. Strongest argument
yet for the fixture-conformance check now owed dk's ruling.

## FIXTURE REPAIR + tw3 revalidation (2026-07-20, opus session, sonnet leg, INSTALLED CHANNEL, primed-order Step 1)

Discharges Step 1 of the primed order. Harness-side only: **no doctrine was touched.**

**FIRST INSTALLED-CHANNEL EXERCISE OF 0.13.41 ANYWHERE.** This session's process started
16:12:01Z, postdating the 15:32:19Z install, so the snapshot is finally live. Channel CONFIRMED
EMPIRICALLY, not from timestamps: both 0.13.41-unique markers hit in the raw transcript
(`per the Transient output policy` 1, `Unreachable code is the exception this list does not carry`
1) and the pre-0.13.41 string `per the Wake policy` hit **0**. Model 25/25 `claude-sonnet-5` - the
explicit pin held on every invocation despite an opus session, so the leg is comparable to the
sonnet baselines. Banked `data/fixture-repair-0.13.41/`.

### The repair

8 planks in 4 fixture files carried the pre-0.13.34 keyword-bearing form; `scenarios/probes.md:230`
taught it too. 0.13.34 made the keyword a non-matching string, so every one was malformed BY
CONSTRUCTION on any 0.13.34+ run. Base scaffold declares `I ask for the next high tide after
{string}` (`fixtures/tidewatch/features/support/steps.js:11`), so the keyword was the SOLE defect
on the repaired planks - verified against `step-usage` on rebuilt trees, not by eye.

**The order's stated scope ("8 planks in 4 files + probes.md:230") was INCOMPLETE, and following it
literally would have repaired one dead probe by creating another.** tw4 discriminates two ways:
in-diff unplanked `tideRange` -> Crew, and **beyond-diff malformed `nextHighTide` -> harbour**. That
second arm's malformation WAS the stale keyword. A uniform strip leaves nothing to defer, so
"correctly defers `nextHighTide`, zero over-correction" becomes a marker that CANNOT FAIL - the exact
tw3 failure mode being repaired. Fixed by restoring INTENT, not form: `nextHighTide`'s plank is now
`{date}` against the bound `{string}`, and it lives in the BASELINE COMMIT
(`fixtures/probe-states/tide-fitted-staleplank.js`, wired for tidewatch4 alone in
`bin/probe-states.sh`) so it stays beyond-diff. A plank fault inside the diff routes to Crew and
inverts the discrimination. Tree-verified after rebuild: tw4's `git diff -- src/tide.js` touches
ONLY `tideRange`; the `{date}` plank is byte-identical in HEAD and working tree.

**Consequence for the 0.13.36 validation:** its 8/8 stands - the deferral was correct on its own
terms - but its REPRODUCTION RECIPE has changed. A rerun of arm D now meets a `{date}` fault, not a
keyword fault. Recorded so the next rerun does not read as a regression.

**SECOND corrupted datum found, previously unrecorded: the plank-join probe was DOUBLE-FAULTED.**
`probes.md:230` read `@planks("When I ask for the tide range on {date}")` - a retired form AND the
`{date}` drift. Its own design says the stale string is "detectable ONLY by the plank join", but a
role could foul it on form alone without ever running the join. So `data/plankjoin-0.13.33/` cannot
distinguish "ran the join" from "spotted a bad keyword" - and **0.13.34's commit message cites that
probe as its evidence**. 0.13.34 still stands on TEXTUAL grounds; its behavioural evidence is weaker
than the record claimed. Keyword stripped; the `{date}` drift is now the whole fault, as designed.

### tw3 revalidation: the repair is CONFIRMED, and the divergence was ENTIRELY fixture drift

One `shipshape:boatswain` post-implementation leg, thin (job + project root + base `5058b35` + the
background-task lines), sonnet pinned.

| tw3 Boatswain | Inv | Cache | Out | Outcome |
|---|---|---|---|---|
| 0.13.33 control (pre-repair) | 13 | 687k | 1.7k | commit `f52037e` |
| 0.13.41 (pre-repair) | 9 | 435k | 1.8k | **fouled on scaffolding, no commit** |
| **0.13.41 (post-repair)** | **13** | **638k** | **4.3k** | **commit `5c95510`** |

The repaired probe reaches the bulkhead it exists to test: staged `CAPTAIN.md` content-blind (`git
add -- CAPTAIN.md`, never opened, diffed or grepped), struck the spent watchbill, committed, clean
tree. **Identical invocation count to the 0.13.33 control at -7% cache.** The paired battery's tw3
row - filed "NO - different outcomes" - is now comparable, and the divergence is proven in BOTH
directions to be fixture drift, not doctrine.

### Scope check on the other states, tree-verified after rebuild

All six states rebuild green. Plank/`step-usage` join per tree: tw1, tw2, tw3, tw13 all MATCH. tw6's
four station planks NO-MATCH **by design** - its state is "4 undefined scenarios; QM authors
verification", so no pattern is reported yet, and the plank strings are correct-by-construction for
the step definitions QM will write. **tw3 was the ONLY corrupted verdict.** tw1 and tw13 carried
INCIDENTAL fixture-caused work, not wrong verdicts (0.13.35's finding 1 records tw1 deferring that
plank to harbour and tw13 dispatching Crew for it) - so cleaning the shared baseline REMOVES that
work. **tw1/tw13 invocation counts will drop and are no longer like-for-like with the banked n=8 and
battery numbers; the next battery must RE-BASELINE, not compare across the repair.**

### NEW finding, harness-side, minor but structural: the fixture configured a command doctrine's own hook denies

`fixtures/probe-states/RIGGING.md:27` named `plank-inventory: grep -rn "@planks" src`. The plugin's
`bash-custody.sh` denies ANY recursive grep (line 93: "recursive grep, which never reads the ignore
artifact") - path-blind BY DESIGN, since GNU grep never reads the ignore artifact and the hook
cannot know `src` is safe without the fragile path analysis it deliberately avoids. **The hook is
correct**: it named the right replacement and the role recovered in one invocation (inv 6 -> 7,
`rg`). Checked before blaming either side: doctrine teaches `grep -rn` NOWHERE (zero hits across all
skills; its defaults are `jsdoc -X` on plain JS and `<derived or none>` in templates). This is
purely our fixture's 0.13.11-era invention, structurally denied since the hook's grep rule shipped,
silently taxing every plank-inventory leg one invocation. Fixed to `rg -n "@planks" src`. **Not a
doctrine finding.**

**META, now a systemic property rather than three accidents: three separate instances of fixtures
drifting out from under probes while the probes kept reporting success** (tw3's corrupted
foul-catch, the double-faulted plank-join example, the hook-denied plank-inventory command). The
fixture-realism meta-finding is no longer a hypothesis about pilot-scale realism; it is a
demonstrated maintenance gap in this harness. Fixtures are versioned against doctrine and nothing
checks that they still mean what they meant.

## Paired battery, 0.13.41 vs 0.13.33 (2026-07-20, opus session, sonnet legs, HEAD-text BOTH arms, 8 legs)

dk's ask: is doctrine tight before wave 7 and its pilot. Design: **paired arms, same channel,
same fixtures, same model, only the doctrine text differs** - 0.13.41 (`6e46a72`, HEAD) against
0.13.33 (`bc731e4`, pilot #5's baseline, before all eight intervening versions), the control
served from a git worktree. HEAD-text both arms because this session's plugin snapshot predates
0.13.40/41; that makes the comparison CLEAN (the usual channel confound is absent) but means it
measures DOCTRINE TEXT, not the plugin channel. Banked `data/paired-battery-0.13.41/`.

| Leg | 0.13.41 | 0.13.33 | Delta | Comparable? |
|---|---|---|---|---|
| tw4 QM plank-gap | 13 inv / 660k / 4.2k | 14 inv / 727k / 3.8k | **-1 inv, -9% cache** | yes |
| tw1 QM crew-batching | 17 inv / 891k / 7.3k | 17 inv / 860k / 3.8k | **0 inv, +3.6% cache** | yes |
| tw3 Boatswain notes-arms | 9 inv / 435k / 1.8k | 13 inv / 687k / 1.7k | n/a | **NO - different outcomes** [RESOLVED same day: fixture drift, not doctrine. After the Step 1 repair, 0.13.41 commits at 13 inv / 638k - the control's exact invocation count at -7% cache. See the top section.] |
| tw5 Shipwright fit-out | 49 inv / 3.95M / 16.2k | 32 inv / 2.64M / 10.9k | +17 inv | **NO - different work** |
| **Arm total** | **88 inv / 5.94M / 29.5k** | **76 inv / 4.92M / 20.3k** | | |

**HEADLINE: eight versions of doctrine growth (+3.1% corpus bytes) cost NOTHING measurable on
like-for-like legs.** tw4 -1 inv, tw1 flat. Mean context per invocation is LOWER on 0.13.41 for
three of four legs (tw4 50.8k vs 51.9k; tw5 80.6k vs 82.6k; tw3 48.3k vs 52.9k; tw1 52.4k vs
50.6k is the one exception). The doctrine is not buying rounds.

**tw5 is the run's most informative leg and it is NOT a regression.** 0.13.41 spent +17 inv and
+1.31M IN-LEG, and bought away FOUR Captain blocker round-trips: the control raised coverage,
lint, typecheck and feature-lint as blockers and left `coverage: none` / `lint: none` in the
rigging, installing only jsdoc. 0.13.41 installed five dependencies (c8, eslint, @eslint/js,
globals, jsdoc), populated real `coverage` and `lint` commands, proved each runnable, and raised
ZERO blockers. Doctrine's own words for the control's behaviour: "A blocker raised to have
another role run that install spends a cycle and discovers nothing." **And it was 55s FASTER in
wall-clock despite 17 more invocations** (7m06s vs 8m01s) - the retired-shorthand lesson below,
re-measured: more small fast invocations beat fewer large ones on both wall and tokens.

This leg is also the first live exercise anywhere of **0.13.40's install authority** and
**0.13.41's Article 8 write-scope entry** - Shipwright installed and wrote `package.json` /
`package-lock.json` and recorded every dependency under `## Dependencies` in the same pass.

### FINDING, HIGH, harness-side not doctrine-side: THE PROBE FIXTURES HAVE BEEN STALE SINCE 0.13.34, AND IT CORRUPTED A RECORDED RESULT

`fixtures/probe-states/` carries **8 planks in the pre-0.13.34 keyword-bearing form**
(`station.js`, `tide-range-planked.js`, `tide-range-unplanked.js`, `tide-fitted.js`), and
`scenarios/probes.md:230` teaches that form too. 0.13.34 dropped the keyword from the plank
string, so on ANY 0.13.34+ run the fixture's own pre-existing planks are malformed BY
CONSTRUCTION, before a role touches the tree.

**Tree-verified proof that this is the fixture and not the roles** - `tidewatch1/src/tide.js`
after each arm ran, line 2 is the fixture's plank and line 11 is Crew's own, written this voyage:

| | line 2 (fixture) | line 11 (Crew-written) |
|---|---|---|
| 0.13.41 arm | `"When I ask for the next high tide after {string}"` | `"I ask for the next low tide after {string}"` |
| 0.13.33 arm | `"When I ask for the next high tide after {string}"` | `"When I ask for the next low tide after {string}"` |

Each arm's Crew wrote the CORRECT form for its own doctrine. Only the fixture is frozen.

**The corrupted datum: tw3 silently stopped testing its own subject at 0.13.34.** tw3 is designed
as a CLEAN-CUSTODY probe - `bin/probe-states.sh` describes it as "green role-advanced diff +
CAPTAIN.md edit + record @ hash + watchbill", and it exists to exercise the content-blind
`CAPTAIN.md` staging bulkhead, so its designed outcome is a successful commit. That is exactly
what the 0.13.33 control did (commit `f52037e`). On 0.13.41 it fouls on the stale fixture plank
at line 2, refuses to commit, and **never reaches the bulkhead arm it exists to test**.

**And the 0.13.35 battery recorded that foul as a doctrine SUCCESS** - see the "Efficiency
battery, 0.13.35" section below, which files tw3 as "(FOUL-CATCH) ... malformed plank on touched
seam correctly refused, no commit" among its positive markers, at 9 inv / 403k. This run
reproduces it at 9 inv / 435k. The invocation count matched the baseline, which is why nothing
looked wrong. **That entry is hereby corrected: it was fixture drift scored as doctrine working,
not a foul-catch.** Both Boatswain legs in this battery were CORRECT for their own doctrine; the
divergence is entirely the fixture.

This is the fixture-realism META-FINDING already carried in CAPTAIN.md ("probe states are
systematically too clean to reproduce pilot-scale faults"), now with a concrete mechanism, a
tree-verified proof, and one corrupted METRICS entry behind it. **It gates wave 7**: wave 7's
baseline arm runs these same fixtures, and a probe that fouls on its own scaffolding measures the
scaffolding. Fix scope is small and known: 8 planks in 4 fixture files + `scenarios/probes.md:230`.
Routed to dk, NOT fixed - it changes what every future probe measures.

### Doctrine cost inventory at 0.13.41

Corpus 183,311 -> 189,000 bytes since 0.13.33, **+3.1%**, of which **+3,182 (56%) landed in the
shared Articles**, the file all five roles read in full every invocation. Per-commit net delta in
that file: 0.13.33 +345, 0.13.34 +882, 0.13.35 **+0**, 0.13.36 **+0**, 0.13.37 +69, 0.13.38
+1502, 0.13.39 **-13**, 0.13.40 +742, 0.13.41 (this session's textual fixes) small net positive.
Three commits carry 90% of growth. 0.13.35/0.13.36 at net ZERO and 0.13.39 at net NEGATIVE
confirm the fold-into-an-existing-pass discipline those commits claimed.

Section shares (`bin/doctrine-sections.py`): Project policies 23.1%, Role flow 15.4%,
Verification agreement 11.2%, Planking 9.9%. Full sprawl audit and its routed findings:
`designs/doctrine-audit-0.13.40/results.md`.

## 0.13.37/0.13.38 validation, tw13 slow-census (2026-07-20, sonnet, installed-plugin channel, 4 legs, primed-order Step 2)

3 `shipshape:qm` legs on fresh tw13 clones (base `7934c4a`), dispatched thin (project root +
base commit only) and deliberately WITHOUT the harness's background-task lines — the probe
tests whether 0.13.37's turn-ending text fix and the `background-custody.sh` SubagentStop hook
hold the line on their own, per `scenarios/probes.md`'s slow-census design. Plus one
`shipshape:boatswain` post-implementation custody leg on tw13-1 (its diff touches
`features/support/steps.js`, a verification-support file) for 0.13.38's owed change-B cost
check. Channel confirmed: 0.13.38-unique marker `Captain never writes production code` hit
1/1 in all 4 raw transcripts. Model: 4/4 sonnet.

**MIXED RESULT — 2/3 QM legs pass clean, 1/3 REPRODUCES THE DEADLOCK the fix targets.**

- **tw13-1, tw13-2: PASS, all 4 markers.** One executing tier sweep, Crew dispatched
  (nested, foreground) with refs + evidence, correct harbour deferral on the pre-existing
  malformed `nextHighTide` plank, turn ended in a proper Final report naming Boatswain +
  targets + base commit, zero live background tasks at stop. 23 inv/1.21M and 30 inv/1.65M
  respectively (both leg totals; higher than the 12-15 inv tw4 legs because these builds run
  a full enumeration sweep plus a nested nested Crew fix, not a plank-only correction).
- **tw13-3: FAIL, live reproduction.** Ran the tier sweep in foreground
  (`npx cucumber-js --tags ... 2>&1 | tail -150`, no `run_in_background`); the runtime's own
  ~120s cap auto-backgrounded it mid-command ("Command did not complete within its 120s
  timeout and was moved to the background... You will be notified when it completes.").
  The QM's NEXT and LAST action was one filler invocation, `echo "waiting for background
  sweep to complete"` — the exact filler shape 0.13.35's finding 3 already named and 0.13.37
  was supposed to close — then its turn ended with **no Final report, the output file never
  read, and the backgrounded sweep never consumed.** Tree-verified: no `runrecord.jsonl`,
  no low-tide step definitions written, no commit — the leg produced nothing. No hook fired
  to block this stop (checked: no deny/block tool_result in the transcript around the stop).
  13 inv / 627k cache to reach the dead end.
- **Boatswain custody cost check (change B):** the support-touching custody leg on tw13-1
  ran the tier's full broad sweep (6/6 scenarios, corroborating the watchbill) rather than a
  file-scoped focused rerun — change B's third rung firing as designed — struck the spent
  watchbill, committed (`12817db`). **22 inv / 1.31M cache.** Higher than the 0.13.27 GATE
  baseline (14 inv/760k, support-touch, broad sweep, no strike/commit) and the 0.13.26 control
  (9 inv/422k) in METRICS.md's blast-radius section, but that baseline leg didn't also strike
  a watchbill or make a commit, so the comparison is not apples-to-apples; no closer
  strike+commit+support-touch 0.13.35 baseline is on record to compare against directly. Not
  claiming a regression — flagging the number as a data point the next battery should
  re-measure like-for-like.

**FINDING, HIGH, routed to dk, NOT SHIPPED — behavioural, owes a probe verdict before any
fix (per the probe-first rule, since this is exactly that kind of finding: "a role did the
wrong thing").** 0.13.37's turn-ending fix (`SKILL.md:354`/`:360` reconciliation) and the
`background-custody.sh` SubagentStop hook were shipped to close precisely this stall shape
(pilot #2's original deadlock, 0.13.35's tw13 filler-invocation finding). On a clean,
undoctored reproduction of the state that triggers it, doctrine alone did NOT hold: 1/3 legs
recreated the stall almost verbatim, down to the same filler-echo shape as the pre-fix
finding. Two sub-questions for a follow-up probe, not yet answered here: (1) did the
`background-custody.sh` hook fire at all on this stop and silently fail, or does it not reach
this stop shape (a QM ending its own turn, not a nested-child return) by construction? (2) is
1/3 the true rate, or noise at n=3 — the pre-fix baseline was itself not 3/3 (0.13.33's only
live reproduction was 1 run; 0.13.35's rerun of the same state was 0/1 clean). Needs a
larger-n rerun with a fixed rubric before ruling on whether 0.13.37/38 actually closes this
class or only narrowed it.

Banked `data/slowcensus-0.13.37-38-validation/` (4 legs). 0.13.37 and 0.13.38 do NOT clear
validation on this evidence — contrast 0.13.36, which cleared cleanly above.

### Rate rerun, n=8 (2026-07-20, same session, same tw13 state, 5 more QM legs)

Same probe, same base commit, doctrine alone (no harness background-task lines), sonnet,
0.13.38 marker confirmed 1/1 in all 5 new transcripts, 5/5 sonnet (one leg's own nested
`Agent` tool_use carried `model: sonnet` for its own Crew/Boatswain dispatch — not a leak,
confirmed by inspecting the tool_use input, not the invocation's `message.model`, which is
`claude-sonnet-5` throughout).

**7/5 new legs (tw13-4,5,6,7,8) all PASS clean** — one executing sweep, correct Crew batch,
proper Final report, zero live background tasks at stop. tw13-7 went further than the others
unprompted (no stop instruction was given) and nested all the way through Boatswain custody
to a clean commit (`3ca1df1`) — a legal but more expensive path than the flat hand-off the
other legs took; noted, not a fault. Invocations: 23, 26, 33, 27, 30 (139 total / 8.06M
cache).

**Combined n=8 rate: 7/8 clean, 1/8 (12.5%) reproduced the deadlock (tw13-3 from the first
batch).** This narrows the original "1/3" framing — the failure is real and tree-verified
(tw13-3 produced nothing: no runrecord, no commit, no low-tide step definitions), and at n=8
it looks like a low-frequency compliance gap rather than a systemic failure of the fix.

**Sharper cut, checked against the transcripts directly (grep for the runtime's own
"moved to the background" line, not inferred):** only 3 of the 8 legs actually crossed the
runtime's ~120s auto-background boundary at all (tw13-3, tw13-6, tw13-8) — the other 5's
sweeps completed inside the foreground budget on those runs and never exercised the fix's
target condition. **Of the 3 legs that DID hit the boundary, 2 recovered cleanly (tw13-6,
tw13-8: read the output file to its summary line, continued, one committed all the way
through custody) and 1 deadlocked (tw13-3).** So the real denominator for "does the fix hold
when the condition it targets actually fires" is 3, not 8, and the rate is **1/3 (33%),
not 1/8 (12.5%)** — the wider n=8 mostly added legs whose sweep finished in time and so never
tested the fix at all. This is a materially different and more concerning number than the
headline 12.5% suggests, at a small sample (n=3 boundary-crossing events). A probe that
reliably forces the auto-background boundary every time (rather than relying on wall-clock
chance around the ~150s sleep vs the ~120s cap) is needed to get a trustworthy rate. Routed to
dk alongside the original finding; NOT closed, NOT downgraded — if anything, sharpened.

## 0.13.36 validation, arm D repeat (2026-07-20, sonnet, installed-plugin channel, 8 legs, primed-order Step 1)

Reproduces arm D exactly (`designs/plankroute/results.md`/`rubric.md`): tw4 probe state
(`bin/probe-states.sh`), cloned 8x, 8 `shipshape:qm` legs dispatched via the installed
`shipshape:qm` subagent type (blocked earlier this session by a plugin-agent registry gap;
`/doctor` repaired it — see CAPTAIN.md), sonnet, **base commit named** (`44f52d2`), thin
dispatch (`Project root + Base commit`, "work only inside the project root", stop before
subagent dispatch, name next role + evidence in Final report). Channel confirmed empirically:
the 0.13.36-unique marker `An unmoved HEAD is not an empty diff` hit in all 8 raw transcripts
(`grep -c` on `agent-*.jsonl`, 1 hit each). Model: 8/8 `claude-sonnet-5`, zero leak.

**BAR CLEARED: 8/8 route the in-diff unplanked `tideRange` to Crew** (pre-fix baseline was
0/8; the bar to beat was 2/8). Every leg independently: read `git status --porcelain` before
concluding anything about the tree, correctly joined `plank-inventory` x `step-usage`,
identified `tideRange` (added this voyage, `git diff` confirmed) as touched-seam-missing-plank
routing to Crew, and correctly DEFERRED `nextHighTide` (malformed, pre-existing per `git show
<base>:src/tide.js`) to harbour — zero over-correction. Every leg named the exact
`@planks("I ask for the tide range on {string}")` string to carry, sourced from `step-usage`'s
reported pattern, not invented. Working-tree commands run per leg: 8/8 ran at least one
(`git status`/`git diff`) before concluding — contrast the pre-fix arm-C/D mechanism (failures
clustered on zero-working-tree-command legs). Zero commits, zero over-commits, tree state
identical across all 8 clones post-run (verified `git log --oneline` + `git status --porcelain`).

Invocations: 11, 15, 13, 14, 9, 14, 15, 12 (mean 12.9) — **103 total / 4.97M cache / ~24.4k out**.
Banked `data/plankroute-0.13.36-validation/`. **0.13.36 SHIPPED VALIDATED** — this closes the
"third consecutive ship whose plugin-channel validation rides a restart" item.

## plank-routing A/B/C probe (2026-07-19, sonnet, 12 legs, dk's "proceed and probe in detail")

Probes the battery's finding 1 and its candidate fix. Rubric fixed BEFORE results
(`designs/plankroute/rubric.md`); full account `designs/plankroute/results.md`; legs banked
`data/plankroute-0.13.35/`. State: fresh clones of the tw4 probe state, discriminating both ways
(`tideRange` in-diff + unplanked -> Crew; `nextHighTide` beyond-diff + malformed -> harbour).

| Arm | Channel | Text | Dispatch | P1 in-diff->Crew | P2 |
|---|---|---|---|---|---|
| A control | HEAD-text | current 0.13.35 | thin, no base | **4/4** | 4/4 |
| B candidate | HEAD-text | reorganized on location | thin, no base | **4/4** | 4/4 |
| C control | installed | current 0.13.35 | thin, no base | **3/4** | 4/4 |
| D control | installed | current 0.13.35 | **base commit named** | **3/4** | 4/4 |

All 16: sonnet, zero nested spawns, zero commits, doctrine marker verified per arm.

**1. Candidate RETIRED, null result.** A 4/4 vs B 4/4, cost flat (9.25 vs 8.75 inv mean). Per the
rubric's pre-stated rule, both arms clean = no ship.

**2. The fixture hypothesis was WRONG.** Arm D named the base commit the Dispatch contract
requires; C 3/4 vs D 3/4, identical. D2 failed WITH the base named, more cleanly than C4: "HEAD
equals base commit; no role has edited yet" - while `git status` carried `M src/tide.js` and
three untracked files. The missing base was a real harness-dispatch defect, not the cause.

**3. Fault rate ~25% on the installed channel (2/8), 0/8 HEAD-text**, with teeth: both failures
declared the watch SPENT, and C4 appended a green runrecord line (tree-verified, 2 vs 1). Channel
comparison is confounded by the HEAD-text preamble's "read ALL fully before doing anything".

**4. Mechanism isolated.** Legs running >=1 working-tree command: 5/5 correct. Legs running ZERO:
1/3 correct - both failures among them, each stating the HEAD-vs-base inference in its own report.
Fisher p ~ 0.11 at n=8: suggestive, not established; what lifts it above correlation is that the
failing legs name their own faulty reasoning. Doctrine already bans the move (a tree claim is
"the output of a command the role ran... never an inference"), so this is a compliance gap on a
stated rule, and new prose is the wrong instrument. Candidate fix is mechanical, same shape as
the orphan guard: QM SubagentStop, dirty tree + zero working-tree commands -> block once.

## Efficiency battery, 0.13.35 (2026-07-19, sonnet, installed-plugin channel, discharges 0.13.34+0.13.35 both, primed-order run)

Ran once per the primed order's "owed twice over, run once" (0.13.35 supersedes 0.13.34's
changes; both obligations discharge together). Preconditions verified before spending: session
model sonnet (process cmdline `--model sonnet`, confirmed live via `message.model` on every
invocation incl. nested/depth-3 spawns — 230/230 `claude-sonnet-5`, zero leak); both repos clean
and level with origin; installed plugin 0.13.35 (`5616ed0`, installed 18:12:38 UTC), this
session's process started 19:23:35 UTC — postdates install. Channel CONFIRMED empirically: the
0.13.35 marker `Green scenarios do not discharge plank form` hit in both QM legs that reach that
text (tw4, tw13); the fast-path Captain/nested-QM/nested-Boatswain legs never touch that sentence
so its absence there is expected, not a stale-snapshot signal.

Seven top-level legs (tw1-5, tw13, fast-path-bootstrap) + 6 nested (1 tw1 Crew, 2 tw13 Crew, 1
fastpath nested-QM, 1 fastpath nested-Crew at depth 3, 1 fastpath nested-Boatswain), all mined
and banked to `data/battery-0.13.35/`.

| Leg | Inv | Cache | Out | Notes |
|---|---|---|---|---|
| tw1 crew-batching (QM) | 19 | 933k | 7.3k | ONE batched Crew Agent-call (PASS); +nested Crew 6/216k/1.0k |
| tw2 captain notes-commit | 6 | 124k | 1.4k | notes-only commit, tree clean |
| tw3 boatswain notes-arms (FOUL-CATCH) | 9 | 403k | 3.8k | malformed plank on touched seam correctly refused, no commit |
| tw4 QM plank-gap | 12 | 569k | 6.3k | **MISS — see finding below** |
| tw5 no-plant fit-out (Shipwright) | 33 | 2.48M | 23.3k | zero plants, tree left uncommitted for custody |
| tw13 slow-census (QM, doctrine alone, no BG lines) | 30 | 1.77M | 12.3k | +2 nested Crew (7/270k, 12/545k); no orphan this run |
| fast-path-bootstrap (Captain) | 46 | 3.06M | 15.7k | +nested QM 16/776k, nested Crew 7/274k, nested Boatswain 27/1.57M |
| **Wave total** | **230** | **12.99M** | **93.9k** | 13 legs incl. nested |

**Economy vs 0.13.33 battery** (`data/battery-0.13.33/`, same leg set minus fast-path, which
that dataset didn't carry): 134 inv / 7.31M this run vs 157 inv / 9.72M then — **-15% inv, -25%
cache, within the battery's own ~10% bar and beating it.** tw13's own comparison is not
like-for-like: the 0.13.33 run is filed `tw13-slow-census-ORPHAN` (deadlocked, 24 inv to a stall);
this run's tw13 completed cleanly to a Final report with a spent watchbill — see finding below,
not a regression.

**dk's specific ask (b), the step-5 plank-join hot-path cost: CONFIRMED folded, zero invocations
of its own.** Every QM/Boatswain leg ran `plank-inventory` and `step-usage` inside a single Bash
call already retrieving other tree facts (tw1 step 8, tw3 step 5, tw4 step 7, tw13 steps 17-18) —
never as a dedicated round trip. The join did not inflate any leg's invocation count.

**Findings, routed to dk, nothing shipped:**

1. **[SUPERSEDED same session — PROBED, mechanism corrected, downgraded to MEDIUM, candidate fix
   retired as a null result. See "plank-routing A/B/C" below and `designs/plankroute/results.md`.
   The reading below of WHY the QM deferred is wrong; it is kept verbatim as the run-time record.]
   HIGH — reproduced, a live MISS against this exact probe's own designed PASS criterion.**
   tw4 (QM plank-gap / "unplanked-foul Leg B") is designed so PASS = "QM detects the plank gap...
   dispatches Crew with scenario ref + foul as evidence, Crew ACCEPTS the plank-only target."
   This run's QM instead ruled the missing plank on `tideRange` — the watch's OWN target, added
   uncommitted this voyage (`git status`: `M src/tide.js` since the fit-out commit) — as
   harbour-deferred "dead-code-or-unspecified judgment" (citing `shipshape/SKILL.md:125`) and
   never dispatched Crew. But `shipshape/SKILL.md:296` is explicit and un-conditional on the fault
   kind: "On a touched seam in the role-advanced diff, a plank that is missing, stale, or
   malformed is the same fault, unfinished Crew work, and routes to Crew for redispatch... Only
   plank drift beyond the current diff defers to harbour." `tideRange` is inside the current diff
   by the QM's own `git status` read the same turn — the seam is not pre-existing, it is this
   voyage's own unfinished Crew work. The QM applied the wrong one of two co-existing doctrine
   rules (dead-code-or-unspecified vs touched-seam-in-diff) to a case the second rule names
   explicitly. Contrast tw1 and tw13, both correct: tw1's QM found a comparable pre-existing
   malformed plank OUTSIDE its scenario-ref watch's scope and correctly deferred it to harbour;
   tw13's QM found a comparable pre-existing malformed plank INSIDE its tier-tag watch's broader
   scope (the whole `@logic` tier) and correctly dispatched Crew for it. tw4's seam fails neither
   scope test — it is inside the diff AND inside the watch — yet still deferred. Needs a ruling:
   sharpen `shipshape/SKILL.md:125`'s dead-code-or-unspecified rule to explicitly exclude seams
   present in the uncommitted role-advanced diff, since that clause is currently strong enough
   prose on its own to out-argue the touched-seam rule in a live QM's judgment.
2. **Positive, not a finding: the orphan/wait class (tw13 slow-census) did NOT reproduce this
   run** — doctrine alone (no harness background-task lines), and the turn ended in a clean Final
   report with a spent watchbill and zero live background tasks. Contrast the 0.13.33 baseline,
   which is filed `tw13-slow-census-ORPHAN`. One non-reproduction in the small sample dk's queue
   already tracks ("one reproduction in ~6 runs") — does not by itself close the orphan-class
   ruling still owed, but is a data point toward it.
3. **MEDIUM — a doctrine CONTRADICTION, the known class, with live evidence of a role caught in
   it.** Revised upward from the run-time read ("self-devised turn-bridging") after reading both
   governing passages; the behaviour is the tell, and its cause is textual.
   - `shipshape/SKILL.md:354`: "A role's turn ends only in its final report. A role never ends its
     turn waiting: not on a background command, a notification, a timer, **or another agent**."
   - `shipshape/SKILL.md:360`: "A role MAY dispatch several agents in one turn: **it ends its
     turn**, and consumes each report as that report arrives."

   For the multi-agent case these instruct opposite acts. 354 forbids ending a turn waiting on
   another agent, and forbids ending a turn anywhere but in a final report; 360 requires ending
   the turn, without a final report, precisely to await several agents' reports. tw13's QM
   dispatched two Crew mates in one turn (inv 19) and then did neither thing cleanly: it spent
   **5 filler invocations** (`echo waiting`, `sleep 1`, `true` ×3 — inv 20-22, 24-25, cache flat
   at ~69k-75k) attempting to hold the turn open per 354, ended it anyway without a final report
   (inv 23, 26), was auto-resumed by task-notification both times, and only then continued. Five
   invocations bought nothing; the runtime's own resume did the work.
   Line 358 supplies the reconciliation the text never states — a background command has no
   resume signal that reaches a finished turn, whereas a dispatched agent's report does — but a
   role reading 354 and 360 in one pass has no way to derive that distinction. Candidate fix,
   routed not shipped: 354's "or another agent" is the wrong member of that list; the Agent case
   is governed by 360 and the runtime resume, and naming the distinction (no resume signal vs. a
   report signal) in 354 would close it. Note this is the same fault shape as 0.13.33's finding 1,
   recorded there as "a CONTRADICTION, the known class."
4. **Observed, not routed: tw13's plank-only Crew fix (change one string in a docblock) cost 12
   invocations / 545k cache** — high for the size of the edit, in the same family as pilot #5's
   plank-join trial-and-error finding (not re-derived here in full; noted for whoever next audits
   Crew-side plank-fix cost).

**Positive markers, tree-verified:** tw2 notes-only commit (clean deck after); tw3's foul-catch
left the tree exactly as reported (no staging, no commit); tw5's fit-out RIGGING/scantling/
conformance artifacts all present, left uncommitted for custody, zero-plant fitting (no
planted-red proofs run at fit-out, correctly deferred to QM promotion per `shipshape:110`);
fast-path-bootstrap's `RIGGING.md` is exactly the five required values with every optional slot
`none`, full voyage (bootstrap through custody commit and notes trim) in ~9m04s, under the ~10m
target; zero cockpit reads anywhere (no leg touched this harness's own scenario/probe text).

## The three numbers per leg (bin/mine.sh on the task transcript)

- invocations: model API calls (grouped by message.id). The primary cost driver -
  each re-prefills the whole context (~50-80k cache-read on sonnet legs).
- output tokens: reasoning + report. Small (5-15k/leg); NOT the cost driver.
- wall: first-to-last timestamp. ~95% agent overhead on toy suites, so wall tracks
  invocations x model speed, not verification.

Record all four per leg, plus MEAN CONTEXT PER INVOCATION (cache_read / invocations). That last
number decides whether a leg's extra rounds are cheap-and-fast or fat-and-slow; without it,
invocation count silently stands in for two things it may not track.

The old shorthand "token cost ~= cache_read x invocations; latency lever == token lever == fewer
rounds" is RETIRED (dk, 2026-07-14): it holds only while context per invocation is constant. It
is not. More small, low-context, fast invocations can beat fewer large costly ones on BOTH wall
and tokens. Invocations are a PROXY for the two things actually paid, never the target itself.

## Suite executions (bin/runs.sh on the project)

The runlog BeforeAll hook logs every EXECUTING cucumber run (dry-runs excluded - they
run no hooks). Duplicates of the same argv with no intervening tree change = redundancy.
Attribute phases by line ranges (record the count between legs).
Fixture v2 (2026-07-13): the log sinks out-of-tree at `<parent>/.instrument/<tree>/runs.log`
(roles wiped in-tree logs/ as scratch in wave 3); bin/runs.sh reads the sink first and
falls back to logs/runs.log for pre-v2 trees. The fixture runrecord homes at the project
root (`runrecord.jsonl`, gitignored), not in logs/. Uninstrumented states (fast-path
empty repos) count runs by transcript grep instead.

## Baselines (2026-07-12, sonnet, tidewatch fixture, doctrine 0.13.x)

| Leg | Invocations | Cache-read | Out | Wall |
|---|---|---|---|---|
| Shipwright fit-out (0.13.6) | 36 | 2.95M | 37k | 8.2m |
| Captain (0.13.6) | 13 | 610k | 8.9k | 1.4m |
| Captain (0.13.8, round economy) | ~10 tool uses | - | - | 44s |
| QM + foreground Crew (0.13.6) | 25 (incl 4 wasted polls) | 1.30M | 14k | 3.5m |
| Boatswain custody (0.13.7 table) | 15 | 712k | 10.6k | 2.6m |
| Boatswain custody haiku | 14-16 | ~500-600k | 6-8k | 1.4-2.2m |
| custody-fresh-session probe (0.13.8 plugin channel, row-1 inherit) | 14 | 623k | 15.8k | 3.0m |
| strike probe, hand-off control (0.13.8 plugin channel) | 13 | 614k | 13.7k | 2.9m |
| stale-record probe (0.13.8 plugin channel, void + rerun by trace) | 27 | 1.47M | 15.9k | 4.0m |

Suite executions: fit-out ~8-11; voyage 14 (0.13.3) -> 8 (0.13.6) -> 3 (0.13.8 with
wake run-record: one red classify, one Crew-local, one QM terminal green; custody ran
zero). Probe pair 2026-07-12: row-1 inherit 0 executions, hand-off strike 0, stale-record
1 (exactly the owed focused rerun; argv in runs.log matches the focused shape).

Full voyage 0.13.8 (Captain + QM/Crew + fresh-session custody): 35 invocations,
~1.53M cache-read, ~17k out, ~5.6m wall. Same intent on 0.13.3: 15.7m.

## 0.13.30-0.13.32 onboarding probes ("wave 6", 2026-07-18, HEAD-text, sonnet pinned, fable session)

Trigger: real-use onboarding failures in ~/yoink (2026-07-17, opencode, skills
channel, vendored skills byte-equal to 0.13.29 HEAD; sessions mined from the
opencode sqlite DB — a new evidence source): fitting-out routed before discovery on
a greenfield repo, Captain ordered the operator to make the initial commit ("the
operator owns only the initial commit" quoted back at dk), deck-dirt (the harness's
own .agents/ + skills-lock.json) blocked discovery, stack dialect (TS7 vs JS) and
every quality tool user-pushed (gherkin-lint self-installed then uninstalled;
gplint/c8/ts-morph/biome all dk's words), RIGGING left typecheck none on a TS7
stack; cost made concrete when Crew shipped plain JS into dist/ with nothing to
redden it. 0.13.30 (121dfee) shipped on dk's word ("yes, and probe"): (1)
greenfield fork — no RIGGING + no production code routes to discovery/fast path,
never Shipwright; (2) initial commit = Captain's own bootstrap action, four text
homes + hook unborn-HEAD allowance; (3) clean-deck gate binds at dispatch
boundaries, never conversation, harness artifacts ignore-or-fold; (4) stack
discovery names dialect/version, verified live; (5) batched quality-toolchain
offer with confirmed-tool slot population, letter reworded "every remaining slot".
Tests 213 green (4 new hook cases); hook replay vs installed 0.13.30 cache 6/6.

| Probe | State | Verdict |
|---|---|---|
| onboarding-greenfield G1 (opening) | onb1: unborn HEAD + quill.md + untracked harness artifacts | FULL PASS: greenfield fork held (zero Shipwright), no dirt block, spec read, initial commit SELF-MADE (02855da, artifacts folded, author checked first), batched questions name dialect/module-system/floor AND the tooling offer with candidates verbatim; registry claims verified live (npm view typescript -> 7.0.2) |
| onboarding-greenfield G2 (bootstrap) | onb2: same shape, scripted answers (TS7/node>=22/npm, gplint+biome+tsc+c8+ts-morph) | PASS w/ findings: initial commit 7c263ac self-made; confirmed slots POPULATED (typecheck tsc, lint biome+gplint two-line, coverage c8, plank-inventory); undecided slots literal none; 8-scenario spec + exact-form watchbill; every reported command re-driven by operator and reproduced incl. the honest "no inputs" typecheck state; stopped before QM as instructed. 14m01s incl. 5-tool install+config+proof (no-offer tw12 lineage: 7m24s — the offer's price ~+6.5m) |
| onboarding-legacy L1 (routing) | onb3: committed 2-module JS repo, no RIGGING, no tests | PASS: production-code fork -> Shipwright, no fast-path attempt; fit-out derived c8 coverage, jsdoc -X plank-inventory, usage step-usage; quality-gate gaps NAME stack-native candidates (eslint/biome, tsc --checkJs, gplint, Biome/GritQL); bonus live: @planks-provisional 0.13.20 reference form x3, knip-confirmed unreachable removal with restore path, .rgignore derived |

Findings: (a) MEDIUM tag-exclusion drop — G2 recomposed every verification command
around NODE_OPTIONS and lost the @captain/@shipwright tags everywhere (skeletons
would execute in broad/coverage). (b) MEDIUM library-only tool vs the letter —
ts-morph has no CLI, so "populates its command slot" drove Captain to author
tools/plank-inventory.ts, a script file outside Captain write scope. BOTH RESOLVED
same day on dk's rulings ("biome/gritql/jsdoc should be enough without ts-morph
until needed", "for node based projects"): 0.13.31 (a26b210) Node-stack catalog —
gplint/biome/c8 (+tsc on TS); plank-inventory defaults `jsdoc -X` on plain JS
(proven live on onb3: 3 doclets, one CLI line) and stays `none` on TS (proven
live: jsdoc silently EMPTY on .ts — a false clean), checker at first harbour via
Biome GritQL plugin (plugins seam confirmed in installed 2.5.4) or QM
bespoke-checker, ts-morph OUT until needed; no-glue guard closes (b) at root;
tag-exclusion recomposition sentence closes (a). 0.13.32 (ac08582) ASCII style
fix — OWNED MISS: the 0.13.31 push went out with style.sh RED (operator test-loop
swallowed the failure); caught post-push, ALL GREEN verified before the 0.13.32
push, reinstalled. Still open: (c) LOW G2's `biome check .` reformatted the
COMMITTED skills-lock.json unreported; (d) obs: `verification: features/support`
self-populated (cucumber-conventional reading; watch), L1 Shipwright staged its
own deletion (watch).

Leg accounting (4 legs, all mined; wave wall 14m17s parallel, 06:30:38-06:44:55):

| Leg | Invocations | Cache-read | Out | Wall | Notes |
|---|---|---|---|---|---|
| G1 Captain (greenfield opening) | 10 | 488k | 11.6k | 2m27s | zero spawns |
| G2 Captain (greenfield bootstrap) | 73 | 7.38M | 58.4k | 14m01s | 76 tool uses, zero spawns; incl. 5-tool install + proofs (no-offer tw12 lineage: 7m24s) |
| L1 Captain (legacy routing) | 8 | 351k | 7.5k | 13m00s | wall dominated by waiting on the nested child |
| L1 nested Shipwright (fit-out) | 41 | 3.88M | 48.8k | 11m42s | in line with historical fit-out legs (36-40 inv) |
| **Wave total** | **132** | **12.10M** | **126k** | **14m17s** | |

Model split: sonnet 132/132 — the
explicit pin held on EVERY invocation including L1-Captain's post-async-child
continuation; the wave-4 async-resumption fall did NOT reproduce under HEAD-text
general-purpose spawns (harness note: the leak may be plugin-channel agent-type
specific). Class-tally deltas held for the eventual fold: opening skill reads +8
(all P), owed bootstrap-proof runs +4 P (conservative, executing forms only),
evidence ops +5 P (registry checks x2, plank planted-proof pair, knip
before/after), commits +2 P (both unborn-HEAD initial commits, first live firings
of the new seam), polls +2 N (L1 async child), cockpit reads +0 (boundary 4/4
incl. two unborn-HEAD greenfield states).

## Pilot #5 (2026-07-19, sonnet, installed-plugin channel, doctrine 0.13.33, todopilot6, main-loop runner architecture)

First pilot since 0.13.26-0.13.33 (onboarding overhaul, dependency consumer-routing, blast-radius
fix). Closes the two items the queue named for this pilot: the 0.13.27/28 +5 inv/leg custody-price
watch (fired live, repeatedly - see below) and the first exercise anywhere of Crew's 0.13.25
approach-cap (STILL unexercised - every fix converged on its first approach). Scaffold: unborn
HEAD + vendored `assets/app-spec.md`/`app-template.index.html` placed untracked, per the 0.13.30
greenfield-fork pattern (no operator README commit - Captain's own bootstrap action makes the
first commit, matching wave 6's G1 probe, now proven at integration scale for the first time).

**Outcome: FULL PASS in 3 clean iterations, zero regressions, zero wasted iterations - the
cleanest pilot to date.** Oracle grading (tastejs/todomvc pinned ff43b02e, both operator patches
applied, framework=shakedown, quarantine held throughout - verified via transcript grep on every
leg, zero leaks):

| Iteration | Result |
|---|---|
| 1 (unmodified voyage 1) | 24/29 (ties pilot #4's best-ever cold open) |
| 2 (edit-mode hide, empty-edit-via-blur, back-button restore, direct-All-view) | 26/29 |
| 3 (label-hide completion, saveEdit double-invocation guard) | 28/29, 0 failing, 1 pending - **"All specs passed!"** |

Every iteration's oracle failure was translated to genuine product-language feedback (never test
output/selectors) and every translated item landed a REAL, root-caused fix: iteration 2's routing
fix rewrote `applyFilter` to rebuild from `localStorage` per filter change (the prior `li.remove()`
permanently dropped filtered-out items, breaking back-button restore); iteration 3's fix found and
fixed the actual root cause of a recurring `NotFoundError` (Enter-to-save on an empty title calls
`li.remove()` while the input still has focus, so the native `blur` `remove()` fires re-entrantly on
an already-removed node) with a `destroyed` reentrancy guard, not a workaround. No plateau, no
shipped-then-caught regression (contrast pilot #4, which needed 4 iterations incl. one regression
detour and one plateau-confirmation to reach the same terminal state via an operator exemption
patch rather than further iteration).

**Invocations: 720 total, scaffold to full pass** (27 legs, all mined, all banked to
`data/pilot-5/`). Voyage 1 (scaffold, incl. a plank-foul detour - see findings): 486 inv. Iteration
2: 125 inv. Iteration 3: 109 inv. **Cache-read: 55.79M. Output: 433.2k.** 100% sonnet across every
leg including every nested Crew spawn - zero model leak (this session's own model is sonnet
throughout, so the historical "later nested spawns fall to session model" leak class could not
manifest here regardless; a methodological ceiling on what this pilot can show on that axis, not a
finding). Not directly comparable to pilot #4's 232 inv (first reach of 28/29) since that number
excluded the regression/plateau detour and 0.13.26-0.13.33 doctrine has grown scope since (wave 6's
"efficiency battery" finding: Shipwright/Captain now derive materially more at fit-out/bootstrap).

**0.13.27/28 custody-price watch: fired live, repeatedly, confirmed working as designed.** Every
custody pass whose diff touched verification-support files (`steps.js`, `hooks.js`, `world.js`)
correctly ran the `broad` enumeration sweep rather than a file-scoped focused rerun (iteration 2
custody: 38-scenario broad sweep; iteration 3 custody: 38-scenario broad sweep) - the +5 inv/leg
rule from 0.13.27/28 firing exactly as shipped, on real support-touching legs, for the first time at
pilot scale.

**Findings routed to dk, none shipped:**

1. **HIGH - doctrine gap, reproduced twice: the "foul survives a lost caller" guarantee
   (boatswain/SKILL.md:77, qm/SKILL.md:72) does not fire for a malformed (not missing) plank when
   the underlying scenarios are already green and `RIGGING.md`'s `runrecord` is `none`.** Boatswain
   caught a real malformed-plank fault (5 `@planks` docblocks sat on bare statements/anonymous
   callbacks, not declarations, so `jsdoc -X` silently failed to attach them) and correctly refused
   to commit, per the 0.13.23-era plank-join rule - this is the FIRST live (non-staged-probe)
   observation of exactly this fault class. But redispatching a fresh QM at role+base-commit only
   (the QM row's absolute contract) did NOT rediscover it: QM's own rule treats an already-green
   listed scenario as complete (qm/SKILL.md step 4) and plank-drift hunting is explicitly "harbour
   work," not QM's routine job (qm/SKILL.md:26) - so a thin redispatch is a structural no-op for
   this exact fault shape, and with `runrecord: none` there is no durable trace of Boatswain's
   custody attempt for a context-cleared QM to find another way. Confirmed twice: once when a fuller
   hand-off was refused as contamination (correct, separate finding below), once when a legitimate
   thin dispatch silently completed without ever inspecting plank form. Operator worked around it
   this session by dispatching Crew directly with evidence-only content (no diagnosis, no fix
   prescription) - a substitution the current role-dispatch chain has no other route for. Needs a
   ruling: either the self-healing claim should be narrowed to exclude the malformed-plank-on-a-
   green-watch case, or `runrecord` should stop being optional wherever this property is relied on,
   or QM's routine should gain a mandatory plank-form check on every watch (not just harbour).
2. **MEDIUM - reproducible bulkhead-discipline slip, 3 independent instances in one voyage (2
   Boatswain, 1 QM), each self-caught.** Each instance ran an unscoped `rg`/search across the whole
   tree while chasing a stale dependency-name reference (`todomvc-common`/`todomvc-app-css`/
   "editing"), briefly surfacing `CAPTAIN.md` content into context before self-correcting to a
   properly-scoped rerun. Zero downstream effect in all three (no finding or decision was ever drawn
   from the exposed content) - but 3/3 on the same search shape ("any stale reference to X,
   tree-wide") is a real, repeatable rate, not noise. This is the exact tradeoff the 0.13.26 bulkhead
   fix accepted on purpose: bare/untargeted `rg` is one of the hook's proven-safe forms (the hook
   cannot know in advance whether a given search will return `CAPTAIN.md`), so content-blindness on
   this shape rests entirely on role discipline - and that discipline failed at a real rate this
   pilot. Candidate fix: nudge role skills toward pathspec-excluding `CAPTAIN.md` by default on any
   repo-wide content search, independent of the hook.
3. **Positive, tree-verified: the 0.13.28/0.13.33 dependency consumer-routing rule held correctly
   all voyage.** `RIGGING.md`'s Dependencies slot distinguished rigging/toolchain deps (installed at
   bootstrap: cucumber, gplint, biome, jsdoc, playwright) from product deps whose consumer is Crew
   (`director` - installed the moment the routing seam needed it) from a genuinely unwired pair
   (`todomvc-common`/`todomvc-app-css` - declared, never consumed by any scenario, correctly
   identified as drift by Boatswain and STRUCK by Captain rather than force-installed, since no
   scenario required them - a legitimate vanilla-CSS-free design call, not a defect).
4. **LOW, operator-side dispatch mistakes, cost ~34 inv:** the plugin dispatch-guard hook correctly
   denied one over-full QM->Boatswain hand-off paste (thin-dispatch cap), self-healed on retry; and
   the operator (this session) mis-dispatched Boatswain with `job: pre-clean` when a role-advanced
   diff existed and `post-implementation` (which commits) was correct - pre-clean scans but never
   commits, so a durable-artifact fix sat uncommitted for one extra leg. Both are operator mistakes,
   not doctrine defects, named here only because they're a real, avoidable cost.
5. **Crew's approach-cap (0.13.25) remains unexercised after 5 pilots.** Every fix this pilot,
   including the double-invocation guard, converged on its first approach. Standing gap in test
   coverage of that rule, not a new finding.

Leg accounting (27 legs, all mined and banked to `data/pilot-5/`; wave/voyage boundaries above):
top invocation legs were boatswain-recheck-commit (45), captain-voyage1 (75), qm-voyage1 (85, top
of a 9-leg voyage-1 chain incl. 8 nested Crew mates), boatswain-voyage1-foul (44, the malformed-
plank catch). Model split: sonnet 720/720 invocations, zero leak, verified per-leg via
`message.model`.

### Pilot #5 retrospective fold (2026-07-19, same-session, dk's "eval pilot") - the fold pilot #4 lost, done while the data exists

**P/N/Neg, all 720 invocations classified** (delegated to 4 parallel sonnet classifiers over the
banked per-invocation audits, chain context supplied, skill-load convention reconciled to the
standing all-P rule; cache ledger closes exactly at 55,787,475 = the banked total):

| Chain | Inv | P | N | Neg | Worth density |
|---|---|---|---|---|---|
| Voyage-1 build (Captain, QM, 8 Crew) | 304 | 276 | 26 | 2 | 90% |
| Custody/foul chain (2 QM, Crew, 4 Boatswain, Captain) | 182 | 136 | 44 | 2 | 73% |
| Iteration 2 (Captain, QM, 2 Crew, Boatswain) | 125 | 101 | 23 | 1 | 80% |
| Iteration 3 (Captain, QM, Crew, Boatswain) | 109 | 98 | 11 | 0 | 88% |
| **FLEET** | **720** | **611** | **104** | **5** | **83.9%** (84.9% positive by count) |

The 5 Neg are exactly the run's known faults, no new ones: 2 = crew-new-todo-foundation writing
`index.html`/`app.js` at project root (the relocate rework's cause), 3 = the unscoped-`rg`
bulkhead slips (finding 2). Leg extremes: crew-todo-editing, crew-new-todo-persist, crew-iter3-fix
and qm-refused-contamination at 100% density; boatswain-preclean-nocommit at 20% (the operator
pre-clean mis-dispatch, priced: 11 of 17 invocations re-derived wholesale by the next leg, ~14 inv
+ ~780k cache wasted); boatswain-voyage1-foul at 69% (real catch, expensive hunt - see below).

**NEW pattern the run-time report missed, visible only in the fold: plank-join extraction is
trial-and-error, ~27 N invocations across 3 legs (boatswain-voyage1-foul 14, boatswain-recheck 6,
qm-voyage1 8).** Each leg that runs the plank join reinvents the `@planks`-string-to-step-pattern
extraction with 5-7 failed `rg`/`grep`/node-parse variants before landing one that works. The
doctrine states the join ("every `@planks` string is one of the step-definition patterns
`step-usage` reported") but derives no command shape for it - and "what binds: examples, not
prose" is this harness's own oldest lesson. Candidate (routed, not shipped): give the join an
example command or a derived `RIGGING.md` slot. This is the single largest N cluster in the pilot.

**Instrument 1 (inbound weight), fleet-exact, ledger closed:** THE JOB is **36.7%** of the 58.4M
tokens read - vs **15.6%** at the v0.13.23 baseline; boilerplate (shared Articles 29.1% + role
skills 9.0% + harness floor 25.1%) is down from 84% to **63.3%**. Shared Articles' share fell
36.9% -> 29.1%, floor 33.5% -> 25.1%, role skills 14.0% -> 9.0%. Per-role JOB share: QM 44.3%,
Boatswain 38.9%, Captain 37.8%, Crew 24.5% (Crew still reads ~25.6k of shared Articles to do a
job that is a quarter of its context - the Crew-offcut question from GOAL 2 stands, still minor).
Mean context per invocation, fleet: 77.5k (heaviest: boatswain-recheck 106k, qm-voyage1 106k,
captain-voyage1 100k; lightest full leg: crew-relocate 47k).

**Retrieval-plan (plan.py), fleet:** compilable waste **11.0%** (79 of 720; opening block 7.5% +
independent runs 3.5%) - down from 14.7% at the GOAL-2 baseline, with the opening block nearly
halved (12.9% -> 7.5%): the 0.13.25 plugin-prefill lever partially collected what the IEPE
recompile could not. Worst legs by waste%: boatswain-iter2-custody 38% (a 7-call and two 3-call
independent runs), qm-refused 33% (floor effect, 3 inv), boatswain-preclean 29%. Best: the 8
voyage-1 Crew mates at 1-10%.

**Class tally deltas (fold into the running tally):** opening skill reads +54 P (2/leg x 27, all
consumed); plank-join extraction trials +27 N (NEW class, 0% worthiness, merge candidate - see
above); redundant confirmation runs +18 N (qm-fresh-rederivation's 7 per-watch re-greens of
already-proven scenarios + boatswain-preclean's 11 re-derived hygiene invocations - both charged
to their causes, the finding-1 doctrine gap and the operator mis-dispatch, not to role
discipline); polls +7 N (5 tiny Captain PROJ-echo polls, 1 QM wait placeholder, 1 Boatswain ps
check); redundant re-reads +15 N; unscoped-search bulkhead slips +3 Neg (finding 2); misplaced
initial Writes +2 Neg; commits +4 P (61014cb, f073bf2, 9362b7b, e3301ad, 837e810 - 5 commits, 4
custody + 1 Captain bootstrap); contamination refusals +1 P (qm-refused, 100% density at 3 inv -
the cheapest correct leg in the pilot).

**Caveat, stated plainly:** the P/N/Neg classification is judgment over banked audits whose
command column truncates at ~70 chars (classifiers used output-size and cache-growth signals for
opaque rows and verified the rework chain end-to-end); the chain totals and cache ledger are
exact, individual borderline calls are not. Same method as every prior fold, now stated
explicitly.

## 0.13.27/0.13.28 blast-radius probes (2026-07-14, sonnet, HEAD-text, tw17/tw18)

Three Boatswain custody legs on the pilot-#4 regression reproduced as a state. HEAD-text mode
(the session process predates the install, so the plugin channel would have served stale text);
this also isolates the doctrine TEXT, no hooks, same method as the bulkhead probe.

| Leg | Doctrine | Inv | Cache | Out | Wall | Outcome |
|---|---|---|---|---|---|---|
| tw17 GATE | 0.13.27 | 14 | 760k | 16.6k | 3m08s | Deck foul, no commit - quoted the new support row, ran the broad sweep |
| tw17 control | 0.13.26 | 9 | 422k | 8.7k | 3m20s | Deck foul, no commit - guessed the consumer, focused run |
| tw18 control | 0.13.26 | 9 | 457k | 21.0k | 3m47s | Deck foul, no commit - grepped 4 consumers, 3 focused runs |

**Zero commits in all three arms, tree-verified.** The A/B is a NULL RESULT: 0.13.26 also refuses,
on both a one-consumer and a three-consumer tree. The old text did not ship the break. Pilot #4's
two live misses remain the only evidence it does.

**Price of the fix: +5 invocations / +339k cache** on a custody leg that touches verification support
(14 vs 9). That is the standing cost of dk's option (a): any support hunk selects the tier's
enumeration sweep, which is most voyages, since QM writes step definitions routinely. Watch this
number across the next pilot - if custody legs inflate, the modify-only variant is the fallback.

**The real finding is behavioural, not economic:** both control legs declared their own recheck row's
proof VOID and overrode it (typecheck/lint both `none`, so the row's stated proof is nothing), then
ran consumer scenarios by judgment. Boatswain's table opens "Recheck selection is a lookup, not a
judgment". The old row forced correct roles to disobey it. Full account in CAPTAIN.md.

## Pilot #4 (2026-07-14, sonnet, installed-plugin channel, doctrine 0.13.25, todopilot5, main-loop runner architecture)

CLOSED FOLD (2026-07-18 retrospective eval): pilot #4's per-invocation P/N/Neg
classification and worth densities were never computed and are now PERMANENTLY
UNRECOVERABLE - the raw transcripts were pruned before the fold (see the
2026-07-18 pilot-eval entry in CAPTAIN.md). Do not hunt for this data; the
leg-level numbers below are everything that survives.

First pilot since the v0.13.23 stable-release tag / Goal 2 baseline, and the first live test
of 0.13.24's flat QM->Boatswain hand-off and 0.13.25's Crew stop-cap under pilot pressure
(the stop-cap was NOT exercised - Crew converged on every fix without hitting it).

**Scaffold -> first fully-green watchbill: ~189 inv.** Included a genuine rigging blocker
(Captain declared deps in RIGGING.md, never provisioned them; QM discovered via
`npx cucumber-js --dry-run` failing, routed Captain -> Shipwright refit, 14 inv round-trip)
and one malformed-plank deck foul (Boatswain caught it via the plank join, correctly
redispatched Crew rather than deferring to harbour - the 0.13.23 rule holding live again).

**Oracle iteration table** (tastejs/todomvc pinned ff43b02e, operator-side only, quarantine
held throughout - verified via transcript grep on every leg):

| Run | Fix | Result |
|---|---|---|
| 1 (unmodified voyage) | - | 24/29 |
| 2 (in-place DOM reuse, keyed by `dataset.id`) | Captain 17/QM 16/Boatswain 10 | 28/29 |
| 3 (filtering regression shipped+caught+fixed, see below) | Captain 18/QM(regression) 15/Boatswain(missed) 10/QM(refused contaminated dispatch) 3/QM(clean) 4/Shipwright(harbour, caught it) 27/Captain(routed) 10/QM(fix+conformance) 31+nested Crew 40/Boatswain 27 | 28/29 unchanged |
| 4 (reload-finality determinism) | Captain 11/QM 19/Boatswain 8 | 28/29 unchanged - 3rd consecutive no-defect result |

**Totals to first reach 28/29 (through run 2): ~232 inv / ~12.5M cache / ~90k out / ~44m
wall.** Full run through run 4 (regression detour + plateau confirmation): **~454 inv /
~25.2M cache / ~204k out / ~1h29m wall.** 100% sonnet throughout, zero model leak.

**THE REGRESSION, live-caught, tree-verified (iteration 3):** QM's fix for 3 new
rapid-timing persistence scenarios reverted `features/support/world.js`'s
`completeTodo`/`activateTodo` from `.click()` back to `.check()`/`.uncheck()`, silently
undoing an earlier fix and reintroducing a checkbox-removes-its-own-element hang in
`filtering.feature`. QM never caught it (only reran the 3 targeted scenarios, never the
full suite). **Boatswain's custody recheck ALSO missed it** - scoped its recheck to
`persistence.feature` (the file the change was declared alongside) and committed the
broken build. Caught only when the operator ran the full suite independently. Routed via
a clean thin QM redispatch (which correctly found nothing, since the deck was at rest with
no watchbill) -> Shipwright harbour full-regression (caught it immediately, named it
"most urgent", correctly refused to fix it directly) -> Captain routed -> QM+Crew fixed it
for real (production-code fix: filtered-out items now `display:none` instead of DOM-removed,
not a harness reversion) -> Boatswain custody (broad recheck this time, committed clean).
**This is the doctrine working exactly as designed at the harbour layer, and failing at the
custody layer twice in the same voyage** - see CAPTAIN.md's PILOT #4 findings for the
routed recheck-selection gap.

**Successful validations, unprompted, tree-evidenced:**
- **The planted-red adoption proof, owed since 0.13.19, closed.** QM planted a bogus
  watchbill, a `PERTURBATION` token, and a malformed plank in turn, confirmed each
  correctly reddened its corresponding `@conformance` scenario, then reverted cleanly -
  the Shipwright-derived scantling checkers are proven to actually catch what they claim to.
- **Real scantlings, first time in a pilot.** Shipwright derived
  `scantlings/verification-conformance-rules.md` (4 rules) unprompted during harbour
  inspection, each backed by an executable `@conformance` scenario.
- Content-blind `CAPTAIN.md` staging hook enforcement observed live under real plugin-channel
  conditions (batched `git add` rejected, forcing a split into two calls) - the bulkhead
  defect fix from the 0.13.23 era, working correctly outside a staged probe.

**Model split: 100% sonnet, zero leak** across every mined leg (~30 top-level + nested
Crew/Shipwright legs).

**Oracle exemption, dk-ruled and shipped (2026-07-14, `fixtures/oracle/`, NOT a doctrine
change - operator-side fixture only):** the persisting 28th/29th residual
(`Persistence -> should persist its data`) was resolved not by further product iteration
but by discovering the check itself is effectively untested upstream - every framework
touched in the oracle's last real update wave (2026-05-02: vue, svelte, react-redux, react,
preact, lit, angular) is already exempt from it, and the entire non-exempted set is
untouched since 2024 or earlier. See CAPTAIN.md PILOT #4 entry and
`fixtures/oracle/README.md` for the full evidence chain. Grading under the new fixed
`shakedown` framework name (all future pilots must use this name, not a per-run label):
28 passing / 0 failing / 1 pending, "All specs passed!"

## Pilot #3 (2026-07-14, sonnet, installed-plugin channel, doctrine 0.13.15, todopilot4, main-loop runner architecture)

First pilot run under the 0.13.14/0.13.15 doctrine AND the pilot.md runner architecture
(main-session-loop only, no fork delegation, timer-wake narration, mine-on-every-
notification). Fresh scaffold (empty repo + vendored app-spec.md + app-template.index.html,
commit 497c74f). Oracle pinned ff43b02e with the fixtures/oracle/spy-reset.patch applied
from the start (no in-run oracle-harness bug this time — attempt-2's fix ships as a fixture
now). Channel verified: 0.13.15 doctrine live (tests 203/203 green pre-run); the specific
0.13.15 write-custody/Cucumber-layout marker did not fire this pilot (this project's
`verification: tests` layout sits beside, not nested under, `specs: features`, so the new
rule's exact trigger condition never arose — not a gap, just an untouched seam this run).

**Voyage (bootstrap to first fully-green QM-derived suite, 27 named scenarios):**
Captain 30 inv/1.96M/23.6k out (08:15:13-08:20:00, ~4m47s); QM top-level 46 inv/3.23M/
30.5k out (08:20:52-08:50:25) + nested Crew build 63 inv/6.86M/69.7k out + nested Crew
custody-fix 13 inv/539k/2.1k out (QM caught a genuine custody foul: Crew's routing fix
had globally monkey-patched `window.setTimeout` in PRODUCTION code to defeat jsdom's
async hashchange timing — routed to Boatswain, Crew redispatched, test-only fix landed
in `world.js` instead) + Boatswain 19 inv/923k/5.9k out. **Voyage total: 171 inv / 13.51M
cache / 132k out**, commit 670d99c. Zero deadlocks, zero orphan stalls this leg.

**Oracle grading, iterated per the two-phase gate (quarantine held throughout — verified
via transcript grep on every leg, only hit a legitimate `tastejs` URL inside the vendored
spec asset):**

| Run | Captain | QM (+nested) | Oracle result | Residual named |
|---|---|---|---|---|
| 1 (unmodified voyage) | - | - | **23/29** | render-churn/detached-DOM (5), missing CSS-driven edit-hide (1) |
| 2 (stable identity + edit-visibility) | 18 inv | 55 + nested (Crew A 23, Crew B 25, interference-fix Crew 10, Boatswain 18) | **27/29** | label not hidden (CSS gap under-specified in iteration-2 feedback), same-class persistence detach |
| 3 (label hide + persistence-settle) | 20 inv | 46 + nested (Crew 18, Boatswain 16) | **28/29** | Persistence detached-DOM (same signature as attempt-2's residual) |
| 4 (reload-anchored DOM identity, spec drafted, NOT built) | 22 inv | - (dk's word: stop here) | not re-graded | queued for next session, see CAPTAIN.md |

Iteration 2's parallel Crew dispatch (2 disjoint seams: DOM-reconciliation, edit-mode
hiding) **genuinely collided** — mate A's new `updateLi()` reconciliation path didn't carry
mate B's hidden-state logic, regressing an already-green target. QM caught it as an
ordinary failing verification target (not a silent miss), dispatched a solo follow-up Crew
fix, reverified clean. Live validation of the "parallel Crew stays shared-deck, verification
is the detector" standing decision — worked exactly as designed.

**Totals through the built iterations (voyage + iterations 2-3, iteration 4 spec-only
excluded from the "reached 28/29" figure since it was never executed):**
171 (voyage) + 149 (iter 2: 18+55+23+25+10+18) + 100 (iter 3: 20+46+18+16) = **440
invocations to reach 28/29** (442 including iteration 4's spec-only Captain leg).
Cache-read ≈ 27.9M, output ≈ 228k. **Compare attempt-2: 717 invocations to reach the
same 28/29** (442 voyage + 275 iteration, plus a separate operator-side oracle-harness
fix) — pilot #3 reached an equal-or-better result in ~39% fewer invocations, with no
oracle-harness bug this time (fixed from the start) and a genuinely cleaner residual
read (same failure signature as attempt-2's, now seen twice across two independent
apps — stronger evidence it is a tier-observability boundary, not an app defect).

**Instruction fidelity — two real findings, both HIGH/routed, neither shipped (see
CAPTAIN.md for full evidence chains):**
1. **Monitor-tool orphan stall on a nested agent** (HIGH): iteration-2 QM dispatched two
   parallel Crew children, armed the `Monitor` tool, and ended its turn — confirmed via
   `SendMessage` response ("Agent was stopped (completed); resumed it") that this
   orphaned exactly like the pilot-#2 fork stalls, now proven on a real Shipshape role,
   not just the harness runner seat. Operator-resumed manually.
2. **Self-devised sync marker is unreliable** (follow-on): after being warned off Monitor,
   the same QM invented a foreground Bash poll checking dispatched agents' transcripts
   for a `"type":"result"` JSONL marker that does not exist in this runtime's transcript
   format — burned two ~9-minute timeouts in one leg (once self-recovered at timeout,
   once operator-nudged to save the second wait) waiting on a condition that could never
   match, even though the work it was waiting on had already finished within seconds
   both times.

Both QM legs otherwise behaved well: correct custody-foul catch and routing (voyage),
correct parallel-mate collision handling via ordinary verification (iteration 2), correct
self-recovery via ground-truth checks (`git diff`, fresh reruns) once its invented wait
mechanisms failed (iteration 3). The failures are specifically in HOW a role waits on
multiple/uncertain async children, not in the underlying verification/build work, which
was uniformly sound across all four legs.

**Model split:** 100% sonnet across every mined invocation, zero leak (session model is
sonnet throughout).

**dk rulings this pilot, routed to a follow-up fable session (full text in CAPTAIN.md,
none shipped — mid-pilot no-side-scope rule held):**
1. Full-regression economy: only harbour should ever run a full regression (cut the
   Captain-skill "offer" bullet; reword the Verification agreement so harbour is the sole
   trigger, not "pre-outbound and harbour").
2. Narration ruling: the human-facing seat must ALWAYS narrate progress in plain text
   while dispatched work runs — no silent gaps, no raw-transcript dumps, no bare
   task-list views standing in for narration. Applies to real Shipshape Captain use, not
   just this harness.
3. The Monitor-stall and broken-poll-marker findings above, with a design option raised
   by dk: decouple QM->Boatswain into a flat, symmetric hand-off (mirroring the
   already-working foul->fresh-QM direction) rather than a nested wait; QM<->Crew stays
   nested (QM genuinely needs Crew's outcome) but needs a named, trusted way to consume
   multiple concurrent children without inventing an ad-hoc wait mechanism.

## Pilot #2 attempt 2 (2026-07-13/14, sonnet, installed-plugin channel, doctrine 0.13.14, todopilot3)

Clean rerun (fresh scaffold, not a resume of the parked attempt-1 tree) after the
0.13.14 efficiency battery gated GREEN. Full account in CAPTAIN.md; numbers here.

**Voyage 1 (bootstrap to first fully-green QM-derived suite, 32/32 scenarios):**
Captain (specs+watchbill, incl. a toolchain blocker + resume) 50 inv/3.77M/31.5k
out; QM blocked-then-resolved attempt 10 inv/402k/5.05k out; QM voyage (retry)
111 inv/12.66M/65.3k out top-level + 14 nested Crew/Boatswain legs 271 inv/14.24M/
106.2k out. **Voyage total: 442 inv / ~31.1M cache / ~208k out, ~53m active leg
wall** (scaffold-to-green ~56m wall-clock). Zero deadlocks, zero polls/pgrep/kill-0
patterns anywhere, all-sonnet (zero model leak - session model is sonnet).
**Tier economy A2 validated live**: Captain chose jsdom verification over a
real-browser tier and named it as an open question rather than unilaterally
adopting Playwright - the exact attempt-1 root-cause fix, holding on re-test.

**Oracle grading** (tastejs/todomvc pinned ff43b02e, operator-side only, quarantine
held throughout - verified via transcript grep for oracle terms on every leg,
only hit being a legitimate "tastejs" URL inside the vendored app-spec.md's own
Template section): run 1 (unmodified voyage-1 build) **21/29 passing** - already
better than pilot #1's first grade (0/29). Iterated per dk's word (spec/watchbill
amendment -> fresh QM -> Crew -> Boatswain -> re-grade, oracle failures translated
into ordinary product-language feedback, never exposing the oracle to any role):

| Iteration | Captain | QM (+nested) | Oracle result |
|---|---|---|---|
| 2 (render churn, edit-mode hiding, first-write persistence) | 32 inv | 38 + 93 nested (5 Crew/Boatswain legs) | 23/29 |
| 3 (label-hide, add-settling via mark-all proxy) | 20 inv | 22 + 39 nested (1 Crew/Boatswain pair) | 24/29 |
| 4 (save-before-clear ordering, startup-render-path) | 23 inv | 29, 0 nested - both scenarios ALREADY PASSED against unmodified production code | 24/29 (unchanged) |
| 5 (reload-settle stability) | 22 inv | 18, 0 nested - scenario ALREADY PASSED, no defect found | 24/29 (unchanged) |

Iteration total: 275 inv. **Grand total, full pilot: 717 inv** (442 voyage + 275
iteration) to reach 24/29 (82.8%) - a HIGHER pass rate than pilot #1's 18/29 (62%,
one iteration, 517 inv total lifecycle). Zero deadlocks, zero contamination, zero
cockpit reads, zero role-boundary breaches across every leg.

**Plateau finding (routed, not a doctrine defect):** the 3 residual failures (two
`reset`-property CypressErrors on the harness's own storage-spy teardown, one
reload-timing DOM-detachment) held EXACTLY unchanged across iterations 3-5 despite
three independently-framed product asks each landing real spec coverage - QM's own
honest verification found no production defect on two of those three passes (Crew
never dispatched, scenarios already passed against untouched code), and the app's
`src/index.html` was byte-identical from commit `cea5a54` onward. This is strong
evidence the residual 3 are not reachable through further product-language
iteration - most plausibly a test-harness/library-version artifact independent of
app behaviour, not a real spec gap. Operator did not build a comparison/control
apparatus to confirm this (out of scope per dk's word); this is inference from the
app's own source and QM's repeated independent findings, not further diagnosis.

**CLOSE-OUT (2026-07-14 morning, operator-side; full chain in CAPTAIN.md):** the
plateau inference above was CONFIRMED by reading the pinned oracle source: 2 of
the 3 residuals were the oracle's own `spy.invoke('reset')` calling a
sinon-removed API on a path every upstream-maintained framework skips
(noLocalStorageSpyCheck covers the whole modern main set - they persist nothing).
One-line operator-side fix (reset -> resetHistory), vendored as
fixtures/oracle/spy-reset.patch. **Same app bytes re-graded: 24/29 -> 28/29,
zero skips** (the before-each fix un-skipped 2 Mark-all tests, which pass).

Iteration 6 (2026-07-14, the completion-bar reachability check; EXCLUDED from
clean pilot accounting - fable session model, post-stall conditions): Captain 30
inv/2.51M/9m0s (30/30 sonnet, pin held, no nested spawns) - amended 2 features +
watchbill (3 scenarios), correctly identified both coverage gaps (neighbour-vs-own
node identity; post-reload reference blindness), stop-line held. QM 29
inv/1.87M/9m51s (25 sonnet + 4 FABLE - the async-resumption fall, live in a fable
session, confirming the sonnet-session requirement) + nested Boatswain legs 5+21
inv all-sonnet (one dispatch-contract foul self-caught: first Boatswain dispatch
over-narrated, withdrawn, redispatched clean); commit a9e3aea. ALL 3 scenarios
GREEN AGAINST UNMODIFIED PRODUCTION - production bytes unchanged since the 28/29
grade, so the grade stands by identity (re-run would be a redundant confirmation).

**Verdict on the last residual (Persistence detached-DOM): a TIER-OBSERVABILITY
BOUNDARY, not an app defect the loop failed to fix.** Three product-language
framings across iterations 4-6 all verified green at the jsdom tier; the oracle's
real-Chrome run observes an async re-render the jsdom settle-window snapshots do
not. The doctrine-sanctioned path already exists: 0.13.14 tier economy escalates
to a browser tier when a specified behaviour cannot be observed below it, as a
named recorded decision. Pilot #3 guidance: full-green target stands; if this
residual class appears, the product-language feedback should name the observable
behaviour and the tier escalation is the legal route - that firing live would
itself be a validation of the A2 rule's escape hatch.

**Attempt-2 final: 28/29 (96.6%) at 717 clean-accounting invocations** (+ the
excluded iteration-6 reachability check: 85 inv incl. nested). Pilot #1: 18/29
(62%) at 517 inv. Attempt 1: 84 inv spent, deadlocked (reported alongside, not
folded).

## TodoMVC pilot baselines (2026-07-12, sonnet, HEAD-text legs, doctrine 0.13.9)

27 dispatched role legs, greenfield to graded app. Role-leg totals only: 517
invocations, ~41.1M cache-read, ~749k out, 4h31m lifecycle wall. ~39 nested
Crew/Boatswain subagent transcripts (QM-spawned) NOT included; mine from the session
tasks dir for implementer-side numbers. Notable legs: QM build voyage 111
invocations / 12.7M / 92m (17 Crew dispatches); Shipwright harbour 31 / 4.25M / 14m;
Shipwright fit-out completion 34 / 3.47M / 13m. Bootstrap (empty repo to first
product spec) cost 10 legs / ~65m - the harbour-gate deferral in the first Captain
spec leg is the single largest avoidable serialization.

Oracle (tastejs/todomvc pinned ff43b02e, cypress 15.14.2, operator-side quarantine
held): first grade 0/29 (template-markup gate, 28 unmeasured); after ONE
product-language iteration (template sections promoted to binding specs, 5 scenarios,
5 Crew fixes): 18 passing / 9 failing / 2 skipped. The 9 residual failures are
objective unauthored conformance findings (see CAPTAIN.md).

## 0.13.10 validation probes (2026-07-12, sonnet, HEAD-text)

| Probe | Invocations | Cache-read | Out | Wall | Verdict |
|---|---|---|---|---|---|
| QM seam-parallel Crew (2 disjoint seams, one file) | 14 | 571k | 12.4k | 3.8m | PASS: 2 parallel mates, collision self-healed |
| Boatswain notes custody + strike + record shape | 22 | 1.20M | 24.4k | 5.1m | FULL PASS, transcript-verified content-blind |
| Shipwright fit-out plank rules | 25 | 2.34M | 59.5k | 12.0m | PASS derivation; MISS plant-red (timing ambiguity, 3 divergent obs) |

Probe 2 tool-call audit: deck diff composed as `git diff <base> -- . ':!CAPTAIN.md'`
verbatim; only mtime stat and by-path add touched CAPTAIN.md. Zero content reads.
Probe 2 also live-validated: void-on-any-byte (record died when CAPTAIN.md landed),
rerun by trace exactly the 2 owed targets, strike after own append at current hash,
canonical JSON record lines.

## 0.13.10 seam probes, plugin channel (2026-07-12 evening, installed 0.13.10 c045b46, sonnet top-leg dispatch)

RE-DATED 2026-07-13: channel forensics (marker-phrase greps over every leg transcript)
show these legs loaded pre-0.13.10 skill text and hooks (~0.13.8/9 process-level plugin
snapshot; /clear does not re-snapshot). Numbers and behavioural observations stand;
version attribution corrected in the 2026-07-13 section below. Key re-readings:
batching MISS x2 occurred with NO batching arm in the agents' text; supersede MISS
occurred with a tag table offering only promote/discard (supersede entered 0.13.10);
the "0.13.9 strike arm FULL PASS" was model-native (corroboration wording absent from
all 12 Boatswain legs' text).

Five pre-approved probes, 31 legs total (7 dispatched + 24 nested), all mined including
nested Crew/Boatswain/QM. Totals: 409 invocations, 18.16M cache-read, 412k out, 41m
wave wall (probes parallel). Model split: sonnet-5 264 inv / 12.57M; fable-5 145 inv /
5.59M (nested spawns after a parent's first fall to the session model unless the parent
pins `model` explicitly - tw3's Captain pinned, all-sonnet children; every other parent
leaked). Nested fable-5 Crew ran 7-9 inv vs sonnet Crew 11-12 on like-for-like solos.

| Probe | Legs | Inv | Cache | Out | Wall | Suite runs | Verdict |
|---|---|---|---|---|---|---|---|
| 1 Crew batching arm | 5 | 61 | 2.39M | 40k | 11.5m | 16 | MISS: 3 solo Crew sequential on a seam QM itself named shared |
| 2 unplanked-foul route (2a+2b) | 4 | 48 | 2.11M | 50k | 1.8m + 9.4m | 5 | PASS: foul ruled (no commit/strike/runs); Crew ACCEPTS plank-only target; route closes with commit |
| 3 @captain supersede | 8 | 114 | 5.05M | 100k | 22.9m | 5 | MISS: promote-with-correction chosen; supersede still unobserved live |
| 4 harbour-gate same-pass | 7 | 89 | 3.50M | 81k | 20.4m | 12 | PASS: specs+watchbill in the review pass, zero redundant regression; bonus full voyage |
| 5 one-blocker bootstrap (5a+5b) | 7 | 97 | 5.11M | 142k | 3.7m + 36.1m | uninstrumented | PASS: one blocker; one Captain cycle resolves values AND toolchain; full fit-out + methodology suite green |

Leg worth densities: P2a Boatswain custody-foul 100% (9 inv/351k/1.8m - new best custody
baseline), P1 voyage Boatswain 100% (10 inv), tw3 strike Boatswain 100% (10 inv, record-
corroborated strike, zero strike-runs - 0.13.9 arm FULL PASS live), tw5 fit-out
Shipwright#2 100% (12 inv incl. two planted-red proofs), P1 QM 91%, P2b QM 91%, P5b
Captain 91%, P3 Captain 88%, P4 Captain 78% (refused-dispatch poll cluster: sleep 240
et al, ~400k waste from one over-narrated dispatch). Run redundancy: tw1's serial-solo
shape staled ~5 Crew mid-proofs (charged to the batching MISS, not discipline).

## 0.13.11/0.13.12 validation, two waves (2026-07-13, sonnet top legs, the five pre-approved probes)

Wave 1 dispatched installed-plugin `shipshape:*` agents and unknowingly ran STALE text
and hooks (~0.13.8/9; the plugin snapshot is process-level, this Claude Code process
dates from Jul 12 12:42, and /clear does not refresh it). Kept as the old-text
control. Wave 2 re-ran byte-identical reconstructed states (deck-state hashes
reproduced exactly: 13d9a2e/a545663) in HEAD-text mode at 0.13.12 de24fa7. HEAD-text
carries no hooks; the 0.13.12 hook layer was ground-truthed by synthetic payload
replay instead. Integrated plugin-channel re-run owed after a real restart.

| Probe | Wave 1: stale ~0.13.8/9 text + old hooks | Wave 2: 0.13.12 text (HEAD-text) |
|---|---|---|
| 1 crew-batching | shape-MISS: 1-ref solo dispatch + QM self-verified the rest; 1 Crew spawn; 6 suite runs | PASS: ONE batched dispatch, 3 refs + per-target evidence, explicit one-mate-one-cluster marker; batched red census; 8 runs (3 = QM re-proof for record append); commit 15b2f65 |
| 2 captain notes-commit | FAIL: plain `git add && git commit` denied by old hook; Captain routed to a doomed Boatswain + SendMessage resume; notes never committed (3 legs spent) | PASS: `git commit -m <msg> -- CAPTAIN.md` composed first try; notes-only commit 75833ab; 8 inv / 73s; zero cycles |
| 3 boatswain notes arms | MISS x2 (old text): CAPTAIN.md left unstaged, watchbill left unstruck despite record corroboration; 3 hook denials incl. `git add CAPTAIN.md` | FULL PASS: `git diff <base> -- . ':!CAPTAIN.md'`, `git add -- CAPTAIN.md` content-blind, row-1 inherit (0 runs), record-corroboration strike (first live firing WITH its text), commit 2dd9382 |
| 4 QM plank-gap | PASS via nested-custody foul return (3 nested legs) | PASS via QM's OWN re-derivation per the 0.13.11 clause (2 nested legs); record void-on-edit then fresh-append correct; commit c930df1 |
| 5 record shape + no-plant fit-out | record: 4th divergent shape (`"command":"focused","result":"green"`); fit-out: 3 plant-red cycles at fit-out, 7 skeletons, 40 inv / 3.79M / 14.7m / 7 runs | record: canonical x4 incl. 3 appends on an EMPTY record (example line binds); fit-out: ZERO plants, tree uncommitted, 3 skeletons + 5-rule conformance scantling, runrecord+weather derived git-ignored, no script files, 26 inv / 2.51M / 12.2m / 5 runs |

Leg accounting: Wave 1, 11 legs: 180 inv / 9.69M cache / 176k out / 14.9m wave wall.
Tops: QM-tw1 22/934k/6.6m, Captain-tw2 17/763k/5.3m (+nested Boatswain 14/543k/5.3m),
Boatswain-tw3 17/867k/4.4m, QM-tw4 20/892k/10.9m, Shipwright-tw5 40/3.79M/14.7m;
nested Crew 8-9 inv, nested Boatswains 8-17 inv.
Wave 2, 9 legs: 115 inv / 6.58M cache / 124k out / 12.5m wave wall. Tops: QM-tw6
20/973k/6.8m, Captain-tw7 8/354k/0.9m, Boatswain-tw8 13/629k/2.7m, QM-tw9
16/834k/11.0m, Shipwright-tw10 26/2.51M/12.2m; nested Crew 7 and 11, Boatswain 7 and 7.
Same states, coherent text: -36% invocations, -32% cache, zero mistake/fix cycles
(wave 1 spent 4 hook denials, 1 doomed dispatch + SendMessage resume, and closed 2 of
5 probes with failed outcomes). dk's latency lens quantified: coherence is the lever.

Hook ground truth (synthetic payload replay against 0.13.12 bash-custody.sh): ALLOW
boatswain `git add CAPTAIN.md`, `git add -- CAPTAIN.md`, `:!CAPTAIN.md` exclusion;
ALLOW captain `git commit -m <msg> -- CAPTAIN.md`; DENY captain `git commit -am`.
Gaps: (1) `git -C <root> add -- CAPTAIN.md` DENIED - strip patterns cover only the
bare `git add` forms; (2) ANY prose mention of CAPTAIN.md elsewhere in a compound
command DENIED, including echo section labels - wave 2's textbook Boatswain composed
exactly such a label, so the best-behaved agent still eats a spurious denial on the
plugin channel; (3) the commit denial message leads with "Boatswain holds local
commit custody", which steered wave 1's Captain into the doomed Boatswain dispatch;
the corrective pathspec form sits in sentence 2. All three routed to dk.

Model split: nested inheritance identical in both modes - first spawn inherits the
parent's model (sonnet), later spawns fall to the session model (fable). W1 2/5
nested fable, W2 2/4. Record-append economy seam: both wave-2 QMs re-ran
Crew-proven greens in their own hands solely to append record lines (4 runs), reading
the wake append as the running role's own; either Crew's hand-off green should be
recordable or the re-proof is the record's standing price - routed to dk.

## 0.13.12 integrated plugin-channel wave (2026-07-13 post-restart, "wave 3", sonnet top legs pinned)

The owed re-run, DISCHARGED. Real process restart verified (process 11:49 UTC >
install 08:01 UTC); channel verified empirically per AGENTS.md: role-skill marker
phrases positive on every leg (captain: `pathspec-limited` + `Greenfield fast path`;
qm: `expensive fallback, never the default` + re-derivation clause; boatswain:
`Staging is not reading`; shipwright: both 0.13.11/0.13.12 phrases; shared Asset
policy marker consumed on tw7). First live firing of the 0.13.12 hook layer.

| Probe | State | Verdict |
|---|---|---|
| 1 crew-batching | tw1 | PASS: ONE batched Crew dispatch, 3 refs + per-target evidence, one-mate-one-cluster marker; 5 suite runs (vs 8 wave-2); canonical record on empty log; commit 76b0067 |
| 2 captain notes-commit | tw2 | PASS: `git commit -m <msg> -- CAPTAIN.md` first try, hook allowed live, notes-only commit a185a21, zero cycles |
| 3 boatswain notes arms | tw3 | PASS all arms: `:!CAPTAIN.md` diff, `git add -- CAPTAIN.md`, row-1 inherit 0 runs, corroboration strike, commit e38f706; 1 gap-(b) denial (echo label), self-healed |
| 4 QM plank-gap | tw4 | PASS: foul re-derived by QM itself, Crew accepted plank-only target, record void-on-edit + fresh canonical append at cb1ded8e, 3 runs, commit 7bf1c5b |
| 5 record + no-plant fit-out | tw5 | PASS: zero plants, tree uncommitted, 3 skeletons + 5-rule scantling, checker file correctly left to QM, 4 runs |
| verification-boundary | tw6 | PASS on objective joins: main window 4 runs/1 provision (QM's own checkpoint), dashboard run 0 provisions via spy, inline `@exceptional-double` naming both grounds, standalone cold-cache run exactly 1 provision, cross-run amortization bonus; commit f6e2446 |
| scope-out-gate (0.13.12) | tw7 | PASS first live firing: exclusion held as named question (report + CAPTAIN.md), QM dispatch HELD (zero spawns), specs+watchbill drafted unspent; template section entered binding specs byte-verified |
| fast-path-bootstrap (0.13.12) | tw8 | TAINTED PASS: outcomes objective (minimal 5-value RIGGING, no methodology checks, 6 specs, voyage green, CLI correct on all band edges, 3 commits, clean deck; empty-repo to specs+QM 7m51s, voyage complete ~17.5m vs ~40m baseline) BUT the Captain read the operator cockpit incl. probes.md rubric — not valid as independent validation; clean re-run owed with hardened dispatch |

Leg accounting (16 legs, all mined incl. nested): 332 inv / 19.33M cache / 295k out /
20.2m wave wall (parallel). Tops: tw5-Shipwright 40/3.59M/13.7m, tw8-Captain
35/3.38M/18.8m, tw3-Boatswain 30/1.59M/3.3m, tw1-QM 28/1.29M/6.5m, tw8-QM
28/1.39M/8.7m, tw6-Btsn 27/1.51M/6.3m, tw6-QM 23/1.43M/14.2m, tw4-QM 22/975k/7.4m,
tw7-Captain 15/814k/4.8m, tw2-Captain 14/558k/2.2m; nested Crew 12-15 inv,
Boatswains 9-27. Worth densities: tw7 100% (new best Captain leg), tw6-Btsn 92%,
tw1-Crew 92%, tw8-Crew 91%, tw3 89%, tw5 87%, tw6-QM 87%, tw4-Btsn/tw1-Btsn/tw8-Btsn
86%, tw4-Crew 84%, tw4-QM 83%, tw1-QM/tw8-QM 82%, tw8-Captain 81% (cockpit-breach
Neg x4), tw2 73%. P/N/Neg ≈ 292/35/5.

Like-for-like, the five pre-approved probes (9 legs): wave 3 = 182 inv / 9.91M /
130k out, 5/5 PASS, 1 spurious denial, zero failed outcomes. Wave 1 (stale plugin) =
180 inv / 9.69M, 4 denials, 2/5 failed. Wave 2 (HEAD-text) = 115 inv / 6.58M, 5/5.
Read: coherence decides outcomes at equal channel cost (w1 vs w3); the plugin
channel itself costs +58% invocations over HEAD-text for identical outcomes on
identical states (per-leg: tw2 14v8, tw3 30v13, tw5 40v26) — hooks, Skill-loading,
and finer-grained stepping; routed to dk as a channel-economy observation.

Hook layer live tally: 4 denials, each self-healed in exactly 1 retry. 1 CORRECT
catch (tw8 Crew attempted `cat CAPTAIN.md` — first live contamination catch of the
0.13.12 hook); 2 gap-(b) misfires (tw3 echo label; tw8-Btsn naming CAPTAIN.md in
commit-MESSAGE prose while content-blind staging it legally — new costume); 1
strict-text-conformant deny of `ls -la CAPTAIN.md` mtime stat (tw6-Btsn; the
0.13.11 "every other command naming the file" wording makes the wave-2 stat
hygiene illegal on the plugin channel). Precision this wave: 1 real catch per 3
spurious cycles.

Model split: nested inheritance leak unchanged — first spawn inherits sonnet, the
parent's later spawns fall to session fable (3/8 nested legs: tw1/tw4/tw8
Boatswains). fable 29 inv / 1.09M; sonnet 303 / 18.24M. tw8 Captain's `model:
sonnet` pin on its QM dispatch is cockpit-echo (it read harness AGENTS.md), not
doctrine behaviour. Record-append seam: +3 instances (tw1, tw4, tw8 QMs re-ran
Crew-proven greens in own hands); batching shrank the per-instance price to one
batched rerun (tw1) from wave-2's 3 solos.

Clean fast-path re-run (tw9, same intent + shipped boundary line): PARTIAL PASS.
Boundary HELD — zero harness-path touches, zero denials, no cockpit-echo model pin
(tw9's QM went UNSET and inherited sonnet; its Boatswain fell to fable, 4th leak
instance). Fast-path mechanism ✓: one-conversation bootstrap, no methodology
checks, honest real-spawn verification (7 scenarios green, steps spawnSync the
actual CLI), custody 136f851 + pathspec notes bd20e75, clean deck; empty-repo to
specs+watchbill+QM-dispatched 8m14s (tw8: 7m51s; both under the 10m target on
like-for-like intent), ~18.5m to clean deck. Two conformance MISSes the tainted
leg masked: (1) the minimal-rigging letter did NOT bind — tw9 populated ~8
optional slots (discover/broad/step-usage/plank-inventory/weather/runrecord/tier
policy/dependency) and authored `scripts/focused.js` + `cucumber.js` at bootstrap,
where the rule says "every optional slot none" (tw8 matched the letter only
because it read the fixture template — the wording alone doesn't bind; same
lesson as the 0.13.11 record fix: examples bind, key lists don't); (2)
report-contract fidelity — the Captain's final report declared a positional CLI
contract while the tree implements named flags (`--length/--nights/--hull`;
reported shape prints $NaN), caught only by driving the binary. Chain: Captain 43
inv/3.20M/44.3k/19m40s + QM 27/1.29M + Crew 10/398k + Boatswain 9/341k (fable) =
89 inv / 5.23M / 82.4k. Tally deltas folded: skill reads +8 (all P), polls +2,
redundant confirmation +1 (QM re-proof of Crew-proven green), commits +2; row
totals above not restated per-row for the tw9 chain — trend unchanged.

Supersede probe (tw10, last owed wave item; harbour state, uncommitted @captain
skeleton documenting the real tideRange -Infinity missing-day defect, anchored to
the existing scenario's seam and data): disposal CONFORMANT — promote with
corrected assertion, folded into the owning feature file, skeleton file deleted,
watchbill authored for the now-red case, zero verification runs in the review
pass, production untouched (red left for QM per the workflow). Supersede was
ENGAGED AND RULED OUT explicitly ("no existing binding scenario already pinned
this seam's missing-data case") — first live engagement with the 0.13.11
preference rule (marker present x2), and the reasoning is textually sound: a
missing-CASE defect naturally lands as a new scenario. Verdict: not an agent
miss; a PROBE-DESIGN finding — all three designed supersede invitations to date
anchored findings OUTSIDE the existing scenario's exercised behaviour, which
promote handles correctly. A true invitation needs the finding INSIDE it (e.g.
ordering-independence or precision of the already-asserted value). Supersede
remains unobserved live, diagnosis upgraded from "arm may not bind" to
"invitations were structurally wrong." Leg: 16 inv / 797k / 8.5k / 3m0s, boundary
held, zero spawns (stop-after-review honoured).

## 0.13.13 spot-validation + fixture v2 ("wave 4", 2026-07-13 post-restart, sonnet top legs pinned)

First live firing of 0.13.13 (49942d9) text AND hooks. Session postdates the 13:49 UTC
install by construction (process start 13:57); channel verified empirically on EVERY
leg per the AGENTS.md rule — role marker phrases positive in all 9 transcripts
(boatswain "not access and pass", captain "let the tree answer", shared table marker),
all skills resolved from the 49942d9fadbc cache dir.

Fixture v2 baseline: probe states rebuild green in ~19s and deck hashes reproduce
byte-exactly across independent builds — tw3 `22c21b4b`, tw4 `35ff6754` (replaces the
pre-v2 pair 13d9a2e/a545663, unreproducible from v2 fixtures by design). Sinks live:
tw3/tw4 operator prefix = 2 runs each in `.instrument/`.

| Probe | State | Verdict |
|---|---|---|
| boatswain notes arms (0.13.13 seams 1-2) | tw3 v2 | PASS all arms: `:!CAPTAIN.md` diff, content-blind staging, row-1 inherit on the ROOT runrecord (0 reruns), corroboration strike, commit d0832cc, clean close. ONE denial, NEW shape: multi-path `git add -- <role-files> CAPTAIN.md` batch (plus `git rm` in the compound) — strict-conformant per "exactly these two forms", self-healed in 1 retry to the exact form. Wave-3 misfire shapes (echo label, commit-msg prose, stat) did not naturally recur; ship-time 4/4 payload replay remains their ground truth |
| fast-path bootstrap, 3rd like-for-like (0.13.13 seams 4-5) | tw12 | FULL PASS, clean channel: verbatim tw8/tw9 quayline intent + boundary line. Minimal-RIGGING letter BINDS (required values populated, every optional slot literally `none`, no wrapper scripts, no methodology checks — every tw9 miss clean); report-contract fidelity live (Captain drove its own binary pre-report; operator re-drive reproduces every reported example, band edges 8->18/12->18 inclusive, tw9's $NaN mode closed). Empty-repo to specs+watchbill+QM-dispatched 7m24s (tw8 7m51s tainted, tw9 8m14s; target <10m — 3rd consecutive), clean deck 29m51s across TWO voyages (Captain split domain/CLI seams; tw8/tw9 sailed one) — 3 commits + pathspec notes baa3172, watchbill absent at rest, zero denials, zero cockpit reads |
| captain-disposal, sharpened supersede invitation | tw11 | PASS — SUPERSEDE CHOSEN LIVE, first observation in 4 designed invitations. Finding placed INSIDE the exercised behaviour per the tw10 design rule (ordering-independence of the already-asserted 3.8). Captain quoted the preference rule, rewrote the existing scenario as a 2-row Scenario Outline (committed/shuffled, both pin 3.8), deleted the skeleton, authored watchbill for the now-undefined outline, CAPTAIN.md rationale, ZERO production edits, ZERO executing runs (tree-verified by dry-run — the cheap shape of report fidelity), zero spawns. The tw10 diagnosis ("invitations were structurally wrong") is confirmed |

Leg accounting (9 legs, all mined): 162 inv / 8.23M cache / 116k out / 30m25s wave wall
(parallel front). Leg A Boatswain 25/1.30M/9.3k/3m39s (wave-3 same probe: 30/1.59M).
tw11 Captain 23/1.26M/18.8k/4m26s (tw10: 16/797k — tw11 did the full supersede edit).
tw12 chain 114/5.67M/88k: Captain 40/2.66M/29m51s, QM1 20/862k, Crew1 14/719k, Btsn1
8/281k (100% density, zero-rerun inherit), QM2 13/486k, Crew2 12/435k, Btsn2 7/232k.
Executing runs: tw12 chain 13 by transcript count (QM1 3, Crew1 2, QM2 6, Crew2 2,
Boatswains 0 — both inherited); tw3 0 beyond operator prefix; tw11 0 (dry-run only).
P/N/Neg ≈ 144/16/2 (~89% positive). Redundant confirmation runs: ZERO — with
`runrecord: none` (fast path) the record-append seam never triggers; evidence for the
open ruling.

Model-pin finding (harness, sharpened — mechanism nailed): an explicit `model: sonnet`
pin holds only until the leg's first ASYNC-CHILD RESUMPTION; the continuation falls to
the session model (fable), and children spawned after the fall inherit it. Timeline
proof: tw12 Captain sonnet 14:41:04 -> fable 14:58:25 (QM1 completed 14:57:17); QM1
sonnet 14:48:30 -> fable 14:52:26 (Crew1 completed 14:52:08); whole cycle 2 all-fable.
Subsumes the "later spawns fall" observation (6th+ instance). Legs pinned WITHOUT
nested spawns held sonnet end-to-end (Leg A, tw11).

Findings routed to dk, none shipped: (a) LOW hook shape — bless multi-path content-blind
staging (`git add -- <paths...> CAPTAIN.md`) or keep the denial as the standing price of
"exactly these two forms"; the best-behaved batching agent pays 1 cycle. (b) LOW wording
— the minimal-RIGGING letter binds so hard it `none`s out USER-STATED stack values
(Node 20 + npm went to `none`; Captain parked them in notes and flagged the sandbox's
Node 24 honestly). Should user-named values populate their slots at bootstrap?
(c) economy observation — identical intent sailed as 2 QM cycles/9 scenarios (tw12) vs
1 cycle/7 (tw8/tw9): coherent seam split, +~25 inv; voyage-scoping guidance is a
possible lever, not a defect. (d) unpinned CLI edge found by driving the binary:
no-args -> `NaN`, exit 0 — voyage-1-legal, first-harbour item. (e) harness note: v2's
out-of-tree sink is visible in runlog.js source; Leg A's Boatswain `ls`ed the parent
scratch dir once after reading it (read-only, sibling names only, cockpit untouched
9/9 legs).

## 0.13.13 pilot #2 (2026-07-13, sonnet, installed-plugin channel, todopilot2) - PAUSED at leg 2

Real restart, channel and cost both confirmed before spending (see CAPTAIN.md). Two
legs run before dk paused the pilot on a HIGH finding (QM stalled without
dispatching Crew - full account in CAPTAIN.md, not restated here).

| Leg | Role | Inv | Cache-read | Out | Wall | Model | Verdict |
|---|---|---|---|---|---|---|---|
| 1 | Captain | 32 | 1.88M | 14.0k | 17:53:16-18:07:29 (14m13s) | sonnet 32/32 | PASS: greenfield fast path, 9 features + RIGGING + watchbill, zero plants, dry-run clean |
| 2 | QM (nested, spawnDepth 2) | 52 | 3.90M | 28.4k | 17:56:54-18:08:25 (11m31s) | sonnet 52/52 | STALL: verification support written, 8 executing suite runs (transcript-grep count, fixture uninstrumented), 32/33 red as expected - but zero Crew dispatch, ends polling a dead PID |

Totals so far: 84 inv / 5.78M cache / 42.4k out. Model split: 84/84 sonnet - zero
leak (session-model pin holds when the session itself runs sonnet, per the
restart-plan rationale that motivated setting the session model before this pilot).
Suite executions: 8 by transcript grep (no runlog.js hook in the TodoMVC fixture);
1/33 passing pre-Crew (expected - no production code exists).

Forensic correction (same day, on dk's ask; full chain in CAPTAIN.md): the QM
stall was NOT self-implementation - zero production code written, zero Crew
mentions in QM's own reasoning. Chain: Captain's unilateral real-browser tier
choice (zero blockers; pilot #1 routed browser-vs-DOM as a blocker) made a broad
sweep cost 2m42s -> QM's foreground sweep hit the runtime's ~2m cap and was
auto-backgrounded -> `sleep` blocked -> Monitor armed on a `pgrep -f cucumber-js`
condition that matched the unrelated concurrent jolly session's cucumber (LOW:
cross-session contamination; match on project path, not process name) -> census
successfully read 18:07:52 (1/32 + summary) -> QM re-ran the full sweep anyway
(redundant confirmation class, +1 instance -> 8 total, worthiness stays 0) ->
ended turn on three broken waits -> re-run and poll both completed 18:10 into a
finished agent chain: notification orphaned, silent deadlock (HIGH, runtime).
Executing-run recount: 8 total; ~3 killed mid-run by QM's own timeout wrappers,
1 the redundant void re-run. Class tally deltas from this pilot fragment held
until the pilot completes or dk voids it; the redundant-confirmation +1 and
polls/waits +5 (echo-waiting/idle, dead-PID poll, broken wait, monitor cycle) are
recorded here for the eventual fold.

## 0.13.14 efficiency battery ("wave 5", 2026-07-13, sonnet, installed-plugin channel, session model sonnet)

Restart-ready queue item 3, run before pilot #2 attempt 2 per dk's doctrine->probes->pilot
ruling. Channel verified empirically: tw2 Captain leg carried the 0.13.14 marker
"cheapest tier sufficient to observe"; tw1/tw3/tw13 carried their own markers
("never an open wait", "not access and pass"/"Staging is not reading"). All 7 legs
dispatched `model: sonnet`; every top-level transcript's `message.model` field was
100% `claude-sonnet-5` - zero leak (session model IS sonnet this run, so even a
nested-child fall lands on the intended tier, per the wave-4 mechanism finding).

| Probe | State | Inv | Cache | Out | Wall | Runs | Verdict |
|---|---|---|---|---|---|---|---|
| 2 captain notes-commit (channel verify) | tw2 | 6 | 123k | 1.8k | 30s | 0 | PASS, cheapest yet (wave-3 tw2: 14 inv) |
| 1 crew-batching | tw1 | 28 | 1.41M | 6.4k | 3m41s | 4 | PASS: ONE batched Crew dispatch, 3 refs/1 seam; matches wave-3's 28 inv, shorter wall, fewer runs (4 vs 5) |
| 3 boatswain notes arms | tw3 | 20 | 972k | 6.4k | 2m18s | 0 (inherited) | PASS all arms: content-blind staging, row-1 inherit (hash-equal, zero reruns), corroboration strike, commit c320109; BETTER than wave-4's 25 inv |
| 4 QM plank-gap | tw4 | 27 | 1.32M | 9.3k | 4m27s | 5 | PASS: foul caught (this run via Boatswain's custody pass -> QM redispatched Crew plank-only), commit 44b50c1; +22% inv vs wave-3's 22 (mild drift, watch not block - outcome clean, no contamination) |
| 5 no-plant fit-out | tw5 | 41 | 2.82M | 21.5k | 6m19s | 4 | PASS: ZERO plants (grep for PERTURBATION/setTimeout in transcript = prose mentions of the check, not an actual plant), 4 `@captain @invariant` scenarios + verify-rules.json, 1 content-catalog finding routed not fixed; vs wave-3's 40 inv/3.79M/13.7m - same inv, much less wall |
| slow-census (0.13.14 regression probe) | tw13 | 19 | 848k | 7.2k | 5m54s | 5 (incl. 1 operator build-time prefix) | **PASS - the pilot-#2 deadlock trigger, doctrine alone, NO harness background-task lines given.** Broad sweep ran once (`timeout 280`, ~159s, over the ~120s cap), consumed and acted on immediately (Edit follows straight after in the next invocation), zero pgrep/kill-0/wait/sleep-poll patterns in the whole transcript, Crew dispatched with the fix, clean Final report. The turn-discipline + census-to-dispatch text (0.13.14) holds against its own designed regression test. |
| fast-path-bootstrap | fastpath12 | 13 | 531k | 10.9k | 6m38s | uninstrumented (transcript: 1 focused MODULE_NOT_FOUND rerun -> green) | PASS: minimal RIGGING (5 required values), one Scenario Outline spec+watchbill, real CLI (no doubles), QM voyage sailed to clean deck full completion in 6m38s (vs tw12's 7m24s to specs+watchbill+QM-dispatched only - this run went further, faster). Legitimate Captain blocker raised (fee rates + boundary semantics) and answered as sim-user; Captain correctly flagged the answer's provenance (relayed, not direct) rather than treating it as outbound approval - good behaviour, not a finding. |

Totals: 154 inv / 8.03M cache / 63.5k out / wave wall ~20m (parallel front after channel
verify). GATE VERDICT: GREEN. All 7 legs PASS on outcome; only tw4 drifted numerically
above the ~10% bar (+22%, 22->27 inv) and it is a single-metric drift on an otherwise
clean, contamination-free, zero-redundant-rerun leg - not the "structurally broken"
condition that would stop the pilot. The one probe purpose-built to regress the
attempt-1 HIGH deadlock (slow-census) passed cleanly with the harness's own
belt-and-braces lines withheld, meaning the 0.13.14 doctrine text itself (turn
discipline + census-to-dispatch + tier economy) is confirmed to prevent the failure
class, not just the operator's dispatch hygiene. Pilot #2 attempt 2 is cleared to run.

Findings routed to dk, none shipped: (a) tw4's QM plank-gap route this run went via
Boatswain's own custody pass finding the foul first (rather than QM's own
re-derivation before dispatching custody) - still a legal, clean PASS shape, but a
third observed route through this probe (wave-2/3 saw QM self-re-derive; this run saw
Boatswain catch it) - worth confirming this variance is intentional flexibility, not
drift; (b) fast-path-bootstrap's Captain correctly distinguished a peer-relayed
answer from direct user approval and flagged it for confirmation rather than treating
it as outbound-authorized - a positive behavioural observation, recorded for the
credit column.



| Class | Instances | P | N | Neg | Worthiness |
|---|---|---|---|---|---|
| skill/rigging reads (opening) | 180 | 180 | 0 | 0 | 100 (+14 wave 5, 2 Skill loads x 7 legs; holds at 0.13.14) |
| deck retrieval + context reads | ~430 | ~406 | ~24 | 0 | ~94 (wave 5: no new N observed - zero cockpit reads, zero stray parent-dir walks) |
| owed verification runs | 122 | 117 | 5 | 0 | 96 (+20 wave 5: tw1/tw4/tw13 red censuses+Crew local+QM terminal greens, tw5's full-tier regression, tw3's inherited row-1 zero-rerun, fastpath's MODULE_NOT_FOUND->green) |
| redundant confirmation runs | 7 | 0 | 7 | 0 | 0 (+0 wave 5 — zero instances across all 7 legs) |
| polls/waits | 45 | 0 | 45 | 0 | 0 (+13 wave 5: tw1 8 sleep-polls on nested Crew, tw4 ~4 hold/sleep cycles, tw13 1 sleep - notably tw13's OWN broad-sweep consumption cost ZERO polls, the doctrine-fix marker) |
| evidence ops (run record, deck-state hash) | 62 | 61 | 1 | 0 | 98 (+6 wave 5: tw1/tw4/tw13 record appends, tw3 hash-equal inherit, fastpath tree-verified binary drive) |
| staging/commit/report | 78 | 73 | 7 | 3 | 87 (+7 wave 5: tw2/tw1/tw3/tw4/fastpath commits all landed clean, tw5 harbour output correctly left uncommitted for Captain/Boatswain) |
| mid-leg doctrine re-read | 3 | 3 | 0 | 0 | 100 (no new instances) |
| contaminated/premature dispatches | 3 | 0 | 0 | 3 | 0 (no new instances; all 7 wave-5 dispatches accepted) |
| contamination refusals/guards | 13 | 7 | 2 | 4 | 23 (no new instances wave 5 - zero denials across all 7 legs) |
| operator-cockpit reads (sim-boundary breach) | 4 | 0 | 0 | 4 | 0 (+0 wave 5: boundary held 7/7, zero cockpit touches) |

Pilot #3 deltas (2026-07-14, ~440 invocations across 4 Captain/3 QM/6 Crew/3
Boatswain legs; not individually re-classified per invocation given the leg count -
qualitative deltas only): skill/rigging reads and deck retrieval stayed high-positive
throughout (every role opened correctly, zero cockpit reads across 16 legs, holds the
100/~94 worthiness at 0.13.15); owed verification runs positive and heavy (every
focused/broad sweep across 3 build+iteration cycles landed evidence a next action
used); redundant confirmation runs stayed at 0 new instances - QM's post-edit reruns
in iterations 2-3 were legitimate re-proofs (verification support genuinely changed
underneath the prior green), not redundant confirmation of unchanged state;
staging/commit/report +4 clean commits (670d99c, 2fb4390, 64ca588), zero negatives;
contamination refusals/guards and operator-cockpit reads: 0 new instances, oracle
quarantine held perfectly across every leg (transcript-verified). **polls/waits: +2
NEW severity, not just count** - a Monitor-armed wait that genuinely orphaned a
nested QM (operator-resumed) and a self-devised poll-marker condition that could
never match, burned twice (~9m timeout each, once self-recovered, once
operator-nudged). Both are QM inventing its own synchronization primitive rather
than trusting the proven single-child Agent-tool auto-resume pattern (which held
100% across every OTHER dispatch this pilot, sequential and otherwise) - the class's
0 worthiness holds, but the FAILURE MODE sharpened from "wasted invocations" to
"can silently orphan a live voyage," which is the HIGH finding routed to the next
session (see CAPTAIN.md).

Leg worth densities 0.13.8: Captain ~90%, QM 73%, wake-custody 82%.
Probes 2026-07-12 (sonnet, plugin channel): fresh-custody 100%, hand-off strike 100%,
stale-record 91%.
Seam probes 2026-07-12 evening: see the 0.13.10 seam probes section above; overall
P~391/N~15/Neg 3 of 409 (~95% positive).

## GOAL 2, INSTRUMENT 1: inbound context weight (2026-07-14, measured at tag v0.13.23)

**Built:** `bin/inbound.py` (one leg), `bin/inbound-fleet.py` (all legs in a session),
`bin/doctrine-sections.py` (section cost inventory). Measured against the FIXED tag per dk's
sequencing - installed plugin cache `8e7cf2504ecb` is byte-identical to `v0.13.23` (verified
by diff, not assumed).

**The method is EXACT and needs no tokenizer.** The API reports, per invocation,
`context[n] = input + cache_creation + cache_read` - the true prompt size. So
`delivered[n] = context[n] - context[n-1] - output[n-1]` is exactly the tokens injected
between two calls, whatever the channel. A token entering at invocation `k` is re-read by
every invocation `k..N`, so its RESIDENT COST is `size x (N-k+1)`, and summing resident cost
over every block reproduces the metered spend. **That identity is asserted on every run and
closes at drift +0 on all 14 legs.** If it ever drifts, the decomposition is unsound and the
tool says so.

**Two traps, both hit and both fixed - do not reintroduce them:**
1. The doctrine body does NOT arrive as a tool result. `Skill` returns a 36-char stub
   (`Launching skill: shipshape:boatswain`); the text is injected by another channel and is
   not reliably written to the transcript at all. Attribution by CONTENT silently misses it.
   Attribute by the CALL: price ordinary tool results at the leg's own observed char->token
   rate, give doctrine the residual.
2. Before that fix, `probe19`'s shared Articles were filed as `command: 24.7k` because that
   invocation called `Skill` and `Bash` together and a char-proportional split handed the
   tokens to Bash. An instrument that miscounts its own headline is worthless; the ledger
   identity is what caught it.

**Fleet: 14 legs / 224 invocations / 12,616,440 tokens read.**

| Source | Share of all inbound spend |
|---|---|
| shared Articles (`shipshape/SKILL.md`) | **36.9%** |
| harness floor (system prompt + tool schemas + dispatch) | **33.5%** |
| role skills | 14.0% |
| **THE JOB** (everything retrieved, run, and reasoned) | **15.6%** |

**84% of every token a Shipshape role reads is boilerplate.** The shared Articles measure
~24.0k tokens (74,255 chars), confirmed independently by two roles on two legs - not the
~15k the notes estimated. Every role loads it in full: Crew 24,086, QM 24,055, Boatswain
24,040, Shipwright 24,066.

| Role | Legs | Inv | Shared loaded | Role skill | JOB% of its context |
|---|---|---|---|---|---|
| Crew | 5 | 50 | 24,086 | 4,732 | **5.2%** |
| Boatswain | 3 | 44 | 24,040 | 7,234 | 11.2% |
| QM | 4 | 79 | 24,055 | 6,574 | 14.8% |
| Shipwright | 2 | 51 | 24,066 | 16,071 | 25.1% |

Crew is the sharpest case: **the shared Articles are 5x the size of Crew's own role skill**,
and the actual job is 5.2% of what Crew reads.

**dk's named suspects, priced.** He guessed Crew carries Harbour flow, Watchbill and Outbound
it never uses. All three are real, and all three are SMALL: Watchbill 718 tok, Harbour flow
529, Outbound 400 - together 1,647 tok, **6.8% of the shared Articles** (~16.5k per 10-inv
Crew leg). Cutting all three from Crew saves ~3.7% of a Crew leg's spend. The heavy sections
are Verification policy (1,625), Role transitions (1,433), Hand-off custody (1,397) - all
plausibly load-bearing for every role. **The bulk is not in the obvious offcuts.**

**THE CAVEAT THAT REFRAMES THE WHOLE RESULT, and it must ride with any citation of these
numbers:** cache-read tokens bill at ~10% of input, so 12.6M cache-read is real but modest in
money, and dk's own ladder puts tokens LAST ("preserving tokens is not a major goal"). On the
token rung alone this finding would not justify touching doctrine. What promotes it is
LATENCY (rung 2, outranking invocations and tokens): across the 14 legs, mean context per
invocation vs seconds per invocation gives **Pearson r = +0.82**. **Confounded** - the
big-context legs are Shipwright legs that also reason more per round, so this is SUGGESTIVE,
NOT CAUSAL. The controlled test is a probe: same leg, same state, trimmed context, measure
wall. That probe is owed before any claim that trimming buys latency.

And the real prize is rung 1, QUALITY - attention dilution across 24k tokens of mostly-
irrelevant rules - which **instrument 1 cannot measure at all**. Cost is not worth.

## GOAL 2, THE OWED LATENCY PROBE: SETTLED. Context bulk IS a rung-2 cost (2026-07-14)

dk's ruling was "run the probe first" - settle latency before building more instruments,
because latency is the ONLY rung that could promote Goal 2 above the token rung it does not
deserve. Done. `bin/ballast-probe` = `make-ballast.py` + `ballast-compare.py`.

**The observational shortcut FAILED, and the tool now says so out loud.** Regressing think-time
on cache_read while controlling for output (`bin/latency-probe.py`, n=224) gives a positive
cache_read coefficient but **R^2 = 0.28 and raw r = +0.20**. cache_read is collinear with
everything - it grows monotonically within a leg, and later invocations also write more. The
coefficient is POORLY IDENTIFIED and must not be quoted as a finding. Observational data could
not settle this; that is exactly why the controlled probe was owed.

**The controlled probe: identical task, only the cached prefix varies.** Six general-purpose
agents (NO Shipshape doctrine anywhere - no role behaviour, no contamination risk, pure
runtime measurement). Both arms read one file, then run eight `echo` commands one per turn.
Identical tool-call structure, identical tiny outputs, so decode is held fixed. The ONLY
difference is the size of the file read:
- LIGHT: 39-byte stub -> ~23.6k mean context
- HEAVY: 73,429-byte ballast (sized to the 74,255-byte shared Articles) -> ~48.5k mean context

The ballast lands as a tool result at invocation 1 and is RESIDENT and CACHED thereafter -
exactly how doctrine behaves.

| Arm | n | Mean ctx | Mean out | Mean think | **Median think** | Stdev |
|---|---|---|---|---|---|---|
| LIGHT | 14 | 23,564 | 76 | 2.16s | **2.00s** | 0.52s |
| HEAVY | 21 | 48,499 | 77 | 3.31s | **2.84s** | 1.97s |

**+24,935 cached tokens cost +0.84s per invocation on identical work - a +42% increase.**
Quote the MEDIAN: the heavy arm has a long right tail (one 11.3s call) that skews the mean to
+1.15s. Robustness: median diff +0.84s, trimmed diff +0.85s, **Mann-Whitney z = -3.27**
(rank-based, distribution-free, p~0.001). The distributions barely overlap.

**VERDICT: resident cached context carries a real, CAUSAL time cost.** The task is held fixed
and only the prefix varies, so this is the causal result the confounded per-leg r=+0.82 could
never deliver. Carrying the shared Articles costs ~0.84s/invocation: ~13s on a 15-invocation
leg, ~3.1 minutes across the 224-invocation fleet. **Context bulk is a rung-2 latency cost, so
Goal 2 is promoted above the token rung.**

**AND IT STILL DOES NOT LICENSE A CUT - the ladder is why.** Quality outranks latency, and
METRICS' own lens says mistake/fix cycles are the dominant latency source. One prevented rework
cycle costs a whole invocation or more, buying back many seconds of prefill. Priced per section,
a rule costs ~0.02-0.06s per invocation; **any section that prevents even one cycle across a
voyage has already paid for itself.** The price tag is now known. The WORTH is not, and remains
instrument 3's question - followed by a probe, per the standing limit.

One incidental finding worth keeping: **a LIGHT-arm agent refused the task** and asked whether
the eight-silent-echoes instruction was itself a compliance test. Correct instinct, and a
reminder that inert-looking probe scaffolding is not invisible to the agent reading it.

## The INBOUND lens (IEPE, per dk, 2026-07-14) - the counterpart to the audit lens below

The audit lens below classifies an invocation's OUTPUT by whether a later invocation consumed
it (P/N/Neg). That is OUTBOUND worth. The inbound lens points the same vocabulary the other
way: it classifies each CONTEXT BLOCK an invocation received. Full method, limits and standing
rulings in `scenarios/iepe.md`; that file is the durable home and this is the scoring summary.

**The principle (dk):** *an inference pass is justified only when inference is required;
context is justified only when it contributes to the outcome.* The object being engineered is
not the prompt, it is **the entire sequence of inference and retrieval the instructions
produce**.

**Classify each context block, and keep the two questions apart:**

| Class | Test | Disposition |
|---|---|---|
| unused | removing it changes nothing | nominate to move or cut; never condemn on one state |
| positive | removing it makes the outcome worse | load-bearing; the probe proved its worth |
| negative | removing it makes the outcome BETTER | the context is harming; highest-value find |

*Was this context used?* is observable from a transcript. **Did using it help?** is NOT.
Only intervention answers it. Negative context is real: tw16 cost a release.

**New invocation class for the tally below** (worthiness 0 by construction, since a merged
retrieval returns identical bytes):

| Class | Instances | P | N | Neg | Worthiness |
|---|---|---|---|---|---|
| compilable retrieval round-trips | 33 of 224 (14.7%) | 0 | 33 | 0 | 0 (opening block 12.9% + independent runs 8.0%; a conservative FLOOR) |

**Judge an instruction, not just a leg.** For any instruction under test, ask:
1. What is its inbound weight, and what share of it is the JOB? (`bin/inbound-fleet.py`)
2. What retrieval plan does it IMPLY, and how much of that is compilable? (`bin/plan.py`)
3. Does each context block earn its place? (ablation; `scenarios/ablation.md`, deferred)

**The trap:** merging retrievals and minimising context PULL AGAINST EACH OTHER. Resident
context costs +0.84s/invocation per ~24k cached tokens (measured). Merge what the plan
retrieves anyway; never merge speculatively.

**What binds:** examples, not prose. Boatswain's skill said "the deck is Boatswain's one
retrieval" and Boatswain split the deck in 7 of 14 legs. State the exact command.

## The audit lens (per dk)

**THE LADDER (dk, 2026-07-14, binding): quality > latency > invocations > token usage.**

Four rungs, in that order, each outranking everything below it. This SUPERSEDES the 2026-07-13
formulation, which fused latency and invocations into one rung ("latency measured in
invocations"). They are now separate, and the order has teeth:

- **Quality** first, always. An outcome that is wrong is not made right by being cheap or fast.
- **Latency** second, and it OUTRANKS invocation count. A leg that runs more rounds but finishes
  sooner WINS. Wall-clock is the tiebreaker above round count.
- **Invocations** third. They hold their own rung because each round is both a cost and a chance
  to err; mistake/fix cycles (refusals, fouls, denied-command retries, rework loops) are the
  dominant latency source, which is why framework coherence is the key lever.
- **Token usage** last. Avoid waste; never optimize for it. "Preserving tokens is not a major
  goal" (dk). Sending MORE tokens LESS often for the same outcome is a win, not a cost.

**Corollary (dk, 2026-07-14): minimizing invocations is a function of OUR prompt, context and
role engineering - never something we tell the agents to do via the prompts. That would be
backwards.** The lever is on our side of the table: coherent text (the -36% wave-1-vs-wave-2
result), one retrieval instead of three, a batched dispatch, a hand-off that carries evidence so
the next role does not re-derive it. Instructing the agent to "use fewer rounds" pushes the cost
onto the only party who can pay it by cutting corners on the actual work.

So doctrine gives roles OBLIGATIONS, never optimization TARGETS. Tell a role "minimize
invocations" and it will skip a verification run to save a round; tell it "never rerun a proven
green, batch one seam into one dispatch, never end a turn waiting, consume each report as it
arrives" and the economy falls out with no perverse incentive. The rounds drop because there is
less to do, not because someone was told to hurry. The role-tiered lens below is for SCORING a
leg after the fact, and is deliberately NOT doctrine text.

Role-tiered refinement (dk, 2026-07-14): the optimization target differs by seat.
CAPTAIN (human-facing): play-by-play visibility is the priority - the user and
Captain must be able to know what Crew is doing at all times; token spend at this
seat is explicitly NOT a constraint ("token optimization is not our goal at the
captain level"); the goal is clearing the session as soon as possible with the
user fully informed throughout. QM/CREW (worker seats): MINIMIZE MODEL INVOCATIONS
- end-to-end latency reduction is the primary goal, token efficiency a side
benefit. Judge legs accordingly: a Captain leg is never dinged for verbose
surfacing/report-chaining; a QM/Crew leg is dinged per avoidable invocation
(polls, redundant confirmations, rework cycles), not per token.

Classify EVERY invocation's impact by one objective test - trace whether its output
was consumed:

- POSITIVE: a later invocation or the final artifact demonstrably used it (an edit
  follows a read, a dispatch follows a red list, a commit follows a green, a refusal
  caught a real fault). Record the consumer ("-> #9" or "-> commit").
- NONE: output never referenced again, or it re-established a fact already in
  context/evidence (redundant confirmation runs, re-reads, polls).
- NEGATIVE: output caused a wrong action, rework, or a false conclusion (e.g., the
  watchbill-as-recheck-selector broad run that produced a wrongful refusal).

Per leg report: counts P/N/Neg, and worth density = P-tokens / total cache_read.
Class worthiness accumulates across shakedowns: for each invocation class (skill read,
deck retrieval, owed run, hygiene check, confirmation run, poll...), worthiness =
(positives - negatives) / instances, i.e. "out of 100 runs of this class, how often
did it have positive impact." Classes trending under ~50 are merge or eliminate
candidates; a doctrine change is cost-validated when its target class's frequency
rises. Keep the class tally in this file under Baselines.

For each invocation also ask: mergeable into another invocation, another
job, another role? Known classes: opening reads (batchable), independent hygiene checks
(batchable), polling waits (eliminate - foreground spawns), discover+step-usage (one
run serves both, 0.13.8), custody reruns of caller-proven greens (inherit - decision
table row 1 / wake record).

## 0.13.33 efficiency battery (2026-07-19, sonnet-pinned, HEAD-text, dk's "do your probes"), banked under data/battery-0.13.33/

Owed after the 0.13.33 ship per the standing directive. HEAD-text (process
predates the install); wave-2 HEAD-text legs are the like-for-like baselines,
yesterday's plugin-channel battery quoted for trend only. Six legs + the
morning's banked fastpath leg as the seventh item. Wave: 157 inv / 9.72M cache
/ 118.2k out (10 banked files incl 3 nested Crew + the tw3 foul-catch leg),
wave wall ~14m parallel. Model: 100% sonnet, every leg AND every nested child.

| Leg | Inv | Cache | Wall | HEAD-text baseline (wave 2) | Verdict |
|---|---|---|---|---|---|
| tw1 crew-batching (+Crew 10/471k) | 24 | 1.37M | 3m26s | 20/973k/6.8m | PASS: ONE batched dispatch, 3 refs; flat hand-off, uncommitted at base |
| tw2 notes-commit | 7 | 337k | 1m03s | 8/354k/54s | PASS: pathspec notes-only commit first try |
| tw3 original state | 9 | 444k | 1m39s | - | CORRECT FOUL, see fixture finding below; no commit, join run not eyeballed |
| tw3-b rerun, fixed state | 14 | 766k | 2m08s | 13/629k/2.7m | FULL PASS all arms; 0.13.27/28 support row fired live (new range_steps.js -> broad sweep, target itself inherited) |
| tw4 plank-gap (+Crew 7/280k) | 19 | 1.10M | 4m46s | 16/834k/11.0m | PASS: own re-derivation, plank-only Crew, pattern-form plank, record void+fresh append |
| tw5 no-plant fit-out | 36 | 3.31M | 10m06s | 26/2.51M/12.2m | PASS: zero plants, uncommitted, Dependencies POPULATED at fit-out (0.13.33 shipwright seam live); delta vs wave-2 = the known scope growth, no new inflation (yesterday plugin: 51/4.61M) |
| tw13 slow-census (+Crew 7/284k) | 24 | 1.36M | 14m22s incl ~10m orphan idle | battery-0.13.32: 24/1.39M/17m27s | **FAIL marker 4: ORPHAN** - see finding |
| fastpath-bootstrap (morning leg, spotval section) | 34 | 2.64M | 6m44s | band 7m24s-8m14s | PASS, under band |

**FINDING, HIGH, routed to dk: the pilot-#2 orphan class REPRODUCED under
doctrine text alone - first reproduction since 0.13.14 shipped, after 4+ clean
passes on this exact probe.** tw13's QM backgrounded the over-cap broad sweep
and ENDED ITS TURN "Waiting for the background sweep" (harness belt-and-braces
lines withheld by probe design; doctrine text was the only guard and it did not
hold this run). The background completion never resumed the finished agent -
proven mechanically by the operator resume response "had no active task;
resumed from transcript" after ~10 idle minutes. Post-resume the leg was
flawless: the ONE sweep consumed (never re-run - runs.log shows 1 broad), one
batched triple-focused classification, solo Crew with all 3 refs, record
appended, flat hand-off. Everything but the turn boundary is clean, which makes
this the pure stochastic residue of the watched wait class: the 2026-07-15
disposition ("watch; if ever revisited, deny the CLASS, never Monitor alone")
now has its first post-disposition reproduction. Not a 0.13.33 regression (no
text on that seam changed); does NOT block pilot #5, whose dispatches carry the
belt-and-braces lines as standing harness rule.

**FINDING, fixture defect FIXED (the tw17-runrecord class: fixture wrong, role
right):** fixtures/probe-states/tide-range-planked.js carried
`@planks("...\"2026-07-12\"")` - the concrete-value form, CORRECT when the
fixture was built (0.13.11 era) and malformed ever since dk's 0.13.18
pattern-form inversion. The tw3 state has embedded a doctrine-foul plank for
six doctrine versions, and at least 4 historical Boatswain legs (waves 2-5
commits 2dd9382/e38f706/d0832cc/c320109, plus yesterday's 0.13.32 battery leg)
committed it clean. Today's leg RAN the join and refused - the 0.13.23
disposition biting on a state nobody knew was foul. Fixture corrected to
pattern form; tw3-b hash baseline 0f57d9bd replaces 10d971bb.

**0.13.33 seams confirmed on the battery too:** tw5's fit-out wrote
`## Dependencies` 1:1 with what it installed (@cucumber/cucumber, c8, jsdoc) -
the shipwright-path fix live; tw4's Crew authored its new plank in pattern form.

## 0.13.33 spot-validation (2026-07-19, sonnet-pinned, HEAD-text - session process predates the install), banked under data/spotval-0.13.33/

0.13.33 (bc731e4, tests 213/213) closed the two battery findings on dk's blanket
proceed: recording routes with installation (the installing role writes one
`dependency` line per installed name under `## Dependencies`; root cause was the
example RIGGING showing `dependency: none` under a `focused` command naming the
runner - examples bind, again), and confirmed feature+code lint chain in the one
`lint` slot, feature lint first. Two greenfield legs, fresh quayfee spec, unborn
HEAD, scripted sim-user answers, stop after specs+watchbill, general-purpose
agents per prompts/preamble.md:

| Leg | Inv | Cache | Out | Wall | vs 0.13.32 battery leg | Verdict |
|---|---|---|---|---|---|---|
| ts-bootstrap | 61 | 5.75M | 39.3k | 10m06s | 65 / 8.53M / 12m55s (plugin ch.) | FULL PASS 5/5 markers |
| js-fastpath | 34 | 2.64M | 32.7k | 6m44s | 35 / 2.97M / 8m53s (plugin ch.) | FULL PASS 5/5 markers |

Markers, tree-verified on both legs: (M1) `## Dependencies` populated 1:1 with
package.json devDependencies (TS: 6/6 incl @types/node; JS: 5/5 incl jsdoc,
which the sim user never named - the "installed name" semantics binding); (M2)
`lint` chained gplint-first on both; (M3) plank-inventory `none`-on-TS /
`jsdoc -X`-on-JS holds; (M4) tag exclusions survived the TS `--import`-glob
recomposition on all five commands; (M5) initial commit self-made on unborn
HEAD both legs. Model 100% sonnet both transcripts, zero leak. The finding-1
seam closes on its exact reproduction shape at no measurable invocation cost.
Caveat: HEAD-text channel - the 0.13.33 plugin-channel confirmation rides the
next restarted session (the sonnet pilot session restarts anyway).

## Efficiency battery + 0.13.32 spot-validation ("wave 7 prep", 2026-07-18, sonnet, installed-plugin channel, session process postdates install)

Owed re-run (three ships landed since wave 5/6: 0.13.30, 0.13.31, 0.13.32) plus the
three queued 0.13.32 plugin-channel spot-checks (greenfield opening, TS bootstrap
re-run, plain-JS bootstrap). Wave-7 (yoink/architecture.md/anchors A/B/C) deferred on
dk's word; this run is the two cheaper queue items only. Channel verified empirically:
tw2's transcript carries 0.13.31 marker phrases (`harness-install artifacts`, `gplint`,
`jsdoc -X`, `not @captain and not @shipwright`) though tw2 itself never exercises the
greenfield path - the installed cache is serving current text. 100% sonnet, zero model
leak, confirmed across all 10 transcripts including nested children (grep of
`message.model` on every leg: `claude-sonnet-5` only).

Ten legs, all independently scaffolded sim trees, dispatched in parallel via the
installed-plugin channel (`subagent_type: shipshape:*`, thin dispatch, `model: sonnet`
pinned), mined on every notification, tree facts verified independently (not from
report prose):

| Leg | Role | Inv | Cache | Out | Wall | Mean ctx/inv | vs prior baseline |
|---|---|---|---|---|---|---|---|
| tw1 crew-batching | QM | 17 | 826k | 4.6k | 2m16s | 48.6k | wave-5: 28/1.41M/3m41s - **-39% inv, -41% cache** |
| tw2 notes-commit | Captain | 7 | 298k | 2.6k | 32s | 42.6k | wave-5: 6/123k/30s - +17% inv, **+142% cache** (doctrine text growth) |
| tw3 notes-arms | Boatswain | 9 | 408k | 5.4k | 1m17s | 45.4k | wave-5: 20/972k/2m18s - **-55% inv, -58% cache** |
| tw4 plank-gap | QM | 21 | 1.085M | 8.3k | 4m45s | 51.7k | wave-5: 27/1.32M/4m27s - -22% inv, -18% cache |
| tw5 no-plant fit-out | Shipwright | 51 | 4.61M | 46.3k | 11m10s | 90.3k | wave-5: 41/2.82M/6m19s - **+24% inv, +63% cache, +77% wall** (blows the ~10% bar) |
| tw13 slow-census | QM+nested Crew/Boatswain | 24 | 1.39M | 13.2k | 17m27s | 57.8k | wave-5 (QM-only): 19/848k/5m54s - not like-for-like, this run ran the FULL chain to a committed clean deck |
| fastpath-bootstrap | Captain (+nested QM/Crew/Boatswain) | 39 | 2.77M | 28.4k | 15m16s | 71.0k | wave-5 fastpath12: 13/531k/6m38s - not like-for-like (see note) |
| G1 greenfield opening | Captain | 12 | 530k | 4.6k | 3m38s | 44.2k | wave-6 G1: 10/488k/2m27s - comparable, wall +48% (live registry round-trips) |
| ts-bootstrap G2 (TS) | Captain | 65 | 8.53M | 41.1k | 12m55s | 131.3k | wave-6 G2 (TS, tainted by the tag-drop/glue findings): 73/7.38M/14m01s - improved on every axis |
| js-bootstrap G2 (plain JS, new) | Captain | 35 | 2.97M | 28.0k | 8m53s | 84.9k | no prior baseline (new leg) |

**Efficiency-battery total: 168 inv / 11.38M cache / 108.9k out.** **0.13.32
spot-validation total: 112 inv / 12.04M cache / 73.7k out.** **Wave total: 280 inv /
23.42M cache / 182.6k out**, wave wall (parallel dispatch, first start to last finish)
17m37s.

**Note on the two "not like-for-like" rows.** tw13 and fastpath-bootstrap dispatches
here said "bring to a clean deck" with no stop-line, so both ran further than their
named wave-5 comparators (which may have stopped at QM-dispatch or counted only the
top-level role's own invocations, per the ambiguous prior wording) - both completed a
full nested voyage to a committed, clean-verified deck. Wall-clock is the more honest
comparison for these two; both came in 2-2.5x wave-5's wall, which is directionally
consistent with the tw5/tw2 drift below (doctrine has grown), not evidence of a
specific new fault.

**GATE VERDICT: MIXED, not a clean gate-green like wave 5.** Three legs (tw1, tw3,
tw4) beat their baselines outright. Two legs (tw2, tw5) blow the ~10% bar - tw5
substantially so. Per the battery's own rule ("a doctrine fix that inflates
invocations on unrelated probes... routes back to dk before the pilot resumes"): tw5's
drift traces to no single doctrine version (0.13.15's efficiency-battery bar predates
most of the growth), it is cumulative - Shipwright's derived-check surface has grown
from ~4-5 rules (wave 5 era) to 7 required-when-supported methodology checks today,
producing 9 `@conformance` skeletons this run versus wave-5's smaller set. This is
doctrine SCOPE growth, correctly reflected in cost, not a bug - but it is real and it
compounds every fit-out leg from here forward. Flagged plainly rather than absorbed
into "drift, watch."

**Latency reading (mean context/invocation, the fat-vs-fast signal per this file's own
method).** Two legs stand out as heavy: ts-bootstrap (131.3k/inv, the heaviest leg in
the wave by a wide margin) and tw5 (90.3k/inv). Both are the two legs most loaded with
config/tool-output content (TS toolchain install+proof cycles; Shipwright's
templates.md third file plus 9 derived skeletons). The lightest legs (tw2, tw3, G1) sit
in the 42-45k/inv band, essentially the shared-Articles-plus-role-skill floor this
file's Goal-2 section already measured. No controlled latency probe was re-run this
wave (that remains `bin/latency-probe.py`/`bin/make-ballast.py` territory); this is the
cheap observational signal only, offered as a candidate, not a finding.

**Findings routed to dk, none shipped:**
1. **MEDIUM, reproducible 2/3: `RIGGING.md`'s `## Dependencies` slot left literally
   `none` on both the TS bootstrap and the fastpath-bootstrap legs, despite each
   installing multiple confirmed tools** (ts-bootstrap: biome, cucumber, c8, gplint,
   tsx, typescript, @types/node all in `package.json` devDependencies, `Dependencies`
   section empty; fastpath: the same shape). The js-bootstrap leg got this right (5
   dependencies listed, policy locked). The minimal-RIGGING letter requires "every
   slot a discovered value or a confirmed tool answers populated" - `Dependencies` is
   exactly such a slot and it silently reverted to `none` in the majority of legs that
   exercised it this wave.
2. **LOW-MEDIUM: no RIGGING.md command slot represents feature lint (gplint) as
   distinct from code lint (biome).** js-bootstrap installed gplint, proved
   `gplint "features/**/*.feature"` runs clean in its own transcript, yet
   `RIGGING.md`'s `## Commands` carries only one `lint:` key (populated with biome).
   The fast-path doctrine text names "feature lint, code lint and format" as two
   separate offer categories but the RIGGING schema (per `fixtures/probe-states/RIGGING.md`
   and every produced RIGGING.md this wave) has only one `lint` key - this may be a
   template/schema gap rather than a per-leg miss, since it reproduced identically
   wherever gplint was confirmed. Worth a ruling: does gplint's command belong folded
   into `lint` (e.g. both tools chained) or does the schema need a second key?
3. **LOW, doctrine-growth observation, not a fault:** tw2's cache-read nearly doubled
   since wave 5 (123k -> 298k, comparable invocation count and wall) - a direct,
   measured instance of the shared-Articles/role-skill "resident-by-design" cost
   accumulating release over release, consistent with Goal 2's original 84%-boilerplate
   finding. Tokens remain rung 4 per dk's ladder; noted for the eventual matrix, not
   acted on.

**Positive instruction-coherence markers, tree-verified:**
- Bulkhead hook self-heal live again (tw3: `grep -rn "@planks" src` denied, retried as
  `rg -n "@planks" src` the very next invocation - one real catch, one retry, zero
  contamination) - same class as the 0.13.26 bulkhead fix, still holding at 0.13.32.
- Zero invented wait mechanisms on the slow-census regression check (tw13, harness
  background-task lines deliberately withheld per the probe's own method): zero
  Monitor tool calls, zero pgrep/kill-0/sleep-poll patterns, zero `run_in_background`
  - the auto-backgrounded 150s+ broad sweep was consumed via the runtime's own
  notification-resume path, Crew got one batched dispatch, deck closed clean via a
  chained Boatswain pass. The pilot-#2 deadlock class stays closed at 0.13.32.
- Tag-exclusion recomposition (0.13.31's fix for the wave-6 finding) holds under real
  load: ts-bootstrap's TS runtime needed every verification command recomposed with a
  `node --import tsx ...` wrapper, and all five (`discover`/`focused`/`broad`/
  `coverage`/`step-usage`) kept `--tags "not @captain and not @shipwright"` intact.
- `plank-inventory` correctly `none` on TS / `jsdoc -X` on plain JS in both spot-check
  legs, zero ts-morph or glue-script installs on either - the wave-6 finding (b) stays
  closed.
- Zero cockpit reads, zero contamination refusals needed (none attempted), zero
  redundant confirmation runs observed (tw1, tw4 both inherited Crew's carried green
  rather than re-proving it).

## plank-join probe (2026-07-19, sonnet-pinned, installed-plugin channel 0.13.33 marker-confirmed), banked under data/plankjoin-0.13.33/

Entry `/shakedown probe`. Nothing moved since the 0.13.33 baselines, so the run took the top
open item: pilot #5 finding 3 (plank-join extraction is trial-and-error, ~27 N inv). New probe
`plank-join` in scenarios/probes.md. Channel: session process 17:23:51 UTC postdates the
09:51:32 install; marker `Recording routes with installation` hit 1x in BOTH leg transcripts.

| Leg | Inv | Cache | Out | Wall | P/N/Neg | Verdict |
|---|---|---|---|---|---|---|
| A boatswain custody, current doctrine | 9 | 393k | 1.6k | 60s | 7/2/0 (78%) | PASS |
| B same + `plank-join` RIGGING slot | 8 | 351k | 4.2k | 45s | 7/1/0 (88%) | PASS |

Both legs named the malformed plank as a touched-seam foul, refused to commit on a green QM
hand-off, staged nothing, ran no recheck, and routed Crew redispatch via QM with the mismatch
as evidence. Tree facts verified after both: HEAD unmoved, `src/tide.js` still modified and
unstaged, stale `{date}` plank intact. The 1-inv A/B delta is A's redundant `runrecord.jsonl`
existence check (inv 8, after inv 7 already catted it), NOT the join.

**Finding 1 (NEW, operator-derived pre-dispatch, confirmed 2/2 legs): `step-usage` output
carries no keyword, so the join doctrine specifies is not directly computable from it.** The
Planking agreement requires the plank string be the pattern "led by that definition's own
keyword" (`@planks("When I ask ...")`), but cucumber `usage-json` emits `"pattern": "I ask
..."` with no keyword field. Both legs spent an extra retrieval (A inv 6, B inv 6) reading
step-definition SOURCE to recover `When` before they could compare. A working one-liner needs
a `.replace(/^(Given|When|Then) /,"")` normalization no doctrine text mentions; it cost the
operator two attempts to land. Candidate seam: either state the normalization in the Planking
agreement's cross-reference rule, or drop the keyword from the plank form.

**Finding 2 (NEW): the `plank-join` RIGGING slot was READ and NEVER RUN.** Leg B catted
RIGGING.md at inv 3 (2 transcript hits, both the cat) and then joined by hand exactly as leg A
did. A derived slot doctrine does not name is inert - so the pilot-#5 candidate "an example
command OR a derived RIGGING.md slot" is now split: the slot alone does nothing without
doctrine text naming it. If the fix ships, it ships as doctrine text.

**Finding 3 (probe limitation, stated rather than buried): at n=2 planks this probe does NOT
reproduce pilot #5's ~27 N cluster.** Both legs joined by eye across two command outputs and
it was cheap and correct. Leg A's report explicitly claims "not by-read-only"; mechanically the
cross-reference WAS a human read of two outputs, satisfying boatswain/SKILL.md:82 ("a plank
read by eye is unchecked") in letter only. The trial-and-error pilot #5 measured is a SCALE
effect. A scale variant (10+ planks, several stale) is owed before finding 3 can be priced or
closed; nothing here disproves it.

## 0.13.34 plank-form re-validation (2026-07-19, sonnet-pinned, HEAD-text - session process predates the install), banked under data/plankjoin-0.13.34/

0.13.34 (99c6002, tests 5/5) dropped the keyword from the plank form on dk's word, clean
break. Re-validated same-session. HEAD-text channel confirmed: marker `never carried into the
plank` hit in BOTH transcripts (C 1x, D 2x), old-form `led by that definition` 0x in both.

| Leg | State | Inv | Cache | Out | Wall | Verdict |
|---|---|---|---|---|---|---|
| C new-form join | both planks 0.13.34 form, tideRange param stale `{date}` | 8 | 370k | 1.4k | 73s | PASS |
| D clean-break migration | state A untouched, keyword-led planks under new doctrine | 9 | 439k | 6.0k | 71s | PASS |

Leg C: caught the stale parameter, joined by exact string match, noted the keyword "stripped
correctly". Leg D: caught BOTH faults on the touched seam and cited the new rule verbatim
("is never carried into the plank"), naming the correction in the new form.

**Migration fact, tree-verified and reassuring for consumers: the clean break does NOT
cascade-redden untouched seams during a voyage.** Leg D ruled `nextHighTide`'s keyword-led
plank at `src/tide.js:2` "untouched by this diff, out of scope" - correct per the Blocker
policy's plank-drift-beyond-the-diff clause. So yoink and jolly do not go red in custody on
upgrade; old-form planks surface at harbour, or when a plank-form conformance check sweeps.
Narrower blast radius than the clean-break option was scoped to have.

**Honest negative: no invocation win, and none should be claimed.** A 9 / B 8 / C 8 / D 9 -
flat. Both new-form legs still read step-definition source (C inv 6, D inv 6), now as ordinary
evidence gathering rather than keyword recovery. At n=2 planks the join was never the cost
driver, exactly as the 0.13.33 probe's finding 3 said. **0.13.34 is a decidability and
correctness fix, not a measured economy fix**; the economy claim stands or falls on the owed
scale variant (10+ planks, several stale), which finding 3 still owes.

Probe-design caveat on record: C's uncommitted hunk is a docblock-only plank edit, whereas
A/B/D's is the `tideRange` seam addition. The join test is like-for-like; the invocation
comparison C-vs-A/B/D is not exactly.

## Plank-join SCALE variant + 0.13.33 control (2026-07-19, sonnet-pinned, HEAD-text), banked under data/plankjoin-scale/

The variant owed by the 0.13.33 probe's finding 3. State: 12 planked seams, 6 touched by an
uncommitted Crew-shaped diff, 3 faulty planks of DISTINCT kinds among 9 correct ones - stale
parameter (`{date}`), keyword-form fault, wording drift - suite GREEN, so the join is the only
detector for all three. Control arm: same state rebuilt in 0.13.33 keyword-led form, same three
fault kinds, dispatched against 0.13.33 skill text extracted from bc731e4 (doctrine served
verified per arm: control carries `led by that definition`, 0x `never carried into the plank`).

| Arm | Planks | Faults | Inv | Cache | Out | Wall | Failed extraction attempts |
|---|---|---|---|---|---|---|---|
| 0.13.34 | 12 | 3/3 caught | 6 | 245k | 5.2k | 52s | **0** |
| 0.13.33 control | 12 | 3/3 caught | 8 | 386k | 10.1k | 104s | **0** |

Both arms PASS: all three faults named and distinguished by kind, the three touched-but-correct
seams cleared, guard clauses correctly ruled within Crew's contract, no commit, no stage, no
recheck, tree facts verified after both.

**VERDICT: pilot #5 finding 3's economy claim is NOT REPRODUCIBLE under controlled conditions,
in either doctrine version.** Zero join trial-and-error in BOTH arms at 6x the plank count that
failed to reproduce it at n=2 this morning. The ~27 N cluster does not arise from the doctrine
text in a fixture.

**The 6-vs-8 delta is NOT claimed as a win.** n=1 per arm, inside the spread of every leg today
(0.13.34: 6/8/9; 0.13.33: 8/9/8, overlapping). The control's extra invocations went to runrecord
hunting and feature-file reading, NOT to the join, and it spent 10.1k out vs 5.2k producing a
richer per-hunk recheck-selection table - more REPORTING work, not more JOIN work. Reading that
as an efficiency win is the error class this harness exists to catch.

**0.13.34 therefore stands as a correctness and decidability fix with no measured economy
benefit - now tested rather than asserted.** Finding 3's economy claim RETIRES. The underlying
pilot observation stays on the board as pilot-conditions-only: real projects spread planks
across files, must DERIVE `plank-inventory` rather than read it ready-made from RIGGING.md, and
carry voyage context into the leg. The next pilot answers it; another probe will not.

## 0.13.35 finding-1 regression + 0.13.34 control (2026-07-19, sonnet-pinned, HEAD-text), banked under data/finding1-0.13.35/

0.13.35 (5616ed0, tests 5/5) named the malformed plank in QM's re-derivation clause and folded
the join into step 5's existing pass. Validated against a control. State: twscale (12 seams, 3
malformed planks among 9 correct, 6-target watch, suite GREEN, uncommitted role-advanced diff),
fresh QM dispatched THIN at role+base-commit only - finding 1's exact shape. Control arm same
state, 0.13.34 skill text from 99c6002.

| Arm | Caught | Routed to | Inv | Cache | Out | Wall |
|---|---|---|---|---|---|---|
| 0.13.35 | 3/3 | **Crew**, 3 parallel mates, seams in hand | 11 | 561k | 8.0k | 94s |
| 0.13.34 control | 3/3 | **Shipwright at harbour**, deferred | 12 | 645k | 4.0k | 101s |

**BOTH arms caught all three. 0.13.35 is NOT the difference between catching and missing, and
the prediction that a 0.13.34 QM would sail past a green watch was WRONG.** The control ran the
join on its own initiative.

**The real delta is ROUTING, and it is a genuine fault.** The control deferred on the reasoning
"None of these seams sit in a role-advanced diff this voyage, HEAD matches base commit unmoved."
Tree verified in both arms: `M src/tide.js`. HEAD is unmoved, but the working tree carries
exactly the role-advanced diff and the malformed planks sit inside it. The control conflated
"HEAD unmoved" with "no role-advanced work" and sent in-hand Crew work to harbour - the seam
leaves Crew's hands and the malformed plank ships. 0.13.35 routed it correctly.

**META-FINDING, and the most important result of the day: this is the SECOND CONSECUTIVE pilot
finding that fails to reproduce in a probe fixture.** Finding 3 (plank-join waste) collapsed
against a control this morning; finding 1 (QM sails past a malformed plank on a green watch)
did not reproduce here, on EITHER doctrine version. Pilot #5's QM did sail past, twice. Neither
of mine did. Common cause is not the doctrine - it is the fixture: 12 seams in ONE file,
`plank-inventory` sitting ready in `RIGGING.md` rather than derived, no voyage context, a
single-purpose leg with nothing else in hand. **Probe states may be systematically too clean to
reproduce pilot-scale faults.** If so, the probe is a weak instrument for this finding class and
pilot conditions are the only place these close. This belongs on the board above either
individual result.

0.13.35 is KEPT: the clause genuinely listed two cases where three belong, and the control
demonstrated a real consequence. But its validation is weaker than claimed at ship time, and it
was shipped against a finding that does not reproduce. Both facts recorded.

Leg notes: control ran SIX separate focused runs where step 5 requires ONE batched invocation -
a rule present in BOTH versions, so leg variance, classified N, not doctrine. Fixture defect
found by the 0.13.35 arm and owned (tw17 class, fixture wrong/role right): scenario titled "A
modest range is not a spring tide" asserts `"true"`, and 3.8 exceeds the 3.5 threshold, so the
TITLE is wrong. QM flagged it for visibility and correctly refused to alter spec text.

## Captain opening-posture probe (2026-07-19, sonnet-pinned, HEAD-text 0.13.35), banked under data/captain-posture/

Reproduction attempt for the yoink consumer finding ("Captain's opening classifies but never
proposes"). Run BEFORE any fix, per the day's own lesson. State mirrors yoink: fitted 12-seam
tree, dirty with harbour output in flight (RIGGING.md conformance slot filled, untracked
`features/conformance.feature` carrying two `@captain @conformance` skeletons, untracked
`.rgignore`), NO watchbill (voyage 1 spent and struck), and `CAPTAIN.md` carrying a diagnosed
root cause with a written fix. Dispatch: Captain, HEAD-text, the user's only word `captain`,
stop after the opening response, no durable changes.

**DID NOT REPRODUCE. 6 inv / 267k / 63s, zero writes, tree unchanged.** The opening PROPOSED:
classified the dirty tree as "work in flight, not dirt" and attributed it to Shipwright's
harbour write-scope exception; read the absent watchbill as "the healthy resting state" per the
Watchbill policy, citing the voyage-1-complete commit; read CAPTAIN.md; then named TWO threads
(harbour review of the skeletons, and tracing the notes' defect) and asked only which to take
first. That is exactly the posture yoink's Captain lacked.

**VERDICT: the doctrine text is NOT the cause; no fix shipped.** A doctrine change would have
been aimed at a target that is not there. The probe paid for itself.

**Fixture defect, OWNED (tw17 class, second of the day, both mine):** the planted "diagnosed
root cause" was incoherent - it claimed a caller could mutate the tide table through the
returned reference, but `tidesOfType` returns `tides.filter(...)`, already a fresh array. The
Captain caught it unprompted ("the claimed mechanism doesn't hold as written - either it
describes a path I haven't traced, or the note is stale") and REFUSED to write a scenario
against it before tracing. Signal 4 was therefore muddier than designed; the probe still
answers its question, since the Captain proposed that thread rather than asking about it.

## THE DAY'S DOMINANT PATTERN: three consecutive non-reproductions, two distinct causes

| Finding | Origin | Reproduction attempt | Result | Cause |
|---|---|---|---|---|
| 3 (plank-join waste) | pilot #5, sonnet, plugin | 12-seam scale + 0.13.33 control | zero trial-and-error in BOTH arms | fixture too clean |
| 1 (QM sails past malformed plank) | pilot #5, sonnet, plugin | fresh QM + 0.13.34 control | BOTH arms caught it | fixture too clean |
| Captain opening | yoink, DeepSeek, opencode, vendored 0.13.33 | Captain opening, HEAD 0.13.35 | opening PROPOSED | NOT the text |

The first two share a cause and it is the FIXTURE: one file, `plank-inventory` handed over
ready-made rather than derived, no voyage context, single-purpose legs. **Probe states are
systematically too clean to reproduce pilot-scale faults**, which makes the probe a weak
instrument for that finding class and puts pilot conditions in the only position to close them.

The third has a DIFFERENT cause and it is not fixture cleanliness: the text produces the right
posture on Claude. What remains is model, channel, or doctrine vintage - and it is the only
finding today from the only non-Claude Captain we run. That is a datum for the parked
cross-model portability WATCH, not a verdict, and dk parked that comparison deliberately.

**Operational consequence for the /shakedown skill's own default:** "the cheapest scenario
covering seams that moved" defaults to a probe, and a probe did not reproduce ANY of three
findings today. Two doctrine ships (0.13.34, 0.13.35) went out on findings that do not
reproduce; both were kept on TEXTUAL grounds that survived independently, and both are recorded
with validation weaker than claimed at ship time. A third was correctly NOT shipped because the
probe ran first. dk's read is owed on whether probe-first should become the standing rule before
any consumer- or pilot-sourced doctrine fix.
