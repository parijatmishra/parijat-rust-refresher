#!/usr/bin/env bash
set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/common.sh"

(( $# == 0 )) || fail 'Usage: scripts/build_diagrams.sh'
check_tools

# Render diagrams/<stem>.dot to src/images/<stem>.svg when the SVG is missing or older.
shopt -s nullglob
tmp=
for source in diagrams/*.dot; do
    [[ -f $source && ! -L $source ]] || continue
    name=${source##*/}
    svg=src/images/${name%.dot}.svg
    [[ ! -e $svg || $source -nt $svg ]] || continue
    mkdir -p src/images
    make_temp tmp src/images .render
    dot -Tsvg "$source" -o "$tmp"
    mv -f -- "$tmp" "$svg"
done
