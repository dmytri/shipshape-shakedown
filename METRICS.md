# Metrics: how to read a shakedown

## The three numbers per leg (bin/mine.sh on the task transcript)

- invocations: model API calls (grouped by message.id). The primary cost driver -
  each re-prefills the whole context (~50-80k cache-read on sonnet legs).
- output tokens: reasoning + report. Small (5-15k/leg); NOT the cost driver.
- wall: first-to-last timestamp. ~95% agent overhead on toy suites, so wall tracks
  invocations x model speed, not verification.

Token cost ~= cache_read x invocations. Latency lever == token lever == fewer rounds.

## Suite executions (bin/runs.sh on the project)

The runlog BeforeAll hook logs every EXECUTING cucumber run (dry-runs excluded - they
run no hooks). Duplicates of the same argv with no intervening tree change = redundancy.
Attribute phases by line ranges (record the count between legs).
Fixture v2 (2026-07-13): the log sinks out-of-tree at `<parent>/.instrument/<tree>/runs.log`
(roles wiped in-tree logs/ as scratch in wave 3); bin/runs.sh reads the sink first and
falls back to logs/runs.log for pre-v2 trees. The fixture runrecord homes at the project
root (`runrecord.jsonl`, gitignored), not in logs/. Uninstrumented states (fast-path
empty repos) count runs by transcript grep instead.

## Baselines (2026-07-12, sonnet, tidewatch fixture, doctrine 0.13.x)

| Leg | Invocations | Cache-read | Out | Wall |
|---|---|---|---|---|
| Shipwright fit-out (0.13.6) | 36 | 2.95M | 37k | 8.2m |
| Captain (0.13.6) | 13 | 610k | 8.9k | 1.4m |
| Captain (0.13.8, round economy) | ~10 tool uses | - | - | 44s |
| QM + foreground Crew (0.13.6) | 25 (incl 4 wasted polls) | 1.30M | 14k | 3.5m |
| Boatswain custody (0.13.7 table) | 15 | 712k | 10.6k | 2.6m |
| Boatswain custody haiku | 14-16 | ~500-600k | 6-8k | 1.4-2.2m |
| custody-fresh-session probe (0.13.8 plugin channel, row-1 inherit) | 14 | 623k | 15.8k | 3.0m |
| strike probe, hand-off control (0.13.8 plugin channel) | 13 | 614k | 13.7k | 2.9m |
| stale-record probe (0.13.8 plugin channel, void + rerun by trace) | 27 | 1.47M | 15.9k | 4.0m |

Suite executions: fit-out ~8-11; voyage 14 (0.13.3) -> 8 (0.13.6) -> 3 (0.13.8 with
wake run-record: one red classify, one Crew-local, one QM terminal green; custody ran
zero). Probe pair 2026-07-12: row-1 inherit 0 executions, hand-off strike 0, stale-record
1 (exactly the owed focused rerun; argv in runs.log matches the focused shape).

Full voyage 0.13.8 (Captain + QM/Crew + fresh-session custody): 35 invocations,
~1.53M cache-read, ~17k out, ~5.6m wall. Same intent on 0.13.3: 15.7m.

## TodoMVC pilot baselines (2026-07-12, sonnet, HEAD-text legs, doctrine 0.13.9)

27 dispatched role legs, greenfield to graded app. Role-leg totals only: 517
invocations, ~41.1M cache-read, ~749k out, 4h31m lifecycle wall. ~39 nested
Crew/Boatswain subagent transcripts (QM-spawned) NOT included; mine from the session
tasks dir for implementer-side numbers. Notable legs: QM build voyage 111
invocations / 12.7M / 92m (17 Crew dispatches); Shipwright harbour 31 / 4.25M / 14m;
Shipwright fit-out completion 34 / 3.47M / 13m. Bootstrap (empty repo to first
product spec) cost 10 legs / ~65m - the harbour-gate deferral in the first Captain
spec leg is the single largest avoidable serialization.

Oracle (tastejs/todomvc pinned ff43b02e, cypress 15.14.2, operator-side quarantine
held): first grade 0/29 (template-markup gate, 28 unmeasured); after ONE
product-language iteration (template sections promoted to binding specs, 5 scenarios,
5 Crew fixes): 18 passing / 9 failing / 2 skipped. The 9 residual failures are
objective unauthored conformance findings (see CAPTAIN.md).

