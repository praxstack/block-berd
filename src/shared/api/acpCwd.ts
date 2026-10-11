/** Expand local ACP cwd spellings Goose rejects as non-absolute. */

import { expandHomePath } from "@/shared/lib/homePath";
import { LOCAL_BACKEND_ID, type AcpBackendId } from "./acpBackendId";
import { getCachedHomeDir, getHomeDir } from "./system";

export function shouldExpandAcpCwd(backendId: AcpBackendId): boolean {
  return backendId === LOCAL_BACKEND_ID;
}

/**
 * Map Berd's local default cwd (`~`, `~/…`, empty, `.`) to a POSIX-absolute
 * path using `homeDir`. Absolute paths and non-home-relative paths pass
 * through `expandHomePath` unchanged.
 */
export function toAcpAbsoluteCwd(cwd: string, homeDir: string): string {
  const trimmed = cwd.trim();
  if (
    trimmed === "" ||
    trimmed === "." ||
    trimmed === "./" ||
    trimmed === "~"
  ) {
    return expandHomePath("~", homeDir);
  }
  return expandHomePath(trimmed, homeDir);
}

export async function resolveLocalAcpCwd(cwd: string): Promise<string> {
  const homeDir = getCachedHomeDir() ?? (await getHomeDir());
  return toAcpAbsoluteCwd(cwd, homeDir);
}

export async function resolveAcpWireCwd(
  cwd: string,
  backendId: AcpBackendId,
): Promise<string> {
  if (!shouldExpandAcpCwd(backendId)) {
    return cwd;
  }
  return resolveLocalAcpCwd(cwd);
}
