# data/ — the layer that survives, and how to prune it

Only what is pushed to origin survives (AGENTS.md, VM mortality). Everything here is small on
purpose: the durable record of a leg is its `session.jsonl` (~500K), its folded `map.txt`, its
`tree.diff`/`tree.status`, its `leg.json`, plus the wave's `driver.log` and oracle grades.

**Raw `pi.stdout` is NOT banked.** `eval-bank.sh` copies it only with `EVAL_KEEP_STDOUT=1`.
json-mode streaming re-emits accumulated state per event, so a single leg's render reached 40G
apparent (`P6-ctrl-cmimo/v6-qm.stdout.json`) while its `session.jsonl` was 500K. Banking it by
default took `data/` to 19G and twice drove this box to 99%, voiding a live cell mid-run. Raw
belongs on BorgBase; structured fidelity — thinking, tool calls, results, per-turn usage — is
all in `session.jsonl`, so analysis loses nothing.

## Layout, chosen so pruning is one command

    data/<wave>/          CURRENT work: the doctrine comparison in flight and its baselines
    data/archive/<wave>/  PRE-CONTROL history: earlier instrument generations, kept for citation

`data/archive/` holds the 0.13.x-era batteries, probes, waves and pilots that established the
method but are not part of the live candidate-vs-control question. Nothing in flight reads it;
METRICS.md and CAPTAIN.md cite it by name where a finding rests on it.

**To reclaim space, drop the archive wholesale** — it is the pre-control history and its
conclusions live in METRICS.md:

    rm -rf data/archive        # ~144M, 108 waves

**What must stay in `data/` (not archivable):**

- `P5-*`, `P6-*`, `P7-*` — the candidate/control/midway pilot cells under active comparison
- `methods-candidate/` — the fit-out matrix results (r21–r23) and the candidate diffs
- `todomvc-3model-compare/`, `todomvc-mimo*`, `todomvc-frontier-compare/` — the banked baselines
  every current number is read against

## Retention rule

A wave earns a place here while its cell is unsettled or while a live claim rests on it. Once a
finding is written into METRICS.md with its evidence quoted, the wave moves to `data/archive/`
at the next session boundary, and the archive is expendable whenever disk demands it.
