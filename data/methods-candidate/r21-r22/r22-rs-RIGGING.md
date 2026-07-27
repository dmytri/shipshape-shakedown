# Rigging

Project tooling values for Shipshape roles. Values only, not procedure.
Procedure lives in the skills. Every role reads this on open.

## Stack

- language: Rust
- runtime: none
- packageManager: cargo

## Directories

- implementation: src
- specs: features
- verification: tests
- assets: data
- scantlings: .shipshape/conformance-rules.json

## Methods

- prove: `SS_SCENARIO="{scenario}" npx @dk/yoink --max-bytes 200000 --run 'cargo test --test cucumber -- -i "${SS_SCENARIO%%:*}" --name "^${SS_SCENARIO#*:}$"' --label prove --timeout 600`
- verify: `SS_SCENARIO="{scenario}" npx @dk/yoink --max-bytes 200000 --run 'cargo test --test cucumber -- -i "${SS_SCENARIO%%:*}" --name "^${SS_SCENARIO#*:}$"' --label prove --timeout 600 --run 'node .shipshape/plank-join.mjs' --label plank-join --timeout 120`
- sweep: `npx @dk/yoink --max-bytes 200000 --run 'cargo test --test cucumber -- --tags "not @captain and not @shipwright"' --label sweep --timeout 900`
- plank-join: `npx @dk/yoink --max-bytes 200000 --run 'node .shipshape/plank-join.mjs' --label plank-join --timeout 120`
- hygiene: `npx @dk/yoink --max-bytes 200000 --run 'node .shipshape/plank-join.mjs' --label plank-join --timeout 120 --run 'cargo check --all-targets' --label typecheck --timeout 300 --run 'cargo clippy --all-targets -- -D warnings' --label lint --timeout 300 --run 'cargo fmt --check' --label fmt --timeout 300`
- static: `npx @dk/yoink --max-bytes 200000 --run 'cargo test --no-run --test cucumber' --label discovery --timeout 300 --run 'cargo check --all-targets' --label typecheck --timeout 300 --run 'cargo clippy --all-targets -- -D warnings' --label lint --timeout 300 --run 'cargo fmt --check' --label fmt --timeout 300`
- discovery: `npx @dk/yoink --max-bytes 200000 --run 'cargo test --no-run --test cucumber' --label discovery --timeout 300`
- regression: `npx @dk/yoink --max-bytes 200000 --run 'cargo llvm-cov test --ignore-filename-regex=tests/ --test cucumber -- --tags "not @captain and not @shipwright"' --label coverage --timeout 900`
- condemnation: `SS_SCENARIO="{scenario}" npx @dk/yoink --max-bytes 200000 --run 'cargo check --all-targets' --label typecheck --timeout 300 --run 'cargo clippy --all-targets -- -D warnings' --label lint --timeout 300 --run 'cargo fmt --check' --label fmt --timeout 300 --run 'cargo test --test cucumber -- -i "${SS_SCENARIO%%:*}" --name "^${SS_SCENARIO#*:}$"' --label prove --timeout 600`
- dead-code: `npx @dk/yoink --max-bytes 200000 --run 'cargo machete' --label dead-code --timeout 300`
- spec-lint: `npx @dk/yoink --max-bytes 200000 --run 'npx gplint -c .gplintrc features/' --label gherkin-lint --timeout 300`
- install: `SS_DEPENDENCY="{dependency}" npx @dk/yoink --max-bytes 200000 --run 'cargo add --dev "$SS_DEPENDENCY"' --label install --timeout 600`
- ship: none
- ship-verify: none

## Perturbation

- message: `PERTURBATION: consider current durable context; remove when fixed`
- perturb: `compile_error!("PERTURBATION: consider current durable context; remove when fixed");`

## Tiers

- default: @logic
- sandbox: none
- policy: @logic: no credentials needed
- weather: none
- runrecord: .shipshape/runrecord.json

## Dependencies

- policy: locked
- dependency: serde
- dependency: serde_json
- dependency: cucumber
- dependency: tokio

## Outbound

- outbound: none
- ship: none
- verify: none