# shellcheck shell=bash
# Sourced by the other scripts under scripts/, after `set -euo pipefail`.
# On return, the CWD is the repository root.

# Pinned tool versions: <tool> '<phrase its `--version` output must contain>'.
# The phrase must appear as whitespace-delimited words. Keep README.md in sync.
TOOL_VERSIONS=(
    mdbook      'mdbook v0.5.4'
    mdbook-quiz 'mdbook-quiz 0.5.0'
    dot         'graphviz version 16.1.1'
    shellcheck  'version: 0.11.0'
)
readonly TOOL_VERSIONS

fail() { printf '%s\n' "$*" >&2; exit 1; }
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

# Check rustup, the stable toolchain, and every tool in TOOL_VERSIONS.
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
}
