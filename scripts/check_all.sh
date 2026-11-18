#!/usr/bin/env bash
set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/common.sh"

# Run every check before committing or pushing: lint scripts, check examples, build the book
# (which also fails on stale diagrams). Stops at the first failure.
(( $# == 0 )) || fail 'Usage: scripts/check_all.sh'
check_tools

"$SCRIPTS_DIR/lint_scripts.sh"
"$SCRIPTS_DIR/check_examples.sh"
"$SCRIPTS_DIR/build_book.sh"
