---
name: prax-mode
description: >-
  Use for Prax, /prax-mode, or requests to work in this style.
disable-model-invocation: true
---

# Prax mode

Opt-in. Load this skill only when the user names it or `/prax-mode`. Do not auto-attach it.

Refer to other skills by path. Do not paste their bodies here. The installed stack inventory is `.agents/skills/README.md`.

## Response style

Be direct. Short sentences. No pep talk, no hedging, no "let me know if".

The user types fast and leaves typos. Infer intent and execute. Do not ask them to restate.

If they ask why work is still on a feature branch, merge to `main`. Do not explain git.

## Autonomy

Default is proceed. "Don't stop", "I'm going to sleep", `/autopilot`, and "no pushback" mean finish the loop. Spec, implement, review, open PRs, merge to `main`.

Do not ask permission for reversible work. Do not argue scope on a clear issue list.

Keep the work on the cloud VM. Push from there. Do not leave a local leftover for the user to finish.

Use the compute you need. Many small PRs beat one stalled branch.

## Understand first

Non-trivial product work is spec-driven. Write the spec. Run a multi-agent design review. Implement only after the design is approved.

Follow the repo pipeline in `.agents/skills/README.md`:

discover → interrogate/spec → plan → implement → review → security → browser QA → ship → learn

Pick one primary methodology per task. Do not run pstack, Superpowers, and gstack on the same change.

## Subagents

For a batch of issues, use `.agents/skills/subagent-driven-development/SKILL.md`.

Review loop, in order:

1. Program lead scopes the issue.
2. Principal and senior principal engineers debate the design until they agree.
3. Front-end or back-end implements from the approved design.
4. QA verifies.
5. One PR per issue.

Do not skip the design loop to start coding.

## Skills

Stacks already chosen for this repo:

- pstack
- Superpowers
- gstack
- Compound Engineering
- PraxStack skills-and-personas at https://github.com/praxstack/skills-and-personas

Install and pin with `scripts/install-agent-skills.sh` and `scripts/install-praxstack-skills.sh`.

gstack must be a runnable runtime, not flattened markdown. If `/plan-ceo-review` and sibling skills are missing, fix the install rather than telling the user they are "installed".

Discover extra skills on demand with `find-skills`. Do not dump 900 skills into always-on context.

Heavy, opinionated skills including this one stay `disable-model-invocation: true`.

A broken skill mid-task gets its own PR. Do not silently work around it. Do not block the original work.

## Review and verify

Code-review before merge. Use `.agents/skills/code-review/SKILL.md`. Run CodeRabbit when the user asks and the CLI can authenticate.

When they ask for a status report, return valid HTML only. No Markdown. Cover completed work, remaining work, items gated on the user, why a subagent went silent, current branch vs `main`, which PRs merged and which are open, and whether the Cloud Agent environment is saveable and current.

Do not greenwash. Do not hide blockers.

## Process

Branch from latest `main` as `prax/<short-name>-533e`.

Open PRs with ManagePullRequest. Never `gh pr create`. The GitHub integration token cannot create PRs through `gh`. `gh` is fine for read-only status.

Target `main`. Review, fix, merge. Done means the user is on `main`, not left on a feature branch.

Open a draft PR only when the user wants to review the artifact first. Otherwise open it ready and merge it.

Merge `origin` and `upstream` when they ask to sync.

The Cloud Agent environment must stay saveable. `.cursor/Dockerfile`, `.cursor/environment.json`, and `scripts/cloud-agent-install.sh` belong to env-setup. Do not fight those files on an unrelated task.
