# FINDING (doctrine, textual footing): the watchbill's mandatory shape is stated only where it is
# REJECTED, never where it is WRITTEN — and conformance is anti-correlated with outcome

Channels (candidate AND installed 0.13.65 — this is shared doctrine, not candidate-specific):
- `shipshape/SKILL.md` Watchbill policy: states the fixed form (`watch1`, `watch2`, ...; each watch
  contains only `scenarios`; entries `<spec>.feature:<Scenario Name>`), inside a long prose policy.
- `qm/SKILL.md` step 3: restates it and orders enforcement — "Reject malformed or free-form context."
- `captain/SKILL.md` work-loop step (the WRITER's point of action): "Write valid `watchbill.json`
  with watch objects and scenario references only" — no concrete form, no example.
- pilot Captain task: says "author the specs and watchbill your role requires"; carries no shape.
- grep: `watch1` appears in qm + shipshape only. Zero hits in captain. Same in 0.13.65.

Tree evidence, two draws, same model (xiaomi/mimo-v2.5), same doctrine, same task:
- P3-cand-mimo `watchbill.json` = `{voyage, base, watches:[{id,...}]}`   -> NON-conforming
- P4-cand-mimo `watchbill.json` = `{voyage, base, features:[{file,scenarios[]}]}` -> NON-conforming
  Both Captain legs loaded captain + shipshape (eval-map role reads). Captain conformed in NEITHER.

The sharp part — QM enforcement is draw-unstable, and obeying doctrine LOST:
- P4 QM (7 turns, 16.2s, $0.005): obeyed its own text, rejected the free-form watchbill, blocked to
  Captain. Voyage produced NO app. Its report is correct and well-formed.
- P3 QM: ignored the same class of malformity, proceeded, built the app -> oracle 23/29 in a 539s
  build leg.
=> The role that followed the rule produced nothing; the role that broke it produced the run's best
   build. Same inversion as the r21 rs lesson: the "failing" leg was the witness that the text is
   mis-sited.

Reading, per the probe-first rule: TEXTUAL footing. The defect is visible in the artifact — a form
whose only statement lives at the reader and the rejector, not at the writer. Candidate fix shape,
per "prompt clearer, not harder": put the concrete form (or a 3-line example) in Captain's work-loop
at the point of authoring, so the writer is shown what the rejector will check.

NOT shipped. Routed to dk. Control arm will show whether 0.13.65 deadlocks the same way.
