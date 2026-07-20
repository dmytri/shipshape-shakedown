# Pre-wave-7 doctrine audit: bloat, sprawl, efficiency (2026-07-20, opus session)

dk's ask: "full run to check bloat, sprawl, efficiency... before we go to wave 7, I want to
know that our doctrine is tight prior to a full pre-wave-7 pilot run."

Method: four parallel read audits over the doctrine corpus at 0.13.40 (`5c131ec`), plus
static cost accounting (`bin/doctrine-sections.py`, per-commit char deltas). **Every
load-bearing claim was then re-verified by the operator against the quoted line**, per the
handoff audit's discipline. ONE claim was downgraded on that check and ONE of the operator's
own framing numbers was found wrong. No legs were run; this is a static pass.

## Cost accounting

Corpus: 183,311 -> 189,000 bytes since pilot #5's 0.13.33 baseline, **+3.1%**. Of that,
**+3,182 bytes (56%) landed in the shared Articles**, the file all five roles read in full on
every invocation, so it carries a 5x multiplier no role file does.

Per-commit net char delta in `shipshape/SKILL.md`, verified directly:

| commit | version | delta |
|---|---|---|
| bc731e4 | 0.13.33 | +345 |
| 99c6002 | 0.13.34 | +882 |
| 5616ed0 | 0.13.35 | **+0** |
| 49a1597 | 0.13.36 | **+0** |
| b761b64 | 0.13.37 | +69 |
| f86dd31 | 0.13.38 | **+1502** |
| ad245ce | 0.13.39 | **-13** |
| 5c131ec | 0.13.40 | +742 |

**OPERATOR ERROR, owned:** the run-time framing said "seven versions". It is EIGHT commits;
0.13.34 (`99c6002`) was dropped from the version list by a bad grep. This matters, because
the Planking agreement's +887 growth that was attributed to the seven is ~882 from 0.13.34
alone. Any "seven fixes, each justified, so the sum is earned" argument was missing an input.

**Three commits carry 90% of the growth** (0.13.38, 0.13.34, 0.13.40). 0.13.35, 0.13.36 and
0.13.39 are exemplary: two at net ZERO (folded into passes that already run, exactly as their
commit messages claimed - verified) and one net NEGATIVE.

Section prices at 0.13.40 (`doctrine-sections.py`, ~24,060 measured tokens for the file):
Project policies 23.1%, Role flow 15.4%, Verification agreement 11.2%, Planking 9.9%.

## CONFIRMED defects, textual

**1. HIGH-value/low-cost: a citation naming a section that does not exist. Latent since
0.13.8 (`425c642`), 32 versions.** `qm:75`, `boatswain:60`, `shipwright:72` each cite "per
the Wake policy". Grep-verified: no such heading exists in any skill. The corpus's own terms
of art (`shipshape:93`) states "Wake: ... the **Transient output policy** carries the rules."
A role following the citation to verify its own claim finds nothing. Fix: three words, x3.

**2. Contradiction on dead-code removal, within one paragraph.** `shipshape:125` lists
"unreachable code" among things to "remove ... when safe", unqualified by role or phase; the
same line then says "Dead code does not block the voyage: it is reported and deferred to
harbour", and `:141` restricts removal to Shipwright, harbour-only. A Crew mate reading the
first clause has textual licence for an act the rest of the Article forbids. Fix: drop
"unreachable code" from the `:125` list, which `:125`-later and `:141` already own.

**3. `shipwright:110`, the Methodology-checks bullet: 4,368 bytes in ONE unbroken paragraph**
- 9.7% of the file, 70% of its subsection, four nested conditional branches, read ~26x/leg.
The single largest cost concentration in the corpus (~113k byte-invocations). Load-bearing
procedure, so it resists a plain cut; restructuring the comma-chained sentence into a list
recovers ~800-1,200 bytes of connective prose with no loss of binding content.

**4. `captain:54`, the greenfield fast-path bullet: 4,781 bytes, 20.1% of the whole file**,
twelve distinct sub-rules chained into one paragraph before its worked example.

