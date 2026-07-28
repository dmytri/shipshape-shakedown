# Generation A — pre-harness fixture (2026-07-27)

**Superseded. Do not compare any cell here against a later generation.**

| axis | value |
|---|---|
| harness | `70b2ebb` and earlier — pilot scaffold ships NO verification support |
| playbook | fit-out ran AFTER voyage 1; 1500s leg cap; `tail -3` self-suite parse |
| doctrine arms | candidate `experiments/methods-candidate`, control installed 0.13.65 |
| oracle | one clone per arm, no lock |

**Why it is void as a comparison.** The fixture had no world/harness, so the executable tier
never loaded the production artifact: a wave could run a green suite over an EMPTY `js/`
(P5-cand-flash, 19/21 green, oracle 0/29 for twelve voyages, final "app" two lines and
correctly planked). happy-dom also never fires `hashchange`, so the whole routing family was
unreachable. Both were fixed in generation B.

**What it is still good for.** It carries the evidence for six defects of ours — the dead
oracle, the 1500s truncation, the vanishing `chai` dependency, the greenfield contradiction,
the watchbill form stated only at the rejector, and the green-suite-over-no-app trap. Findings
and their quoted evidence are in `findings/`.
