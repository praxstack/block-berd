import { describe, expect, it } from "vitest";
import {
  normalizeProviderFieldUpdates,
  normalizeProviderFieldValue,
  stripTrailingOpenAiV1,
} from "./normalizeProviderHost";

describe("stripTrailingOpenAiV1", () => {
  it("strips a trailing /v1 from an origin users copy from OpenAI docs", () => {
    expect(stripTrailingOpenAiV1("http://localhost:1234/v1")).toBe(
      "http://localhost:1234",
    );
    expect(stripTrailingOpenAiV1("http://localhost:1234/v1/")).toBe(
      "http://localhost:1234",
    );
  });

  it("leaves hosts that do not end in /v1 unchanged", () => {
    expect(stripTrailingOpenAiV1("http://localhost:1234")).toBe(
      "http://localhost:1234",
    );
    expect(stripTrailingOpenAiV1("http://localhost:1234/lmstudio")).toBe(
      "http://localhost:1234/lmstudio",
    );
  });
});

describe("normalizeProviderFieldValue", () => {
  it("normalizes LMSTUDIO_HOST only", () => {
    expect(
      normalizeProviderFieldValue("LMSTUDIO_HOST", "http://127.0.0.1:1234/v1"),
    ).toBe("http://127.0.0.1:1234");
    expect(
      normalizeProviderFieldValue("DATABRICKS_HOST", "https://adb.example/v1"),
    ).toBe("https://adb.example/v1");
  });

  it("maps field updates in place for save payloads", () => {
    expect(
      normalizeProviderFieldUpdates([
        { key: "LMSTUDIO_HOST", value: " http://localhost:1234/v1 " },
        { key: "LMSTUDIO_API_KEY", value: "sk-test" },
      ]),
    ).toEqual([
      { key: "LMSTUDIO_HOST", value: "http://localhost:1234" },
      { key: "LMSTUDIO_API_KEY", value: "sk-test" },
    ]);
  });
});
