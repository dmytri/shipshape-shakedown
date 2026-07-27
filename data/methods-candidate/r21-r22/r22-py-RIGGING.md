# Rigging

Project tooling values for Shipshape roles. Values only, not procedure.
Procedure lives in the skills. Every role reads this on open.

## Stack

- language: python
- runtime: python3
- packageManager: uv

## Directories

- implementation: src
- specs: features
- verification: tests
- assets: data
- scantlings: none

## Methods

- prove: `SS_SCENARIO="{scenario}" npx @dk/yoink --max-bytes 200000 --run 'uv run pytest -q -m "not captain and not shipwright" -k "$(printf %s "${SS_SCENARIO#*:}" | tr "[:upper:] " "[:lower:]_")"' --label prove --timeout 600`
- verify: `SS_SCENARIO="{scenario}" npx @dk/yoink --max-bytes 200000 --run 'uv run pytest -q -m "not captain and not shipwright" -k "$(printf %s "${SS_SCENARIO#*:}" | tr "[:upper:] " "[:lower:]_")"' --label prove --timeout 600 --run 'uv run python .shipshape/plank_join.py' --label plank-join --timeout 120`
- sweep: `npx @dk/yoink --max-bytes 200000 --run 'uv run pytest -q -m "not captain and not shipwright"' --label sweep --timeout 900`
- plank-join: `npx @dk/yoink --max-bytes 200000 --run 'uv run python .shipshape/plank_join.py' --label plank-join --timeout 120`
- hygiene: `npx @dk/yoink --max-bytes 200000 --run 'uv run python .shipshape/plank_join.py' --label plank-join --timeout 120 --run 'uv run mypy src' --label typecheck --timeout 300 --run 'uv run ruff check src tests' --label lint --timeout 300`
- static: `npx @dk/yoink --max-bytes 200000 --run 'uv run pytest --collect-only -q -m "not captain and not shipwright"' --label discovery --timeout 300 --run 'uv run mypy src' --label typecheck --timeout 300 --run 'uv run ruff check src tests' --label lint --timeout 300`
- discovery: `npx @dk/yoink --max-bytes 200000 --run 'uv run pytest --collect-only -q -m "not captain and not shipwright"' --label discovery --timeout 300`
- regression: `npx @dk/yoink --max-bytes 200000 --run 'uv run pytest -q --cov=src --cov-report=term -m "not captain and not shipwright"' --label coverage --timeout 900`
- condemnation: `SS_SCENARIO="{scenario}" npx @dk/yoink --max-bytes 200000 --run 'uv run mypy src' --label typecheck --timeout 300 --run 'uv run ruff check src tests' --label lint --timeout 300 --run 'uv run pytest -q -m "not captain and not shipwright" -k "$(printf %s "${SS_SCENARIO#*:}" | tr "[:upper:] " "[:lower:]_")"' --label prove --timeout 600`
- dead-code: `npx @dk/yoink --max-bytes 200000 --run 'uv run vulture src tests --min-confidence 80' --label dead-code --timeout 300`
- spec-lint: `npx @dk/yoink --max-bytes 200000 --run 'npx gplint -c .gplintrc features/' --label gherkin-lint --timeout 300`
- install: `SS_DEPENDENCY="{dependency}" npx @dk/yoink --max-bytes 200000 --run 'uv add --dev "$SS_DEPENDENCY"' --label install --timeout 600`
- ship: none
- ship-verify: none

## Perturbation

- message: `PERTURBATION: consider current durable context; remove when fixed`
- perturb: `raise RuntimeError("PERTURBATION: consider current durable context; remove when fixed")`

## Tiers

- default: @logic
- sandbox: none
- policy: @logic, no credential needed
- weather: .shipshape/weather.json
- runrecord: .shipshape/runrecord.jsonl

## Dependencies

- policy: latest-stable
- dependency: pytest
- dependency: pytest-bdd
- dependency: pytest-cov
- dependency: mypy
- dependency: ruff
- dependency: vulture
- dependency: poethepoet

## Outbound

- outbound: none
- ship: none
- verify: none