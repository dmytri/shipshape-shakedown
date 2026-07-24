# Rigging

## Stack
- language: JavaScript

## Directories
- specs: features
- implementation: js
- verification: features/support
- scantlings: scantlings

## Commands
- focused: npx cucumber-js --name "{scenario}" features/
- discover: npx cucumber-js --dry-run features/
- broad: npx cucumber-js features/
- conformance: none
- step-usage: none
- plank-inventory: none
- typecheck: none
- lint: none
- coverage: none

## Tiers
- @logic: default

## Perturbation
- message: PERTURBATION

## Dependencies
- policy: locked
- dependency: @cucumber/cucumber
- dependency: happy-dom

## Outbound
- targets: none