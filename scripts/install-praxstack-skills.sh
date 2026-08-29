#!/usr/bin/env bash
# Install PraxStack skills-and-personas into Berd (project-local).
# Skills → .agents/skills/
# Personas → docs/agents/personas/praxstack/
# Workflows / goals prompts → docs/agents/workflows/praxstack/
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

readonly LOCK_FILE="$repo_root/praxstack-skills.lock.json"
readonly CACHE_DIR="${PRAXSTACK_SKILLS_CACHE:-$repo_root/.cache/praxstack-skills-and-personas}"

# Berd-owned skills that must not be overwritten.
readonly -a PROTECTED_SKILLS=(
  assistive-ux
  berdctl-new-command
  code-review
  create-pr
  experimental-features
)

is_protected() {
  local name="$1"
  local s
  for s in "${PROTECTED_SKILLS[@]}"; do
    [[ "$s" == "$name" ]] && return 0
  done
  return 1
}

require_jq() {
  if ! command -v jq >/dev/null 2>&1; then
    echo "error: jq is required to read $LOCK_FILE" >&2
    exit 1
  fi
}

lock_field() {
  local field="$1"
  require_jq
  jq -r ".$field // empty" "$LOCK_FILE"
}

fetch_repo() {
  local git_url ref
  git_url="$(lock_field repo)"
  ref="$(lock_field ref)"

  if [[ -z "$git_url" || -z "$ref" ]]; then
    echo "error: praxstack-skills.lock.json must set repo and ref" >&2
    exit 1
  fi

  mkdir -p "$(dirname "$CACHE_DIR")"

  if [[ -d "$CACHE_DIR/.git" ]]; then
    echo "Updating PraxStack cache at $CACHE_DIR …"
    git -C "$CACHE_DIR" fetch --depth 1 origin "$ref" 2>/dev/null \
      || git -C "$CACHE_DIR" fetch --depth 1 origin
    git -C "$CACHE_DIR" checkout -f FETCH_HEAD 2>/dev/null \
      || git -C "$CACHE_DIR" checkout -f "$ref" 2>/dev/null \
      || true
    if ! git -C "$CACHE_DIR" rev-parse --verify -q "$ref^{commit}" >/dev/null 2>&1; then
      rm -rf "$CACHE_DIR"
    fi
  fi

  if [[ ! -d "$CACHE_DIR/.git" ]]; then
    echo "Cloning $git_url @ $ref …"
    git clone --depth 1 --branch "$ref" "$git_url" "$CACHE_DIR" 2>/dev/null \
      || git clone --depth 1 "$git_url" "$CACHE_DIR"
    if ! git -C "$CACHE_DIR" rev-parse --verify -q "$ref^{commit}" >/dev/null 2>&1; then
      git -C "$CACHE_DIR" fetch --depth 1 origin "$ref"
      git -C "$CACHE_DIR" checkout -f FETCH_HEAD
    else
      git -C "$CACHE_DIR" checkout -f "$ref"
    fi
  fi

  local actual
  actual="$(git -C "$CACHE_DIR" rev-parse HEAD)"
  echo "PraxStack skills-and-personas @ ${actual:0:12}"
}

copy_skill_dir() {
  local src="$1"
  local name
  name="$(basename "$src")"

  [[ "$name" == _* ]] && return 0
  [[ "$name" == .* ]] && return 0
  [[ ! -f "$src/SKILL.md" ]] && return 0

  if is_protected "$name"; then
    echo "  skip (protected): $name"
    return 0
  fi

  rm -rf "$repo_root/.agents/skills/$name"
  cp -R "$src" "$repo_root/.agents/skills/$name"
  echo "  skill: $name"
}

install_canonical_skills() {
  local skills_dir rel
  rel="$(lock_field canonicalSkillsDir)"
  skills_dir="$CACHE_DIR/${rel:-new-skills}"

  if [[ ! -d "$skills_dir" ]]; then
    echo "error: canonical skills dir not found: $skills_dir" >&2
    exit 1
  fi

  echo "Installing PraxStack canonical skills from $rel/ …"
  local src_dir
  for src_dir in "$skills_dir"/*/; do
    [[ -d "$src_dir" ]] || continue
    copy_skill_dir "$src_dir"
  done
}

install_additional_skills() {
  require_jq
  local names=()
  mapfile -t names < <(jq -r '.additionalSkills[]? // empty' "$LOCK_FILE")

  if [[ ${#names[@]} -eq 0 ]]; then
    return 0
  fi

  echo "Installing additional public PraxStack skills …"
  local name src
  for name in "${names[@]}"; do
    src="$CACHE_DIR/skills/$name"
    if [[ ! -d "$src" ]]; then
      echo "  warn: missing skills/$name" >&2
      continue
    fi
    copy_skill_dir "$src"
  done
}

copy_tree() {
  local src="$1"
  local dest="$2"
  rm -rf "$dest"
  mkdir -p "$dest"
  cp -R "$src"/. "$dest/"
}

install_personas() {
  local personas_src="$CACHE_DIR/$(lock_field personasDir)"
  local md_src="$CACHE_DIR/$(lock_field mdPersonasDir)"
  local dest="$repo_root/docs/agents/personas/praxstack"
  local md_dest="$repo_root/docs/agents/personas/md"

  if [[ -d "$personas_src" ]]; then
    echo "Installing personas → docs/agents/personas/praxstack/ …"
    copy_tree "$personas_src" "$dest"
  fi

  if [[ -d "$md_src" ]]; then
    echo "Installing md-personas → docs/agents/personas/md/ …"
    copy_tree "$md_src" "$md_dest"
  fi
}

install_workflows() {
  require_jq
  local dest="$repo_root/docs/agents/workflows/praxstack"
  mkdir -p "$dest"

  echo "Installing workflow / goals prompts → docs/agents/workflows/praxstack/ …"
  local rel target_name
  while IFS= read -r rel; do
    [[ -n "$rel" ]] || continue
    target_name="$(basename "$rel")"
    if [[ -d "$CACHE_DIR/$rel" ]]; then
      copy_tree "$CACHE_DIR/$rel" "$dest/$target_name"
    else
      echo "  warn: missing workflow path $rel" >&2
    fi
  done < <(jq -r '.workflows[]? // empty' "$LOCK_FILE")
}

write_manifest() {
  local manifest="$repo_root/docs/agents/praxstack-manifest.json"
  require_jq
  jq -n \
    --arg ref "$(git -C "$CACHE_DIR" rev-parse HEAD)" \
    --arg installedAt "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
    --arg lock "$LOCK_FILE" \
  '{
    source: "praxstack/skills-and-personas",
    lockFile: $lock,
    ref: $ref,
    installedAt: $installedAt,
    skillsDir: ".agents/skills/",
    personasDir: "docs/agents/personas/praxstack/",
    mdPersonasDir: "docs/agents/personas/md/",
    workflowsDir: "docs/agents/workflows/praxstack/",
    goalsDoc: "docs/agents/goals.md"
  }' > "$manifest"
  echo "Wrote $manifest"
}

main() {
  if [[ ! -f "$LOCK_FILE" ]]; then
    echo "error: missing $LOCK_FILE" >&2
    exit 1
  fi

  fetch_repo
  install_canonical_skills
  install_additional_skills
  install_personas
  install_workflows
  write_manifest

  local count
  count="$(find "$repo_root/.agents/skills" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')"
  echo "PraxStack layer complete. Total skills in .agents/skills/: $count"
}

main "$@"
