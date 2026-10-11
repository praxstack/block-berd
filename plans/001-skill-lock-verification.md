# Plan 001: Wire skills-lock.json into install and CI verification

## Design review (APPROVED)

### Senior principal engineer
Approve a read-only verifier plus `--update` for lock catch-up. Do not reinstall skills. Map lock keys to `.agents/skills/<dir>/SKILL.md` with fallbacks for display-name keys. Skip known-removed fixture entries (`alpha`, `beta`, `gstack`) that the install script already deletes. Fail CI on hash mismatch of present skills.

### Principal engineer
Threats: hashing the wrong path (false green), missing skills silently ignored, `--update` rewriting unrelated JSON fields. Mitigations: resolve by lock key then `skillPath` parent; preserve `version`/`skillsCli`/metadata; report missing vs mismatch separately; missing rate of fixtures is ~1% (under the 10% STOP).

### Second senior principal engineer
Independent confirm: current tree has 0 matching hashes (stale lock) and 8 unresolved paths. Updating hashes is required for a green verifier; that is lock maintenance, not skill-content mutation. Approve.

**Decision:** APPROVED. Implement `scripts/verify-skills-lock.sh`, `just verify-skills-lock`, `--verify-only` on the install script, CI step, refresh `computedHash` values.

## Status

- **Priority**: P1
- **Effort**: M
- **Risk**: LOW
- **Depends on**: none
- **Category**: dx
- **Planned at**: commit `7fb24e5`, 2026-08-29
- **Approved**: 2026-10-05 (overnight program lead, three-reviewer loop)
