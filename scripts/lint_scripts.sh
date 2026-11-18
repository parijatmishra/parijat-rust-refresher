#!/usr/bin/env bash
set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/common.sh"

# Lint every shell script in scripts/ (including Git hooks) as it is on disk, using .shellcheckrc.
(( $# == 0 )) || fail 'Usage: scripts/lint_scripts.sh'
check_tools

shellcheck_scripts
