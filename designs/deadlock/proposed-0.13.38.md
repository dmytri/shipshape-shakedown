# Proposed 0.13.38 — the deadlock fixes. DRAFTED, NOT SHIPPED.

Three changes, three different layers. They are complementary, not alternatives: A removes one
cause, B guarantees termination when any cause remains, C catches the deadlocks we have not found
yet. dk: *"this situation where a captain can not resolve a deadlock is wrong"* and *"we want to
solve the real deadlock issue"* — both, so all three.

## A — the run record is read by path (Wake policy, `shipshape/SKILL.md:463`)

Removes the *specific* cause confirmed from yoink's transcript. **Band-aid on its own** — it makes
route (b) reachable, it does not make it terminating.

APPEND to the Wake policy's run-record paragraph:

> The record is read at its `runrecord` path and nowhere else. It is git-ignored by design, so it
> is absent from the index and from ignore-honouring searches: a git-tracking check such as `git
> ls-files`, and a bare `rg` sweep, both report it missing when it is present. Test it by path.

Evidence: `git ls-files --error-unmatch -- watchbill.json coverage/runrecord.json` → exit 1,
`"did not match any file(s) known to git"`, in yoink's 2026-07-20 06:43 custody leg. The check
cannot succeed on a conformant record, because `shipwright/SKILL.md` requires the path be ignored.

## B — the strike gets its third rung (`boatswain/SKILL.md:99`)

**This is the real deadlock fix.** Even with A, a stale record, a moved tree, or an absent record
re-deadlocks the strike. The ladder terminates regardless of cause. Mirrors recheck selection at
`:94-95`, which has had exactly this shape all along.

REPLACE:

> The spent evidence is the strike's whole evidence: the strike is a non-executable deletion and
> orders no run of its own. A watchbill with entries neither a hand-off nor a current-hash
> run-record entry verifies is not spent: leave it and name it in the report for Captain.

WITH:

> Where neither carries the evidence, run the watchbill's own entries through the `focused`
> command and strike on that green, exactly as recheck selection falls back to its planks. The
> entries name themselves, so the run is bounded by the watchbill and orders nothing wider. A
> watchbill whose entries do not all pass is not spent: leave it and name it in the report for
> Captain.

Economy: rungs 1 and 2 are tried first, so rung 3 fires only when both fail — and change A makes
rung 2 work properly, so rung 3 should stay rare. Cost is bounded by watchbill size: yoink's is
one scenario; our fixtures carry one to four. The earlier worry that this inflates custody is
largely answered by that bound, but it is the one part of this ship with a behavioural effect and
it owes the cost check named below.

## C — Captain's authority at sea (Blocker policy, `shipshape/SKILL.md:390`)

dk's ruling, in dk's own framing, which is broader AND better bounded than my first draft:

> "the goal of shipshape is not prevent the captain from keeping progress going, it's ensure code
> is derived from durable specs, the captain should always strive to follow the agreements, but if
> they have to take matters into their own hands to resolve deadlocks or to make critical
> (non-application-code) corrections at sea, that's what their authority is for"

**My first draft was wrong**: it permitted "an action normally reserved to another role" with no
limit, which would have licensed Captain to write production code — breaching the exact guarantee
the Articles exist to provide. dk's framing supplies the boundary: the authority is bounded by the
purpose it serves.

ADD a row to the routing table:

> | A deadlock, or a critical correction no available role may make | Captain | Captain, by the
> minimal action that restores progress, recorded |

ADD after the table:

> **Captain's authority at sea.** These Articles exist so that production code derives from
> durable specs. They do not exist to stop Captain making progress. Captain strives to follow
> them, and departs from them only where following them would stall the voyage or leave a fault
> uncorrected. Where no legal transition can make progress, or a critical correction is owed that
> no available role may make, Captain names the situation, states the routes it tried, takes the
> minimal action that restores progress, and records it as a named decision in its notes and its
> report.
>
> One boundary holds absolutely: **Captain never writes production code.** That is the guarantee
> these Articles exist to protect, and it always routes through a durable spec to QM and Crew.
> Everything else is within Captain's authority when the voyage would otherwise stall: striking a
> spent watchbill, making a custody commit, correcting rigging, repairing a malformed record.
>
> A situation that reaches this rule is a doctrine defect. Report it as one, so the rule stays a
> last resort rather than a habit.

**Note what C alone already does for yoink**: striking a spent watchbill and making the custody
commit are both non-application-code actions, so a Captain holding this authority resolves their
deadlock today without A or B. A and B remain right — they stop the deadlock arising — but C is
the one that unblocks a consumer already stuck.

## Shipping judgment

- A and C are textual with no behavioural cost — they ship on a close read plus green
  `tests/*.sh` per the probe-first rule.
- B changes runtime behaviour (it can order a run that previously did not happen), so by the
  corrected rule — *a textual defect can have a behavioural fix, and the fix inherits the probe
  obligation* — B owes a cost check against the battery states before or shortly after shipping.
  Given the watchbill-size bound, shipping B with A and measuring in the next battery is
  defensible; shipping B alone and unmeasured is not.
- This would be the THIRD unvalidated version riding one restart (0.13.36, 0.13.37, 0.13.38).
  They touch disjoint seams — QM retrieval, turn-ending, custody strike — so they stay
  attributable, but the accumulation is real and named.
- yoink needs a re-vendor (`npx skills update`) to receive any of it; the plugin channel does not
  reach them.
