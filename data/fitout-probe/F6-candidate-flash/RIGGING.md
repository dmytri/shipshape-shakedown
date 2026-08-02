# Rigging

Project tooling values for Shipshape roles. Values only, not procedure.
Procedure lives in the skills. Every role reads this on open.

## Stack

- language: javascript
- runtime: node
- packageManager: npm

## Directories

- implementation: js
- specs: features
- verification: features/support
- assets: assets
- scantlings: none

## Methods

- prove: `SS_SCENARIO="{scenario}" npx @dk/yoink --max-bytes 200000 --run 'npx cucumber-js "${SS_SCENARIO%%:*}" --name "^${SS_SCENARIO#*:}$" --tags "not @captain and not @shipwright"' --label prove --timeout 600`
- verify: `SS_SCENARIO="{scenario}" npx @dk/yoink --max-bytes 200000 --run 'npx cucumber-js "${SS_SCENARIO%%:*}" --name "^${SS_SCENARIO#*:}$" --tags "not @captain and not @shipwright"' --label prove --timeout 600 --run 'node .shipshape/plank-join.mjs' --label plank-join --timeout 120`
- sweep: `npx @dk/yoink --max-bytes 200000 --run 'npx cucumber-js --tags "not @captain and not @shipwright"' --label sweep --timeout 900`
- plank-join: `npx @dk/yoink --max-bytes 200000 --run 'node .shipshape/plank-join.mjs' --label plank-join --timeout 120`
- hygiene: `npx @dk/yoink --max-bytes 200000 --run 'node .shipshape/plank-join.mjs' --label plank-join --timeout 120`
- static: `npx @dk/yoink --max-bytes 200000 --run 'npx cucumber-js --dry-run --tags "not @captain and not @shipwright"' --label discovery --timeout 300`
- discovery: `npx @dk/yoink --max-bytes 200000 --run 'npx cucumber-js --dry-run --tags "not @captain and not @shipwright"' --label discovery --timeout 300`
- regression: `npx @dk/yoink --max-bytes 200000 --run 'npx cucumber-js --tags "not @captain and not @shipwright"' --label sweep --timeout 900`
- condemnation: `SS_SCENARIO="{scenario}" npx @dk/yoink --max-bytes 200000 --run 'node .shipshape/plank-join.mjs' --label plank-join --timeout 120 --run 'npx cucumber-js "${SS_SCENARIO%%:*}" --name "^${SS_SCENARIO#*:}$" --tags "not @captain and not @shipwright"' --label prove --timeout 600`
- dead-code: none
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
- policy: @logic: local, no credentials needed
- weather: .shipshape/weather.json
- runrecord: .shipshape/runrecord.json

## Dependencies

- policy: latest-stable
- dependency: @cucumber/cucumber
- dependency: happy-dom
- dependency: @dk/yoink
- dependency: gplint

## Outbound

- outbound: none
- ship: none
- ship-verify: none