#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${repo_root}"

sudo nixos-rebuild switch --flake "path:${repo_root}#pc" "$@"
