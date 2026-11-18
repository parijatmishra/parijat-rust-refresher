# shellcheck shell=bash
# Sourced by the other scripts under scripts/, after `set -euo pipefail`.
# On return, the CWD is the repository root.

# Pinned tool versions: <tool> '<phrase its `--version` output must contain>'.
# The phrase must appear as whitespace-delimited words. Keep README.md in sync.
# mdbook: scripts/build_book.sh relies on `mdbook test` running `rustdoc` from PATH; recheck on upgrade.
TOOL_VERSIONS=(
    mdbook      'mdbook v0.5.4'
    mdbook-quiz 'mdbook-quiz 0.5.0'
    dot         'graphviz version 16.1.1'
    shellcheck  'version: 0.11.0'
)
readonly TOOL_VERSIONS

# Tools that must be present, any version. Keep README.md in sync.
REQUIRED_TOOLS=(jq git)
readonly REQUIRED_TOOLS

# Example binaries run by check_examples.sh and update_example_outputs.sh. Update by hand when
# adding, renaming, or removing a binary in examples/ (see README.md, "Add or change example code"):
#   '<package> <binary> <expected exit status> <stdout fixture, relative to the package, or -> [args...]'
# Fields are space-separated; arguments cannot contain spaces. Stdin is /dev/null.
BINARIES=(
    'ownership-demo ownership-demo 0 output.txt'
)
readonly BINARIES

fail() { printf '%s\n' "$*" >&2; exit 1; }
warn() { printf 'Warning: %s\n' "$*" >&2; }
setup_fail() { fail "$* See README.md (Pre-requisites)."; }

(( BASH_VERSINFO[0] >= 5 )) || setup_fail "Bash 5 or newer required; found $BASH_VERSION."

SCRIPTS_DIR=$(CDPATH='' cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
REPO_ROOT=${SCRIPTS_DIR%/*}
readonly SCRIPTS_DIR REPO_ROOT
cd -- "$REPO_ROOT" || exit

# Temporary paths registered via make_temp or make_temp_dir are removed on exit.
_temp_paths=()
make_temp() { # make_temp <var> <dir> <prefix>: create a temp file; store its path in <var>
    local -n _out=$1
    _out=$(mktemp "$2/$3.XXXXXXXX")
    _temp_paths+=("$_out")
}
make_temp_dir() { # make_temp_dir <var> <prefix>: create a temp directory under $TMPDIR; store its path in <var>
    local -n _out=$1
    _out=$(mktemp -d "${TMPDIR:-/tmp}/$2.XXXXXXXX")
    _temp_paths+=("$_out")
}
_cleanup() { (( ${#_temp_paths[@]} == 0 )) || rm -rf -- "${_temp_paths[@]}"; }
trap _cleanup EXIT
trap 'exit 129' HUP
trap 'exit 130' INT
trap 'exit 143' TERM

# Check rustup, the stable toolchain, and every tool in TOOL_VERSIONS and REQUIRED_TOOLS.
check_tools() {
    local i tool expected actual compiler
    command -v rustup >/dev/null || setup_fail 'Missing rustup.'
    export RUSTUP_TOOLCHAIN=stable RUSTUP_AUTO_INSTALL=0 CARGO_NET_OFFLINE=true
    rustup run stable true || setup_fail 'Cannot run the stable Rust toolchain.'
    # Some subprocesses call rustc/rustdoc by name, not through a rustup proxy.
    compiler=$(rustup which --toolchain stable rustc) || setup_fail 'Cannot locate stable rustc.'
    export PATH="${compiler%/*}:$PATH"

    for (( i = 0; i < ${#TOOL_VERSIONS[@]}; i += 2 )); do
        tool=${TOOL_VERSIONS[i]} expected=${TOOL_VERSIONS[i + 1]}
        command -v "$tool" >/dev/null || setup_fail "Missing $tool."
        actual=$("$tool" --version 2>&1) || setup_fail "Cannot run $tool --version."
        [[ " ${actual//[[:space:]]/ } " == *" $expected "* ]] ||
            setup_fail "Expected '$expected' from $tool --version; found '$actual'."
    done
    for tool in "${REQUIRED_TOOLS[@]}"; do
        command -v "$tool" >/dev/null || setup_fail "Missing $tool."
    done
}

# Cargo arguments for the examples/ workspace (dev profile, offline, Cargo.lock as committed).
EXAMPLES_DIR=examples
EXAMPLES_CARGO_ARGS=(--locked --quiet --manifest-path "$EXAMPLES_DIR/Cargo.toml")
readonly EXAMPLES_DIR EXAMPLES_CARGO_ARGS

# run_example_binaries check|update: run each binary in BINARIES and check its exit status; then
# diff its stdout against its fixture (check) or replace the fixture (update). Fails at the end.
run_example_binaries() {
    local mode=$1 entry package binary expected fixture rest label tmp='' status
    local -a args failed=()
    for entry in "${BINARIES[@]}"; do
        read -r package binary expected fixture rest <<< "$entry"
        read -ra args <<< "${rest-}"
        [[ -n ${fixture-} && $expected =~ ^[0-9]+$ ]] || fail "Malformed BINARIES entry: '$entry'"
        label="$package/$binary"
        make_temp tmp "$EXAMPLES_DIR/$package" ".$binary.out"
        status=0
        cargo run "${EXAMPLES_CARGO_ARGS[@]}" --package "$package" --bin "$binary" -- "${args[@]}" \
            < /dev/null > "$tmp" || status=$?
        if (( status != expected )); then
            failed+=("$label (exit $status, expected $expected)")
        elif [[ $fixture == - ]]; then
            :
        elif [[ $mode == check ]]; then
            diff -u "$EXAMPLES_DIR/$package/$fixture" "$tmp" || failed+=("$label (stdout differs from $fixture)")
        else
            mv -f -- "$tmp" "$EXAMPLES_DIR/$package/$fixture"
        fi
    done
    (( ${#failed[@]} == 0 )) || fail "Failed: ${failed[*]}"
}

# Run ShellCheck (with .shellcheckrc) on every shell script under scripts/, relative to the CWD.
shellcheck_scripts() {
    local file
    local -a files=()
    for file in scripts/*.sh scripts/git-hooks/*; do
        if [[ -f $file ]]; then files+=("$file"); fi
    done
    shellcheck -- "${files[@]}"
}

# Print each diagrams/<stem>.dot whose src/images/<stem>.svg is missing or older (file timestamps).
stale_diagrams() {
    local source name svg
    for source in diagrams/*.dot; do
        [[ -f $source && ! -L $source ]] || continue
        name=${source##*/}
        svg=src/images/${name%.dot}.svg
        if [[ ! -e $svg || $source -nt $svg ]]; then printf '%s\n' "$source"; fi
    done
}
