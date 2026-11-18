#!/usr/bin/env bash
set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/common.sh"

# Build every target of the examples/ workspace, run its tests, then run every binary and
# compare its exit status and stdout with expected/<binary>.status and expected/<binary>.stdout.
cargo build "${EXAMPLES_CARGO_ARGS[@]}" --workspace --all-targets
cargo test "${EXAMPLES_CARGO_ARGS[@]}" --workspace
run_example_binaries check
