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

## C — Captain may resolve a deadlock (Blocker policy, `shipshape/SKILL.md:390`)

dk's ruling, and the one that generalises. Answers yoink's own indictment: *"The process has no
defined escalation or durable evidence channel for this contradiction."*

ADD a row to the routing table:

> | A deadlock: no legal transition can make progress | Captain | Captain, by the minimal
> progress-restoring action, recorded |

ADD after the table:

> **Deadlock resolution is Captain's.** These Articles bind agents with judgment, not code paths.
> Contract discipline exists to keep context clean; it never exists to produce a state no legal
> move can leave. When every route to the next step demands evidence no role may supply, or an
> action no available role may take, Captain names the deadlock, states the routes it tried and
> the evidence it holds, takes the minimal action that restores progress — including one normally
> reserved to another role — and records it as a named decision in its notes and its report. This
> is a last resort and not a bypass: the legal routes are shown exhausted first, and the record
> makes the deviation auditable. A deadlock that reaches this rule is a doctrine defect; report it
> as one.

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
