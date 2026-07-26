# RIGGING

Project tooling values for Shipshape roles. Values only, not procedure.
Procedure lives in the skills. Every role reads this on open.

## Stack

- language: JavaScript
- runtime: Node.js
- packageManager: npm

## Directories

- implementation: src
- specs: features
- verification: features/support
- assets: none

## Commands

- discover: `npx cucumber-js --dry-run --tags "not @captain and not @shipwright"`
- focused: `npx cucumber-js {scenario} --tags "not @captain and not @shipwright"`
- broad: `npx cucumber-js --tags "not @captain and not @shipwright"`
- coverage: `npx c8 npx cucumber-js --tags "not @captain and not @shipwright"`
- step-usage: `npx cucumber-js --dry-run --format usage-json --tags "not @captain and not @shipwright"`
- plank-inventory: `grep -rn "@planks" src/`
- typecheck: none
- lint: none
- conformance: none

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
- dependency: c8

## Outbound

- none
