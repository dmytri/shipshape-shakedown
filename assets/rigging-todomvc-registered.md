# RIGGING

Project tooling values for Shipshape roles. Values only, not procedure.
Procedure lives in the skills. Every role reads this on open.

## Stack

- language: JavaScript
- runtime: Node.js
- packageManager: npm

## Directories

- implementation: js
- specs: features
- verification: features/step_definitions
- verification: features/support
- assets: assets
- assets: css

## Methods

- prove: `SS_SCENARIO="$SS_SCENARIO" npm run ss:prove --silent`
- verify: `SS_SCENARIO="$SS_SCENARIO" npm run ss:verify --silent`
- sweep: `npm run ss:sweep --silent`
- plank-join: `npm run ss:plank-join --silent`
- hygiene: `npm run ss:hygiene --silent`
- static: `npm run ss:static --silent`
- discovery: `npm run ss:discovery --silent`
- regression: `npm run ss:regression --silent`
- condemnation: `SS_SCENARIO="$SS_SCENARIO" npm run ss:condemnation --silent`
- dead-code: `npm run ss:dead-code --silent`
- spec-lint: `npm run ss:spec-lint --silent`
- install: `SS_DEPENDENCY="$SS_DEPENDENCY" npm run ss:install --silent`
- ship: none
- ship-verify: none

## Perturbation

- message: PERTURBATION: consider current durable context; remove when fixed
- perturb: `throw new Error("PERTURBATION: consider current durable context; remove when fixed");`

## Tiers

- default: @logic
- sandbox: none
- policy: @logic - no external credentials required
- weather: none
- runrecord: none

## Dependencies

- policy: locked
- dependency: @cucumber/cucumber
- dependency: happy-dom
- dependency: c8

## Outbound

- none
