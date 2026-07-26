# Rigging

Project tooling values for Shipshape roles. Values only, not procedure.
Procedure lives in the skills. Every role reads this on open.

## Stack

- language: javascript
- runtime: node
- packageManager: npm

## Directories

- implementation: js/
- specs: features/
- verification: features/step_definitions
- verification: features/support
- assets: assets/

## Commands

- discover: `npx cucumber-js --import features/ --dry-run --format usage-json`
- focused: `npx cucumber-js --import features/ --name "{scenario}"`
- broad: `npx cucumber-js --import features/ --tags "not @captain and not @shipwright"`
- coverage: `npx c8 npx cucumber-js --import features/ --tags "not @captain and not @shipwright"`
- step-usage: `npx cucumber-js --import features/ --dry-run --format usage-json`
- plank-inventory: `grep -rn '@planks\b\|@planks-provisional' js/`
- typecheck: none
- lint: none
- conformance: none

## Perturbation

- message: `PERTURBATION: consider current durable context; remove when fixed`
- perturb: `throw new Error("PERTURBATION: consider current durable context; remove when fixed");`

## Tiers

- default: @logic
- sandbox: none
- policy: @logic local
- weather: none
- runrecord: coverage/runrecord.jsonl

## Dependencies

- policy: locked
- dependency: node
- dependency: npm
- dependency: @cucumber/cucumber
- dependency: happy-dom
- dependency: c8

## Outbound

- outbound: none