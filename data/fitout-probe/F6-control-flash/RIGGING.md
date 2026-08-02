# Rigging

## Stack
- language: JavaScript
- runtime: node
- packageManager: npm

## Directories
- implementation: js
- specs: features
- verification: features/support
- assets: assets

## Commands
- discover: `FORCE_COLOR=0 npx cucumber-js --dry-run --format json --tags "not @captain and not @shipwright"`
- focused: `ref="{scenario}"; npx cucumber-js "${ref%%:*}" --name "^${ref#*:}$" --tags "not @captain and not @shipwright"`
- broad: `npx cucumber-js --tags "not @captain and not @shipwright"`
- coverage: `npx c8 npx cucumber-js --tags "not @captain and not @shipwright"`
- step-usage: `npx cucumber-js --dry-run --format usage-json --tags "not @captain and not @shipwright"`
- plank-inventory: `npx jsdoc -X -r js 2>/dev/null`
- typecheck: none
- lint: `npx gplint features/ && npx biome check js/ --no-errors-on-unmatched`

## Perturbation
- message: `PERTURBATION: consider current durable context; remove when fixed`
- perturb: `throw new Error("PERTURBATION: consider current durable context; remove when fixed");`

## Tiers
- default: logic
- budget: 30s

## Dependencies
- policy: locked
- dependency: @cucumber/cucumber
- dependency: happy-dom
- dependency: c8
- dependency: gplint
- dependency: @biomejs/biome
- dependency: jsdoc

## Outbound
- outbound: none