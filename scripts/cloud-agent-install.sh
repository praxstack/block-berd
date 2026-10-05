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

# llama-cpp-sys / Goose must use GNU g++, not clang-as-c++ (missing <cstdlib>
# when cc-rs passes --target=x86_64-unknown-linux-gnu).
export CC="${CC:-/usr/bin/gcc}"
export CXX="${CXX:-/usr/bin/g++}"

# Required: pnpm workspace, SDK, pinned Goose backend.
just _setup-dev-deps
GOOSE_DEV_MODE=required GOOSE_BUILD_PROFILE=debug ./scripts/ensure-local-goose.sh

# Optional skill runtimes clone GitHub, install bun, and may pull Playwright.
# They must never fail a Cloud Agent snapshot. Bound each attempt so a hang
# cannot burn the install budget.
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
