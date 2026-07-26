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

## Commands

- discover: `npx cucumber-js --dry-run`
- focused: `npx cucumber-js {scenario}`
- broad: `npx cucumber-js`
- coverage: `npx c8 npx cucumber-js`
- step-usage: `npx cucumber-js --dry-run --format usage`
- plank-inventory: `grep -rn "@planks" js/`
- typecheck: none
- lint: none
- conformance: none

## Methods

- verify: `echo "== focused"; npx cucumber-js {scenario}; echo "== focused exit=$?"; echo "== plank-inventory"; grep -rn "@planks" js/; echo "== plank-inventory exit=$?"; echo "== step-usage"; npx cucumber-js --dry-run --format usage; echo "== step-usage exit=$?"`
- hygiene: `echo "== plank-inventory"; grep -rn "@planks" js/; echo "== plank-inventory exit=$?"; echo "== step-usage"; npx cucumber-js --dry-run --format usage; echo "== step-usage exit=$?"`
- static: none
- regression: none
- rigging-proof: `echo "== discover"; npx cucumber-js --dry-run; echo "== discover exit=$?"; echo "== focused"; npx cucumber-js features/; echo "== focused exit=$?"; echo "== broad"; npx cucumber-js; echo "== broad exit=$?"; echo "== coverage"; npx c8 npx cucumber-js; echo "== coverage exit=$?"; echo "== step-usage"; npx cucumber-js --dry-run --format usage; echo "== step-usage exit=$?"; echo "== plank-inventory"; grep -rn "@planks" js/; echo "== plank-inventory exit=$?"`

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
- dependency: todomvc-app-css
- dependency: todomvc-common
- dependency: c8

## Outbound

- none
