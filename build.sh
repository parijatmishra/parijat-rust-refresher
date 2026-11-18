#!/usr/bin/env bash
set -euo pipefail
CDPATH='' cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

fail() { printf '%s\n' "$*" >&2; exit 1; }
mode=${1-build}
case "$#:$mode" in
    0:build|1:check|1:update-output) ;;
    *) fail 'Usage: build.sh [check|update-output]' ;;
esac

command -v rustup >/dev/null || fail 'Install rustup from https://rustup.rs/ and add it to PATH.'
export RUSTUP_TOOLCHAIN=stable RUSTUP_AUTO_INSTALL=0 CARGO_NET_OFFLINE=true
rustup run stable true || fail 'Install stable: rustup toolchain install stable --profile minimal'
# Some subprocesses call rustc/rustdoc by name, not through a rustup proxy.
compiler=$(rustup which --toolchain stable rustc) || fail 'Install stable: rustup toolchain install stable --profile minimal'
export PATH="${compiler%/*}:$PATH"

require_version() {
    local tool=$1 expected=$2 hint=$3 actual
    command -v "$tool" >/dev/null || fail "Missing $tool. $hint"
    actual=$("$tool" --version) || fail "Cannot run $tool. $hint"
    [[ $actual == "$expected" ]] || fail "Expected $expected; found $actual. $hint"
}
if [[ $mode != update-output ]]; then
    require_version mdbook 'mdbook v0.5.4' 'Run: cargo +stable install mdbook --version 0.5.4 --locked'
    require_version mdbook-quiz 'mdbook-quiz 0.5.0' 'Put the v0.5.0 bare binary for your platform on PATH (see README.md).'
fi

case $mode in
    build) exec mdbook build ;;
    check) mdbook test ;;
esac

demo=examples/ownership-demo
fixture=$demo/output.txt
tmp=$(mktemp "$demo/.output.XXXXXXXX")
trap 'rm -f -- "$tmp"' EXIT
trap 'exit 129' HUP
trap 'exit 130' INT
trap 'exit 143' TERM
cargo run --locked --quiet --manifest-path "$demo/Cargo.toml" > "$tmp"
if [[ $mode == check ]]; then
    diff -u "$fixture" "$tmp"
else
    mv -f -- "$tmp" "$fixture"
fi
