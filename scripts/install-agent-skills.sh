#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

# Tier: core (default) | extended | all
#   core     — layered pipeline packs (default Berd stack)
#   extended — core + selective S-tier additions (hallmark, deep-research, last30days)
#   all      — extended + optional verticals (none bulk-installed by default)
readonly BERD_SKILLS_TIER="${BERD_SKILLS_TIER:-core}"

# Pin skills CLI when skills-lock.json records a version (falls back to latest).
skills_cli_version() {
  if [[ -f "$repo_root/skills-lock.json" ]] && command -v jq >/dev/null 2>&1; then
    local pinned
    pinned="$(jq -r '.skillsCli // empty' "$repo_root/skills-lock.json" 2>/dev/null || true)"
    if [[ -n "$pinned" ]]; then
      echo "$pinned"
      return
    fi
  fi
  echo "latest"
}

readonly SKILLS_CLI="$(skills_cli_version)"
readonly SKILLS_NPX=(npx --yes "skills@${SKILLS_CLI}")

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
  "${SKILLS_NPX[@]}" add "$spec" --skill '*' -a cursor -y --copy "$@"
}

# Install one or more named skills from a pack.
install_skills() {
  local spec="$1"
  shift
  "${SKILLS_NPX[@]}" add "$spec" -a cursor -y --copy "$@"
}

tier_at_least() {
  local want="$1"
  case "$BERD_SKILLS_TIER" in
    core) [[ "$want" == "core" ]] ;;
    extended) [[ "$want" == "core" || "$want" == "extended" ]] ;;
    all) true ;;
    *)
      echo "error: unknown BERD_SKILLS_TIER=$BERD_SKILLS_TIER (use core|extended|all)" >&2
      exit 1
      ;;
  esac
}

# ── CORE tier ────────────────────────────────────────────────────────────────
# Layer: discover → interrogate/spec → plan → implement → review → security → browser QA → ship → learn
install_core_tier() {
  echo "Installing CORE tier (skills@${SKILLS_CLI}) …"

  install_pack shadcn/improve
  install_pack obra/superpowers
  install_pack mattpocock/skills --full-depth
  install_pack garrytan/gstack
  install_pack cursor/plugins --full-depth
  install_pack vercel-labs/agent-skills

  install_pack trailofbits/skills

  install_skills vercel-labs/skills --skill find-skills
  install_skills vercel-labs/agent-browser --skill agent-browser

  install_skills anthropics/skills \
    --skill claude-api \
    --skill doc-coauthoring \
    --skill frontend-design \
    --skill mcp-builder \
    --skill skill-creator \
    --skill web-artifacts-builder \
    --skill webapp-testing

  install_pack github/awesome-copilot

  if ! install_pack EveryInc/compound-engineering-plugin 2>/dev/null; then
    echo "Note: EveryInc/compound-engineering-plugin install failed; use /add-plugin compound-engineering in Cursor."
  fi
}

# ── EXTENDED tier ────────────────────────────────────────────────────────────
# Selective S-tier additions — one skill per pack, project-local only.
install_extended_tier() {
  echo "Installing EXTENDED tier …"

  install_skills nutlope/hallmark --skill hallmark
  install_skills 24601/agent-deep-research --skill deep-research
  install_skills mvanhorn/last30days-skill --skill last30days
}

# ── OPTIONAL tier ────────────────────────────────────────────────────────────
# Documented verticals — install individually, never bulk (context rot).
# Uncomment or run manually when relevant:
#
#   install_skills remotion-dev/skills --skill remotion-best-practices
#   install_skills nvidia/skills --skill <name>   # 343 skills — pick one
#   npx skills add microsoft/skills --list        # armory only
#   npx skills add wshobson/agents --list         # 94 plugins — do NOT bulk install
install_optional_tier() {
  echo "OPTIONAL tier: no bulk installs (see .agents/skills/README.md)."
}

# Optional packs — install manually when relevant (not part of default stack):
#   install_pack supabase/agent-skills
#   install_pack cloudflare/skills
#   install_pack aws/agent-toolkit-for-aws/skills
# Microsoft skills: searchable armory only — do NOT install whole repo (context rot).
#   npx skills@latest add microsoft/skills --list
#   npx skills@latest add microsoft/skills --skill <name> -a cursor -y --copy

echo "BERD_SKILLS_TIER=$BERD_SKILLS_TIER"

if tier_at_least core; then
  install_core_tier
fi

if tier_at_least extended; then
  install_extended_tier
fi

if tier_at_least all; then
  install_optional_tier
fi

restore_protected_skills
remove_gstack_fixtures
remove_junk_dirs

# Skill markdown is copied above; gstack also needs its runtime (bin/, browse, hooks).
"$repo_root/scripts/install-gstack-runtime.sh"

echo "Installed skills:"
ls -1 "$repo_root/.agents/skills" | wc -l
