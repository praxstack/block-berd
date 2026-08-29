# Plan 002: Pin the skills CLI adapter version in install script

> **Executor instructions**: Follow this plan step by step. Run every
> verification command and confirm the expected result before moving to the
> next step. If anything in the "STOP conditions" section occurs, stop and
> report — do not improvise. When done, update the status row for this plan
> in `plans/README.md`.
>
> **Drift check (run first)**: `git diff --stat 7fb24e5..HEAD -- scripts/install-agent-skills.sh`
> If any in-scope file changed since this plan was written, compare excerpts
> against live code; on mismatch, STOP.

## Status

- **Priority**: P2
- **Effort**: S
- **Risk**: LOW
- **Depends on**: none (complements 001)
- **Category**: dx
- **Planned at**: commit `7fb24e5`, 2026-08-29

## Why this matters

`npx skills@latest` makes every refresh non-reproducible: upstream CLI changes
can alter copy behavior, flags, or directory layout. Pinning the adapter version
turns the install module into a stable seam; combined with `skills-lock.json`
(plan 001), refresh becomes predictable.

## Current state

`scripts/install-agent-skills.sh` calls `npx --yes skills@latest` in
`install_pack` and `install_skills` (lines 51–58).

## Commands you will need

| Purpose | Command | Expected |
|---------|---------|----------|
| Install test | `./scripts/install-agent-skills.sh --verify-only` (after 001) or dry-run doc | documented |
| Format | `just fmt` | exit 0 |

## Scope

**In scope**:
- `scripts/install-agent-skills.sh`
- `.agents/skills/README.md` (document pinned version and bump process)

**Out of scope**:
- Re-installing all skills
- Changing lock hashes

## Steps

### Step 1: Determine current working version

Run `npx skills@latest --version` once in a controlled environment; record the
semver in a `readonly SKILLS_CLI_VERSION=...` at the top of the install script.

Replace `@latest` with `@${SKILLS_CLI_VERSION}` in both install helpers.

### Step 2: Document bump process

In `.agents/skills/README.md` "Install or refresh" section, add: pin lives in
install script; bump requires re-run install + regenerate `skills-lock.json`
(document how lock is produced if a script exists, or add a note to run
install twice and commit diff).

**Verify**: `grep -n 'skills@latest' scripts/install-agent-skills.sh` → no matches

## Done criteria

- [ ] No `skills@latest` in install script
- [ ] README documents version pin
- [ ] `plans/README.md` updated

## STOP conditions

- Pinned version cannot install existing pack specs (flag incompatibility).
- Upstream requires `@latest` for security patch — document and escalate.

## Maintenance notes

- Bump `SKILLS_CLI_VERSION` deliberately when adopting new skills CLI features.
