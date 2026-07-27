# tidewatch Rigging

## Stack

- language: Rust
- runtime: rustc 1.97.1
- packageManager: cargo

## Directories

- implementation: src
- specs: features
- verification: tests
- assets: data
- scantlings: .shipshape/conformance.json

## Methods

- prove: `SS_SCENARIO="{scenario}" npx @dk/yoink --max-bytes 200000 --run 'cargo test --test cucumber -- -i "${SS_SCENARIO%%:*}" --name "^${SS_SCENARIO#*:}$"' --label prove --timeout 600`
- verify: `SS_SCENARIO="{scenario}" npx @dk/yoink --max-bytes 200000 --run 'cargo test --test cucumber -- -i "${SS_SCENARIO%%:*}" --name "^${SS_SCENARIO#*:}$"' --label prove --timeout 600 --run 'node .shipshape/plank-join.mjs' --label plank-join --timeout 120`
- sweep: `npx @dk/yoink --max-bytes 200000 --run 'cargo test --test cucumber -- -t "not @captain and not @shipwright"' --label sweep --timeout 900`
- plank-join: `npx @dk/yoink --max-bytes 200000 --run 'node .shipshape/plank-join.mjs' --label plank-join --timeout 120`
- hygiene: `npx @dk/yoink --max-bytes 200000 --run 'node .shipshape/plank-join.mjs' --label plank-join --timeout 120 --run 'cargo check --all-targets' --label typecheck --timeout 300 --run 'cargo clippy --all-targets -- -D warnings 2>&1' --label lint --timeout 300 --run 'cargo fmt --check' --label fmt --timeout 120`
- static: `npx @dk/yoink --max-bytes 200000 --run 'cargo test --no-run --test cucumber' --label discovery --timeout 300 --run 'cargo check --all-targets' --label typecheck --timeout 300 --run 'cargo clippy --all-targets -- -D warnings 2>&1' --label lint --timeout 300 --run 'cargo fmt --check' --label fmt --timeout 120`
- discovery: `npx @dk/yoink --max-bytes 200000 --run 'cargo test --no-run --test cucumber' --label discovery --timeout 300`
- regression: `npx @dk/yoink --max-bytes 200000 --run 'cargo llvm-cov --test cucumber -- -t "not @captain and not @shipwright"' --label coverage --timeout 900`
- condemnation: `SS_SCENARIO="{scenario}" npx @dk/yoink --max-bytes 200000 --run 'cargo check --all-targets' --label typecheck --timeout 300 --run 'cargo clippy --all-targets -- -D warnings 2>&1' --label lint --timeout 300 --run 'cargo test --test cucumber -- -i "${SS_SCENARIO%%:*}" --name "^${SS_SCENARIO#*:}$"' --label prove --timeout 600`
- dead-code: `npx @dk/yoink --max-bytes 200000 --run 'cargo machete' --label dead-code --timeout 300`
- spec-lint: `npx @dk/yoink --max-bytes 200000 --run 'npx gplint -c .gplintrc features/' --label gherkin-lint --timeout 300`
- install: `SS_DEPENDENCY="{dependency}" npx @dk/yoink --max-bytes 200000 --run 'cargo add "$SS_DEPENDENCY"' --label install --timeout 600`
- ship: none
- ship-verify: none

## Perturbation

- message: `PERTURBATION`
- perturb: `PERTURBATION`

## Tiers

- default: @logic
- budget: 120
- weather: .shipshape/weather.json
- runrecord: .shipshape/runrecord.json

## Dependencies

- policy: latest-stable
- dependency: serde
- dependency: serde_json
- dependency: cucumber
- dependency: tokio

## Outbound

- outbound: none
- ship: none
- ship-verify: none

## Methodology checks

- watchbill-conformance: absent watchbill conforms
- perturbation-quiescence: `rg -q "PERTURBATION" src/ && exit 1 || exit 0`
- plank-form: `.shipshape/conformance.json` rule `plank-form`
- plank-coverage: `plank-join` method
- feature-lint: `.gplintrc`
- budget-check: none
- verification-conformance: `.shipshape/conformance.json`