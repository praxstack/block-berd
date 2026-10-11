# Plan 004: Resolve js-yaml high advisory in SDK dependency chain

## Design review (APPROVED)

### Senior principal engineer
Prefer a root `pnpm.overrides` for `js-yaml>=4.3.1` over an openapi-ts major bump. This is build-time codegen, not production runtime, but CI/agent environments still parse schemas.

### Principal engineer
Risk: override breaks `@hey-api/json-schema-ref-parser`. Mitigation: run SDK `build:ts` after install. Do not regenerate SDK types unless required.

### Second senior principal engineer
Confirm override is the smallest safe patch. Disagree with upgrading openapi-ts in the same PR (unrelated churn). Approve override-only.

**Decision:** APPROVED. `pnpm-workspace.yaml` already pins `js-yaml: "4.3.2"`. This change adds the matching `package.json` `pnpm.overrides` entry from the original plan so both override sites stay in agreement.

## Status

- **Priority**: P2
- **Approved**: 2026-10-05
