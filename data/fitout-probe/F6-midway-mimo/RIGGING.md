# Rigging

Project tooling values for Shipshape roles. Values only, not procedure.
Procedure lives in the skills. Every role reads this on open.

## Stack

- language: JavaScript
- runtime: none
- packageManager: none

## Directories

- implementation: js
- specs: features
- verification: features/support
- assets: css
- scantlings: none

## Commands

- discover: `npx cucumber-js --dry-run --tags "not @captain and not @shipwright"`
- prove: `ref="{scenario}"; file="${ref%%:*}"; name="${ref#*:}"; npx cucumber-js "$file" --name "^${name}$" --tags "not @captain and not @shipwright"`
- sweep: `npx cucumber-js --tags "@default and not @captain and not @shipwright"`
- coverage: none
- step-usage: `npx cucumber-js --format usage-json --tags "not @captain and not @shipwright" > /dev/null; cat node_modules/.cucumber.usage.json 2>/dev/null || echo "no usage output"`
- plank-inventory: `npx jsdoc -X js/`
- typecheck: none
- lint: `npx gplint features/`
- conformance: none

## Perturbation

- message: `PERTURBATION: consider current durable context; remove when fixed`
- perturb: `throw new Error("PERTURBATION: consider current durable context; remove when fixed");`

## Tiers

- default: @default
- sandbox: none
- policy: none
- weather: none
- runrecord: none

## Dependencies

- policy: locked
- dependency: @cucumber/cucumber
- dependency: happy-dom
- dependency: gplint

## Outbound

- outbound: none
