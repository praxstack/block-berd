#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

# Pin tool versions to the repo's Hermit environment (just, node, pnpm, rust).
source "$repo_root/bin/activate-hermit"

export PATH="$repo_root/bin:$PATH"
export CI="${CI:-true}"

# Skip git hooks in cloud agents; they are not needed for validation workflows.
just _setup-dev-deps
GOOSE_DEV_MODE=required GOOSE_BUILD_PROFILE=debug ./scripts/ensure-local-goose.sh

# gstack skill markdown lives in .agents/skills/; runtime installs to ~/.claude/skills/gstack.
"$repo_root/scripts/install-gstack-runtime.sh" -q
