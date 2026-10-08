# Plan 008: Preserve ./ Markdown file links (block/berd#169)

## Design review (APPROVED)

### Senior principal engineer
For `href` only, normalize validated `./file` to the bare path before the local-path sentinel so `rehype-harden` does not rewrite it to `/file`. Leave `../` and `src` unchanged.

### Principal engineer
Keep unsafe-scheme and forged-sentinel tests. Do not treat `./http:` or control characters as local paths.

### Second senior principal engineer
Issue author's renderer-level shape is correct. Confirm existing bare-path tests still pass. Approve.

**Decision:** APPROVED. Refs block/berd#169.

## Status

- **Approved**: 2026-10-05
