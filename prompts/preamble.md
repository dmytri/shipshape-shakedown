# Role-agent preamble (HEAD-text mode)

Prepend to every leg prompt, substituting {ROLE} and its skill path. Use HEAD-text mode
whenever the doctrine under test is newer than the session's installed-plugin snapshot
(plugin resolution is pinned at session start; a mid-session reinstall does NOT reach
subagents). Use installed-plugin mode (subagent_type: shipshape:{role}, minimal dispatch
prompt) only after a session restart, to validate the plugin channel itself.

```text
You are the Shipshape {ROLE} role agent. Your authoritative instructions are these
files - read ALL fully before doing anything and follow them exactly; they override
anything you think you know about Shipshape:

1. /home/exedev/shipshape/skills/shipshape/SKILL.md (shared Articles of Agreement)
2. /home/exedev/shipshape/skills/{role}/SKILL.md (your role skill)

Project root: {PROJECT} - work only inside it; never modify anything under
/home/exedev/shipshape. Use git author "Sim Operator <sim@example.test>" for any commit.

When you dispatch or load another Shipshape role, spawn a general-purpose subagent
(never a shipshape:* agent type; those are stale in this runtime) and start its
prompt with this same preamble form, substituting that role and its skill path,
followed by your dispatch per the Dispatch contract.
```

(The nested-spawn paragraph is mandatory in a stale-snapshot session and validated
2026-07-13: both wave-2 QMs composed correct preamble'd general-purpose dispatches.
Drop the git-author sentence per the rule below; scaffold.sh sets the repo-local
author.)

Rules learned live:

- Dispatch THIN. Role, base commit, job (Boatswain), scope (Shipwright), project root.
  Any narrative about tree contents, expected failures, or "red by design" gets refused
  as contamination - correctly.
- A caller hand-off (QM report to Boatswain) is a legal vector: paste the caller's
  smart-but-silent report verbatim, nothing more.
- Crew spawned by QM must run FOREGROUND; background spawns cost 3-5 polling
  invocations (~55k prefill each) of pure waste.
- To stop a role before it loads the next role, say so explicitly and ask for the
  final report in the skill's Final report form; ask "for each staged hunk, which
  recheck-selection row applied" to audit custody decisions.
- Shipwright fitting-out legs get templates.md as a third authoritative file.
- No git-author line in dispatches: scaffold.sh sets the repo-local Sim Operator
  author; an author instruction in a QM dispatch was refused as contamination
  (2026-07-12, plugin channel).
- Plugin-channel dispatches MUST carry "Work only inside the project root." (the
  HEAD-text preamble already has it; the thin plugin dispatch dropped it, and a
  greenfield-state Captain leg walked out of its empty repo into the harness repo
  and read the probe rubric - 2026-07-13 wave 3, sole leak in 16 legs).
- Plugin channel: nested spawns inherit the parent's model only for the parent's FIRST
  spawn; later spawns silently fall to the session model unless the parent pins
  `model`. Mine every leg's model and report the split.
- Plugin dispatch guard caps captain-seat dispatches to any shipshape role at 2500
  prompt chars; trim hand-offs to fit, and know a verbatim role report cannot be
  pasted into a fresh QM at all (finding routed 2026-07-12).
