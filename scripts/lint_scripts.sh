#!/usr/bin/env bash
set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/common.sh"

case "$#:${1-}" in
    0:|1:--staged) ;;
    *) fail 'Usage: scripts/lint_scripts.sh [--staged]' ;;
esac
check_tools

# --staged: lint the Git index (what would be committed) instead of the working tree.
# Export staged scripts/ and .shellcheckrc to a temp dir with the same layout, and lint there.
if [[ ${1-} == --staged ]]; then
    staged=
    make_temp_dir staged lint-staged
    git ls-files -z -- scripts .shellcheckrc | git checkout-index -z --stdin --prefix="$staged/"
    cd -- "$staged"
fi

# Lint every shell script in scripts/ (including Git hooks), using .shellcheckrc.
shopt -s nullglob
files=(scripts/*.sh scripts/git-hooks/*)
shellcheck -- "${files[@]}"
