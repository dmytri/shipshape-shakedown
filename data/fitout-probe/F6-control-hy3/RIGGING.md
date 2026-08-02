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

## Commands
- discover: `npx cucumber-js --dry-run --tags "not @captain and not @shipwright"`
- focused: `ref="{scenario}"; npx cucumber-js "${ref%%:*}" --name "^${ref#*:}$" --tags "not @captain and not @shipwright"`
- broad: `npx cucumber-js --tags "not @captain and not @shipwright"`
- coverage: `npx c8 --reporter=text npx cucumber-js --tags "not @captain and not @shipwright"`
- step-usage: `npx cucumber-js --dry-run --format usage --tags "not @captain and not @shipwright"`
- plank-inventory: `npx jsdoc -X js`
- typecheck: none
- lint: `npx gplint "features/**/*.feature" && npx biome check --files-ignore-unknown=true .`
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
