# Rigging

Project tooling values for Shipshape roles. Values only, not procedure.
Procedure lives in the skills. Every role reads this on open.

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
- scantlings: scantlings/todo-record.schema.json
- scantlings: scantlings/verification-conformance.json

## Methods

- prove: `SS_SCENARIO="{scenario}" npx @dk/yoink --max-bytes 200000 --run 'npx cucumber-js "${SS_SCENARIO%%:*}" --name "^${SS_SCENARIO#*:}$" --tags "not @captain and not @shipwright"' --label prove --timeout 600`
- verify: `SS_SCENARIO="{scenario}" npx @dk/yoink --max-bytes 200000 --run 'npx cucumber-js "${SS_SCENARIO%%:*}" --name "^${SS_SCENARIO#*:}$" --tags "not @captain and not @shipwright"' --label prove --timeout 600 --run 'node .shipshape/plank-join.mjs' --label plank-join --timeout 120`
- sweep: `npx @dk/yoink --max-bytes 200000 --run 'npx cucumber-js --tags "not @captain and not @shipwright"' --label sweep --timeout 900`
- plank-join: `npx @dk/yoink --max-bytes 200000 --run 'node .shipshape/plank-join.mjs' --label plank-join --timeout 120 --run 'node .shipshape/plank-join.mjs --conformance' --label conformance --timeout 120`
- hygiene: `npx @dk/yoink --max-bytes 200000 --run 'node .shipshape/plank-join.mjs' --label plank-join --timeout 120 --run 'if ls js/*.js >/dev/null 2>&1; then npx tsc -p tsconfig.json; else echo "no implementation files yet"; fi' --label typecheck --timeout 300 --run 'npx biome check' --label lint --timeout 300`
- static: `npx @dk/yoink --max-bytes 200000 --run 'npx cucumber-js --dry-run --tags "not @captain and not @shipwright"' --label discovery --timeout 300 --run 'if ls js/*.js >/dev/null 2>&1; then npx tsc -p tsconfig.json; else echo "no implementation files yet"; fi' --label typecheck --timeout 300 --run 'npx biome check' --label lint --timeout 300`
- discovery: `npx @dk/yoink --max-bytes 200000 --run 'npx cucumber-js --dry-run --tags "not @captain and not @shipwright"' --label discovery --timeout 300`
- regression: `npx @dk/yoink --max-bytes 200000 --run 'npx c8 --reporter=text npx cucumber-js --tags "not @captain and not @shipwright"' --label coverage --timeout 900`
- condemnation: `SS_SCENARIO="{scenario}" npx @dk/yoink --max-bytes 200000 --run 'if ls js/*.js >/dev/null 2>&1; then npx tsc -p tsconfig.json; else echo "no implementation files yet"; fi' --label typecheck --timeout 300 --run 'npx biome check' --label lint --timeout 300 --run 'npx cucumber-js "${SS_SCENARIO%%:*}" --name "^${SS_SCENARIO#*:}$" --tags "not @captain and not @shipwright"' --label prove --timeout 600`
- dead-code: `npx @dk/yoink --max-bytes 200000 --run 'npx knip' --label dead-code --timeout 300`
- spec-lint: `npx @dk/yoink --max-bytes 200000 --run 'npx gplint -c .gplintrc features/' --label gherkin-lint --timeout 300`
- install: `SS_DEPENDENCY="{dependency}" npx @dk/yoink --max-bytes 200000 --run 'npm install --save-dev "$SS_DEPENDENCY"' --label install --timeout 600`
- ship: none
- ship-verify: none

## Perturbation

- message: `PERTURBATION: consider current durable context; remove when fixed`
- perturb: `throw new Error("PERTURBATION: consider current durable context; remove when fixed");`

## Tiers

- default: @logic
- sandbox: none
- policy: @logic runs locally under happy-dom and needs no credentials
- weather: .wake/weather.json
- runrecord: .wake/runrecord.jsonl

## Dependencies

- policy: locked
- dependency: @cucumber/cucumber
- dependency: happy-dom
- dependency: todomvc-app-css
- dependency: todomvc-common
- dependency: @biomejs/biome
- dependency: typescript
- dependency: gplint
- dependency: knip
- dependency: c8
- dependency: acorn
- dependency: ajv
- dependency: @dk/yoink

## Outbound

- outbound: none
- ship: none
- verify: none
