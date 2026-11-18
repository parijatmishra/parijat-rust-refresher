#!/usr/bin/env bash
set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/common.sh"

# Render diagrams, build the examples/ workspace (dev profile), test the book's Rust code blocks
# against it, then build the book. Writes only src/diagrams/, examples/target/, and book/.

# 1. Render every diagrams/<stem>.dot to src/diagrams/<stem>.svg (generated; ignored by Git).
rm -rf src/diagrams
mkdir src/diagrams
shopt -s nullglob
for source in diagrams/*.dot; do
    name=${source##*/}
    dot -Tsvg "$source" -o "src/diagrams/${name%.dot}.svg"
done

# 2. Build examples/; list "<crate>\t<file>" for each library in this build (from Cargo's JSON
#    messages), or "<crate>\t" for a crate built more than once (two versions or feature sets).
libs=$(
    cargo build "${EXAMPLES_CARGO_ARGS[@]}" --workspace --message-format=json-render-diagnostics |
    jq -rs '
        map(select(.reason == "compiler-artifact"
                   and any(.target.kind[]; . == "lib" or . == "rlib" or . == "proc-macro"))
            | {name: .target.name,
               file: (.filenames | map(select(endswith(".rlib"))) + map(select(endswith(".dylib"))) | first)}
            | select(.file != null))
        | group_by(.name)[]
        | [.[0].name, (if length == 1 then .[0].file else "" end)]
        | @tsv'
)
extern_args=()
dups=()
while IFS=$'\t' read -r name file; do
    if [[ -z $name ]]; then continue
    elif [[ -z $file ]]; then dups+=("$name")
    else extern_args+=(--extern "$name=$file")
    fi
done <<< "$libs"
(( ${#dups[@]} == 0 )) || warn "Crate(s) built more than once in examples/: ${dups[*]}." \
    'Code blocks cannot use them directly; see README.md (Duplicate crates).'

# 3. `mdbook test` runs `rustdoc` from PATH and accepts only -L, which fails (E0464) once deps/
#    holds several builds of a crate. Put a wrapper first on PATH that adds an exact --extern
#    per library, and finds their dependencies in deps/.
mkdir "$TMP_DIR/bin"
{
    printf '#!/usr/bin/env bash\nexec %q "$@"' "$(rustup which rustdoc)"
    printf ' %q' "${extern_args[@]}" -L "dependency=$PWD/examples/target/debug/deps"
    printf '\n'
} > "$TMP_DIR/bin/rustdoc"
chmod +x "$TMP_DIR/bin/rustdoc"
PATH="$TMP_DIR/bin:$PATH" mdbook test

# 4. Build the book.
mdbook build
