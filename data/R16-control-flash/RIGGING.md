# Rigging

## Stack
- language: JavaScript
- runtime: node
- packageManager: npm

## Directories
- implementation: src
- specs: features
- verification: features/support
- verification: features/steps
- assets: assets
- scantlings: assets/schemas

## Commands
- discover: `npx cucumber-js --dry-run --format summary --tags "not @captain and not @shipwright"`
- focused: `ref="{scenario}"; npx cucumber-js "${ref%%:*}" --name "^${ref#*:}$" --tags "not @captain and not @shipwright"`
- broad: `npx cucumber-js --tags "not @captain and not @shipwright"`
- coverage: `npx c8 cucumber-js --tags "not @captain and not @shipwright"`
- step-usage: `npx cucumber-js --tags "not @captain and not @shipwright" --format usage-json`
- plank-inventory: `npx jsdoc -X -recurse src/`
- typecheck: none
- lint: `npx gplint features/ && npx biome check src/`
- conformance: none

## Perturbation
- message: `PERTURBATION: consider current durable context; remove when fixed`
- perturb: `throw new Error("PERTURBATION: consider current durable context; remove when fixed");`

## Tiers
- default: not @captain and not @shipwright
- budget: none
- weather: .wake/weather.json
- runrecord: .wake/runrecord.ndjson

## Dependencies
- policy: locked
- dependency: @cucumber/cucumber
- dependency: happy-dom
- dependency: todomvc-common
- dependency: todomvc-app-css
- dependency: ajv
- dependency: chai

## Outbound
- outbound: none