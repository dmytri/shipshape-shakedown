# Rigging

## Stack

- language: JavaScript
- runtime: node 24
- packageManager: npm

## Directories

- implementation: js
- specs: features
- verification: features/steps
- verification: features/support
- assets: assets
- scantlings: scantlings/todo-storage.schema.json

## Methods

- discover: `npx @dk/yoink --run 'npx cucumber-js --dry-run --tags "not @captain and not @shipwright"' --label discover --timeout 120`
- discovery: `npx @dk/yoink --run 'npx cucumber-js --dry-run --tags "not @captain and not @shipwright"' --label discovery --timeout 120`
- prove: `npx @dk/yoink --run 'rc=0; IFS=";"; set -- ${SS_SCENARIO}; unset IFS; for r in "$@"; do npx cucumber-js "${r%%:*}" --name "^${r#*:}$" --tags "not @captain and not @shipwright" || rc=1; done; exit $rc' --label prove --timeout 600`
- verify: `npx @dk/yoink --run 'rc=0; IFS=";"; set -- ${SS_SCENARIO}; unset IFS; for r in "$@"; do npx cucumber-js "${r%%:*}" --name "^${r#*:}$" --tags "not @captain and not @shipwright" || rc=1; done; exit $rc' --label verify --timeout 600 --run 'npx cucumber-js --dry-run --format usage-json --tags "not @captain and not @shipwright"' --label step-patterns --timeout 120 --run 'npx jsdoc -X -r js' --label plank-doclets --timeout 120`
- sweep: `npx @dk/yoink --run 'npx cucumber-js --tags "not @captain and not @shipwright"' --label sweep-logic --timeout 900`
- coverage: `npx @dk/yoink --max-bytes 400000 --run 'npx c8 --reporter=text --reporter=lcov --reports-dir=coverage npx cucumber-js --format summary --format json:.wake/scenarios.json --tags "not @captain and not @shipwright"' --label coverage-logic --timeout 1800`
- plank-join: `npx @dk/yoink --max-bytes 400000 --run 'npx cucumber-js --dry-run --format usage-json --tags "not @captain and not @shipwright"' --label step-patterns --timeout 120 --run 'npx jsdoc -X -r js' --label plank-doclets --timeout 120 --run 'grep -rn "@planks" js || true' --label plank-tokens --timeout 30`
- hygiene: `npx @dk/yoink --run 'npx gplint "features/**/*.feature"' --label feature-lint --timeout 120 --run 'npx biome check .' --label code-check --timeout 120 --run 'npx knip --no-config-hints' --label dead-code --timeout 300`
- static: `npx @dk/yoink --run 'npx cucumber-js --dry-run --tags "not @captain and not @shipwright"' --label discover --timeout 120 --run 'npx gplint "features/**/*.feature"' --label feature-lint --timeout 120 --run 'npx biome lint .' --label code-lint --timeout 120`
- regression: `npx @dk/yoink --max-bytes 400000 --run 'npx c8 --reporter=text --reporter=lcov --reports-dir=coverage npx cucumber-js --format summary --format json:.wake/scenarios.json --tags "not @captain and not @shipwright"' --label regression-logic --timeout 1800`
- condemnation: `npx @dk/yoink --run 'rc=0; IFS=";"; set -- ${SS_SCENARIO}; unset IFS; for r in "$@"; do npx cucumber-js "${r%%:*}" --name "^${r#*:}$" --tags "not @captain and not @shipwright" || rc=1; done; exit $rc' --label condemnation --timeout 600`
- dead-code: `npx @dk/yoink --run 'npx knip --no-config-hints' --label dead-code --timeout 300`
- spec-lint: `npx @dk/yoink --run 'npx gplint "features/**/*.feature"' --label feature-lint --timeout 120`
- typecheck: none
- lint: `npx @dk/yoink --run 'npx gplint "features/**/*.feature"' --label feature-lint --timeout 120 --run 'npx biome lint .' --label code-lint --timeout 120`
- conformance: none
- install: `npx @dk/yoink --run 'npm install --no-audit --no-fund "${SS_DEPENDENCY}"' --label install --timeout 600`
- ship: none
- ship-verify: none

## Perturbation

- message: `PERTURBATION: consider current durable context; remove when fixed`
- perturb: `throw new Error("PERTURBATION: consider current durable context; remove when fixed");`

## Tiers

- default: @logic
- sandbox: none
- policy: @logic runs locally against a happy-dom window built by features/support/world.js; no credentials
- budget: none
- weather: .wake/weather.json
- runrecord: .wake/runrecord.jsonl

## Dependencies

- policy: locked
- dependency: @cucumber/cucumber
- dependency: happy-dom
- dependency: gplint
- dependency: @biomejs/biome
- dependency: c8
- dependency: jsdoc
- dependency: knip
- dependency: ajv
- dependency: @dk/yoink
- dependency: todomvc-common
- dependency: todomvc-app-css

## Outbound

- outbound: none
