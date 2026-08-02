# Rigging

## Stack
- language: JavaScript
- runtime: node 24
- packageManager: npm

## Directories
- implementation: js
- specs: features
- verification: features/support
- assets: assets
- scantlings: scantlings

## Methods
- discover: `npx cucumber-js --dry-run --tags "not @captain and not @shipwright"`
- prove: `ref="${SS_SCENARIO}"; npx cucumber-js "${ref%%:*}" --name "^${ref#*:}$" --tags "not @captain and not @shipwright"`
- verify: `ref="${SS_SCENARIO}"; npx cucumber-js "${ref%%:*}" --name "^${ref#*:}$" --tags "not @captain and not @shipwright"`
- sweep: `npx cucumber-js --tags "not @captain and not @shipwright"`
- coverage: none
- plank-join: `npx cucumber-js --dry-run --format usage-json --tags "not @captain and not @shipwright" && npx jsdoc -X -r js`
- hygiene: none
- static: none
- discovery: `npx cucumber-js --dry-run --tags "not @captain and not @shipwright"`
- regression: `npx cucumber-js --tags "not @captain and not @shipwright"`
- condemnation: none
- dead-code: none
- spec-lint: `npx gplint "features/**/*.feature"`
- install: `npm install --save-dev "${SS_DEPENDENCY}"`
- typecheck: none
- lint: `npx gplint "features/**/*.feature" && npx biome check .`
- conformance: none

## Perturbation
- message: `PERTURBATION: consider current durable context; remove when fixed`
- perturb: `throw new Error("PERTURBATION: consider current durable context; remove when fixed");`

## Tiers
- default: @logic
- sandbox: none
- policy: none
- weather: none
- runrecord: none

## Dependencies
- policy: locked
- dependency: @cucumber/cucumber
- dependency: happy-dom
- dependency: gplint
- dependency: @biomejs/biome
- dependency: jsdoc
- dependency: ajv
- dependency: todomvc-app-css
- dependency: todomvc-common

## Outbound
- outbound: none
- ship: none
- ship-verify: none
