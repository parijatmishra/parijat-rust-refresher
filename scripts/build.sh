#!/usr/bin/env bash
set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/common.sh"

mode=${1-build}
case "$#:$mode" in
    0:build|1:check|1:update-output) ;;
    *) fail 'Usage: scripts/build.sh [check|update-output]' ;;
esac
check_tools

workspace=examples
case $mode in
    build) exec mdbook build ;;
    check)
        mdbook test
        cargo test --workspace --locked --quiet --manifest-path "$workspace/Cargo.toml"
        ;;
esac

# Run each package that has an output.txt fixture; diff (check) or replace it (update-output).
shopt -s nullglob
tmp=
failed=()
for fixture in "$workspace"/*/output.txt; do
    package=${fixture%/output.txt}
    make_temp tmp "$package" .output
    if ! cargo run --locked --quiet --manifest-path "$package/Cargo.toml" > "$tmp"; then
        failed+=("$package (run)")
    elif [[ $mode == check ]]; then
        diff -u "$fixture" "$tmp" || failed+=("$package (diff)")
    else
        mv -f -- "$tmp" "$fixture"
    fi
done
(( ${#failed[@]} == 0 )) || fail "Failed: ${failed[*]}"
