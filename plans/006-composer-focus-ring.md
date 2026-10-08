# Plan 006: Remove native focus ring on Cmd+N composer (block/berd#322)

## Design review (APPROVED)

### Senior principal engineer
`focus-override` opts the centered composer textarea out of the global outline reset, so WebKit paints a native black ring. Match `ChatInput`: drop `focus-override`, keep `focus:outline-none focus-visible:ring-0 focus-visible:ring-offset-0`. Do not change other `focus-override` consumers.

### Principal engineer
Accessibility: the pill already has a focus-within chrome. Suppressing the native ring matches in-session composer. Test that the textarea class list no longer includes `focus-override`.

### Second senior principal engineer
Issue author already identified the class. Independent confirm in `globals.css` (`*:not(body):not(.focus-override)`). Approve the smallest CSS class change.

**Decision:** APPROVED. Refs block/berd#322.

## Status

- **Approved**: 2026-10-05
