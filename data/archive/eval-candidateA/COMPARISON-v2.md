# eval-candidateA v2 — behaviour-level ledger — SAMPLE result (ONE draw each)

v2 pushed the ledger from seam granularity to BEHAVIOUR granularity. Result is
MIXED and, at one draw each, NOT conclusive — it changes the methodology need.

| Model | control | v1 (seam ledger) | v2 (behaviour ledger) | @captain: ctl -> v2 |
|---|---|---|---|---|
| glm-4.7 (failer) | no | no (ledger emitted) | **no** (behaviour ledger emitted) | 0 -> 0 |
| devstral-2512 (failer) | no | no (1 plank) | **CLEAR** (3 @captain edge-case scenarios) | 0 -> **3** |
| qwen3.6-35b (clearer) | CLEAR | CLEAR | **no** (behaviour ledger emitted, 0 @captain) | 1 -> **0** |

## What v2 established (structural, reproducible)

**v2 forces behaviour-level ENUMERATION.** glm-4.7 and qwen3.6-35b both emitted a
behaviour-row ledger (happy path + error path enumerated), where v1's glm ledger had a
single seam row. The form change worked: the walk is now visible.

## What v2 did NOT establish, and the deeper limit

**The ledger forces enumeration, not DISPOSITION judgment.** A model can enumerate a
behaviour and still (wrongly) call it "covered": glm-4.7 and qwen3.6-35b both listed
happy+error behaviours and dispositioned them all covered -> 0 @captain, missing the
edge-case gaps (empty table, only-low-tides) devstral enumerated and wrote 3 @captain
skeletons for. "Prompt clearer" can compel the enumeration; whether an enumerated
behaviour is a gap is a judgment the structure can't fully compel.

## Why this is NOT a verdict: one draw is too noisy for a ship decision

Each cell above is a SINGLE sample. v2 flipped devstral, glm persisted, and the clearer
qwen3.6-35b went to 0 @captain (a REJECT signal IF real). A clearer regressing on one
draw is exactly the variance the corpus warns against ("one draw is noise, a flail-point
is a pattern"). We CANNOT conclude v2 helps, hurts, or nulls from this.

**Method call: the exploration phase (one draw, fast iteration) got us the instrument,
the off-ramp finding, and two candidate shapes. A SHIP decision now owes REPEAT DRAWS.**
Proposed: N=3-5 draws per model per arm on the sample (control + v2), clear-RATE per arm,
before any verdict. ~18-30 cheap legs. Only then does "v2 flips failers without
regressing clearers" become a claim rather than a coin flip.

## Standing
- Do NOT ship v1 or v2. ~/shipshape untouched.
- Deeper open question for the rethink: if disposition judgment is a partial capability
  floor, the honest doctrine answer may be a smaller clarification than a ledger, or an
  acceptance that some roles need a capable model — not more prescription.
