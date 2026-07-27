# Rigging

Project tooling values for Shipshape roles. Values only, not procedure.
Procedure lives in the skills. Every role reads this on open.

## Stack

- language: Go
- runtime: go 1.26
- packageManager: go mod

## Directories

- implementation: src
- specs: features
- verification: .
- assets: data
- scantlings: .shipshape/verification-conformance-rules.txt

## Methods

- prove: `SS_SCENARIO="{scenario}" npx @dk/yoink --max-bytes 200000 --run 'SCENARIO=$(echo "$SS_SCENARIO" | sed "s/^[^:]*://"); TEST_NAME=$(echo "$SCENARIO" | sed "s/ /_/g"); go test -run "TestFeatures/${TEST_NAME}" . -args -godog.tags="~@captain && ~@shipwright"' --label prove --timeout 600`
- verify: `SS_SCENARIO="{scenario}" npx @dk/yoink --max-bytes 200000 --run 'SCENARIO=$(echo "$SS_SCENARIO" | sed "s/^[^:]*://"); TEST_NAME=$(echo "$SCENARIO" | sed "s/ /_/g"); go test -run "TestFeatures/${TEST_NAME}" . -args -godog.tags="~@captain && ~@shipwright"' --label prove --timeout 600 --run 'node .shipshape/plank-join.mjs' --label plank-join --timeout 120`
- sweep: `npx @dk/yoink --max-bytes 200000 --run 'go test -run TestFeatures . -args -godog.tags="~@captain && ~@shipwright"' --label sweep --timeout 900`
- plank-join: `npx @dk/yoink --max-bytes 200000 --run 'node .shipshape/plank-join.mjs' --label plank-join --timeout 120`
- hygiene: `npx @dk/yoink --max-bytes 200000 --run 'node .shipshape/plank-join.mjs' --label plank-join --timeout 120 --run 'go vet ./...' --label typecheck --timeout 300 --run 'staticcheck ./...' --label lint --timeout 300 --run 'deadcode -test ./...' --label dead-code --timeout 300`
- static: `npx @dk/yoink --max-bytes 200000 --run 'go test -run TestFeatures . -args -godog.definitions' --label discovery --timeout 300 --run 'go vet ./...' --label typecheck --timeout 300 --run 'staticcheck ./...' --label lint --timeout 300`
- discovery: `npx @dk/yoink --max-bytes 200000 --run 'go test -run TestFeatures . -args -godog.definitions' --label discovery --timeout 300`
- regression: `npx @dk/yoink --max-bytes 200000 --run 'go test -cover ./... -args -godog.tags="~@captain && ~@shipwright"' --label coverage --timeout 900`
- condemnation: `SS_SCENARIO="{scenario}" npx @dk/yoink --max-bytes 200000 --run 'SCENARIO=$(echo "$SS_SCENARIO" | sed "s/^[^:]*://"); TEST_NAME=$(echo "$SCENARIO" | sed "s/ /_/g"); go test -run "TestFeatures/${TEST_NAME}" . -args -godog.tags="~@captain && ~@shipwright"' --label prove --timeout 600 --run 'go vet ./...' --label typecheck --timeout 300 --run 'staticcheck ./...' --label lint --timeout 300`
- dead-code: `npx @dk/yoink --max-bytes 200000 --run 'deadcode -test ./...' --label dead-code --timeout 300`
- spec-lint: `npx @dk/yoink --max-bytes 200000 --run 'npx gplint -c .gplintrc features/' --label gherkin-lint --timeout 300`
- install: `SS_DEPENDENCY="{dependency}" npx @dk/yoink --max-bytes 200000 --run 'go get "$SS_DEPENDENCY"' --label install --timeout 600`
- ship: none
- ship-verify: none

## Perturbation

- message: `PERTURBATION: consider current durable context; remove when fixed`
- perturb: `panic("PERTURBATION: consider current durable context; remove when fixed")`

## Tiers

- default: @logic
- sandbox: none
- policy: @logic local, no external accounts
- weather: .shipshape/wake/weather.jsonl
- runrecord: .shipshape/wake/runrecord.jsonl

## Dependencies

- policy: locked
- dependency: github.com/cucumber/godog v0.15.1

## Scantlings

- verification-conformance: .shipshape/verification-conformance-rules.txt

## Outbound

- outbound: none
- ship: none
- ship-verify: none
