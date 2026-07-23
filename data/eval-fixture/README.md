# eval-map.py schema-lock fixture

`smoke-qwen3.6-27b.session.jsonl` — a real pi 0.81 session JSONL captured
2026-07-23 from `pi -p "..." --provider openrouter --model qwen/qwen3.6-27b
--session-dir ... --mode json`, WITHOUT `--approve`. It is the committed
regression fixture for `bin/eval-map.py`: the fold is pure over this file and
never spends a model call to test.

Notable: this capture shows the `confirm`-tool loop (turns 1-2) that non-
interactive `-p` mode induces via the @rwese/pi-question package when `--approve`
is absent — the exact flake `bin/eval-leg.sh` neutralises. eval-map.py must
flag those turns as harness noise, not doctrine flailing.
