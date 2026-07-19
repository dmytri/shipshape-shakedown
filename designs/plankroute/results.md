# plank-routing A/B/C — results, scored against the rubric fixed before the legs reported

12 legs, 4 per arm, byte-identical state (fresh clones of the tw4 probe state, base `0a557ee`),
all sonnet, zero nested spawns, zero commits. Banked `data/plankroute-0.13.35/`.

| Arm | Channel | Doctrine text | P1 in-diff → Crew | P2 no over-correction |
|---|---|---|---|---|
| A control | HEAD-text | current 0.13.35 | **4/4** | 4/4 |
| B candidate | HEAD-text | reorganized on location | **4/4** | 4/4 |
| C control | installed plugin | current 0.13.35 | **3/4** | 4/4 |

Integrity, every leg: arm-unique marker present and the other arm's absent (A/B), 0.13.35 marker
present (C); 100% `claude-sonnet-5`; zero `Agent` spawns; zero commits.

## The candidate is a NULL RESULT — do not ship it

A 4/4 vs B 4/4 on the same channel. The reorganization neither helped nor hurt, and it had no
fault to fix in HEAD-text mode because the control never failed there. Per the rubric's own
stated rule — *"Both arms at 4/4 = null result, no ship"* — **the reorganization ships nothing.**

Cost was also flat (A mean 9.25 inv / 443k, B mean 8.75 inv / 417k), inside noise at n=4, so no
economy claim rides on it either.

## The fault IS real — it reproduced 1/12, on the installed channel only

**C4 failed**, and its stated reasoning is the whole finding:

> "Neither seam was touched by this voyage's diff (**HEAD is base, nothing dispatched yet**), so
> both are plank drift beyond the current diff: deferred to harbour."

It ran **zero** working-tree commands. It inferred "no role-advanced diff exists" from
`HEAD == base commit`, while `git status` would have shown `M src/tide.js`. Downstream teeth,
tree-verified: C4 declared the watch **spent** and appended a green line to `runrecord.jsonl`
(2 lines vs 1 in every other arm-C tree) — the unplanked seam leaves Crew's hands with a
recorded green behind it.

This is character-for-character the fault the 2026-07-19 session already recorded for the
0.13.34 control arm: *"conflating an unmoved HEAD with no role-advanced work while the tree
carried `M src/tide.js`."* Second independent observation, same mechanism.

## My battery finding was RIGHT that there is a fault and WRONG about its mechanism

The battery write-up said the QM "applied the wrong one of two co-existing doctrine rules
(dead-code-or-unspecified vs touched-seam-in-diff)." C4 shows something different: it applied the
touched-seam rule **correctly** and computed its input **wrong**. It asked exactly the question
arm B's text tells it to ask — *is the seam in the role-advanced diff?* — and answered it from
the wrong evidence.

That is why arm B cannot fix it, and the numbers agree. A reorganization that makes the location
question more prominent does not help a role that reaches the location question and then answers
it by inference.

Note the two failures used two different rationales: tw4 reached harbour via the
dead-code/unspecified classification, C4 via the HEAD-vs-base inference. n=2, two routes, one
destination. Neither is established as *the* mechanism.

## Doctrine already forbids what C4 did

`shipshape/SKILL.md`, Hand-off custody: *"A report states what the tree answered. Every factual
claim a report makes about the tree … is the output of a command the role ran, never a
recollection and **never an inference** from what the role wrote earlier."*

C4's "neither seam was touched by this voyage's diff" is an unbacked tree claim in a place
doctrine explicitly bans inference. The rule exists, is load-bearing elsewhere (it fired in all
three legs on 2026-07-15), and C4 broke it. **This is a compliance failure at ~8%, not a text
gap** — and a text gap is the only thing new text can fix.

## Recommendation

1. **Ship nothing for finding #1.** The proposed reorganization is a null result against its own
   control; the four-site change dk flagged as "big" buys nothing measurable.
2. **Downgrade the battery finding from HIGH.** It is real and reproduced, but at 1/12 on one
   channel, against a rule doctrine already states, with the mechanism mis-described in the
   original write-up. Corrected on both counts here.
3. **If dk wants hardening**, the candidate is *not* more prose — it is check-precedence applied
   to the routing input: establish the role-advanced diff by running `git status --porcelain` /
   `git diff HEAD`, never by comparing HEAD to the base commit. That is a smaller, different
   change than the one probed here, aimed at the mechanism this probe actually found, and it owes
   its own probe before it ships.

## Limits

- n=4/arm on a judgment call; 1 failure total. This sizes nothing precisely.
- Arms A/B are HEAD-text and arm C installed-plugin, so A/B-vs-C is confounded by channel *and*
  by the HEAD-text preamble's "read ALL fully before doing anything," which plausibly suppresses
  the fault. The A-vs-B comparison is clean; the A-vs-C comparison is not.
- Stop-before-dispatch reads routing from the report, not from an executed dispatch.
