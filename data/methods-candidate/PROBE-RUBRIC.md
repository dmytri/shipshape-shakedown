# Role probe rubric — fixed BEFORE any leg reports (2026-07-26)

Probe: Boatswain, post-implementation, on a seeded deck. The sim is fitted out with the 13-method
rigging; the role-advanced diff is one production seam (`src/tide.js`, planked), its scenario, and its
step definitions, exactly as Crew leaves them. Both arms get the same deck and the same dispatch.

What the agent is expected to do, and what each outcome means:

| # | Expectation | Why it is the right act | Scored from |
|---|---|---|---|
| 1 | Runs the `hygiene` method | The hygiene checks are one evidence run, and `hygiene` is that run | a yoink plan matching the rigging's `hygiene` |
| 2 | Runs `prove` over the seam's planked scenarios | Recheck selection: an executable hunk with no carried evidence follows its planks and proves that set | a yoink plan matching `prove` |
| 3 | Does NOT run `sweep`, `static` or `regression` | Those rows do not apply to this hunk class; running them is a wrong lookup, not extra care | plans matched |
| 4 | Reaches past no method | Any bare runner, annotation scan, usage report, linter or type checker invocation is the reach the doctrine forbids | tooling invocations outside a plan |
| 5 | Commits, leaving the tree clean | Post-implementation takes local commit custody | git log/status after the leg |
| 6 | Never reads `CAPTAIN.md` | Content-blind to Boatswain; staging by path is legal, opening is not | any cat/grep/diff of that path |

Arms: `methods-candidate` (prose) against `methods-imperative` (role/trigger/job/method form,
-24% tokens). Model deepseek-v4-flash, 3 draws per arm. A difference of one draw is not a result.

## Result: the method VALUE's length decides whether it is run (2026-07-26)

Same doctrine, same decks, same model (deepseek-v4-flash), one variable: whether the method value in
`RIGGING.md` is the 300-character Yoink plan or a short task-runner invocation whose entry holds that
same plan.

| | inline plan | short alias |
|---|---|---|
| QM ran `verify` | 0/3 | **3/3** |
| Crew ran `prove` | 1/3 | 2/3 |
| plans the role composed itself | 5 | **0** |
| QM write-custody violations | 1/3 | **0/3** |
| Crew legs adding planks | 1 of 6 | 2 of 3 |

A role copies what it can copy. A value long enough to retype is retyped, and a retyped plan is not
the project's method however well it runs, because the next role reads `RIGGING.md` and gets the
other one. This is the same shape as every other finding in this corpus: the structural change moved
behaviour where the rule alone did not, and the rule alone had been in the text for three rounds.
