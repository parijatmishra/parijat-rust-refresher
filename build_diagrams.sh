#!/usr/bin/env bash
set -euo pipefail
CDPATH='' cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

tmp=''
trap 'if [[ -n $tmp ]]; then rm -f -- "$tmp"; fi' EXIT
trap 'exit 129' HUP
trap 'exit 130' INT
trap 'exit 143' TERM

shopt -s nullglob
for source in diagrams/*.dot; do
    [[ -f $source && ! -L $source ]] || continue
    name=${source##*/}
    svg=src/images/${name%.dot}.svg
    [[ ! -e $svg || $source -nt $svg ]] || continue
    if ! command -v dot >/dev/null; then
        printf '%s\n' 'Install Graphviz (brew install graphviz or your Linux graphviz package) and rerun build_diagrams.sh.' >&2
        exit 1
    fi
    mkdir -p src/images
    tmp=$(mktemp 'src/images/.render.XXXXXXXX')
    dot -Tsvg "$source" -o "$tmp"
    mv -f -- "$tmp" "$svg"
    tmp=''
done
