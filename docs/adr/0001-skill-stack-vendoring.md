# ADR 0001: Vendor the agent skill stack for Cloud Agents

## Status

Accepted (recorded after PR #3, 2026-08-29)

## Context

Cloud Agents and other checkouts need the same Agent Skills without a network install of ~740 packs on every boot. `npx skills@latest add …` is not reproducible and is too slow for environment setup.

## Decision

Vendor project-local copies under `.agents/skills/` and record hashes plus the skills CLI version in `skills-lock.json`. Refresh with `./scripts/install-agent-skills.sh`. Berd-owned skills (`assistive-ux`, `berdctl-new-command`, `code-review`, `create-pr`, `experimental-features`) are restored after each refresh so upstream packs cannot overwrite them.

Do **not** treat the lock as permission to bulk-commit generated PraxStack persona trees; those install outputs stay gitignored.

## Consequences

- The Git tree is large; refreshes rewrite many files.
- Discovery needs a profile (`.codex/skill-stack.json`) so agents do not load the whole armory.
- Hash verification (`just verify-skills-lock`) is the CI signal that the lock still matches on-disk `SKILL.md` files.
