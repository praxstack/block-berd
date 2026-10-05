#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

# Cloud Agent install/snapshot cannot answer prompts.
export DEBIAN_FRONTEND="${DEBIAN_FRONTEND:-noninteractive}"
export GIT_TERMINAL_PROMPT=0
export CI="${CI:-true}"

# Pin tool versions to the repo's Hermit environment (just, node, pnpm, rust).
source "$repo_root/bin/activate-hermit"
export PATH="$repo_root/bin:$PATH"

# Required snapshot path: Hermit + pnpm workspace + SDK.
# Do not compile Goose here. llama-cpp-sys-2 has failed Cloud image builds
# (clang-as-c++ missing <cstdlib>, rust-lld unable to find -lstdc++).
# Agents that need the sidecar can run `just goose-sync` after boot.
just _setup-dev-deps

# Optional skill runtimes clone GitHub, install bun, and may pull Playwright.
# They must never fail a Cloud Agent snapshot. Bound each attempt so a hang
# cannot burn the 90-minute install budget.
run_optional() {
  local label="$1"
  shift
  echo "optional: starting $label"
  local status=0
  if command -v timeout >/dev/null 2>&1; then
    timeout --kill-after=20s 180 "$@" || status=$?
  else
    "$@" || status=$?
  fi
  if [[ "$status" -ne 0 ]]; then
    echo "warning: optional $label failed (exit $status); continuing cloud snapshot" >&2
    return 0
  fi
  echo "optional: $label ok"
}

run_optional praxstack "$repo_root/scripts/install-praxstack-skills.sh"
run_optional gstack "$repo_root/scripts/install-gstack-runtime.sh" -q
