# Rigging
## Stack
- language: JavaScript
- runtime: none
- packageManager: npm
## Directories
- implementation: src
- specs: features
- verification: features/support
- assets: assets
- scantlings: none
## Methods
- discover: `npx cucumber-js --dry-run --tags "not @captain and not @shipwright"`
- prove: `ref="{scenario}"; npx cucumber-js "${ref%%:*}" --name "^${ref#*:}$" --tags "not @captain and not @shipwright"`
- sweep: none
- coverage: none
- plank-join: none
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