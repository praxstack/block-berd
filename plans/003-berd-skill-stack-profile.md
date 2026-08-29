# Plan 003: Add Berd skill-stack profile for agent discovery

> **Executor instructions**: Follow this plan step by step. Run every
> verification command and confirm the expected result before moving to the
> next step. If anything in the "STOP conditions" section occurs, stop and
> report — do not improvise. When done, update the status row for this plan
> in `plans/README.md`.
>
> **Drift check (run first)**: `git diff --stat 7fb24e5..HEAD -- .agents/skills/agent-skill-stack/ .agents/skills/README.md AGENTS.md`
> On mismatch, STOP.

## Status

- **Priority**: P2
- **Effort**: M
- **Risk**: LOW
- **Depends on**: 001 (hashes stable)
- **Category**: direction
- **Planned at**: commit `7fb24e5`, 2026-08-29

## Why this matters

741 vendored skills create context rot: agents see a huge skill list in
`agent_skills` metadata with no ranking. The merged `agent-skill-stack` skill
already defines `.codex/skill-stack.json` profiles and `skill_index.py`, but
Berd does not ship a repo-local profile naming the ~25 entry-point skills from
`.agents/skills/README.md`. A checked-in profile gives locality for discovery
without deleting the armory.

## Current state

- `.agents/skills/README.md` — documents layered pipeline and "Entry points" table
  (poteto-mode, improve, code-review, berdctl-new-command, etc.).
- `.agents/skills/agent-skill-stack/references/local-index-and-profiles.md` —
  describes `skill-stack.json` shape and active skills list.
- `.agents/skills/agent-skill-stack/scripts/skill_index.py` — builds searchable index.
- Berd `AGENTS.md` points to five Berd-owned skills explicitly; does not reference
  a stack profile file.
- No `.codex/skill-stack.json` at repo root today.

## Commands you will need

| Purpose | Command | Expected |
|---------|---------|----------|
| Index build | `python3 .agents/skills/agent-skill-stack/scripts/skill_index.py build --root .agents/skills --output /tmp/berd-skill-index.json` | exit 0, JSON written |
| Check | `just check` | exit 0 |

## Scope

**In scope**:
- `.codex/skill-stack.json` (new — Berd default profile)
- `.agents/skills/README.md` (link to profile)
- `AGENTS.md` (one short paragraph: agents should read skill-stack profile first)
- Optional: `scripts/build-skill-index.sh` thin wrapper

**Out of scope**:
- UI changes to skill picker
- Trimming vendored skills from git
- Modifying agent-skill-stack upstream skill content

## Steps

### Step 1: Author skill-stack.json

Using the entry points table in `.agents/skills/README.md`, list active skills:
Berd-owned five + core workflow skills (improve, poteto-mode, systematic-debugging,
writing-plans, executing-plans, code-review from mattpocock if distinct, etc.).
Mark layers (discover, plan, implement, review, ship). Keep list under 30 skills.

Follow schema from `local-index-and-profiles.md`.

### Step 2: Document usage

Update `.agents/skills/README.md` and `AGENTS.md` to say: for non-trivial work,
consult `.codex/skill-stack.json` before loading arbitrary skills from the armory.

### Step 3: Optional index artifact

If index build is fast (&lt;10s), add `just build-skill-index` and gitignore
`/tmp` output OR commit a generated `skill-index.json` only if team prefers
(check repo policy — default: document manual build, do not commit large JSON).

**Verify**: `test -f .codex/skill-stack.json && python3 -m json.tool .codex/skill-stack.json > /dev/null` → exit 0

## Done criteria

- [ ] `.codex/skill-stack.json` valid JSON with active skills list
- [ ] README + AGENTS.md reference it
- [ ] `just check` exit 0
- [ ] `plans/README.md` updated

## STOP conditions

- Profile schema in references does not match agent-skill-stack version in repo.
- Required entry-point skill missing from `.agents/skills/` tree.

## Maintenance notes

- Update profile when README entry points change.
- Reviewers: profile is product surface for agents — keep Berd-owned skills prominent.
