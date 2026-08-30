# Agent goals and workflow alignment

Berd agents should align on **what** to build before **how**. PraxStack workflow material from [skills-and-personas](https://github.com/praxstack/skills-and-personas) is vendored as prompts (not duplicate skill bodies).

## Goals layer (when to use)

| Situation | Entry point | Location |
| --- | --- | --- |
| Reconnect after a long break; verify shared understanding | **Align** | `docs/agents/workflows/praxstack/project-alignment/ALIGN-ONLY.md` |
| New machine / fresh clone; install packs + align + QA report | **Align + install + QA** | `docs/agents/workflows/praxstack/project-alignment/ALIGN-INSTALL-QA.md` |
| Install named packs only (gstack, Superpowers, Matt Pocock, OpenSpec, deep-research) | **Install skills** | `docs/agents/workflows/praxstack/project-alignment/INSTALL-SKILLS.md` |
| Steady engineering loop (spec → plan → build → review → ship) | **High-end operator** | `docs/agents/workflows/praxstack/high-end-operator/README.md` |

These prompts **invoke** installed skills by name. They do not replace Berd's core stack in `.agents/skills/README.md`.

## Steady-state loop

For day-to-day Berd work, prefer the layered pipeline in `.agents/skills/README.md`:

```
discover → interrogate/spec → plan → implement → review → security → browser QA → ship → learn
```

Use PraxStack **goals / alignment** prompts when:

- You no longer trust that agent and human want the same thing
- A new contributor or cloud agent needs project reconstruction
- You need constellation-team role routing (`kingmode`, `constellation-team`, `product-manager`, etc.)

## PraxStack skills (canonical for these workflows)

Installed by `./scripts/install-praxstack-skills.sh` into `.agents/skills/`:

| Category | Examples | Slash / trigger |
| --- | --- | --- |
| Orchestration | `kingmode`, `super-mode-core`, `ultrathink-frontend`, `constellation-team` | Mode keywords or skill name |
| Engineering roles | `principal-engineer`, `backend-pe`, `frontend-pe`, `qa-security-engineer`, `devops-sre-engineer` | Skill name |
| Document production | `blueprint-creator`, `spec-creator`, `transcript-pipeline` | Skill name |
| Learning | `teach-pro-max`, `techtutor`, `lecture-alchemist`, `gabriel-petersson-topdown-mentor` | `/teach-pro-max`, etc. |
| Leadership | `coding-agent-leadership-principles`, `cross-agent-handoff`, `superimprove` | Skill name |

Full inventory: run the installer, then `ls .agents/skills/ | grep -E 'kingmode|constellation|teach-pro'`.

## Personas (reference material)

Persona packs live under `docs/agents/personas/praxstack/` (multi-file) and `docs/agents/personas/md/` (single-file). They are **source material** for skills — not Cursor rules. Do not copy persona bodies into `.cursor/rules/`; use the distilled skills in `.agents/skills/` instead.

## Pin and refresh

```bash
./scripts/install-praxstack-skills.sh
# or with the full Berd stack (extended tier includes PraxStack):
BERD_SKILLS_TIER=extended ./scripts/install-agent-skills.sh
```

Commit pin: `praxstack-skills.lock.json` → `ref` field. Bump with:

```bash
./scripts/update-praxstack-skills-lock.sh <commit-sha-or-tag>
```

Manifest after install: `docs/agents/praxstack-manifest.json`.
