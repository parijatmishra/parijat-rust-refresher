#!/usr/bin/env bash
set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/common.sh"

# Build every target of the examples/ workspace, run its tests, then run each binary in
# BINARIES (scripts/common.sh): check its exit status and diff its stdout against its fixture.
(( $# == 0 )) || fail 'Usage: scripts/check_examples.sh'
check_tools

cargo build "${EXAMPLES_CARGO_ARGS[@]}" --workspace --all-targets
cargo test "${EXAMPLES_CARGO_ARGS[@]}" --workspace
run_example_binaries check
