# shellcheck shell=bash
# Sourced by every script under scripts/, after `set -euo pipefail`. Rejects arguments, checks
# tools, changes the CWD to the repository root, and provides TMP_DIR (removed on exit).

# Settings you edit by hand. README.md points here instead of repeating them.
# Pinned tools: <tool> '<phrase its `--version` output must contain, as whole words>'.
# mdbook: build_book.sh relies on `mdbook test` running `rustdoc` from PATH; recheck on upgrade.
TOOL_VERSIONS=(
    mdbook      'mdbook v0.5.4'
    mdbook-quiz 'mdbook-quiz 0.5.0'
)
# Tools that must be present, any version.
REQUIRED_TOOLS=(rustup cargo dot shellcheck jq git)

# Let check_prereqs.sh read the tool lists without running the setup it checks.
if [[ ${_CHECK_PREREQS_LISTS_ONLY:-} == 1 ]]; then return 0; fi

fail() { printf '%s\n' "$*" >&2; exit 1; }
warn() { printf 'Warning: %s\n' "$*" >&2; }
setup_fail() { fail "$* See README.md (Pre-requisites)."; }

(( BASH_VERSINFO[0] >= 5 )) || setup_fail "Bash 5 or newer required; found $BASH_VERSION."
(( $# == 0 )) || fail "Usage: $0 (takes no arguments)"

check_tools() {
    local i tool expected actual
    for tool in "${REQUIRED_TOOLS[@]}"; do
        command -v "$tool" >/dev/null || setup_fail "Missing $tool."
    done
    for (( i = 0; i < ${#TOOL_VERSIONS[@]}; i += 2 )); do
        tool=${TOOL_VERSIONS[i]} expected=${TOOL_VERSIONS[i + 1]}
        actual=$("$tool" --version 2>&1) || setup_fail "Cannot run $tool --version."
        [[ " ${actual//[[:space:]]/ } " == *" $expected "* ]] ||
            setup_fail "Expected '$expected' from $tool --version; found '$actual'."
    done
}
check_tools

cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." || exit
TMP_DIR=$(mktemp -d "${TMPDIR:-/tmp}/${0##*/}.XXXXXXXX")
trap 'rm -rf -- "$TMP_DIR"' EXIT

# Cargo arguments for the examples/ workspace: dev profile, Cargo.lock as committed.
EXAMPLES_CARGO_ARGS=(--locked --quiet --manifest-path examples/Cargo.toml)

# run_example_binaries check|update: run every binary in the examples/ workspace (stdin /dev/null)
# and require exit status expected/<binary>.status (default 0); then diff its stdout against
# expected/<binary>.stdout (check) or replace that file (update). Fails at the end.
run_example_binaries() {
    local mode=$1 list package binary dir expected status out fixture
    local -a failed=()
    list=$(cargo metadata --locked --no-deps --format-version 1 --manifest-path examples/Cargo.toml |
        jq -r '.packages[] | .name as $p | (.manifest_path | rtrimstr("/Cargo.toml")) as $d
               | .targets[] | select(.kind | index("bin")) | [$p, .name, $d] | @tsv')
    while IFS=$'\t' read -r package binary dir; do
        [[ -n $package ]] || continue
        expected=0
        if [[ -f $dir/expected/$binary.status ]]; then expected=$(< "$dir/expected/$binary.status"); fi
        out=$TMP_DIR/$package.$binary.stdout
        fixture=$dir/expected/$binary.stdout
        status=0
        cargo run "${EXAMPLES_CARGO_ARGS[@]}" --package "$package" --bin "$binary" < /dev/null > "$out" ||
            status=$?
        if (( status != expected )); then
            failed+=("$package/$binary (exit $status, expected $expected)")
        elif [[ $mode == update ]]; then
            mkdir -p "$dir/expected"
            mv -f -- "$out" "$fixture"
        elif [[ ! -f $fixture ]]; then
            failed+=("$package/$binary (no expected/$binary.stdout; run scripts/update_example_outputs.sh)")
        else
            diff -u "$fixture" "$out" || failed+=("$package/$binary (stdout differs)")
        fi
    done <<< "$list"
    (( ${#failed[@]} == 0 )) || fail "Failed: ${failed[*]}"
}
