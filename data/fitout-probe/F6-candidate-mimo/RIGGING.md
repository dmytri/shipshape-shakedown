# Rigging

## Stack

- language: JavaScript
- runtime: Node
- packageManager: npm

## Directories

- implementation: js/
- specs: features/
- verification: features/support/
- assets: assets/

## Methods

- prove: `SS_SCENARIO="{scenario}" npx @dk/yoink --max-bytes 200000 --run 'npx cucumber-js "${SS_SCENARIO%%:*}" --name "^${SS_SCENARIO#*:}$" --tags "not @captain and not @shipwright"' --label prove --timeout 600`
- verify: `SS_SCENARIO="{scenario}" npx @dk/yoink --max-bytes 200000 --run 'npx cucumber-js "${SS_SCENARIO%%:*}" --name "^${SS_SCENARIO#*:}$" --tags "not @captain and not @shipwright"' --label prove --timeout 600`
- sweep: `npx @dk/yoink --max-bytes 200000 --run 'npx cucumber-js --tags "not @captain and not @shipwright"' --label sweep --timeout 900`
- plank-join: none
- hygiene: `npx @dk/yoink --max-bytes 200000 --run 'npx cucumber-js --dry-run --tags "not @captain and not @shipwright"' --label discovery --timeout 300`
- static: `npx @dk/yoink --max-bytes 200000 --run 'npx cucumber-js --dry-run --tags "not @captain and not @shipwright"' --label discovery --timeout 300`
- discovery: `npx @dk/yoink --max-bytes 200000 --run 'npx cucumber-js --dry-run --tags "not @captain and not @shipwright"' --label discovery --timeout 300`
- regression: `npx @dk/yoink --max-bytes 200000 --run 'npx cucumber-js --tags "not @captain and not @shipwright"' --label regression --timeout 900`
- condemnation: `SS_SCENARIO="{scenario}" npx @dk/yoink --max-bytes 200000 --run 'npx cucumber-js "${SS_SCENARIO%%:*}" --name "^${SS_SCENARIO#*:}$" --tags "not @captain and not @shipwright"' --label prove --timeout 600`
- dead-code: none
- spec-lint: none
- install: `SS_DEPENDENCY="{dependency}" npx @dk/yoink --max-bytes 200000 --run 'npm install --save-dev "$SS_DEPENDENCY"' --label install --timeout 600`
- ship: none
- ship-verify: none

## Perturbation

- message: "PERTURBATION: behaviour-stable seam marked for reimplementation"
- perturb: `// PERTURBATION`

## Tiers

- default: @logic

## Dependencies

- policy: locked
- dependency: @cucumber/cucumber
- dependency: happy-dom

## Outbound

none
