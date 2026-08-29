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
    .zcode .zencoder .neovate .pochi agent data skills; do
    rm -rf "$repo_root/$d"
  done
}

remove_gstack_fixtures() {
  rm -rf "$repo_root/.agents/skills/alpha" "$repo_root/.agents/skills/beta"
}

install_pack() {
  local spec="$1"
  shift
  npx --yes skills add "$spec" --all -y --copy -a cursor "$@"
}

echo "Installing agent skill packs into .agents/skills/ …"

install_pack shadcn/improve
install_pack obra/superpowers
install_pack mattpocock/skills --full-depth
install_pack garrytan/gstack --full-depth
install_pack cursor/plugins --full-depth
install_pack vercel-labs/agent-skills

restore_protected_skills
remove_gstack_fixtures
remove_junk_dirs

echo "Installed skills:"
ls -1 "$repo_root/.agents/skills" | wc -l
