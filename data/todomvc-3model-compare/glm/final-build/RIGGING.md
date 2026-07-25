# Rigging

## Stack
- language: JavaScript
- runtime: none
- packageManager: npm

## Directories
- implementation: js
- specs: features
- verification: none
- assets: assets
- scantlings: none

## Commands
- discover: none
- focused: `ref="{scenario}"; npx cucumber-js "${ref%%:*}" --name "^${ref#*:}$" --tags "not @captain and not @shipwright"`
- broad: none
- coverage: none
- step-usage: none
- plank-inventory: none
- typecheck: none
- lint: none
- conformance: none

## Perturbation
- message: `PERTURBATION: consider current durable context; remove when fixed`
- perturb: `throw new Error("PERTURBATION: consider current durable context; remove when fixed");`

## Tiers
- default: none
- sandbox: none
- policy: none
- weather: none
- runrecord: none

## Dependencies
- policy: locked
- dependency: @cucumber/cucumber
- dependency: happy-dom

## Outbound
- outbound: none