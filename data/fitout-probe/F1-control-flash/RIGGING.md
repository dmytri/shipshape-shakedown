# Rigging

## Stack
- language: JavaScript
- runtime: none
- packageManager: npm

## Directories
- implementation: js
- specs: features
- verification: features/support
- assets: assets
- scantlings: none

## Commands
- discover: `npx cucumber-js --dry-run --format json --tags "not @captain and not @shipwright"`
- focused: `ref="{scenario}"; npx cucumber-js "${ref%%:*}" --name "^${ref#*:}$" --tags "not @captain and not @shipwright"`
- broad: `npx cucumber-js --tags "not @captain and not @shipwright"`
- coverage: `npx c8 cucumber-js --tags "not @captain and not @shipwright"`
- step-usage: `npx cucumber-js --tags "not @captain and not @shipwright" --format usage-json`
- plank-inventory: `npx jsdoc -X -d /dev/null js/ 2>/dev/null`
- typecheck: none
- lint: `npx gplint features/ && npx biome check js/`
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
- dependency: todomvc-app-css
- dependency: todomvc-common
- dependency: c8
- dependency: gplint
- dependency: biome
- dependency: jsdoc

## Outbound
- outbound: none