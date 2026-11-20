#!/usr/bin/env bash
set -euo pipefail

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
# common.sh normally checks tools and exits on the first failure; load only its lists.
_CHECK_PREREQS_LISTS_ONLY=1 source "$script_dir/common.sh"
cd -- "$script_dir/.."

status=0
ok() { printf '%s: OK\n' "$1"; }
missing() { printf '%s: %s\n' "$1" "$2"; status=1; }

if [[ $(uname -s) == Darwin ]]; then ok macOS; else missing macOS 'required'; fi
if command -v bash >/dev/null 2>&1 && (( BASH_VERSINFO[0] >= 5 )); then
    ok bash
else
    missing bash 'Bash 5 or newer required on PATH'
fi
if command -v brew >/dev/null 2>&1 && brew --version >/dev/null 2>&1; then
    ok brew
else
    missing brew 'not available on PATH'
fi

for tool in mktemp diff chmod; do
    if command -v "$tool" >/dev/null 2>&1; then ok "$tool"; else missing "$tool" 'not on PATH'; fi
done

if command -v rustup >/dev/null 2>&1 && rustup --version >/dev/null 2>&1; then
    ok rustup
else
    missing rustup 'not available on PATH'
fi
active=$(rustup show active-toolchain 2>/dev/null) || active=
for tool in rustc cargo; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        missing "$tool" 'not on PATH'
    elif [[ $active != stable-* ]]; then
        missing "$tool" 'active rustup toolchain is not stable'
    elif ! actual=$("$tool" --version 2>/dev/null) ||
         ! expected=$(rustup run stable "$tool" --version 2>/dev/null) ||
         [[ $actual != "$expected" ]]; then
        missing "$tool" 'not available from the active stable toolchain'
    else
        ok "$tool"
    fi
done

for tool in "${REQUIRED_TOOLS[@]}"; do
    case $tool in rustup|cargo) continue ;; esac
    if command -v "$tool" >/dev/null 2>&1; then ok "$tool"; else missing "$tool" 'not on PATH'; fi
done
for (( i = 0; i < ${#TOOL_VERSIONS[@]}; i += 2 )); do
    tool=${TOOL_VERSIONS[i]} expected=${TOOL_VERSIONS[i + 1]}
    if ! command -v "$tool" >/dev/null 2>&1; then
        missing "$tool" 'not on PATH'
    elif ! actual=$("$tool" --version 2>&1); then
        missing "$tool" 'cannot run --version'
    elif [[ " ${actual//[[:space:]]/ } " != *" $expected "* ]]; then
        missing "$tool" "expected $expected"
    else
        ok "$tool"
    fi
done
exit "$status"
