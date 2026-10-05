#!/usr/bin/env bash
# Verify (or refresh) skills-lock.json hashes against on-disk SKILL.md files.
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

exec python3 - "$repo_root" "$@" <<'PY'
from __future__ import annotations

import hashlib
import json
import sys
from pathlib import Path

KNOWN_REMOVED = {"alpha", "beta", "gstack"}
LOCK_NAME = "skills-lock.json"


def skill_dir_candidates(name: str, skill_path: str) -> list[Path]:
    path = Path(skill_path)
    candidates: list[Path] = []
    if skill_path.startswith(".agents/skills/"):
        candidates.append(Path(skill_path))
    slug = name.strip().lower().replace(" ", "-")
    candidates.append(Path(".agents/skills") / name / "SKILL.md")
    candidates.append(Path(".agents/skills") / slug / "SKILL.md")
    if path.parent.name:
        candidates.append(Path(".agents/skills") / path.parent.name / "SKILL.md")
    return candidates


def resolve_skill_file(name: str, skill_path: str) -> Path | None:
    seen: set[Path] = set()
    for candidate in skill_dir_candidates(name, skill_path):
        if candidate in seen:
            continue
        seen.add(candidate)
        if candidate.is_file():
            return candidate
    return None


def file_hash(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main(argv: list[str]) -> int:
    repo = Path(argv[1])
    update = "--update" in argv[2:]
    lock_path = repo / LOCK_NAME
    lock = json.loads(lock_path.read_text())
    skills = lock.get("skills")
    if not isinstance(skills, dict):
        print("error: skills-lock.json missing skills object", file=sys.stderr)
        return 2

    missing: list[str] = []
    skipped: list[str] = []
    mismatched: list[tuple[str, str, str]] = []
    matched = 0

    for name, meta in skills.items():
        if not isinstance(meta, dict):
            missing.append(f"{name} (invalid metadata)")
            continue
        skill_path = str(meta.get("skillPath") or "")
        resolved = resolve_skill_file(name, skill_path)
        if resolved is None:
            parent = Path(skill_path).parent.name
            if name in KNOWN_REMOVED or parent in KNOWN_REMOVED:
                skipped.append(name)
                continue
            missing.append(f"{name} ({skill_path})")
            continue
        actual = file_hash(resolved)
        expected = str(meta.get("computedHash") or "")
        if update:
            meta["computedHash"] = actual
            matched += 1
            continue
        if actual == expected:
            matched += 1
        else:
            mismatched.append((name, expected, actual))

    if update:
        lock_path.write_text(json.dumps(lock, indent=2) + "\n")
        print(
            f"updated {matched} hashes in {LOCK_NAME} "
            f"(skipped {len(skipped)} known-removed, {len(missing)} unresolved)"
        )
        if missing:
            print("unresolved:", file=sys.stderr)
            for item in missing:
                print(f"  {item}", file=sys.stderr)
            if len(skills) and len(missing) / len(skills) > 0.10:
                print(
                    "error: more than 10% of lock entries could not be resolved",
                    file=sys.stderr,
                )
                return 2
        return 0

    print(
        f"skills-lock: {matched} matched, {len(mismatched)} mismatched, "
        f"{len(missing)} missing, {len(skipped)} skipped"
    )
    for name, expected, actual in mismatched[:20]:
        print(f"mismatch {name}: expected {expected} actual {actual}", file=sys.stderr)
    if len(mismatched) > 20:
        print(f"... {len(mismatched) - 20} more mismatches", file=sys.stderr)
    for item in missing:
        print(f"missing {item}", file=sys.stderr)

    total_checked = matched + len(mismatched) + len(missing)
    missing_rate = (len(missing) / total_checked) if total_checked else 0.0
    if total_checked and missing_rate > 0.10:
        print("error: more than 10% of lock entries could not be resolved", file=sys.stderr)
        return 2
    if mismatched:
        return 1
    if missing:
        print(
            f"warning: {len(missing)} unresolved lock entries "
            f"({missing_rate:.1%}); under the 10% stop, treating as fixtures",
            file=sys.stderr,
        )
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
PY
