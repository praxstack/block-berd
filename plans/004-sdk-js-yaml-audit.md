# Plan 004: Resolve js-yaml high advisory in SDK dependency chain

> **Executor instructions**: Follow this plan step by step. Run every
> verification command and confirm the expected result before moving to the
> next step. If anything in the "STOP conditions" section occurs, stop and
> report — do not improvise. When done, update the status row for this plan
> in `plans/README.md`.
>
> **Drift check (run first)**: `git diff --stat 7fb24e5..HEAD -- sdk/ pnpm-lock.yaml package.json`
> On mismatch, STOP.

## Status

- **Priority**: P2
- **Effort**: S
- **Risk**: MED
- **Depends on**: none
- **Category**: security
- **Planned at**: commit `7fb24e5`, 2026-08-29

## Why this matters

`pnpm audit` reports one high severity issue: js-yaml &lt;4.3.1 (CVE-2026-59870)
via `sdk > @hey-api/openapi-ts > @hey-api/json-schema-ref-parser > js-yaml`.
The SDK is built on every `just check` / `just ci`. Upgrading or overriding
the transitive dependency closes a known parser DoS vector in codegen tooling.

## Current state

Audit output (2026-08-29):

```
Package: js-yaml
Vulnerable: >=4.0.0 <4.3.1
Patched: >=4.3.1
Path: sdk>@hey-api/openapi-ts>@hey-api/json-schema-ref-parser>js-yaml
```

SDK package: `sdk/package.json` — uses `@hey-api/openapi-ts` for schema generation.

## Commands you will need

| Purpose | Command | Expected |
|---------|---------|----------|
| Audit | `pnpm audit --audit-level=high` | 0 vulnerabilities |
| SDK build | `pnpm --filter @aaif/goose-sdk build:ts` | exit 0 |
| Full check | `just check` | exit 0 |

## Scope

**In scope**:
- `sdk/package.json`
- `pnpm-lock.yaml` (root)
- Optional: `package.json` `pnpm.overrides` if direct bump insufficient

**Out of scope**:
- Regenerating SDK types unless required by openapi-ts upgrade
- Runtime app dependencies unrelated to sdk

## Steps

### Step 1: Attempt direct upgrade

In `sdk/`, bump `@hey-api/openapi-ts` to latest compatible version that pulls
`js-yaml@>=4.3.1`. Run `pnpm install` and `pnpm audit --audit-level=high`.

### Step 2: Override if needed

If transitive dep remains vulnerable, add pnpm override:

```json
"pnpm": {
  "overrides": {
    "js-yaml": ">=4.3.1"
  }
}
```

(Place at root `package.json` per repo convention.)

### Step 3: Regenerate if openapi-ts version changed

If openapi-ts major bumped, run SDK codegen scripts documented in `sdk/README`
or `AGENTS.md` and commit generated output only if repo expects it.

**Verify**: `pnpm audit --audit-level=high` → no high/critical;
`just check` → exit 0

## Done criteria

- [ ] `pnpm audit --audit-level=high` clean
- [ ] `just check` exit 0
- [ ] `plans/README.md` updated

## STOP conditions

- openapi-ts upgrade breaks schema generation and no override resolves audit.
- Override breaks `@hey-api/openapi-ts` at runtime — revert and report.

## Maintenance notes

- Re-run audit after sdk dependency bumps.
- This is build-time tooling risk, not production runtime — still worth fixing for CI/agent environments parsing untrusted OpenAPI.
