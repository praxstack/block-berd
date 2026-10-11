import { describe, expect, it } from "vitest";
import { expandHomePath, isHomeRelativePath } from "./homePath";

describe("expandHomePath", () => {
  const home = "/Users/ada";

  it("detects ~ prefixes", () => {
    expect(isHomeRelativePath("~")).toBe(true);
    expect(isHomeRelativePath("~/src")).toBe(true);
    expect(isHomeRelativePath("/tmp")).toBe(false);
  });

  it("expands ~ to the home directory", () => {
    expect(expandHomePath("~", home)).toBe("/Users/ada");
    expect(expandHomePath("~/Projects/berd", home)).toBe(
      "/Users/ada/Projects/berd",
    );
  });

  it("passes through non-home paths", () => {
    expect(expandHomePath("/tmp/project", home)).toBe("/tmp/project");
  });
});
