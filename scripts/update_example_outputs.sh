#!/usr/bin/env bash
set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/common.sh"

# Run every binary in the examples/ workspace and write its stdout to expected/<binary>.stdout,
# if it exits with the expected status. Use after an intentional change; review the diff.
run_example_binaries update
