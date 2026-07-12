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
```

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
