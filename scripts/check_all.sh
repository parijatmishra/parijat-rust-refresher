#!/usr/bin/env bash
set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/common.sh"

# Run every check before committing or pushing. Stops at the first failure.
scripts/lint_scripts.sh
scripts/check_examples.sh
scripts/build_book.sh
