import { describe, expect, it, vi } from "vitest";
import { LOCAL_BACKEND_ID, sshBackendId } from "./acpBackendId";
import {
  resolveAcpWireCwd,
  shouldExpandAcpCwd,
  toAcpAbsoluteCwd,
} from "./acpCwd";

vi.mock("./system", () => ({
  getHomeDir: vi.fn().mockResolvedValue("/Users/ada"),
  getCachedHomeDir: vi.fn().mockReturnValue("/Users/ada"),
}));

describe("toAcpAbsoluteCwd", () => {
  const home = "/Users/ada";

  it("expands ~ and empty and dot defaults to the home directory", () => {
    expect(toAcpAbsoluteCwd("~", home)).toBe("/Users/ada");
    expect(toAcpAbsoluteCwd("  ", home)).toBe("/Users/ada");
    expect(toAcpAbsoluteCwd(".", home)).toBe("/Users/ada");
    expect(toAcpAbsoluteCwd("./", home)).toBe("/Users/ada");
  });

  it("expands ~/relative paths", () => {
    expect(toAcpAbsoluteCwd("~/Projects/berd", home)).toBe(
      "/Users/ada/Projects/berd",
    );
  });

  it("leaves POSIX-absolute paths unchanged", () => {
    expect(toAcpAbsoluteCwd("/tmp/project", home)).toBe("/tmp/project");
  });
});

describe("shouldExpandAcpCwd", () => {
  it("expands only the local backend", () => {
    expect(shouldExpandAcpCwd(LOCAL_BACKEND_ID)).toBe(true);
    expect(shouldExpandAcpCwd(sshBackendId("box.example"))).toBe(false);
  });
});

describe("resolveAcpWireCwd", () => {
  it("expands local ~ to the home directory", async () => {
    await expect(resolveAcpWireCwd("~", LOCAL_BACKEND_ID)).resolves.toBe(
      "/Users/ada",
    );
  });

  it("leaves remote ~ unexpanded so SSH hosts keep their own home spelling", async () => {
    await expect(
      resolveAcpWireCwd("~", sshBackendId("box.example")),
    ).resolves.toBe("~");
  });
});
