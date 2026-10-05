/** Normalize Goose provider host fields that the backend appends `/v1` onto. */

const OPENAI_V1_SUFFIX = /\/v1\/?$/i;
const HOST_KEYS_WITH_APPENDED_V1 = new Set(["LMSTUDIO_HOST"]);

export function stripTrailingOpenAiV1(value: string): string {
  return value.trim().replace(OPENAI_V1_SUFFIX, "");
}

export function normalizeProviderFieldValue(
  key: string,
  value: string,
): string {
  if (HOST_KEYS_WITH_APPENDED_V1.has(key)) {
    return stripTrailingOpenAiV1(value);
  }
  return value;
}

export function normalizeProviderFieldUpdates<
  T extends { key: string; value: string },
>(fields: T[]): T[] {
  return fields.map((field) => ({
    ...field,
    value: normalizeProviderFieldValue(field.key, field.value),
  }));
}
