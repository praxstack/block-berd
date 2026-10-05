import { test } from "node:test";
import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import { spawnSync } from "node:child_process";
import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";

const root = join(dirname(fileURLToPath(import.meta.url)), "..");
const dockerfile = readFileSync(join(root, ".cursor/Dockerfile"), "utf8");
const install = readFileSync(join(root, "scripts/cloud-agent-install.sh"), "utf8");

test("Dockerfile does not unconditionally create the ubuntu user", () => {
  assert.match(
    dockerfile,
    /if ! id -u ubuntu/,
    "ubuntu:24.04 already has ubuntu; useradd must be guarded",
  );
  assert.doesNotMatch(
    dockerfile,
    /^RUN useradd -m -s \/bin\/bash ubuntu/m,
    "unconditional useradd ubuntu fails Cloud Agent image builds",
  );
});

test("Dockerfile grants the ubuntu user passwordless sudo", () => {
  assert.match(dockerfile, /NOPASSWD:ALL/);
  assert.match(dockerfile, /USER ubuntu/);
});

test("cloud-agent-install wraps optional skill installers so they cannot fail snapshot", () => {
  assert.match(install, /run_optional praxstack/);
  assert.match(install, /run_optional gstack/);
  assert.doesNotMatch(
    install,
    /^\s*"\$repo_root\/scripts\/install-praxstack-skills\.sh"\s*$/m,
  );
  assert.doesNotMatch(
    install,
    /^\s*"\$repo_root\/scripts\/install-gstack-runtime\.sh".*$/m,
  );
});

test("run_optional swallows a failing optional command under set -e", () => {
  const match = install.match(/run_optional\(\) \{[\s\S]*?\n\}/);
  assert.ok(match, "run_optional function should be defined");
  const result = spawnSync(
    "bash",
    [
      "-c",
      `${match[0]}\nset -euo pipefail\nrun_optional fail /bin/false\necho survived`,
    ],
    { encoding: "utf8" },
  );
  assert.equal(result.status, 0, result.stderr);
  assert.match(result.stdout, /survived/);
  assert.match(result.stderr, /optional fail failed/);
});
