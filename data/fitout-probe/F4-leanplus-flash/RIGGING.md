# Rigging

## Stack

- language: JavaScript
- runtime: node
- packageManager: npm

## Directories

- implementation: js/
- specs: features/
- verification: features/support/
- assets: assets/
- scantlings: none

## Methods

- prove: `SS_SCENARIO="{scenario}" npx @dk/yoink --max-bytes 200000 --run 'npx cucumber-js "${SS_SCENARIO%%:*}" --name "^${SS_SCENARIO#*:}$" --tags "not @captain and not @shipwright"' --label prove --timeout 600`
- verify: `SS_SCENARIO="{scenario}" npx @dk/yoink --max-bytes 200000 --run 'npx cucumber-js "${SS_SCENARIO%%:*}" --name "^${SS_SCENARIO#*:}$" --tags "not @captain and not @shipwright"' --label prove --timeout 600 --run 'node .shipshape/plank-join.mjs' --label plank-join --timeout 120`
- sweep: `npx @dk/yoink --max-bytes 200000 --run 'npx cucumber-js --tags "not @captain and not @shipwright"' --label sweep --timeout 900`
- plank-join: `npx @dk/yoink --max-bytes 200000 --run 'node .shipshape/plank-join.mjs' --label plank-join --timeout 120`
- hygiene: `npx @dk/yoink --max-bytes 200000 --run 'node .shipshape/plank-join.mjs' --label plank-join --timeout 120 --run 'npx @biomejs/biome check js/ features/' --label lint --timeout 300`
- static: `npx @dk/yoink --max-bytes 200000 --run 'npx cucumber-js --dry-run --tags "not @captain and not @shipwright"' --label discovery --timeout 300 --run 'npx @biomejs/biome check js/ features/' --label lint --timeout 300`
- discovery: `npx @dk/yoink --max-bytes 200000 --run 'npx cucumber-js --dry-run --tags "not @captain and not @shipwright"' --label discovery --timeout 300`
- regression: `npx @dk/yoink --max-bytes 200000 --run 'npx c8 --reporter=text npx cucumber-js --tags "not @captain and not @shipwright"' --label coverage --timeout 900`
- condemnation: `SS_SCENARIO="{scenario}" npx @dk/yoink --max-bytes 200000 --run 'npx @biomejs/biome check js/ features/' --label lint --timeout 300 --run 'npx cucumber-js "${SS_SCENARIO%%:*}" --name "^${SS_SCENARIO#*:}$" --tags "not @captain and not @shipwright"' --label prove --timeout 600`
- dead-code: `npx @dk/yoink --max-bytes 200000 --run 'npx knip' --label dead-code --timeout 300`
- spec-lint: `npx @dk/yoink --max-bytes 200000 --run 'npx gplint -c .gplintrc features/' --label gherkin-lint --timeout 300`
- install: `SS_DEPENDENCY="{dependency}" npx @dk/yoink --max-bytes 200000 --run 'npm install --save-dev "$SS_DEPENDENCY"' --label install --timeout 600`
- ship: none
- ship-verify: none

## Perturbation

- message: `PERTURBATION`
- perturb: `/* PERTURBATION <reason> */`

## Tiers

- default: @logic
- policy-logic: local happy-dom DOM environment, no external accounts
- budget: 600

## Dependencies

- policy: locked
- dependency: @cucumber/cucumber
- dependency: happy-dom
- dependency: @biomejs/biome
- dependency: c8
- dependency: knip
- dependency: todomvc-app-css
- dependency: todomvc-common

## Outbound

- outbound: github
- ship: none
- verify: none