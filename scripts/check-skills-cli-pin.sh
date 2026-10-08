#!/usr/bin/env bash
# Guardrail: live install helpers must not call skills@latest.
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
script="$repo_root/scripts/install-agent-skills.sh"

if grep -nE '^[^#]*skills@latest' "$script"; then
  echo "error: install-agent-skills.sh still invokes skills@latest" >&2
  exit 1
fi
echo "skills CLI pin: no live skills@latest invocations"
