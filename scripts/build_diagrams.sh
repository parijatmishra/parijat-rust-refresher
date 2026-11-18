#!/usr/bin/env bash
set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/common.sh"

# Render diagrams/<stem>.dot to src/images/<stem>.svg when the SVG is missing or older.
(( $# == 0 )) || fail 'Usage: scripts/build_diagrams.sh'
check_tools

mapfile -t stale < <(stale_diagrams)
tmp=
for source in "${stale[@]}"; do
    name=${source##*/}
    mkdir -p src/images
    make_temp tmp src/images .render
    dot -Tsvg "$source" -o "$tmp"
    mv -f -- "$tmp" "src/images/${name%.dot}.svg"
done
