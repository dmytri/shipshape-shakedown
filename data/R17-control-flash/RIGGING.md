# Rigging

## Stack
- language: JavaScript
- runtime: node
- packageManager: npm

## Directories
- implementation: js
- implementation: css
- specs: features
- verification: features/support
- assets: assets
- scantlings: none

## Commands
- discover: `npx cucumber-js --dry-run --format json --tags "not @captain and not @shipwright" 2>/dev/null`
- focused: `ref="{scenario}"; npx cucumber-js "${ref%%:*}" --name "^${ref#*:}$" --tags "not @captain and not @shipwright"`
- broad: `npx cucumber-js --tags "not @captain and not @shipwright"`
- coverage: `npx c8 npx cucumber-js --tags "not @captain and not @shipwright"`
- step-usage: `npx cucumber-js --tags "not @captain and not @shipwright" --format usage-json 2>/dev/null`
- plank-inventory: `grep -rn '@planks\|@planks-provisional' js css 2>/dev/null || true`
- typecheck: `none`
- lint: `npx gplint features && npx biome check --no-errors-on-unmatched js css`

## Perturbation
- message: `PERTURBATION: consider current durable context; remove when fixed`
- perturb: `throw new Error("PERTURBATION: consider current durable context; remove when fixed");`

## Tiers
- default: @logic
- sandbox: none
- policy: none
- weather: .wake/weather.json
- runrecord: .wake/runrecord

## Dependencies
- policy: locked
- dependency: @cucumber/cucumber
- dependency: happy-dom
- dependency: todomvc-common
- dependency: todomvc-app-css
- dependency: gplint
- dependency: biome
- dependency: c8

## Outbound
- outbound: none