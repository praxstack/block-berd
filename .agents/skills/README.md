# Agent skill stack

Project-local skills for Cursor and other Agent Skills-compatible agents. Installed into `.agents/skills/` via `scripts/install-agent-skills.sh`.

## Install or refresh

```bash
./scripts/install-agent-skills.sh
```

The script uses [`npx skills`](https://github.com/vercel-labs/skills) and restores Berd-owned skills (`assistive-ux`, `berdctl-new-command`, `code-review`, `create-pr`, `experimental-features`) after upstream packs are copied.

## Packs included

| Pack | Source | Primary use |
| --- | --- | --- |
| **improve** | [shadcn/improve](https://github.com/shadcn/improve) | Audit codebase, write implementation plans, execute/reconcile |
| **superpowers** | [obra/superpowers](https://github.com/obra/superpowers) | Spec-driven dev: brainstorm → plan → TDD → review → verify |
| **pstack** | [cursor/plugins/pstack](https://github.com/cursor/plugins/tree/main/pstack) | Engineering team workflows: `/poteto-mode`, `/how`, `/why`, `/architect`, `/arena` |
| **mattpocock** | [mattpocock/skills](https://github.com/mattpocock/skills) | Teaching, specs, triage, domain modeling, TypeScript patterns |
| **gstack** | [garrytan/gstack](https://github.com/garrytan/gstack) | Planning, QA, design review, shipping, browser dogfooding |
| **vercel** | [vercel-labs/agent-skills](https://github.com/vercel-labs/agent-skills) | React/Next best practices, web design guidelines, deploy helpers |

## Entry points (most useful first)

| Command / skill | When to use |
| --- | --- |
| `/poteto-mode` or `/figure-it-out` | Default for non-trivial engineering work (pstack) |
| `/improve` | Full codebase audit → plans in `plans/` |
| `/how` | Understand how a subsystem works before changing it |
| `/why` | Understand motivation and history (uses MCP evidence) |
| `/architect` | Design types/modules before implementation |
| `/systematic-debugging` | Structured root-cause debugging (superpowers) |
| `/writing-plans` + `/executing-plans` | Multi-step work with checkpoints (superpowers) |
| `/setup-pstack` | Configure per-role models for pstack subagents |
| `/setup-matt-pocock-skills` | One-time repo config for mattpocock code-review skills |
| `gstack` router | Route to planning, QA, design, ship, investigate skills |

## Berd-specific skills (do not overwrite)

- `assistive-ux` — accessibility and assistive UX patterns
- `berdctl-new-command` — add berdctl commands
- `code-review` — Berd pre-PR review (not mattpocock's two-axis review)
- `create-pr` — open and watch PRs
- `experimental-features` — experiment registry workflow

## Other credible packs to consider

Browse [skills.sh](https://skills.sh) or install ad hoc:

```bash
npx skills add <owner/repo> --list          # preview
npx skills add <owner/repo> --skill <name> -a cursor -y --copy
```

| Pack | Source | Notes |
| --- | --- | --- |
| Vercel skills CLI | [vercel-labs/skills](https://github.com/vercel-labs/skills) | Package manager for all skills |
| Anthropic skills | [anthropics/skills](https://github.com/anthropics/skills) | Official Claude skill examples |
| Trail of Bits | [trailofbits/skills](https://github.com/trailofbits/skills) | Security review, static analysis |
| Supabase | [supabase/agent-skills](https://github.com/supabase/agent-skills) | Postgres/Supabase workflows |
| Cloudflare | [cloudflare/skills](https://github.com/cloudflare/skills) | Workers, edge deployment |
| Expo | [expo/skills](https://github.com/expo/skills) | React Native / Expo |
| Stripe | [stripe/agent-toolkit](https://github.com/stripe/agent-toolkit) | Payments integration patterns |
| CodeRabbit | Cursor plugin `code-review` | Already available via Cursor marketplace |
| Cursor docs | `/add-plugin cursor-guide` | Cursor product documentation agent |

## Desktop-only plugins

Some packs (pstack, superpowers) also ship as Cursor marketplace plugins. In Cursor Agent chat:

```text
/add-plugin pstack
/add-plugin superpowers
```

Project-local copies in `.agents/skills/` work in Cloud Agents and keep skills versioned with the repo.
