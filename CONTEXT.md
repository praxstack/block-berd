# Berd domain vocabulary

Short glossary for agents and contributors. Product behavior lives in `LAWS/`. This file is vocabulary, not law.

## Purpose

Use these names in issues, plans, and tests so Session / Project / Agent / Skill do not drift into synonyms.

## Core entities

- **Session** — one chat thread with an ACP session id, working directory, agent, and model.
- **Project** — a named workspace with one or more folders (`workingDirs`) that sessions can attach to.
- **Agent / persona** — a named instruction set the user picks for a session (bundled or imported).
- **Harness** — the agent runtime that executes the session (Goose, Claude Code, Codex, and other ACP backends).
- **Skill** — Agent Skills markdown the runtime can load. Sources: bundled (`distro/skills`), personal (`~/.agents/skills`), project (`.agents/skills`), marketplace.
- **Connection / extension / MCP** — a configured MCP server or OAuth service the harness can call.
- **Composer** — the chat input that queues prompts into the selected session.

## Control plane

- **berdctl** — CLI → Tauri broker → renderer command registry. Not an HTTP API. Bounds live in zod; clap mirrors them.
- **ACP** — Agent Client Protocol. Berd talks to Goose (`goosed` sidecar) over ACP for session create/run, models, and config.

## Backend

- **Goose** — pinned sidecar (`goose-backend.lock.json`). Release builds stage `goosed`.
- **cwd on the wire** — ACP requires a POSIX-absolute working directory for local sessions.

## Terms to avoid

- Do not call berdctl commands "API endpoints".
- Do not call a Session a "conversation resource" or a Project a "repo" unless it is actually a Git folder.
- Do not treat `.agents/skills/` as the in-app Skills marketplace; that tree is the agent skill stack for Cursor/Cloud Agents.

## Pointers

- `LAWS/` — required product behavior
- `docs/berdctl-architecture.md` — CLI / broker / registry
- `.codex/skill-stack.json` — discovery profile for the vendored skill armory
- `.agents/skills/README.md` — install tiers and entry points
- `docs/adr/` — architecture decisions
