# Plan 007: Expand local ACP cwd before session/new (block/berd#326)

## Design review (APPROVED)

### Senior principal engineer
Expand `~`, `~/…`, empty, and `.` to `$HOME` at the ACP wire (`newSession` / `loadSession` / `forkSession` / `updateWorkingDir`). Reuse `expandHomePath`. SSH backends keep the host spelling of `~`.

### Principal engineer
Threats: expanding remote cwd locally; Windows drive letters; getHomeDir failure. Mitigations: only expand for `LOCAL_BACKEND_ID`; leave `C:\` and POSIX-absolute paths; if home lookup fails, throw rather than send `~`.

### Second senior principal engineer
Issue already names `toAcpAbsoluteCwd`. Confirm default `workingDir ?? "~"` in `acpLoadSession` can stay; the wire helper expands it. Approve.

**Decision:** APPROVED. Refs block/berd#326.

## Status

- **Approved**: 2026-10-05
