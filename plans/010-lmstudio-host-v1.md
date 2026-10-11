# Plan 010: Strip trailing /v1 from LMSTUDIO_HOST (block/berd#144)

## Design review (APPROVED)

### Senior principal engineer
Goose's lmstudio provider appends `/v1` to `LMSTUDIO_HOST`. Berd must persist a bare origin. Normalize on save in `saveProviderConfig` so every UI path is covered.

### Principal engineer
Only `LMSTUDIO_HOST`. Do not strip Databricks hosts or custom `apiUrl` in this PR. Preserve path prefixes like `http://localhost:1234/lmstudio` that do not end in `/v1`.

### Second senior principal engineer
Confirm the doubling is Goose-side append + Berd writing the documented OpenAI URL. Approve host-key normalization on write.

**Decision:** APPROVED. Refs block/berd#144.

## Status

- **Approved**: 2026-10-05
