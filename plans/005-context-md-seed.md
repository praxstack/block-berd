# Plan 005: Seed CONTEXT.md with Berd domain vocabulary

> **Executor instructions**: Follow this plan step by step. Run every
> verification command and confirm the expected result before moving to the
> next step. If anything in the "STOP conditions" section occurs, stop and
> report — do not improvise. When done, update the status row for this plan
> in `plans/README.md`.
>
> **Drift check (run first)**: `git diff --stat 7fb24e5..HEAD -- CONTEXT.md docs/agents/domain.md LAWS/`
> On mismatch, STOP.

## Status

- **Priority**: P3
- **Effort**: S
- **Risk**: LOW
- **Depends on**: none
- **Category**: docs
- **Planned at**: commit `7fb24e5`, 2026-08-29

## Why this matters

`docs/agents/domain.md` (added in PR #3) tells skills to read `CONTEXT.md` and
`docs/adr/`, but neither exists at repo root. The super-pro skill stack
(improve, architect, domain-modeling) works better with shared vocabulary for
Session, Project, Harness, Agent, Skill, berdctl, and Goose backend. A minimal
glossary reduces synonym drift in agent output.

## Current state

- `docs/agents/domain.md` — references `CONTEXT.md`, `docs/adr/`; says proceed
  silently if missing.
- `LAWS/README.md` — product behavior laws; not a domain glossary.
- `docs/berdctl-architecture.md` — defines berdctl layers.
- `AGENTS.md` — layout and conventions.
- No `CONTEXT.md`, no `docs/adr/`.

## Commands you will need

| Purpose | Command | Expected |
|---------|---------|----------|
| Lint docs | `just check` (i18n/typecheck unaffected) | exit 0 |
| Link check | manual read of cross-references | consistent |

## Scope

**In scope**:
- `CONTEXT.md` (new, repo root)
- `docs/adr/0001-skill-stack-vendoring.md` (new — record decision to vendor skills)
- `docs/agents/domain.md` (optional: note CONTEXT now exists)

**Out of scope**:
- LAWS changes
- Full ADR backlog
- Source code

## Steps

### Step 1: Draft CONTEXT.md

Include sections (keep under 120 lines):

- **Purpose** — glossary for agents and contributors
- **Core entities** — Session, Project, Agent, Harness, Skill (app vs project vs global sources per `src/features/skills/api/skills.ts` `SkillSourceKind`)
- **Control plane** — berdctl (CLI → broker → renderer registry)
- **Backend** — Goose sidecar (`goosed`), ACP as agent loop interface
- **Terms to avoid** — e.g. don't call berdctl commands "API endpoints"
- **Pointers** — `LAWS/`, `docs/berdctl-architecture.md`, `.agents/skills/README.md`

Use vocabulary from existing docs; do not invent new product behavior.

### Step 2: ADR for skill stack

`docs/adr/0001-skill-stack-vendoring.md`: context (Cloud Agents need skills in repo),
decision (vendor ~741 skills + skills-lock.json), consequences (repo size, refresh via install script).

### Step 3: Cross-link

Ensure `docs/agents/domain.md` example tree matches reality (remove fictional ADR examples or label as illustrative).

**Verify**: `test -f CONTEXT.md && test -f docs/adr/0001-skill-stack-vendoring.md` → exit 0

## Done criteria

- [ ] `CONTEXT.md` exists with core terms
- [ ] At least one ADR under `docs/adr/`
- [ ] `plans/README.md` updated

## STOP conditions

- Drafting CONTEXT.md requires resolving unsettled product disputes — stop and list questions.
- LAWS conflict with proposed terms — escalate, do not override laws in CONTEXT.

## Maintenance notes

- `/domain-modeling` and improve-architecture skills should update CONTEXT lazily.
- Reviewers: CONTEXT describes vocabulary, not normative product law (that's LAWS/).
