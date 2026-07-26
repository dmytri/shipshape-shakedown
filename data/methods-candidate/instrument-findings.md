# Instrument findings, methods-candidate session (2026-07-26)

1. **Toolkit yoink was 0.1.17 and has no `--run` flag form.** Composite rigging methods are
   written in the flag form; a stale toolkit fails PER COMMAND inside a leg ("unknown option:
   --run"), invisible in the driver log. Presence checks cannot see it. FIXED: toolkit upgraded to
   0.2.0 and `eval-drive-todomvc.sh` now RUNS the flag form as its guard, upgrading if it fails.

2. **`--oracle-correct` hands Captain an EMPTY failure block when the page never serves.** A build
   with no `index.html` makes the oracle time out on wait-on, so the grade is `UNPARSEABLE` with
   zero failing titles: `correction_intent` pastes nothing between its rulers and the voyage is a
   guaranteed no-op. Caught IN FLIGHT on methflash-c1 v2 (the leg was killed, the arm resumed from
   voyage 2). FIX: route to the existing `page` intent when the prior grade is UNPARSEABLE or the
   sim has no `index.html`. Applied to `bin/.drive-patched.sh` for the live resume; to be landed in
   the canonical driver once the parallel arm finishes (editing a running bash script is unsafe —
   bash reads scripts incrementally).

3. **`run_shipwright` has no infra-retry, unlike `run_voyage`.** methflash-c1's first Shipwright
   pass went void on a transient `bwrap: Can't make overlay mount` (6 attempts) and the planking
   measurement was simply lost — the driver logged `planks=18 on-seam=0 hoisted=18` from the
   PRE-EXISTING tree, which reads as a Shipwright result and is not one. Two fixes owed: a bounded
   infra-retry around the Shipwright leg, and a distinct `VOID` marker in that log line so a void
   pass can never be read as a planking verdict.

4. **Transient overlay-mount failure still occurs with per-wave dedicated toolkits.** Both arms hit
   it once (c1 sw-prebuild void, b1 V3 retried and recovered) on separate `--overlay-src`
   lowerdirs, with 73G free — so the documented "use dedicated node_modules copies" mitigation
   reduces but does not eliminate it. The voyage-level retry is what makes it survivable.

5. **OPERATOR ERROR, kept visible: `pkill -f methflash-c1` killed my own watchers.** Every watcher
   and the Monitor carried the wave name in its command line, so the pattern matched them too
   (exit 144 = SIGTERM). Same class as the corpus's `pgrep`-matched-a-sibling hazard, this time
   self-inflicted from the operator side. Kill by PID or process group, never by a `-f` pattern
   that the watching machinery itself contains.