## The operator's OWN sprawl, from this session's own ship

**5. `shipshape:384` (0.13.40, mine) is now the LONGEST line in the shared Articles at 2,101
chars - 42% longer than the next (1,476).** Verified by direct measurement. Roughly half is
rationale prose explaining WHY Crew cannot install, addressed to roles that must obey either
way and cannot change it. It also asserts its conclusion three times in three consecutive
sentences ("no dependency routes through Crew" / "could never route through it at all" / "A
product dependency does not route through Crew either"), each carrying a different reason.

**6. The 0.13.40 rule is now stated at FOUR sites** - `shipshape:384`, `shipwright:58`,
`captain:53`, `captain:95` - each already carrying a "per the Rigging read contract" citation,
so the restated rule text (~150 bytes/site) is recoverable at the citation.

**7. 0.13.40 broke the file's own write-scope pattern.** Every other Shipwright write
exception appears BOTH in `shipwright:20` and in Article 8's exception bullets
(`shipshape:140-141`). The new manifest/lockfile write authority was put in the role file
ONLY. Verified: no mention of lockfile/manifest/install in Article 8's exceptions.

**8. Scar tissue in that same paragraph.** 0.13.33's trailing "Recording routes with
installation" sentence survived 0.13.40's rewrite of everything before it, and now sits
bolted to the end of two paragraphs of routing rationale it has nothing to do with. ~280
bytes recoverable by folding "records it under `## Dependencies` in the same pass" into the
installation sentence itself.

## Claims DOWNGRADED on operator re-verification

**The "move the Outbound verification policy to Captain" proposal (1,237 bytes, claimed
Captain-only) is WRONG and does not ship.** Verified: `shipwright:74` and `:109` derive the
`## Outbound` targets and write the section at fitting out, `shipwright:158` reports pending
outbound, and `boatswain:32` carries the "Outbound is Captain-only" prohibition it must know
to obey. Not single-role; not movable. Same overclaim class the handoff audit caught twice.

**A false "subtractive" commit claim, corrected for the record.** 0.13.37 (`b761b64`) says
"Subtractive - the wrong list member and the absolute first sentence both go." Both removals
are real, but the commit ADDED a longer replacement sentence: **net +69 chars**. It fixed a
genuine contradiction and was worth shipping; it was not a subtraction. Trivial in size, but
the framing pattern is what this harness exists to catch.

## What the audits did NOT find, stated so it counts as evidence

- **No dead rules.** Every conditional traced to a role and a procedure that reaches it.
- **No introduced contradictions** in the final state of any passage the eight commits touched.
  Dependency routing is consistent across all five role files post-0.13.40 (grep-verified: no
  site still says "Crew installs"). The 0.13.37 turn-ending rule and the dispatch rule it was
  reconciled against are now mutually consistent.
- **The "fix silently duplicated by the next version" pattern did NOT recur.** Every
  multi-commit touch to one paragraph was a full rewrite superseding the prior text.
- **No near-duplication-with-drift** between shared Articles and role files: no case where a
  role file's wording licenses an act the shared Article forbids.
- **No section is a dumping ground.** All three growth concentrations stayed on-topic.

## Routed to dk, NOTHING SHIPPED

Findings 1, 2, 7 and 8 are TEXTUAL by the probe-first rule (a broken citation, a list member
contradicting its own paragraph, a missing exception-bullet entry, a stranded sentence) and
ship on a close read plus green `tests/*.sh`.

Findings 3, 4, 5 and 6 are SUBTRACTIVE EDITS TO LIVE RULES. Their defect is visible in the
artifact, but the edit is aimed at what roles do with the text, so by AGENTS.md's sharpened
rule they owe a probe with a control. The paired-battery rig for exactly this is built and
parked: probe states at `$SCRATCH/battery-40`, control worktrees at `doctrine-0.13.33` and
`doctrine-0.13.39`, rubric at `designs/depfitout/rubric.md`.
