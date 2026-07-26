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

## Methods

- prove: `npx @dk/yoink --max-bytes 200000 --run 'npx cucumber-js {scenario} --tags "not @captain and not @shipwright"' --label prove --timeout 900`
- verify: `npx @dk/yoink --max-bytes 200000 --run 'npx cucumber-js {scenario} --tags "not @captain and not @shipwright"' --label prove --timeout 900 --run 'grep -rn "@planks" src/' --label plank-inventory --timeout 60 --run 'npx cucumber-js --dry-run --format usage-json --tags "not @captain and not @shipwright"' --label step-usage --timeout 300`
- sweep: `npx @dk/yoink --max-bytes 200000 --run 'npx cucumber-js --tags "not @captain and not @shipwright"' --label sweep --timeout 900`
- plank-join: `npx @dk/yoink --max-bytes 200000 --run 'grep -rn "@planks" src/' --label plank-inventory --timeout 60 --run 'npx cucumber-js --dry-run --format usage-json --tags "not @captain and not @shipwright"' --label step-usage --timeout 300`
- hygiene: `npx @dk/yoink --max-bytes 200000 --run 'grep -rn "@planks" src/' --label plank-inventory --timeout 60 --run 'npx cucumber-js --dry-run --format usage-json --tags "not @captain and not @shipwright"' --label step-usage --timeout 300`
- static: `npx @dk/yoink --max-bytes 200000 --run 'npx cucumber-js --dry-run --tags "not @captain and not @shipwright"' --label discovery --timeout 300`
- discovery: `npx @dk/yoink --max-bytes 200000 --run 'npx cucumber-js --dry-run --tags "not @captain and not @shipwright"' --label discovery --timeout 300`
- regression: `npx @dk/yoink --max-bytes 200000 --run 'npx c8 npx cucumber-js --tags "not @captain and not @shipwright"' --label coverage --timeout 900`
- condemnation: `npx @dk/yoink --max-bytes 200000 --run 'npx cucumber-js {scenario} --tags "not @captain and not @shipwright"' --label prove --timeout 900`
- dead-code: `npx @dk/yoink --max-bytes 200000 --run 'npx knip --no-exit-code' --label dead-code --timeout 300`
- spec-lint: none
- install: `npx @dk/yoink --max-bytes 200000 --run 'npm install --save-dev {dependency}' --label install --timeout 600`
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
- dependency: c8

## Outbound

- none
