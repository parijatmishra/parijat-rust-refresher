#!/usr/bin/env bash
set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/common.sh"

(( $# == 0 )) || fail 'Usage: scripts/lint_scripts.sh'
check_tools

# Lint every shell script in scripts/ (including Git hooks), using .shellcheckrc.
shopt -s nullglob
files=(scripts/*.sh scripts/git-hooks/*)
shellcheck -- "${files[@]}"
