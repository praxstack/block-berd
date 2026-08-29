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

## gstack — two-part install

gstack is **not** just skill markdown. Skills like `/plan-ceo-review` call runtime helpers under `~/.claude/skills/gstack/bin/` (`gstack-skill-start`, telemetry, browse, QA browser, etc.). Copying SKILL.md files alone leaves skills in **degraded mode**.

| Layer | Location | What it provides |
| --- | --- | --- |
| Skill markdown | `.agents/skills/plan-ceo-review/` etc. | Workflow instructions (installed by `install-agent-skills.sh`) |
| Runtime | `~/.claude/skills/gstack/` | Bin scripts, browse binary, Playwright, Cursor skill links |

Install or refresh both:

```bash
./scripts/install-agent-skills.sh   # markdown + runtime (calls install-gstack-runtime.sh at the end)
# or runtime only:
./scripts/install-gstack-runtime.sh
```

After native setup, Cursor also links skills under `~/.cursor/skills/gstack-*`. Invoke with `/plan-ceo-review`, `/office-hours`, `/ship`, `/qa`, etc. (or attach the skill in Agent chat).

**Key gstack skills in `.agents/skills/`:**

| Skill | Slash / trigger | Role |
| --- | --- | --- |
| `plan-ceo-review` | `/plan-ceo-review` | Founder-mode plan review (scope modes, failure maps) |
| `plan-devex-review` | `/plan-devex-review` | DevEx / DX plan review |
| `plan-eng-review` | `/plan-eng-review` | Engineering plan review |
| `plan-design-review` | `/plan-design-review` | Design plan review |
| `office-hours` | `/office-hours` | Problem framing and design doc |
| `ship` | `/ship` | PR, CI, merge workflow |
| `qa` | `/qa` | Browser QA dogfooding |
| `gstack-upgrade` | `/gstack-upgrade` | Update gstack runtime |

The `gstack` router skill is intentionally **not** vendored here (`install-agent-skills.sh` removes upstream test fixtures including `.agents/skills/gstack`). Use the skills above directly or the `~/.cursor/skills/gstack` router after runtime install.

**Verify runtime:**

```bash
~/.claude/skills/gstack/bin/gstack-skill-start --skill plan-ceo-review --model claude --parent-pid $$
```

You should see `SKILL_START_PROTO: 1` (not `SKILL_START: unavailable`). If missing, run `./scripts/install-gstack-runtime.sh`.

`./setup --host cursor` is supported in current gstack (clones into `~/.claude/skills/gstack`, links Cursor skills under `~/.cursor/skills/`).

Cloud Agent environments run `install-gstack-runtime.sh` during `cloud-agent-install.sh`. Re-save the environment after merging so new pods get the runtime.

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
