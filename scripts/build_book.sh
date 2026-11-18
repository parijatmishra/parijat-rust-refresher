#!/usr/bin/env bash
set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/common.sh"

# Build the examples/ workspace (dev profile), test the book's Rust code blocks against it,
# then build the book. Fails first if a diagram is stale. Writes only examples/target/ and book/;
# never modifies source files.
(( $# == 0 )) || fail 'Usage: scripts/build_book.sh'
check_tools

mapfile -t stale < <(stale_diagrams)
(( ${#stale[@]} == 0 )) ||
    fail "SVG missing or older than its DOT source: ${stale[*]}. Run scripts/build_diagrams.sh."

deps=$REPO_ROOT/$EXAMPLES_DIR/target/debug/deps

# "<crate name><TAB><file>" for every library (rlib or proc-macro) in the current build, from
# Cargo's JSON messages; unlike target/debug/deps, this excludes stale builds of the same crate.
libs=$(
    cargo build "${EXAMPLES_CARGO_ARGS[@]}" --workspace --message-format=json-render-diagnostics |
    jq -r '
        select(.reason == "compiler-artifact")
        | select(any(.target.kind[]; . == "lib" or . == "rlib" or . == "proc-macro"))
        | [.target.name, (.filenames | map(select(endswith(".rlib"))) + map(select(endswith(".dylib"))) | first)]
        | select(.[1] != null)
        | @tsv'
)
# A crate built more than once (two versions, or two feature sets) gets no --extern: code blocks
# cannot name it directly, but libraries that depend on it still work.
dups=$(cut -f1 <<< "$libs" | sort | uniq -d)
declare -A skip=()
for name in $dups; do skip[$name]=1; done
[[ -z $dups ]] || warn "Crate(s) built more than once in $EXAMPLES_DIR/: ${dups//$'\n'/ }." \
    'Code blocks cannot use them directly; see README.md (Duplicate crates).'

# `mdbook test` runs `rustdoc` from PATH and accepts only -L, which fails (E0464) once deps/ holds
# several builds of a crate. Put a wrapper first on PATH that adds an exact --extern per library.
extern_args=()
while IFS=$'\t' read -r name file; do
    [[ -n $name && -z ${skip[$name]-} ]] && extern_args+=(--extern "$name=$file")
done <<< "$libs"
wrapper_dir=
make_temp_dir wrapper_dir book-rustdoc
{
    printf '#!/usr/bin/env bash\nexec %q "$@"' "$(rustup which --toolchain stable rustdoc)"
    printf ' %q' "${extern_args[@]}" -L "dependency=$deps"
    printf '\n'
} > "$wrapper_dir/rustdoc"
chmod +x "$wrapper_dir/rustdoc"

PATH="$wrapper_dir:$PATH" mdbook test
mdbook build
