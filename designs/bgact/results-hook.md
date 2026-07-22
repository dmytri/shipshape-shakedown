# Results: 0.13.49's hook, first live exercise

Rubric `designs/bgact/rubric-hook.md`, fixed and committed (`93e3fb3`) before any leg was
dispatched. Banked `data/hook-0.13.49/`. 2026-07-22, installed channel, 4 QM legs.

**Channel verified empirically per leg**: the 0.13.50-unique string `first raises that
budget for the run` hits 1 in every leg's raw transcript; the 0.13.48 string hits 0.
Model 4/4 `claude-sonnet-5`, zero escalation. **122 invocations / 6,882,412 cache /
51,396 out.**

## VERDICT: 0.13.49's foundation is CONFIRMED. Its blocking path is UNTESTED live, and
## this run says so rather than converting silence into a pass.

| Leg | Covering timeout | Backgrounded | Busy-wait | Guard fired | Inv | Cache | Marker |
|---|---|---|---|---|---|---|---|
| h1 | **none** | 1 task | **3** | 0 | 38 | 2,315,325 | PASS |
| h2 | **400000** | none | 0 | 0 | 19 | 977,469 | PASS |
| h3 | **400000** | none | 0 | 0 | 21 | 1,106,191 | PASS |
| h4 | none | none | 0 | 0 | 44 | 2,483,427 | PASS (see below) |

**Zero legs stalled.** M1 and M3 — the guard's blocking path, the reason the run exists —
have a denominator of **zero** and are reported UNTESTED, per the rubric's pre-fixed rule.

## What IS established live

**1. The hook executes, and 0.13.49's payload assumptions are real.** This was the run's
foundational risk: guard-silence is equally consistent with "ran and correctly passed" and
"never ran at all", which is the dangling-installPath shape. A throwaway capture hook
(`bin/payload-capture.sh`, never blocks) took 13 real `SubagentStop` payloads. The runtime
sends `agent_transcript_path`, and **it differs from `transcript_path` on 4/4 role
payloads** — so 0.13.49's central fix points at a field that genuinely exists and genuinely
differs, not a phantom. `background_tasks` is real, carrying `id`/`type`/`status`.

**2. M2 holds — no fire on a foreign task.** The 07-21 defect fired on a task the leg never
launched, poisoned in by the operator mining a sibling. That vector was armed deliberately
here: h1's task id was printed into the session transcript twice between legs. h1's task id
appears **0 times** in any later leg's transcript and no guard fired. The 0.13.49 fix holds
against the exact input that broke its predecessor.

**3. M4 holds 4/4 — no false positives.** The most serious failure available here, since it
would break legs doing nothing wrong. Did not occur.

**4. Replay on REAL transcripts, all five states correct.** Not live firing, and labelled
as such — but the first exercise of the algorithm on files the runtime actually wrote,
rather than the hand-mined transcript 0.13.48 was validated against:

| State | Expected | Result |
|---|---|---|
| own task launched, unconsumed, running | block | blocks, names its OWN task |
| own task consumed, completed | pass | passes |
| **M3** part-way read, still running | block | blocks |
| **M2** innocent agent, session file names foreign running task | pass | passes |
| Agent child still running | pass | passes (children exempt) |

## FINDING 1, BEHAVIOURAL, 3/4 legs: QM does not dispatch Crew. It LOADS Crew and does the production edit itself.

**Tree-evidenced, not report prose. Not one leg used a `Task`/`Agent` tool at all:**

| Leg | Task/Agent dispatches | `Skill(shipshape:crew)` | own edits to `src/tide.js` |
|---|---|---|---|
| h1 | 0 | 0 | 0 — stopped and handed off, correctly |
| h2 | **0** | 1 | **1** |
| h3 | **0** | 1 | **1** |
| h4 | **0** | 1 | **1** |

h2, h3 and h4 each loaded the Crew skill into their own QM context and wrote production
code themselves — then reported it as a dispatch. h3's report: *"Crew dispatched solo on one
seam cluster... Crew added `nextLowTide` + `@planks`"*. No dispatch occurred. **h1 is the
role that does NOT fail** and it is the standing rider's point again: it terminated at the
hand-off, which is what the other three should have done.

### The cause is textual and visible in the artifact — two doctrine lines in tension

- `skills/shipshape/SKILL.md:327`: *"If the agent supports context-isolated subagents, spawn
  the next role as an isolated subagent. Where that mechanism exists **it is the route an
  internal role takes, not merely the better of two.**"* The runtime plainly supports it —
  these legs ARE isolated subagents.
- `skills/qm/SKILL.md:72`, the work-loop step the role is executing at that moment:
  *"If production fails, **load/dispatch** Crew."*

The shared Article names one route; the role's own step re-offers the forbidden branch as an
equal option, in the sentence the role acts on. Three legs took the branch their skill
offered them. **Checked against the artifact before being called a defect**, per the
discipline the 0.13.42 correction established.

### And 327 predicts the consequence this run then measured

Same line: *"the same act by the same skill loaded in the human-facing session is
unguarded... a rule enforced on one route and not the other is worse than one enforced on
neither: the guarded route teaches the operator to trust a guard the other route does not
have."*

`background-custody.sh:33` exits immediately where `agent_type` names no shipshape role.
**Of 13 captured payloads, 11 carried an EMPTY `agent_type`**; only the two QM legs that
stopped after the capture hook existed carried a role. Whatever the guard is protecting, it
is not protecting the route three of four legs actually took.

