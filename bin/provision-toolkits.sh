#!/usr/bin/env bash
# Provision everything a test Captain needs, so no leg spends its session installing.
#
# dk (2026-07-27): "install whatever is needed beforehand so test captains don't struggle with
# missing deps", and "envs have multiple stacks installed" - so every sim sees the SAME full
# toolchain set, the way a real machine does. r19's py fit spent its entire session running
# npm install to get gplint and never reached RIGGING.md.
#
# Idempotent: run it after a fresh clone, or when a tool is added to doctrine.
set -uo pipefail
HERE="$(cd "$(dirname "$0")/.." && pwd)"
SCRATCH="${EVAL_SCRATCH:-$HERE/.eval-scratch}"

# Node tools every stack's methods reach for, gplint above all (doctrine mandates it everywhere).
for t in .shared-nm; do
  mkdir -p "$SCRATCH/$t"
  npm install --prefix "$SCRATCH/$t" gplint >/dev/null 2>&1
done

# Rust: coverage and unused-dependency tools, plus just. Installed into /opt (bound read-only into
# every sim) and symlinked where a --clearenv leg's PATH reaches them.
export CARGO_HOME=/opt/rust/cargo RUSTUP_HOME=/opt/rust/rustup PATH=/opt/rust/cargo/bin:$PATH
rustup component add llvm-tools-preview >/dev/null 2>&1
for c in cargo-machete cargo-llvm-cov just; do
  [ -x "/opt/rust/cargo/bin/$c" ] || cargo install --locked "$c" >/dev/null 2>&1
done

# Go: linters, dead-code and the godog CLI, plus the shared module cache the fixtures resolve from.
export GOBIN=/opt/gotools/bin GOPATH=/opt/gotools/gopath GOMODCACHE=/opt/gotools/pkg/mod
mkdir -p "$GOBIN" "$GOMODCACHE" 2>/dev/null
for t in honnef.co/go/tools/cmd/staticcheck golang.org/x/tools/cmd/deadcode \
         github.com/golangci/golangci-lint/v2/cmd/golangci-lint github.com/cucumber/godog/cmd/godog; do
  [ -x "$GOBIN/$(basename "$t")" ] || go install "$t@latest" >/dev/null 2>&1
done
( cd "$HERE/fixtures/tidewatch-go" && go mod download all >/dev/null 2>&1 )

for b in cargo-llvm-cov cargo-machete just; do sudo ln -sfn "/opt/rust/cargo/bin/$b" "/usr/local/bin/$b" 2>/dev/null; done
for b in staticcheck deadcode golangci-lint godog; do sudo ln -sfn "/opt/gotools/bin/$b" "/usr/local/bin/$b" 2>/dev/null; done

echo "toolkits provisioned:"
for c in gplint just cargo-llvm-cov cargo-machete staticcheck deadcode golangci-lint godog; do
  printf '  %-16s %s\n' "$c" "$(command -v "$c" 2>/dev/null || ls "$SCRATCH"/.shared-nm/node_modules/.bin/"$c" 2>/dev/null || echo MISSING)"
done
