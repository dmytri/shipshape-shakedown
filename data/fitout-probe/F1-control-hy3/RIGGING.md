# Rigging

## Stack

- language: JavaScript
- runtime: node
- packageManager: npm

## Directories

- implementation: js
- implementation: css
- implementation: index.html
- specs: features
- verification: features/support
- assets: assets
- scantlings: scantlings

## Commands

- discover: `npx --no-install cucumber-js --dry-run --tags "not @captain and not @shipwright"`
- focused: `ref="{scenario}"; npx --no-install cucumber-js "${ref%%:*}" --name "^${ref#*:}$" --tags "not @captain and not @shipwright"`
- broad: `npx --no-install cucumber-js --tags "not @captain and not @shipwright"`
- coverage: `npx --no-install c8 --reporter=text -- npx cucumber-js --tags "not @captain and not @shipwright"`
- step-usage: `npx --no-install cucumber-js --dry-run --format usage --tags "not @captain and not @shipwright"`
- plank-inventory: `npx --no-install jsdoc -X -r js`
- typecheck: none
- lint: `npx --no-install gplint "features/**/*.feature" && npx --no-install biome check .`
- conformance: none

## Perturbation

- message: `PERTURBATION: consider current durable context; remove when fixed`
- perturb: `throw new Error("PERTURBATION: consider current durable context; remove when fixed");`

## Tiers

- default: `@logic`
- sandbox: none
- policy: none
- weather: none
- runrecord: none

## Dependencies

- policy: locked
- dependency: @cucumber/cucumber
- dependency: happy-dom
- dependency: todomvc-app-css
- dependency: todomvc-common
- dependency: ajv
- dependency: gplint
- dependency: @biomejs/biome
- dependency: c8
- dependency: jsdoc

## Outbound

- outbound: none
