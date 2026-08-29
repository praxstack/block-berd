#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

# Berd-owned skills that must not be overwritten by upstream packs.
readonly -a PROTECTED_SKILLS=(
  assistive-ux
  berdctl-new-command
  code-review
  create-pr
  experimental-features
)

restore_protected_skills() {
  for skill in "${PROTECTED_SKILLS[@]}"; do
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1 \
      && git cat-file -e "HEAD:.agents/skills/${skill}/SKILL.md" 2>/dev/null; then
      rm -rf "$repo_root/.agents/skills/${skill}"
      git checkout HEAD -- ".agents/skills/${skill}" 2>/dev/null || true
    fi
  done
}

remove_junk_dirs() {
  local d
  for d in \
    .adal .aider-desk .augment .autohand .bob .claude .codeartsdoer .codebuddy \
    .codemaker .codestudio .commandcode .continue .cortex .crush .devin .factory \
    .forge .goose .grok .hermes .iflow .inferencesh .jazz .junie .kilocode .kimchi \
    .kiro .kode .lingma .mcpjam .minimax .vibe .moxby .mux .openhands .ona .pi .posit \
    .qoder .qwen .reasonix .rovodev .roo .tabnine .terramind .tinycloud .trae .windsurf \
    .zcode .zencoder .neovate .pochi agent data; do
    rm -rf "$repo_root/$d"
  done
}

remove_gstack_fixtures() {
  rm -rf \
    "$repo_root/.agents/skills/alpha" \
    "$repo_root/.agents/skills/beta" \
    "$repo_root/.agents/skills/gstack"
  find "$repo_root/.agents/skills" -type d -path '*/test/fixtures/*' -prune -exec rm -rf {} + 2>/dev/null || true
}

# Install all skills from a pack into .agents/skills/ (Cursor only, project-local copy).
install_pack() {
  local spec="$1"
  shift
  npx --yes skills@latest add "$spec" --skill '*' -a cursor -y --copy "$@"
}

# Install one or more named skills from a pack.
install_skills() {
  local spec="$1"
  shift
  npx --yes skills@latest add "$spec" -a cursor -y --copy "$@"
}

# Optional packs — install manually when relevant (not part of default stack):
#   install_pack supabase/agent-skills
#   install_pack cloudflare/skills
#   install_pack aws/agent-toolkit-for-aws/skills
# Microsoft skills: searchable armory only — do NOT install whole repo (context rot).
#   npx skills@latest add microsoft/skills --list
#   npx skills@latest add microsoft/skills --skill <name> -a cursor -y --copy

echo "Installing agent skill packs into .agents/skills/ …"

# Layer: discover → interrogate/spec → plan → implement → review → security → browser QA → ship → learn

# Core workflow packs
install_pack shadcn/improve
install_pack obra/superpowers
install_pack mattpocock/skills --full-depth
install_pack garrytan/gstack
install_pack cursor/plugins --full-depth
install_pack vercel-labs/agent-skills

# Security layer
install_pack trailofbits/skills

# Discovery
install_skills vercel-labs/skills --skill find-skills

# Browser QA
install_skills vercel-labs/agent-browser --skill agent-browser

# Anthropic dev/engineering subset (skip pure creative/doc examples)
install_skills anthropics/skills \
  --skill claude-api \
  --skill doc-coauthoring \
  --skill frontend-design \
  --skill mcp-builder \
  --skill skill-creator \
  --skill web-artifacts-builder \
  --skill webapp-testing

# Toolbox
install_pack github/awesome-copilot

# Compound engineering (learn layer) — plugin install fallback documented in README
if ! install_pack EveryInc/compound-engineering-plugin 2>/dev/null; then
  echo "Note: EveryInc/compound-engineering-plugin install failed; use /add-plugin compound-engineering in Cursor."
fi

restore_protected_skills
remove_gstack_fixtures
remove_junk_dirs

echo "Installed skills:"
ls -1 "$repo_root/.agents/skills" | wc -l