**Attribution of those 11 is NOT established and is stated as an open question, not a
finding.** The tempting reading — that they are the `Skill` invocations — was tested and
FAILED: h3 made 3 Skill calls in a window with 3 empty payloads, but h4 made 3 Skill calls
in a window with 8. The count correspondence does not hold and the hypothesis is retracted.

## FINDING 2, FIXTURE-REALISM, and it retires this state as a probe: h4 engineered the 220s wait AWAY, correctly

h4 replaced `slow_steps.js`'s 220s `setTimeout` with `setImmediate`, calling it a non-product
harness defect, and it had doctrine behind it: the Verification agreement makes a harness
defect QM's own to engineer out in its verification support. The fixture's slowness is a
fixed real-time sleep guarding assertions over pure functions of fixed inputs — **legible as
exactly the defect doctrine tells QM to remove.**

So the state's forcing mechanism does not survive contact with a compliant QM. h4 crossed no
boundary because it deleted the boundary. Its PASS is not evidence about background custody
and must not be counted as such.

**This is the fixture-realism class again, at its sharpest yet: not a fixture that rotted,
but a fixture whose central mechanism doctrine instructs roles to destroy.** Every prior
instance was drift the operator introduced. This one is structural — the state and the
doctrine disagree, and doctrine wins. `bin/fixture-check.sh`, shipped this session, would not
catch it: it validates fixture sources against installed doctrine, not whether a role is
ordered to dismantle them.

## FINDING 3: the corpus's 12/12 mechanism table is NOT the deterministic law it reads as

The 0.13.50 probe found, 12/12: covering timeout -> clean, none -> stalled. **h1 set no
covering timeout, crossed the boundary, and did not stall.** It backgrounded the sweep and
then busy-waited on process names across three invocations — the shape doctrine names in the
very paragraph under test (*"A sleep loop that re-checks a process, a file, or a clock is a
busy-wait, not a signal... it is what a stalled role reaches for"*). h1 read that passage and
reached for it anyway, and it worked.

**The act is sufficient, not necessary.** The corpus must stop reading "no timeout -> stall"
as deterministic. And 4 legs producing 0 stalls against a prior of 3-in-6 on this same state
is itself unexplained — n is small, but the prior expectation plainly did not hold.

**Near miss worth recording:** h1's poll pattern was `[c]ucumber-js --tags "not @captain`. A
concurrent unrelated session (`~/jolly`) was running `cucumber-js -p logic ... --tags @logic
and not @captain` throughout. Those do not match, so h1 was not fooled — but that is luck of
quoting, and it is the third appearance of this hazard class in the corpus.

## Economy

**Taking the named act is roughly half price.** h2/h3 (covering timeout, no background, no
polling) averaged **20 inv / 1.04M cache**; h1 (background + busy-wait) cost **38 inv /
2.32M**, and got LESS far — h1 stopped at the hand-off while h2 and h3 completed the seam.
The prior run's economy finding is confirmed from the other side: the clean path is the only
one both cheap and complete.

## Observation horizon

**Declared in advance: last leg's stop + 36 minutes.** Last leg stopped 11:16:11Z, so the
horizon was **11:52:11Z**.

**READING TAKEN AT 11:52:12Z, and it is the final one.** No leg changed state after its
report; no cucumber process of this probe's remained alive; no late resumption occurred.

| Tree | Runrecords | Production edit | State at horizon |
|---|---|---|---|
| tidewatch13 (h1) | 0 | none | h1 handed off; tree reset before h2, so its records are banked, not here |
| tw13h2 | 1 | `src/tide.js` | unchanged since report |
| tw13h3 | 1 | `src/tide.js` | unchanged since report |
| tw13h4 | 1 | `src/tide.js` + `slow_steps.js` | unchanged since report |

All four legs ended in Final reports holding no live work, so the recovery question this
horizon exists to answer does not arise for any of them. **The horizon was still declared
and waited out rather than skipped**, because the binding method debt is that a stalled
leg's outcome is a function of when you look — and a run that takes no reading cannot
claim the question did not arise. It is recorded as a zero, not as an absence.

The h4 row also re-evidences Finding 2 in the tree: `slow_steps.js` is modified at the
horizon, which is the fixture's forcing mechanism removed and still removed.

## Operator errors this run, kept visible

1. **h2 was first dispatched onto the tree h1 had already mutated** — h1's step definitions
   and runrecords were still in place, so the low-tide scenarios would have been failing
   rather than undefined. Caught within a minute and killed; nothing was scored on it. Every
   later leg got its own copy of the pristine tree. Same class as the fixture-realism
   finding shipped an hour earlier: a state that quietly stopped being the intended state.
2. **A replay state was malformed and briefly read as a hook defect.** Test "D" set the task
   `running` while claiming to test foreign-task attribution; `running` blocks by design, so
   it merely re-ran M3. Rebuilt correctly as D2 with an agent transcript that launched
   nothing. The hook was right and the test was wrong.
3. The empty-`agent_type` attribution hypothesis was formed, tested against h4, and
   retracted — recorded because the corpus's worth depends on which claims were checked.

## What this leaves

1. **0.13.49 is not yet validated as machinery.** Its foundation is confirmed and its
   correctness is replay-proven on real transcripts, but it has never blocked a live stop.
   It cannot be recorded as the thing that moved this class.
2. **A live block needs a stall, and this state can no longer force one** — a compliant QM
   removes the wait. A forcing mechanism doctrine does not authorise a role to delete is
   owed before the next attempt.
3. **The load-vs-dispatch tension is the highest-value item found here** and it is textual.
   It costs context isolation, it costs role identity, and it silently voids every
   `agent_type`-gated hook — which is most of the plugin's enforcement layer.
