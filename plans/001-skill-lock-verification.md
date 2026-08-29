# Plan 001: Wire skills-lock.json into install and CI verification

> **Executor instructions**: Follow this plan step by step. Run every
> verification command and confirm the expected result before moving to the
> next step. If anything in the "STOP conditions" section occurs, stop and
> report — do not improvise. When done, update the status row for this plan
> in `plans/README.md`.
>
> **Drift check (run first)**: `git diff --stat 7fb24e5..HEAD -- scripts/install-agent-skills.sh skills-lock.json .github/ justfile`
> If any in-scope file changed since this plan was written, compare the
> "Current state" excerpts against the live code before proceeding; on a
> mismatch, treat it as a STOP condition.

## Status

- **Priority**: P1
- **Effort**: M
- **Risk**: LOW
- **Depends on**: none
- **Category**: dx
- **Planned at**: commit `7fb24e5`, 2026-08-29

## Why this matters

PR #3 vendored ~741 skills and added `skills-lock.json` with per-skill
`computedHash` values, but `scripts/install-agent-skills.sh` never reads the
lock file. A refresh install can silently change skill content while the lock
stays stale, or the lock can drift from the tree with no CI signal. A single
verify seam gives agents and CI the same truth about whether `.agents/skills/`
matches the recorded hashes.

## Current state

- `scripts/install-agent-skills.sh` — installs packs via `npx skills@latest`,
  restores five protected Berd skills, removes junk dirs. No lock interaction.
- `skills-lock.json` — version 1 manifest mapping display names to
  `source`, `skillPath`, and `computedHash` for each installed skill.
- Protected skills (must survive refresh): `assistive-ux`, `berdctl-new-command`,
  `code-review`, `create-pr`, `experimental-features` (see script lines 8–14).
- CI entry points: `just ci` runs frontend + Rust gates; no skill lock check today.
- Exemplar for shell scripts: `scripts/install-agent-skills.sh` itself uses
  `set -euo pipefail` and `readonly` arrays.

Relevant excerpt from `scripts/install-agent-skills.sh`:

```bash
install_pack() {
  local spec="$1"
  shift
  npx --yes skills@latest add "$spec" --skill '*' -a cursor -y --copy "$@"
}
# ... installs run, then restore_protected_skills, no lock verification
```

## Commands you will need

| Purpose   | Command                  | Expected on success |
|-----------|--------------------------|---------------------|
| Format    | `just fmt`               | exit 0              |
| CI subset | `just check`             | exit 0              |
| Script syntax | `bash -n scripts/install-agent-skills.sh` | exit 0 |

## Scope

**In scope**:
- `scripts/install-agent-skills.sh` (add verify mode + post-install verify)
- `scripts/verify-skills-lock.sh` (new, or inline function — prefer small dedicated script if >40 lines)
- `justfile` (add `just verify-skills-lock` target)
- `.github/workflows/` CI workflow that runs the verify target (match existing workflow style)

**Out of scope**:
- Changing skill content under `.agents/skills/`
- Pinning `npx skills` version (plan 002)
- Building a skill index (plan 003)

## Git workflow

- Branch: `prax/skill-lock-verify-533e`
- Commit style: imperative sentence, e.g. `Add skills-lock verification to install script`

## Steps

### Step 1: Implement hash verification

Add a verifier that, for each entry in `skills-lock.json`, resolves the
on-disk `SKILL.md` under `.agents/skills/<skill-dir>/` (derive directory from
`skillPath` basename or maintain a slug map — read the lock schema first) and
compares SHA-256 of file contents to `computedHash`.

Handle protected Berd skills: they must still be present and hashed if listed
in the lock.

**Verify**: `bash -n scripts/verify-skills-lock.sh` → exit 0

### Step 2: Add `--verify` / `verify` mode to install script

After `restore_protected_skills` and cleanup, call the verifier. Exit non-zero
on mismatch with a concise diff report (skill name, expected hash, actual hash).

Support standalone: `./scripts/install-agent-skills.sh --verify-only` or
`just verify-skills-lock` without reinstalling.

**Verify**: `just verify-skills-lock` → exit 0 on current main tree

### Step 3: Wire CI

Add the verify target to the existing CI workflow (read
`.github/workflows/` for the pattern used by `just check`).

**Verify**: workflow file passes `yamllint` / review; locally
`just verify-skills-lock` still exit 0

## Test plan

- Add a small shell test or document a manual regression: temporarily corrupt one
  `computedHash` in a copy, confirm verifier exits 1.
- No Vitest required unless you add a Node helper; prefer bash + `jq` + `sha256sum`
  to match repo tooling (`jq` is in `.cursor/Dockerfile`).

## Done criteria

- [ ] `just verify-skills-lock` exits 0 on clean tree at commit after changes
- [ ] `just check` exits 0
- [ ] CI workflow includes verify step
- [ ] `plans/README.md` status row updated

## STOP conditions

- `skills-lock.json` schema differs materially from assumptions (e.g. no `computedHash`).
- More than 10% of lock entries cannot be resolved to on-disk paths without schema change.
- Verification requires modifying skill file contents.

## Maintenance notes

- Re-run `skills-lock.json` regeneration when running `./scripts/install-agent-skills.sh`
  for refresh; document the update flow in `.agents/skills/README.md` (one paragraph).
- Reviewers: ensure verify is read-only and fast enough for CI (&lt;60s).
