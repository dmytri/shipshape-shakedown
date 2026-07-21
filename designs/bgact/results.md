# Results: 0.13.50 vs 0.13.48, background-run behaviour

Rubric: `designs/bgact/rubric.md`, fixed and committed (`52e758f`) before any leg was
dispatched. Banked `data/bgact-0.13.50/` (12 legs). 2026-07-21.

**12 QM legs, n=6/arm, HEAD-text skills-only both arms, no hook in either, forced 220s
sweep. 273 invocations / 16,129,878 cache. Model 12/12 `claude-sonnet-5`, zero escalation.**

## VERDICT: NULL. 0.13.50 is not shown to change behaviour.

| Leg | Arm | Covering timeout | Crossed boundary | Marker | Inv | Cache |
|---|---|---|---|---|---|---|
| t1 | 0.13.50 | **300000** | no | **PASS** | 24 | 1,483,007 |
| t2 | 0.13.50 | **400000** | no | **PASS** | 22 | 1,253,158 |
| t3 | 0.13.50 | none | yes | FAIL | 30 | 1,912,977 |
| t4 | 0.13.50 | **420000** | no | **PASS** | 20 | 1,129,094 |
| t5 | 0.13.50 | none | yes | FAIL | 15 | 803,323 |
| t6 | 0.13.50 | none | yes | FAIL | 16 | 824,989 |
| c1 | 0.13.48 | **330000** | no | **PASS** | 20 | 1,180,449 |
| c2 | 0.13.48 | none | yes | FAIL | 39 | 2,627,045 |
| c3 | 0.13.48 | **300000** | no | **PASS** | 29 | 1,521,416 |
| c4 | 0.13.48 | none | yes | FAIL | 28 | 1,775,068 |
| c5 | 0.13.48 | none | yes | FAIL | 18 | 998,239 |
| c6 | 0.13.48 | none | yes | FAIL | 12 | 621,113 |

**Treatment 3/6 clean. Control 2/6 clean.** The rubric's decision rule was fixed in
advance and it is unambiguous here: *"Both arms similar → NULL"*, and *"a difference of
one leg is not a result"* at n=6. **0.13.50 stands on textual grounds only. Its
behavioural claim is NOT earned and must not be recorded as validated.**

Every leg read the text it was given — version-unique markers confirmed per transcript,
zero cross-contamination. The failing treatment legs had the new sentence in context and
reached for the old shape anyway.

## The mechanism is confirmed exactly, which is why the null matters

**The act predicts the outcome perfectly, 12/12, in both arms:**

| | Clean | Stalled |
|---|---|---|
| Set a covering timeout | **5** | **0** |
| Did not | **0** | **7** |

Not one leg that raised the foreground budget stalled. Not one leg that left it default
survived. The 220s sweep against a ~120s default makes this deterministic: the boundary
is crossed by *omission*, and the act is a complete defence.

So 0.13.50 names the right act. **What it does not do is cause roles to take it.** Two
control legs took it spontaneously under the old text (c1 `330000`, c3 `300000`), and
three treatment legs skipped it with the new text in front of them. Naming the act
raised uptake from 2/6 to 3/6 — noise.

This is the sharp contrast with 0.13.42, the corpus's standing example of naming an act
(0/4 → 4/4). That worked because the act was *invisible* until named — a held dependency
produces no failure. Here the act is a tool parameter the role either reasons about or
does not, and prose about it changes nothing. **The lesson to carry: naming an act works
where the obligation is unobservable, not where it is merely unperformed.**

## The recovery count is not a stable statistic — corrected twice, still moving

The operator called this wrong twice:

1. Mid-run: *"zero permanent deadlocks — all three stalled legs recovered"*, on seeing
   c2, c4 and t3 resume and file clean reports.
2. At write-up: *"3 recovered, 4 stayed dead."*
3. **t6 then recovered while that second correction was being committed.**

Standing tally at **17:28Z, 19 minutes after the last leg stopped**, with no basis for
calling it final:

- **Recovered** (resumed, completed, run record written): t3, t6, c2, c4 — **4/7**
- **Not** : t5, c6, and c5 (holds a production edit, no run record) — **3/7**

**The methodological point outranks the number: a stalled leg's outcome is a function of
when you look.** "Did it deadlock" cannot be read off a snapshot. Every prior figure in
this corpus for this class — pilot #2's, 0.13.33's, the n=8 rerun's 1/3, this session's
earlier 3/3 — was a snapshot, and none recorded an observation time. Those rates measure
operator patience as much as runtime behaviour. **Any future probe on this class must fix
an observation horizon in advance and state it.**

What survives regardless: a background completion **sometimes** resumes a finished
subagent turn, contradicting the absolute wording in both `SKILL.md` and
`background-custody.sh`'s header — and it plainly does not always, with three legs still
empty 19 minutes on. The deciding mechanism is **unexplained** (4/7 here against 0/3 in
the previous probe, itself a snapshot). **Open question, not a finding.** Anyone relying
on self-healing is relying on something this harness cannot predict.

## Economy

Mean cost is flat between clean and stalled legs (23.0 vs 22.6 inv), but the distribution
is not: a stalled leg that stays dead is *cheap and worthless* (c6 12 inv, t6 16 inv,
producing nothing), while a stalled leg that recovers is the most expensive outcome on
the board (c2 39 inv / 2.63M — 95% more invocations than the cheapest clean leg). **The
clean path is the only one that is both cheap and complete.**

## The cross-role rider, answered unprompted

The standing rider — probe the role that does NOT fail — was not dispatched, and it
answered itself anyway. **t1's nested Boatswain hit the same fault under treatment text**,
leaving a verification run backgrounded with no resumption path, and disclosed it in its
own report. It was rescued by its parent QM, which noticed and sent a correction. So the
fault is not QM-specific: it belongs to any role that runs the slow sweep. A dedicated
Boatswain/Crew arm is no longer owed to establish that.

## What this leaves

1. **0.13.50 keeps its textual footing and loses its behavioural hope.** No revert is
   indicated — the text it replaced was worse (it ordered the failing branch) — but the
   corpus must not carry it as a validated behavioural fix.
2. **Text is the wrong instrument for this class.** Two versions of wording have now
   failed to move it. What moved it in every single case was the parameter. The next
   candidate is machinery, not prose: the hook (0.13.49, untested live), or a runtime
   that resumes roles, which doctrine already asks for in the same paragraph.
3. **The unexplained resumption** needs its own look before anyone prices the severity of
   this class again.
