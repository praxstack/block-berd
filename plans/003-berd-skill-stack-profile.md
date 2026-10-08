# Plan 003: Add Berd skill-stack profile for agent discovery

## Design review (APPROVED)

### Senior principal engineer
Ship a small `.codex/skill-stack.json` naming Berd-owned skills plus the layered-pipeline entry points already in `.agents/skills/README.md`. Do not vendor an index JSON. Do not trim the armory.

### Principal engineer
Schema: name, profile-first, allow search outside, activeSkills, layer routes. Only list skills that exist on disk. AGENTS.md gets one paragraph pointing at the profile.

### Second senior principal engineer
Confirm: profile is discovery metadata, not a runtime permission boundary. Evidence: agent-skill-stack `local-index-and-profiles.md`. Approve.

**Decision:** APPROVED.

## Status

- **Priority**: P2
- **Approved**: 2026-10-05
