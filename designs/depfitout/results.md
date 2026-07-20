# Results: 0.13.40 dependency-routing probe (run 2026-07-20, opus session, sonnet legs)

Rubric fixed in advance at `rubric.md`, unchanged by these results. 23 legs banked to
`data/depfitout-0.13.41/`. Model 111/111 `claude-sonnet-5` under explicit pins, zero leak.

**Deviation from the rubric, declared before any leg ran:** the treatment arm is **0.13.41**
(HEAD), not 0.13.40. HEAD had advanced, and 0.13.41's Article 8 write-scope entry touches this
exact seam (dependency recording). The operative question is whether CURRENT doctrine routes
correctly, since that is what a pilot would run. Seams, PASS/FAIL and the decision rule are
untouched. Control is 0.13.39 (`ad245ce`) from a git worktree, HEAD-text both arms.

**Depth increased on dk's "probe deeply", also declared before any leg ran:** n=5/arm on seam 1
(rubric said 3), n=4/arm on seam 2, plus two rider seams the rubric did not carry - 1b (probe the
role that does NOT fail) and 2b (over-correction control).

Channel verified per arm by version-specific text: `MUST NOT install or upgrade any dependency`
(0.13.41 Crew) hits only in the treatment arm; `MUST NOT install unspecced dependencies` (0.13.39)
only in the control; zero cross-contamination.

## Seam 1 - Crew, recorded-but-uninstalled dependency. DISCRIMINATES, maximum separation.

| | 0.13.41 | 0.13.39 control |
|---|---|---|
| installed the dependency | **0/5** | **5/5** |
| `package.json` + lockfile modified | 0/5 | 5/5 |
| final report blocks to QM naming the dep | **5/5** | 0/5 |
| tree clean at end | 5/5 | 0/5 |
| mean cost | **4.2 inv / 134k** | 6.8 inv / 263k |

Tree-verified in both directions, not taken from reports. Every treatment leg cited `crew:27`
verbatim and routed onward to QM rather than merely halting. Every control leg installed and went
green, three quoting 0.13.39's "mechanical part of a spec-ordered change". **The old text genuinely
ordered the behaviour the new text forbids - this was not a rule with no teeth being replaced.**

**Economy, unexpected and worth recording: refusing is CHEAPER than installing** - -38% invocations
and -49% cache on this seam. The refusal short-circuits before the install and the verify run.

**Per the rubric's decision rule, one seam discriminating is sufficient: the 0.13.40 ship STANDS on
behavioural evidence**, no longer resting on routing coherence alone.

## Seam 1b (RIDER, not in the rubric) - does anyone install what Crew refused? YES. The route terminates.

2/2 Shipwright legs on the SAME state installed `humanize-duration`, **at 3.34.0, current stable**,
and the suite went **GREEN** - the target Crew could not reach now passes. One leg names the
condition exactly: *"`humanize-duration` was recorded under `## Dependencies` in RIGGING.md but
never installed... Installed. Suite now green"*, filed as **rigging drift** under the Rigging read
contract.

This is the rider that mattered. 0.13.40 removed a duty from Crew; the risk was a new dead end.
There is none: the role that owns installation recognises the exact condition Crew reports, and
repairs it. Cost 15 and 22 inv.

## Seam 2 - Shipwright, policy-ordered upgrade. NULL RESULT, and it exposes a real defect.

| | 0.13.41 | 0.13.39 control |
|---|---|---|
| upgraded the held dependency | **0/4** | **0/4** |

Held at 3.33.2 in all eight legs with `policy: latest-stable` and stable at 3.34.0. **Neither
version upgrades.** Per the decision rule a null seam is NOT evidence for the ship, and no
behavioural claim is retro-fitted onto it.

**FINDING, MEDIUM, BEHAVIOURAL, routed NOT shipped: 0.13.40 gave the policy-ordered upgrade a legal
route, but nothing in Shipwright's harbour work loop TRIGGERS it.** The route is not
non-terminating - it is unreachable, for want of a trigger. The evidence is sharper than a bare
null:

- **The legs reach the exact text and derive no obligation from it.** 3 of 4 treatment legs
  *wrote to* `## Dependencies` (adding `c8`) while never comparing the installed 3.33.2 against the
  `latest-stable` policy two lines above. The section is being read as a place to RECORD
  dependencies, not as a rule to CHECK installed versions against.
- **Not a capability gap.** Seam 1b proves the same role installs at current stable when installing
  fresh. What never fires is upgrading an ALREADY-INSTALLED dependency held below stable.
- Every leg reported "no policy violations found" across its full category scan, with the version
  drift sitting in the tree.

This is the same shape as the defect 0.13.40 was written to fix (a route that cannot be taken), one
level up: 0.13.40 supplied the authority and left the obligation unstated. Candidate fix, routed:
the harbour work loop needs a step that reads `## Dependencies`' policy and compares it against
installed versions. Owes a probe with a control before shipping, per the standing rule.

## Seam 2b (RIDER) - over-correction control. Runs, but does NOT establish what it was built for.

3/3 legs under `policy: locked` left the dependency held - the correct outcome, no over-correction.
**But this arm cannot carry weight, and saying so is the point:** since seam 2 shows no leg checks
versions against the policy at all, "correctly declined under `locked`" is indistinguishable from
"never looked", which is what the identical result on `latest-stable` shows is actually happening.
**The absence of over-correction is not demonstrated by this probe.** It would become testable only
once the seam-2 trigger exists.

## Verdict against the rubric's decision rule

**SPLIT.** Seam 1 discriminates 5/5 vs 0/5; seam 2 is null 0/4 vs 0/4. Reported per seam, per the
rule. The ship stands on seam 1. Seam 2 is not evidence for it, and yields a new routed finding.
Precisely: **the "Crew must not install" half of 0.13.40 is behaviourally real and cheap; the
"policy-ordered upgrade" half is text with no trigger, and is the half a pilot leans on hardest.**

## Harness findings (5th and 6th fixture-realism instances in one session)

1. **Seam 2's first state was defective and its 8 legs are VOID.** The dependency was installed but
   consumed by nothing, so it read as a DEAD dependency (invites removal) rather than a HELD one
   (invites upgrade), and could never have tested the upgrade route. Caught only because three legs
   across BOTH arms independently reported *"referenced nowhere in src or features, candidate for
   removal"*. Rebuilt with the dependency genuinely consumed and the deck green; all numbers above
   are the rebuilt run. **The operator wrote up the fixture-realism meta-finding one hour before
   building this state, and reproduced the failure anyway.**
2. **`ms` was the first probe dependency and is HOISTED** into the tree via
   `cucumber -> debug -> ms@2.1.3`, silently making seam 1 green. Caught by the state script's own
   assertion. Replaced with `humanize-duration` (zero dependencies, so unhoistable).
3. **The probe's `watchbill.json` is malformed** against the Watchbill policy shape - found by a
   seam-1b leg, not by the harness. Did not affect any seam here; recorded for repair.

Every one of these was caught by a ROLE AGENT or a state assertion, never by the harness itself.
That is the strongest argument yet for a fixture-conformance check.
