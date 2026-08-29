#!/usr/bin/env bash
# Resolve and record a new pin for praxstack/skills-and-personas.
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
lock_file="$repo_root/praxstack-skills.lock.json"

ref="${1:-main}"
git_url="$(jq -r '.repo // "https://github.com/praxstack/skills-and-personas.git"' "$lock_file")"

if ! command -v jq >/dev/null 2>&1; then
  echo "error: jq required" >&2
  exit 1
fi

resolved="$(git ls-remote "$git_url" "$ref" | awk 'NR==1 {print $1}')"
if [[ -z "$resolved" ]]; then
  echo "error: could not resolve $ref from $git_url" >&2
  exit 1
fi

tmp="$(mktemp)"
jq --arg ref "$resolved" '.ref = $ref' "$lock_file" > "$tmp"
mv "$tmp" "$lock_file"

echo "Updated $lock_file → ref=$resolved ($ref)"