## 0.13.10 validation probes (2026-07-12, sonnet, HEAD-text)

| Probe | Invocations | Cache-read | Out | Wall | Verdict |
|---|---|---|---|---|---|
| QM seam-parallel Crew (2 disjoint seams, one file) | 14 | 571k | 12.4k | 3.8m | PASS: 2 parallel mates, collision self-healed |
| Boatswain notes custody + strike + record shape | 22 | 1.20M | 24.4k | 5.1m | FULL PASS, transcript-verified content-blind |
| Shipwright fit-out plank rules | 25 | 2.34M | 59.5k | 12.0m | PASS derivation; MISS plant-red (timing ambiguity, 3 divergent obs) |

Probe 2 tool-call audit: deck diff composed as `git diff <base> -- . ':!CAPTAIN.md'`
verbatim; only mtime stat and by-path add touched CAPTAIN.md. Zero content reads.
Probe 2 also live-validated: void-on-any-byte (record died when CAPTAIN.md landed),
rerun by trace exactly the 2 owed targets, strike after own append at current hash,
canonical JSON record lines.

## 0.13.10 seam probes, plugin channel (2026-07-12 evening, installed 0.13.10 c045b46, sonnet top-leg dispatch)

RE-DATED 2026-07-13: channel forensics (marker-phrase greps over every leg transcript)
show these legs loaded pre-0.13.10 skill text and hooks (~0.13.8/9 process-level plugin
snapshot; /clear does not re-snapshot). Numbers and behavioural observations stand;
version attribution corrected in the 2026-07-13 section below. Key re-readings:
batching MISS x2 occurred with NO batching arm in the agents' text; supersede MISS
occurred with a tag table offering only promote/discard (supersede entered 0.13.10);
the "0.13.9 strike arm FULL PASS" was model-native (corroboration wording absent from
all 12 Boatswain legs' text).

Five pre-approved probes, 31 legs total (7 dispatched + 24 nested), all mined including
nested Crew/Boatswain/QM. Totals: 409 invocations, 18.16M cache-read, 412k out, 41m
wave wall (probes parallel). Model split: sonnet-5 264 inv / 12.57M; fable-5 145 inv /
5.59M (nested spawns after a parent's first fall to the session model unless the parent
pins `model` explicitly - tw3's Captain pinned, all-sonnet children; every other parent
leaked). Nested fable-5 Crew ran 7-9 inv vs sonnet Crew 11-12 on like-for-like solos.

| Probe | Legs | Inv | Cache | Out | Wall | Suite runs | Verdict |
|---|---|---|---|---|---|---|---|
| 1 Crew batching arm | 5 | 61 | 2.39M | 40k | 11.5m | 16 | MISS: 3 solo Crew sequential on a seam QM itself named shared |
| 2 unplanked-foul route (2a+2b) | 4 | 48 | 2.11M | 50k | 1.8m + 9.4m | 5 | PASS: foul ruled (no commit/strike/runs); Crew ACCEPTS plank-only target; route closes with commit |
| 3 @captain supersede | 8 | 114 | 5.05M | 100k | 22.9m | 5 | MISS: promote-with-correction chosen; supersede still unobserved live |
| 4 harbour-gate same-pass | 7 | 89 | 3.50M | 81k | 20.4m | 12 | PASS: specs+watchbill in the review pass, zero redundant regression; bonus full voyage |
| 5 one-blocker bootstrap (5a+5b) | 7 | 97 | 5.11M | 142k | 3.7m + 36.1m | uninstrumented | PASS: one blocker; one Captain cycle resolves values AND toolchain; full fit-out + methodology suite green |

Leg worth densities: P2a Boatswain custody-foul 100% (9 inv/351k/1.8m - new best custody
baseline), P1 voyage Boatswain 100% (10 inv), tw3 strike Boatswain 100% (10 inv, record-
corroborated strike, zero strike-runs - 0.13.9 arm FULL PASS live), tw5 fit-out
Shipwright#2 100% (12 inv incl. two planted-red proofs), P1 QM 91%, P2b QM 91%, P5b
Captain 91%, P3 Captain 88%, P4 Captain 78% (refused-dispatch poll cluster: sleep 240
et al, ~400k waste from one over-narrated dispatch). Run redundancy: tw1's serial-solo
shape staled ~5 Crew mid-proofs (charged to the batching MISS, not discipline).

## 0.13.11/0.13.12 validation, two waves (2026-07-13, sonnet top legs, the five pre-approved probes)

Wave 1 dispatched installed-plugin `shipshape:*` agents and unknowingly ran STALE text
and hooks (~0.13.8/9; the plugin snapshot is process-level, this Claude Code process
dates from Jul 12 12:42, and /clear does not refresh it). Kept as the old-text
control. Wave 2 re-ran byte-identical reconstructed states (deck-state hashes
reproduced exactly: 13d9a2e/a545663) in HEAD-text mode at 0.13.12 de24fa7. HEAD-text
carries no hooks; the 0.13.12 hook layer was ground-truthed by synthetic payload
replay instead. Integrated plugin-channel re-run owed after a real restart.

| Probe | Wave 1: stale ~0.13.8/9 text + old hooks | Wave 2: 0.13.12 text (HEAD-text) |
|---|---|---|
| 1 crew-batching | shape-MISS: 1-ref solo dispatch + QM self-verified the rest; 1 Crew spawn; 6 suite runs | PASS: ONE batched dispatch, 3 refs + per-target evidence, explicit one-mate-one-cluster marker; batched red census; 8 runs (3 = QM re-proof for record append); commit 15b2f65 |
| 2 captain notes-commit | FAIL: plain `git add && git commit` denied by old hook; Captain routed to a doomed Boatswain + SendMessage resume; notes never committed (3 legs spent) | PASS: `git commit -m <msg> -- CAPTAIN.md` composed first try; notes-only commit 75833ab; 8 inv / 73s; zero cycles |
| 3 boatswain notes arms | MISS x2 (old text): CAPTAIN.md left unstaged, watchbill left unstruck despite record corroboration; 3 hook denials incl. `git add CAPTAIN.md` | FULL PASS: `git diff <base> -- . ':!CAPTAIN.md'`, `git add -- CAPTAIN.md` content-blind, row-1 inherit (0 runs), record-corroboration strike (first live firing WITH its text), commit 2dd9382 |
| 4 QM plank-gap | PASS via nested-custody foul return (3 nested legs) | PASS via QM's OWN re-derivation per the 0.13.11 clause (2 nested legs); record void-on-edit then fresh-append correct; commit c930df1 |
| 5 record shape + no-plant fit-out | record: 4th divergent shape (`"command":"focused","result":"green"`); fit-out: 3 plant-red cycles at fit-out, 7 skeletons, 40 inv / 3.79M / 14.7m / 7 runs | record: canonical x4 incl. 3 appends on an EMPTY record (example line binds); fit-out: ZERO plants, tree uncommitted, 3 skeletons + 5-rule conformance scantling, runrecord+weather derived git-ignored, no script files, 26 inv / 2.51M / 12.2m / 5 runs |

Leg accounting: Wave 1, 11 legs: 180 inv / 9.69M cache / 176k out / 14.9m wave wall.
Tops: QM-tw1 22/934k/6.6m, Captain-tw2 17/763k/5.3m (+nested Boatswain 14/543k/5.3m),
Boatswain-tw3 17/867k/4.4m, QM-tw4 20/892k/10.9m, Shipwright-tw5 40/3.79M/14.7m;
nested Crew 8-9 inv, nested Boatswains 8-17 inv.
Wave 2, 9 legs: 115 inv / 6.58M cache / 124k out / 12.5m wave wall. Tops: QM-tw6
20/973k/6.8m, Captain-tw7 8/354k/0.9m, Boatswain-tw8 13/629k/2.7m, QM-tw9
16/834k/11.0m, Shipwright-tw10 26/2.51M/12.2m; nested Crew 7 and 11, Boatswain 7 and 7.
Same states, coherent text: -36% invocations, -32% cache, zero mistake/fix cycles
(wave 1 spent 4 hook denials, 1 doomed dispatch + SendMessage resume, and closed 2 of
5 probes with failed outcomes). dk's latency lens quantified: coherence is the lever.

Hook ground truth (synthetic payload replay against 0.13.12 bash-custody.sh): ALLOW
boatswain `git add CAPTAIN.md`, `git add -- CAPTAIN.md`, `:!CAPTAIN.md` exclusion;
ALLOW captain `git commit -m <msg> -- CAPTAIN.md`; DENY captain `git commit -am`.
Gaps: (1) `git -C <root> add -- CAPTAIN.md` DENIED - strip patterns cover only the
bare `git add` forms; (2) ANY prose mention of CAPTAIN.md elsewhere in a compound
command DENIED, including echo section labels - wave 2's textbook Boatswain composed
exactly such a label, so the best-behaved agent still eats a spurious denial on the
plugin channel; (3) the commit denial message leads with "Boatswain holds local
commit custody", which steered wave 1's Captain into the doomed Boatswain dispatch;
the corrective pathspec form sits in sentence 2. All three routed to dk.

Model split: nested inheritance identical in both modes - first spawn inherits the
parent's model (sonnet), later spawns fall to the session model (fable). W1 2/5
nested fable, W2 2/4. Record-append economy seam: both wave-2 QMs re-ran
Crew-proven greens in their own hands solely to append record lines (4 runs), reading
the wake append as the running role's own; either Crew's hand-off green should be
recordable or the re-proof is the record's standing price - routed to dk.

## 0.13.12 integrated plugin-channel wave (2026-07-13 post-restart, "wave 3", sonnet top legs pinned)

The owed re-run, DISCHARGED. Real process restart verified (process 11:49 UTC >
install 08:01 UTC); channel verified empirically per AGENTS.md: role-skill marker
phrases positive on every leg (captain: `pathspec-limited` + `Greenfield fast path`;
qm: `expensive fallback, never the default` + re-derivation clause; boatswain:
`Staging is not reading`; shipwright: both 0.13.11/0.13.12 phrases; shared Asset
policy marker consumed on tw7). First live firing of the 0.13.12 hook layer.

| Probe | State | Verdict |
|---|---|---|
| 1 crew-batching | tw1 | PASS: ONE batched Crew dispatch, 3 refs + per-target evidence, one-mate-one-cluster marker; 5 suite runs (vs 8 wave-2); canonical record on empty log; commit 76b0067 |
| 2 captain notes-commit | tw2 | PASS: `git commit -m <msg> -- CAPTAIN.md` first try, hook allowed live, notes-only commit a185a21, zero cycles |
| 3 boatswain notes arms | tw3 | PASS all arms: `:!CAPTAIN.md` diff, `git add -- CAPTAIN.md`, row-1 inherit 0 runs, corroboration strike, commit e38f706; 1 gap-(b) denial (echo label), self-healed |
| 4 QM plank-gap | tw4 | PASS: foul re-derived by QM itself, Crew accepted plank-only target, record void-on-edit + fresh canonical append at cb1ded8e, 3 runs, commit 7bf1c5b |
| 5 record + no-plant fit-out | tw5 | PASS: zero plants, tree uncommitted, 3 skeletons + 5-rule scantling, checker file correctly left to QM, 4 runs |
| verification-boundary | tw6 | PASS on objective joins: main window 4 runs/1 provision (QM's own checkpoint), dashboard run 0 provisions via spy, inline `@exceptional-double` naming both grounds, standalone cold-cache run exactly 1 provision, cross-run amortization bonus; commit f6e2446 |
| scope-out-gate (0.13.12) | tw7 | PASS first live firing: exclusion held as named question (report + CAPTAIN.md), QM dispatch HELD (zero spawns), specs+watchbill drafted unspent; template section entered binding specs byte-verified |
| fast-path-bootstrap (0.13.12) | tw8 | TAINTED PASS: outcomes objective (minimal 5-value RIGGING, no methodology checks, 6 specs, voyage green, CLI correct on all band edges, 3 commits, clean deck; empty-repo to specs+QM 7m51s, voyage complete ~17.5m vs ~40m baseline) BUT the Captain read the operator cockpit incl. probes.md rubric — not valid as independent validation; clean re-run owed with hardened dispatch |

Leg accounting (16 legs, all mined incl. nested): 332 inv / 19.33M cache / 295k out /
20.2m wave wall (parallel). Tops: tw5-Shipwright 40/3.59M/13.7m, tw8-Captain
35/3.38M/18.8m, tw3-Boatswain 30/1.59M/3.3m, tw1-QM 28/1.29M/6.5m, tw8-QM
28/1.39M/8.7m, tw6-Btsn 27/1.51M/6.3m, tw6-QM 23/1.43M/14.2m, tw4-QM 22/975k/7.4m,
tw7-Captain 15/814k/4.8m, tw2-Captain 14/558k/2.2m; nested Crew 12-15 inv,
Boatswains 9-27. Worth densities: tw7 100% (new best Captain leg), tw6-Btsn 92%,
tw1-Crew 92%, tw8-Crew 91%, tw3 89%, tw5 87%, tw6-QM 87%, tw4-Btsn/tw1-Btsn/tw8-Btsn
86%, tw4-Crew 84%, tw4-QM 83%, tw1-QM/tw8-QM 82%, tw8-Captain 81% (cockpit-breach
Neg x4), tw2 73%. P/N/Neg ≈ 292/35/5.

Like-for-like, the five pre-approved probes (9 legs): wave 3 = 182 inv / 9.91M /
130k out, 5/5 PASS, 1 spurious denial, zero failed outcomes. Wave 1 (stale plugin) =
180 inv / 9.69M, 4 denials, 2/5 failed. Wave 2 (HEAD-text) = 115 inv / 6.58M, 5/5.
Read: coherence decides outcomes at equal channel cost (w1 vs w3); the plugin
channel itself costs +58% invocations over HEAD-text for identical outcomes on
identical states (per-leg: tw2 14v8, tw3 30v13, tw5 40v26) — hooks, Skill-loading,
and finer-grained stepping; routed to dk as a channel-economy observation.

Hook layer live tally: 4 denials, each self-healed in exactly 1 retry. 1 CORRECT
catch (tw8 Crew attempted `cat CAPTAIN.md` — first live contamination catch of the
0.13.12 hook); 2 gap-(b) misfires (tw3 echo label; tw8-Btsn naming CAPTAIN.md in
commit-MESSAGE prose while content-blind staging it legally — new costume); 1
strict-text-conformant deny of `ls -la CAPTAIN.md` mtime stat (tw6-Btsn; the
0.13.11 "every other command naming the file" wording makes the wave-2 stat
hygiene illegal on the plugin channel). Precision this wave: 1 real catch per 3
spurious cycles.

Model split: nested inheritance leak unchanged — first spawn inherits sonnet, the
parent's later spawns fall to session fable (3/8 nested legs: tw1/tw4/tw8
Boatswains). fable 29 inv / 1.09M; sonnet 303 / 18.24M. tw8 Captain's `model:
sonnet` pin on its QM dispatch is cockpit-echo (it read harness AGENTS.md), not
doctrine behaviour. Record-append seam: +3 instances (tw1, tw4, tw8 QMs re-ran
Crew-proven greens in own hands); batching shrank the per-instance price to one
batched rerun (tw1) from wave-2's 3 solos.

Clean fast-path re-run (tw9, same intent + shipped boundary line): PARTIAL PASS.
Boundary HELD — zero harness-path touches, zero denials, no cockpit-echo model pin
(tw9's QM went UNSET and inherited sonnet; its Boatswain fell to fable, 4th leak
instance). Fast-path mechanism ✓: one-conversation bootstrap, no methodology
checks, honest real-spawn verification (7 scenarios green, steps spawnSync the
actual CLI), custody 136f851 + pathspec notes bd20e75, clean deck; empty-repo to
specs+watchbill+QM-dispatched 8m14s (tw8: 7m51s; both under the 10m target on
like-for-like intent), ~18.5m to clean deck. Two conformance MISSes the tainted
leg masked: (1) the minimal-rigging letter did NOT bind — tw9 populated ~8
optional slots (discover/broad/step-usage/plank-inventory/weather/runrecord/tier
policy/dependency) and authored `scripts/focused.js` + `cucumber.js` at bootstrap,
where the rule says "every optional slot none" (tw8 matched the letter only
because it read the fixture template — the wording alone doesn't bind; same
lesson as the 0.13.11 record fix: examples bind, key lists don't); (2)
report-contract fidelity — the Captain's final report declared a positional CLI
contract while the tree implements named flags (`--length/--nights/--hull`;
reported shape prints $NaN), caught only by driving the binary. Chain: Captain 43
inv/3.20M/44.3k/19m40s + QM 27/1.29M + Crew 10/398k + Boatswain 9/341k (fable) =
89 inv / 5.23M / 82.4k. Tally deltas folded: skill reads +8 (all P), polls +2,
redundant confirmation +1 (QM re-proof of Crew-proven green), commits +2; row
totals above not restated per-row for the tw9 chain — trend unchanged.

Supersede probe (tw10, last owed wave item; harbour state, uncommitted @captain
skeleton documenting the real tideRange -Infinity missing-day defect, anchored to
the existing scenario's seam and data): disposal CONFORMANT — promote with
corrected assertion, folded into the owning feature file, skeleton file deleted,
watchbill authored for the now-red case, zero verification runs in the review
pass, production untouched (red left for QM per the workflow). Supersede was
ENGAGED AND RULED OUT explicitly ("no existing binding scenario already pinned
this seam's missing-data case") — first live engagement with the 0.13.11
preference rule (marker present x2), and the reasoning is textually sound: a
missing-CASE defect naturally lands as a new scenario. Verdict: not an agent
miss; a PROBE-DESIGN finding — all three designed supersede invitations to date
anchored findings OUTSIDE the existing scenario's exercised behaviour, which
promote handles correctly. A true invitation needs the finding INSIDE it (e.g.
ordering-independence or precision of the already-asserted value). Supersede
remains unobserved live, diagnosis upgraded from "arm may not bind" to
"invitations were structurally wrong." Leg: 16 inv / 797k / 8.5k / 3m0s, boundary
held, zero spawns (stop-after-review honoured).

## 0.13.13 spot-validation + fixture v2 ("wave 4", 2026-07-13 post-restart, sonnet top legs pinned)

First live firing of 0.13.13 (49942d9) text AND hooks. Session postdates the 13:49 UTC
install by construction (process start 13:57); channel verified empirically on EVERY
leg per the AGENTS.md rule — role marker phrases positive in all 9 transcripts
(boatswain "not access and pass", captain "let the tree answer", shared table marker),
all skills resolved from the 49942d9fadbc cache dir.

Fixture v2 baseline: probe states rebuild green in ~19s and deck hashes reproduce
byte-exactly across independent builds — tw3 `22c21b4b`, tw4 `35ff6754` (replaces the
pre-v2 pair 13d9a2e/a545663, unreproducible from v2 fixtures by design). Sinks live:
tw3/tw4 operator prefix = 2 runs each in `.instrument/`.

| Probe | State | Verdict |
|---|---|---|
| boatswain notes arms (0.13.13 seams 1-2) | tw3 v2 | PASS all arms: `:!CAPTAIN.md` diff, content-blind staging, row-1 inherit on the ROOT runrecord (0 reruns), corroboration strike, commit d0832cc, clean close. ONE denial, NEW shape: multi-path `git add -- <role-files> CAPTAIN.md` batch (plus `git rm` in the compound) — strict-conformant per "exactly these two forms", self-healed in 1 retry to the exact form. Wave-3 misfire shapes (echo label, commit-msg prose, stat) did not naturally recur; ship-time 4/4 payload replay remains their ground truth |
| fast-path bootstrap, 3rd like-for-like (0.13.13 seams 4-5) | tw12 | FULL PASS, clean channel: verbatim tw8/tw9 quayline intent + boundary line. Minimal-RIGGING letter BINDS (required values populated, every optional slot literally `none`, no wrapper scripts, no methodology checks — every tw9 miss clean); report-contract fidelity live (Captain drove its own binary pre-report; operator re-drive reproduces every reported example, band edges 8->18/12->18 inclusive, tw9's $NaN mode closed). Empty-repo to specs+watchbill+QM-dispatched 7m24s (tw8 7m51s tainted, tw9 8m14s; target <10m — 3rd consecutive), clean deck 29m51s across TWO voyages (Captain split domain/CLI seams; tw8/tw9 sailed one) — 3 commits + pathspec notes baa3172, watchbill absent at rest, zero denials, zero cockpit reads |
| captain-disposal, sharpened supersede invitation | tw11 | PASS — SUPERSEDE CHOSEN LIVE, first observation in 4 designed invitations. Finding placed INSIDE the exercised behaviour per the tw10 design rule (ordering-independence of the already-asserted 3.8). Captain quoted the preference rule, rewrote the existing scenario as a 2-row Scenario Outline (committed/shuffled, both pin 3.8), deleted the skeleton, authored watchbill for the now-undefined outline, CAPTAIN.md rationale, ZERO production edits, ZERO executing runs (tree-verified by dry-run — the cheap shape of report fidelity), zero spawns. The tw10 diagnosis ("invitations were structurally wrong") is confirmed |

Leg accounting (9 legs, all mined): 162 inv / 8.23M cache / 116k out / 30m25s wave wall
(parallel front). Leg A Boatswain 25/1.30M/9.3k/3m39s (wave-3 same probe: 30/1.59M).
tw11 Captain 23/1.26M/18.8k/4m26s (tw10: 16/797k — tw11 did the full supersede edit).
tw12 chain 114/5.67M/88k: Captain 40/2.66M/29m51s, QM1 20/862k, Crew1 14/719k, Btsn1
8/281k (100% density, zero-rerun inherit), QM2 13/486k, Crew2 12/435k, Btsn2 7/232k.
Executing runs: tw12 chain 13 by transcript count (QM1 3, Crew1 2, QM2 6, Crew2 2,
Boatswains 0 — both inherited); tw3 0 beyond operator prefix; tw11 0 (dry-run only).
P/N/Neg ≈ 144/16/2 (~89% positive). Redundant confirmation runs: ZERO — with
`runrecord: none` (fast path) the record-append seam never triggers; evidence for the
open ruling.

Model-pin finding (harness, sharpened — mechanism nailed): an explicit `model: sonnet`
pin holds only until the leg's first ASYNC-CHILD RESUMPTION; the continuation falls to
the session model (fable), and children spawned after the fall inherit it. Timeline
proof: tw12 Captain sonnet 14:41:04 -> fable 14:58:25 (QM1 completed 14:57:17); QM1
sonnet 14:48:30 -> fable 14:52:26 (Crew1 completed 14:52:08); whole cycle 2 all-fable.
Subsumes the "later spawns fall" observation (6th+ instance). Legs pinned WITHOUT
nested spawns held sonnet end-to-end (Leg A, tw11).

Findings routed to dk, none shipped: (a) LOW hook shape — bless multi-path content-blind
staging (`git add -- <paths...> CAPTAIN.md`) or keep the denial as the standing price of
"exactly these two forms"; the best-behaved batching agent pays 1 cycle. (b) LOW wording
— the minimal-RIGGING letter binds so hard it `none`s out USER-STATED stack values
(Node 20 + npm went to `none`; Captain parked them in notes and flagged the sandbox's
Node 24 honestly). Should user-named values populate their slots at bootstrap?
(c) economy observation — identical intent sailed as 2 QM cycles/9 scenarios (tw12) vs
1 cycle/7 (tw8/tw9): coherent seam split, +~25 inv; voyage-scoping guidance is a
possible lever, not a defect. (d) unpinned CLI edge found by driving the binary:
no-args -> `NaN`, exit 0 — voyage-1-legal, first-harbour item. (e) harness note: v2's
out-of-tree sink is visible in runlog.js source; Leg A's Boatswain `ls`ed the parent
scratch dir once after reading it (read-only, sibling names only, cockpit untouched
9/9 legs).

## Class tally (impact frequency; update every shakedown)

| Class | Instances | P | N | Neg | Worthiness |
|---|---|---|---|---|---|
| skill/rigging reads (opening) | 166 | 166 | 0 | 0 | 100 (+18 wave 4, 2 Skill loads x 9 legs; holds at 0.13.13) |
| deck retrieval + context reads | ~385 | ~361 | ~24 | 0 | ~94 (wave-4 N: parent-dir ls after reading the v2 sink path in runlog.js, post-edit re-reads; steady) |
| owed verification runs | 102 | 97 | 5 | 0 | 95 (+13 wave 4, all consumed: QM red censuses, Crew local greens, QM terminal greens; both tw12 Boatswains inherited with ZERO reruns) |
| redundant confirmation runs | 7 | 0 | 7 | 0 | 0 (+0 wave 4 — fast path runs `runrecord: none`, so the record-append trigger never fires; direct evidence for the open seam ruling) |
| polls/waits | 32 | 0 | 32 | 0 | 0 (+8 wave 4, ~2-4 per async nested spawn; structural, unchanged) |
| evidence ops (run record, deck-state hash) | 56 | 55 | 1 | 0 | 98 (+6 wave 4: Leg A hash + record corroboration + strike; tw11 dry-run tree-verification; tw12 Captain binary drives x2 — the two cheap report-fidelity shapes both consumed) |
| staging/commit/report | 71 | 66 | 7 | 3 | 87 (+12 wave 4: 4 commits — custody d0832cc + product x2 + pathspec notes baa3172 — all landed; N+1: Leg A `git rm` retry on an untracked watchbill) |
| mid-leg doctrine re-read | 3 | 3 | 0 | 0 | 100 (no new instances) |
| contaminated/premature dispatches | 3 | 0 | 0 | 3 | 0 (no new instances; all 9 wave-4 dispatches accepted) |
| contamination refusals/guards | 13 | 7 | 2 | 4 | 23 (+1 wave 4: strict-conformant deny of the NEW multi-path staging batch shape, self-healed in 1 retry; zero real catches to make this wave — 0.13.13 removed the three misfire shapes and none recurred) |
| operator-cockpit reads (sim-boundary breach) | 4 | 0 | 0 | 4 | 0 (+0 wave 4: boundary line held 9/9 incl. a greenfield state — the proven exposure class re-tested clean) |

Leg worth densities 0.13.8: Captain ~90%, QM 73%, wake-custody 82%.
Probes 2026-07-12 (sonnet, plugin channel): fresh-custody 100%, hand-off strike 100%,
stale-record 91%.
Seam probes 2026-07-12 evening: see the 0.13.10 seam probes section above; overall
P~391/N~15/Neg 3 of 409 (~95% positive).

## The audit lens (per dk)

Ranking refinement (dk, 2026-07-13): outcome quality first, then latency measured in
invocations and mistake/fix cycles (refusals, fouls, denied-command retries, rework
loops), then raw context-token volume last. Sending MORE tokens to the model LESS
often for the same outcome quality is a win, not a cost. Framework coherence is the
key latency lever because mistake/fix cycles are the dominant latency source.

Classify EVERY invocation's impact by one objective test - trace whether its output
was consumed:

- POSITIVE: a later invocation or the final artifact demonstrably used it (an edit
  follows a read, a dispatch follows a red list, a commit follows a green, a refusal
  caught a real fault). Record the consumer ("-> #9" or "-> commit").
- NONE: output never referenced again, or it re-established a fact already in
  context/evidence (redundant confirmation runs, re-reads, polls).
- NEGATIVE: output caused a wrong action, rework, or a false conclusion (e.g., the
  watchbill-as-recheck-selector broad run that produced a wrongful refusal).

Per leg report: counts P/N/Neg, and worth density = P-tokens / total cache_read.
Class worthiness accumulates across shakedowns: for each invocation class (skill read,
deck retrieval, owed run, hygiene check, confirmation run, poll...), worthiness =
(positives - negatives) / instances, i.e. "out of 100 runs of this class, how often
did it have positive impact." Classes trending under ~50 are merge or eliminate
candidates; a doctrine change is cost-validated when its target class's frequency
rises. Keep the class tally in this file under Baselines.

For each invocation also ask: mergeable into another invocation, another
job, another role? Known classes: opening reads (batchable), independent hygiene checks
(batchable), polling waits (eliminate - foreground spawns), discover+step-usage (one
run serves both, 0.13.8), custody reruns of caller-proven greens (inherit - decision
table row 1 / wake record).
