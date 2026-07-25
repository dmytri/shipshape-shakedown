# Rigging

## Stack

- language: JavaScript
- framework: vanilla (no framework)
- test runner: cucumber-js 13.x with happy-dom

## Directories

- implementation: js
- specs: features

## Commands

- focused: npx cucumber-js --require 'features/support/world.js' --require 'features/support/steps.js' --name "{scenario}"
- discover: npx cucumber-js --dry-run --require 'features/support/world.js' --require 'features/support/steps.js'
- broad: npx cucumber-js --require 'features/support/world.js' --require 'features/support/steps.js'
- step-usage: npx cucumber-js --dry-run --require 'features/support/world.js' --require 'features/support/steps.js' --format usage
- plank-inventory: none
- typecheck: none
- lint: none

## Perturbation

- message: throw new Error("PERTURBATION: reimplement this seam from current durable context")

## Dependencies

- policy: locked

## Outbound

- policy: local only
