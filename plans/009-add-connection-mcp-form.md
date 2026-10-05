# Plan 009: Add connection opens the MCP form (block/berd#251)

## Design review (APPROVED)

### Senior principal engineer
Both Connections "Add connection" buttons currently start a setup chat via `createNewTab`, which requires a ready harness and falls through to Settings → AI providers. Open `ExtensionModal` on the Connections page instead.

### Principal engineer
Reuse `useExtensionsSettings` (already unused in UI). Stay on the connections section. Do not change provider troubleshooting chats.

### Second senior principal engineer
Product copy already says "Add connection"; users expect a form (name, command/URL, env), which `ExtensionModal` is. Approve replacing the ask-agent detour for these two buttons.

**Decision:** APPROVED. Refs block/berd#251.

## Status

- **Approved**: 2026-10-05
