# Bare-hand-off audit — have we drifted from hand-offs being bare-workable?

dk, 2026-07-20: *"review all handoffs to see if we've drifted from bare handoffs being workable in
skill-only agents"*, and *"we need to resolve this before wave 7."*

Method: four parallel audits, one per receiving role, each reading HEAD doctrine (0.13.37) and
asked adversarially where its routine dead-ends when the dispatch carries only role + project
root. **Every HANDOFF-ONLY claim was then re-verified against the quoted line by the operator**;
two were downgraded on that check, recorded below.

**Answer: yes, in one systemic way and three minor ones. One over-narrow scoping is the bulk of
it.**

## The rule being tested

dk's, sharpened: **no property may depend SOLELY on hand-off content.** Hand-offs may carry
things as an optimization — Crew needs failure evidence, QM needs the watchbill — but a durable
route must always exist. Skill-only consumers have no dispatch guard, fresh sessions and context
clears are routine, and a human may relay by hand, so any hand-off can arrive bare.

It binds at the SYSTEM level, not the role level: a role may legitimately require carried content
provided some role upstream can re-derive it from durable state.

## SYSTEMIC — one finding, one scoping

`shipshape/SKILL.md:324` imposes a hand-off dependency on **every** transition:

> "On any transition, the preceding role's final-report blockers and open questions are the first
> work item."

`shipshape/SKILL.md:366` supplies the durable fallback for **exactly one** of them:

> "If QM sees no blocker, the deck is clean, not lost."

That sentence appears nowhere else in any skill (grep-verified across all six). So
Boatswain→Captain, Shipwright→Captain and Captain→Shipwright all carry the `:324` dependency with
no safety net. Consequences the audits found, each traced to this one root:

- **Shipwright** cannot learn Captain's blockers or open questions on a bare dispatch. Its read
  scope (`shipwright/SKILL.md:19`) deliberately excludes `CAPTAIN.md`, so no artifact carries
  them. It proceeds blind.
- **Captain** cannot learn Boatswain's or Shipwright's blockers on a bare report, and — unlike
  the QM path — has no stated rule that silence means clean. Report-only harbour findings not
  promoted to durable artifacts are lost for the cycle (re-derivable at the *next* harbour, which
  is a real but delayed fallback).

**FIX: generalize `:366`'s scoping from QM to any reporting role.** One clause. Subtractive in
spirit — it removes a narrowing, exactly like the base-commit fix below — and it closes all three
consequences at once.

## NON-TERMINATING — one finding, and its fix already exists in the same file

The watchbill strike (`boatswain/SKILL.md:99`) terminates gracefully **per role** — "leave it and
name it in the report for Captain" — but the SYSTEM never resolves: no role can supply the
missing evidence, so Captain's only moves loop, and the watchbill lingers permanently.

**Eight lines above, the recheck selection has precisely the ladder the strike lacks:**

| | Rung 1 | Rung 2 | Rung 3 |
|---|---|---|---|
| recheck `:94-95` | caller's hand-off | run record at current hash | **follow the planks and RUN it** |
| strike `:99` | caller's hand-off | run record at current hash | **none — "orders no run of its own"** |

**FIX: give the strike the third rung recheck already has** — hand-off, else run record at the
current deck-state hash, else verify the entries by running them. Economy is preserved because
rungs 1 and 2 are tried first; the point is only that rung 3 exists. This subsumes pilot #5's
finding-1 option "stop treating runrecord as optional wherever this property matters."

## SILENT GAPS — three, minor, one line each

1. **Base-commit fallback is scoped to the wrong entry mode.** `:342` and `qm/SKILL.md:69` both
   gate the HEAD fallback on "fresh session", but `:326` says spawning an isolated subagent "is
   preferred" — the preferred mechanism is not the one the fallback names. Empirically benign:
   every bare-dispatch leg in this session's arms A/B/C resolved it to HEAD anyway, several
   citing the fresh-session rule by analogy. Fix: drop the scoping — "A role that enters with no
   dispatched base commit takes HEAD as the base commit."
2. **`crew/SKILL.md:33` solo/parallel marker has no stated behaviour when absent.** The scenario
   reference and the failure evidence both have explicit stops at `:37`; the marker has neither a
   stop nor a default. A mate assuming solo inside a parallel dispatch could edit beyond its
   target. Fix: state the default (solo) or the stop.
3. **`boatswain/SKILL.md:100` commit-subject form is underivable when the job was self-selected.**
   The subject must reference either the scenario/watch advanced or the harbour session, but
   `:42`'s self-select test is diff-presence alone, which cannot distinguish post-Crew custody
   from harbour custody. Fix: give the self-select path a stated default form.

## NOT DRIFT — two downgraded on operator re-verification

- **Crew halting with `No target. Crew stop.` (`crew:37`) is correct**, not a defect. Crew is a
  leaf role, never a chain entry point; it is always dispatched by QM, whose own inputs are
  durable (`watchbill.json`). A bare-dispatched Crew *should* halt cleanly, and the system
  recovers because QM re-derives and re-dispatches. The audit flagged it HANDOFF-ONLY at the role
  level; at the system level the property survives.
- **Captain's "passing verification" trigger (`captain:51`) is derivable**, contrary to the
  audit. Boatswain's recheck ladder always terminates in evidence — carried, recorded, or freshly
  run — and Boatswain commits only in post-implementation. So the existence of a custody commit
  at HEAD is itself durable proof that verification passed; Captain reads it with `git log`.
  Worth a clarifying half-sentence, not a fix.

## OPERATOR CORRECTION on the yoink finding

The 2026-07-20 yoink entry in CAPTAIN.md said the deadlock left "no legal custody path". **That
overstated it, and the error was mine**: I verified yoink's mechanism (gitignored record,
empty-blob hash, dated the regression to 0.13.17) but adopted their consequence claim without
reading `:99`'s final clause. Custody commits fine. What never terminates is the strike. The
finding stands; its severity was wrong. Corrected in place.

## Shape of the whole fix

Five text changes, four of them one line, none adding a new mechanism:
1. generalize `:366` (systemic)
2. third rung on the strike, mirroring recheck (non-terminating)
3. drop the "fresh session" scoping on the base-commit fallback
4. state the solo/parallel default
5. state the self-select commit-subject default

All five are TEXTUAL by the probe-first rule — visible in the artifacts — so they ship on a close
read plus green `tests/*.sh`. They still need dk's word, and they are doctrine, so they gate wave
7 per dk's ruling.
