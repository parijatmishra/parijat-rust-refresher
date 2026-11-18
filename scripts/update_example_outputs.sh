#!/usr/bin/env bash
set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/common.sh"

# Run each binary in BINARIES (scripts/common.sh) and replace its stdout fixture, if it has one
# and the binary exits with the expected status. Use after an intentional change; review the diff.
(( $# == 0 )) || fail 'Usage: scripts/update_example_outputs.sh'
check_tools

run_example_binaries update
