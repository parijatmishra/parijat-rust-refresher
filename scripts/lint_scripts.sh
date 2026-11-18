#!/usr/bin/env bash
set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/common.sh"

# Lint every shell script in scripts/ (including Git hooks), using .shellcheckrc.
shellcheck -- scripts/*.sh scripts/git-hooks/*
