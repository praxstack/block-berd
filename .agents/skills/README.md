# Agent skill stack (super-pro)

Project-local skills for Cursor and other Agent Skills-compatible agents. Installed into `.agents/skills/` via `scripts/install-agent-skills.sh`.

## Layered pipeline

Agents should move through these layers in order for non-trivial work:

```
discover → interrogate/spec → plan → implement → review → security → browser QA → ship → learn
```

| Layer | Purpose | Primary packs / entry points |
| --- | --- | --- |
| **Discover** | Find the right skill or approach | `find-skills`, `awesome-copilot` toolbox, [skills.sh](https://skills.sh) |
| **Interrogate / spec** | Clarify requirements, write specs | pstack `/interrogate`, mattpocock `/to-spec`, `/triage`, gstack `/spec` |
| **Plan** | Architecture and execution plans | pstack `/poteto-mode`, `/architect`, superpowers `/writing-plans`, shadcn `/improve`, gstack autoplan |
| **Implement** | Build with TDD and discipline | superpowers `/executing-plans`, mattpocock `/implement`, pstack `/tdd` |
| **Review** | Code review before merge | Berd `code-review`, mattpocock `/code-review`, compound `ce-code-review`, superpowers `/requesting-code-review` |
| **Security** | Static analysis, audit prep, vuln scanning | Trail of Bits skills (`audit-context-building`, `secure-workflow-guide`, language scanners) |
| **Browser QA** | Drive the app like a user | `agent-browser` skill + CLI, gstack `/qa`, compound `ce-test-browser` |
| **Ship** | PR, CI, deploy | Berd `create-pr`, gstack `/ship`, compound `ce-commit-push-pr`, cursor-team-kit |
| **Learn** | Capture durable repo learnings | compound `ce-compound`, `ce-compound-refresh`, gstack `/learn`, superpowers `/writing-skills` |

## Core 10 packs

| # | Pack | Source | Role in stack |
| --- | --- | --- | --- |
| 1 | **pstack** | [cursor/plugins/pstack](https://github.com/cursor/plugins/tree/main/pstack) | Engineering workflows: `/poteto-mode`, `/how`, `/why`, `/architect`, `/arena` |
| 2 | **Superpowers** | [obra/superpowers](https://github.com/obra/superpowers) | Spec-driven dev: brainstorm → plan → TDD → review → verify |
| 3 | **Matt Pocock** | [mattpocock/skills](https://github.com/mattpocock/skills) | Teaching, specs, triage, domain modeling, TypeScript patterns |
| 4 | **gstack** | [garrytan/gstack](https://github.com/garrytan/gstack) | Planning, QA, design review, shipping, browser dogfooding |
| 5 | **shadcn/improve** | [shadcn/improve](https://github.com/shadcn/improve) | Audit codebase, write implementation plans, execute/reconcile |
| 6 | **Trail of Bits** | [trailofbits/skills](https://github.com/trailofbits/skills) | Security review, static analysis, audit prep |
| 7 | **agent-browser** | [vercel-labs/agent-browser](https://github.com/vercel-labs/agent-browser) | Browser automation for QA |
| 8 | **Vercel agent-skills** | [vercel-labs/agent-skills](https://github.com/vercel-labs/agent-skills) | React/Next best practices, web design guidelines, deploy helpers |
| 9 | **find-skills** | [vercel-labs/skills](https://github.com/vercel-labs/skills) | Discovery when you need a capability not in the stack |
| 10 | **Compound Engineering** | [EveryInc/compound-engineering-plugin](https://github.com/EveryInc/compound-engineering-plugin) | Learn layer: `ce-compound`, PR workflows, browser test helpers |

Also installed: **Anthropic dev subset** (MCP builder, frontend-design, webapp-testing, etc.) and **awesome-copilot** (417-skill toolbox).

## Install or refresh

```bash
./scripts/install-agent-skills.sh
```

The script uses [`npx skills@latest`](https://github.com/vercel-labs/skills) with `-a cursor -y --copy` (Cursor only, project-local). It restores Berd-owned skills after upstream packs are copied and removes junk agent directories.

Run twice to verify idempotence. Expect ~740 skills after a full install.

## One-time repo setup

Already configured for Berd:

| Setup | Output |
| --- | --- |
| `/setup-matt-pocock-skills` | `docs/agents/issue-tracker.md`, `triage-labels.md`, `domain.md`, `AGENTS.md` block |
| `/setup-pstack` | `~/.cursor/rules/pstack-models.mdc` (per-role model overrides) |

Re-run those skills if you switch issue trackers or change pstack model assignments.

## Entry points (most useful first)

| Command / skill | When to use |
| --- | --- |
| `/poteto-mode` or `/figure-it-out` | Default for non-trivial engineering work (pstack) |
| `find-skills` | Need a capability not in the core stack |
| `/improve` | Full codebase audit → plans in `plans/` |
| `/how` | Understand how a subsystem works before changing it |
| `/why` | Understand motivation and history (uses MCP evidence) |
| `/architect` | Design types/modules before implementation |
| `/systematic-debugging` | Structured root-cause debugging (superpowers) |
| `/writing-plans` + `/executing-plans` | Multi-step work with checkpoints (superpowers) |
| `agent-browser` | Browser QA after implementation |
| `ce-compound` | Capture a solved problem as a durable learning |
| `gstack` router | Route to planning, QA, design, ship, investigate skills |

## Berd-specific skills (do not overwrite)

- `assistive-ux` — accessibility and assistive UX patterns
- `berdctl-new-command` — add berdctl commands
- `code-review` — Berd pre-PR review (not mattpocock's two-axis review)
- `create-pr` — open and watch PRs
- `experimental-features` — experiment registry workflow

## agent-browser CLI

The browser QA layer needs the CLI alongside the skill:

```bash
npm install -g agent-browser
agent-browser install          # downloads Chrome for Testing
agent-browser install --with-deps   # if shared-library errors on Linux
```

## gstack Cursor plugin note

gstack's Cursor native plugin setup may be broken ([gstack#2361](https://github.com/garrytan/gstack/issues/2361)). The project-local skill copy in `.agents/skills/` works in Cloud Agents. For native Claude/Codex integration, prefer gstack's Claude/Codex install path.

## Compound Engineering plugin

Skills are installed via `npx skills`. For Cursor marketplace features, also run:

```text
/add-plugin compound-engineering
```

## Optional packs (not installed by default)

Install manually when relevant:

```bash
npx skills@latest add supabase/agent-skills --skill '*' -a cursor -y --copy
npx skills@latest add cloudflare/skills --skill '*' -a cursor -y --copy
npx skills@latest add aws/agent-toolkit-for-aws/skills --skill '*' -a cursor -y --copy
```

## Searchable armory (do NOT bulk-install)

| Pack | Source | Notes |
| --- | --- | --- |
| **Microsoft skills** | [microsoft/skills](https://github.com/microsoft/skills) | Large repo — context rot risk. Use `npx skills add microsoft/skills --list` and install individual skills only. |
| Vercel skills CLI | [vercel-labs/skills](https://github.com/vercel-labs/skills) | Package manager for all skills |
| Anthropic skills | [anthropics/skills](https://github.com/anthropics/skills) | Dev subset installed; browse for more |
| Supabase | [supabase/agent-skills](https://github.com/supabase/agent-skills) | Postgres/Supabase workflows |
| Cloudflare | [cloudflare/skills](https://github.com/cloudflare/skills) | Workers, edge deployment |
| CodeRabbit | Cursor plugin `code-review` | Available via Cursor marketplace |
| Cursor docs | `/add-plugin cursor-guide` | Cursor product documentation agent |

## Desktop-only plugins

Some packs (pstack, superpowers, compound-engineering) also ship as Cursor marketplace plugins. In Cursor Agent chat:

```text
/add-plugin pstack
/add-plugin superpowers
/add-plugin compound-engineering
```

Project-local copies in `.agents/skills/` work in Cloud Agents and keep skills versioned with the repo.
