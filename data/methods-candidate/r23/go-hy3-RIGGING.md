# Rigging

Project tooling values for Shipshape roles. Values only, not procedure.
Procedure lives in the skills. Every role reads this on open.

## Stack

- language: Go
- runtime: go1.26
- packageManager: go modules

## Directories

- implementation: src
- specs: features
- verification: .
- assets: data
- scantlings: scantlings

## Methods

- prove: `SS_SCENARIO="{scenario}" npx @dk/yoink --max-bytes 200000 --run 'N=$(printf "%s" "${SS_SCENARIO#*:}" | tr " " "_"); go test -run "TestFeatures/${N}" . -args -godog.tags="~@captain && ~@shipwright"' --label prove --timeout 600`
- verify: `SS_SCENARIO="{scenario}" npx @dk/yoink --max-bytes 200000 --run 'N=$(printf "%s" "${SS_SCENARIO#*:}" | tr " " "_"); go test -run "TestFeatures/${N}" . -args -godog.tags="~@captain && ~@shipwright"' --label prove --timeout 600 --run 'node .shipshape/plank-join.mjs' --label plank-join --timeout 120`
- sweep: `npx @dk/yoink --max-bytes 200000 --run 'go test -run TestFeatures . -args -godog.tags="~@captain && ~@shipwright"' --label sweep --timeout 900`
- plank-join: `npx @dk/yoink --max-bytes 200000 --run 'node .shipshape/plank-join.mjs' --label plank-join --timeout 120`
- hygiene: `npx @dk/yoink --max-bytes 200000 --run 'node .shipshape/plank-join.mjs' --label plank-join --timeout 120 --run 'go vet ./...' --label typecheck --timeout 300 --run 'staticcheck ./...' --label lint --timeout 300 --run 'npx gplint -c .gplintrc features/' --label gherkin-lint --timeout 300`
- static: `npx @dk/yoink --max-bytes 200000 --run 'go test -run TestFeatures . -args -godog.definitions' --label discovery --timeout 300 --run 'go vet ./...' --label typecheck --timeout 300 --run 'staticcheck ./...' --label lint --timeout 300`
- discovery: `npx @dk/yoink --max-bytes 200000 --run 'go test -run TestFeatures . -args -godog.definitions' --label discovery --timeout 300`
- regression: `npx @dk/yoink --max-bytes 200000 --run 'go test -cover -coverpkg=./... . -args -godog.tags="~@captain && ~@shipwright"' --label coverage --timeout 900`
- condemnation: `SS_SCENARIO="{scenario}" npx @dk/yoink --max-bytes 200000 --run 'go vet ./...' --label typecheck --timeout 300 --run 'staticcheck ./...' --label lint --timeout 300 --run 'N=$(printf "%s" "${SS_SCENARIO#*:}" | tr " " "_"); go test -run "TestFeatures/${N}" . -args -godog.tags="~@captain && ~@shipwright"' --label prove --timeout 600`
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
- policy: @logic: pure local tests, no credentials or external services
- weather: .wake/weather.json
- runrecord: .wake/runrecord.json

## Dependencies

- policy: locked
- dependency: github.com/cucumber/godog (test runner; godog suite)
- dependency: honnef.co/go/tools/staticcheck (linter)
- dependency: golang.org/x/tools/cmd/deadcode (dead-code analyser)
- dependency: gplint (Gherkin spec linter, via npx)

## Outbound

- outbound: none
- ship: none
- ship-verify: none
