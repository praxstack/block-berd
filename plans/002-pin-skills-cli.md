# Plan 002: Pin the skills CLI adapter version in install script

## Design review (APPROVED)

### Senior principal engineer
The lock already records `skillsCli: 1.5.23` and the install script reads it, but still falls back to `@latest` when the field is missing. That fallback reintroduces non-reproducible refreshes. Fail closed unless `SKILLS_CLI_VERSION` is set. Do not touch README (owned by plan 003).

### Principal engineer
Edge cases: empty `skillsCli`, missing jq, explicit override. Env override stays for emergency bumps. Comments that still say `npx skills@latest` must not be live commands.

### Second senior principal engineer
Disagree with pinning a hardcoded `readonly SKILLS_CLI_VERSION` in the script *and* the lock (two sources of truth). Confirm the lock field as the pin, script as the reader, env as the escape hatch. Approve that design.

**Decision:** APPROVED. Fail closed; keep lock as the pin; env override only.

## Status

- **Priority**: P2
- **Effort**: S
- **Risk**: LOW
- **Approved**: 2026-10-05
