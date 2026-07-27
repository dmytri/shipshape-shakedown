#!/usr/bin/env bash
# Scaffold the tidewatch fixture for a NAMED STACK, un-fitted-out (no RIGGING.md).
#
# The fitting-out claim under test is that Shipwright derives the project's methods AND their
# MECHANISM from the stack (dk, 2026-07-26). A single Node/Cucumber fixture cannot test that: every
# derivation would be the same derivation. Each stack here carries the same tidewatch domain, the
# same two scenarios, and its own native runner, type checker, linter, and coverage tool, so the
# derived commands and methods must genuinely differ.
#
# usage: scaffold-stack.sh <js|ts|py|rs> <target-dir>
set -euo pipefail
STACK="${1:?usage: scaffold-stack.sh <js|ts|py|rs> <target-dir>}"
TARGET="${2:?usage: scaffold-stack.sh <js|ts|py|rs> <target-dir>}"
HERE="$(cd "$(dirname "$0")/.." && pwd)"
case "$STACK" in
  js) SRC="$HERE/fixtures/tidewatch";;
  ts) SRC="$HERE/fixtures/tidewatch-ts";;
  py) SRC="$HERE/fixtures/tidewatch-py";;
  rs) SRC="$HERE/fixtures/tidewatch-rs";;
  go) SRC="$HERE/fixtures/tidewatch-go";;
  *) echo "scaffold-stack.sh: unknown stack '$STACK' (js|ts|py|rs|go)" >&2; exit 2;;
esac
[ -d "$SRC" ] || { echo "scaffold-stack.sh: fixture missing at $SRC" >&2; exit 2; }

mkdir -p "$TARGET"
cp -r "$SRC/." "$TARGET/"
cd "$TARGET"
[ -f gitignore ] && mv gitignore .gitignore

case "$STACK" in
  js|ts)
    # Same overlay contract as scaffold.sh: symlink the shared toolkit to prove the runner, then
    # leave an empty dir as the bwrap mountpoint the leg overlays.
    if [ -n "${EVAL_SHARED_NM:-}" ] && [ -d "$EVAL_SHARED_NM/@cucumber" ]; then
      ln -sfn "$EVAL_SHARED_NM" node_modules
      npx cucumber-js >/dev/null 2>&1 || { echo "SCAFFOLD($STACK): cucumber not green"; exit 1; }
      rm -f node_modules && mkdir node_modules
    else
      npm install >/dev/null 2>&1
      npx cucumber-js >/dev/null 2>&1 || { echo "SCAFFOLD($STACK): cucumber not green"; exit 1; }
    fi
    ;;
  rs)
    # No target/ is shipped: it is ~800M and a moved target dir buys little. The toolchain lives in
    # /opt (already --ro-bind-try'd into every leg) with the real toolchain binaries symlinked into
    # /usr/local/bin, so a leg reaches cargo/rustc/clippy/rustfmt/rustdoc with NO harness change and
    # no rustup shim (the shim needs RUSTUP_HOME, which a --clearenv leg does not have). Cargo.lock
    # ships, so the leg's fetch is deterministic; the leg has network and pays one cold compile.
    rm -rf target
    cargo test >/dev/null 2>&1 || { echo "SCAFFOLD(rs): cargo test not green"; exit 1; }
    rm -rf target
    ;;
  go)
    # Modules resolve from the SHARED read-only cache under /opt, which the leg gets by
    # --setenv (see eval-leg.sh). Nothing is vendored: no third-party code lives in the fixture.
    GOMODCACHE=/opt/gotools/pkg/mod GOFLAGS=-mod=mod go test ./... >/dev/null 2>&1 \
      || { echo "SCAFFOLD(go): go test not green"; exit 1; }
    ;;
  py)
    # A venv is built HERE, at scaffold time and at the sim's own absolute path, because a venv
    # carries that path inside it and does not survive a copy. Network is available at scaffold
    # time; the leg itself then needs none for the suite.
    # uv against pyproject.toml is the shape doctrine prefers on Python: one manifest resolves,
    # locks and runs. The env is built HERE because a venv carries its absolute path inside it.
    uv sync --quiet >/dev/null 2>&1 || { echo "SCAFFOLD(py): uv sync failed"; exit 1; }
    uv run pytest -q >/dev/null 2>&1 || { echo "SCAFFOLD(py): pytest not green"; exit 1; }
    ;;
esac

git init -q
git config user.name "Sim Operator"
git config user.email "sim@example.test"
git add -A
git commit -qm "tidewatch ($STACK): baseline, suite green, not fitted out"
echo "scaffolded tidewatch-$STACK: $TARGET at $(git rev-parse --short HEAD), suite green, no RIGGING.md"
