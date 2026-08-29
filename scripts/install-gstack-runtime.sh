#!/usr/bin/env bash
# Install garrytan/gstack runtime (bin helpers, browse, Cursor skill symlinks).
# Skill markdown alone (via npx skills add) is not enough — gstack skills call
# ~/.claude/skills/gstack/bin/* at runtime.
set -euo pipefail

readonly GSTACK_REPO="${GSTACK_REPO:-https://github.com/garrytan/gstack.git}"
readonly GSTACK_HOME="${GSTACK_HOME:-$HOME/.claude/skills/gstack}"
readonly GSTACK_HOST="${GSTACK_HOST:-cursor}"
QUIET=0

while [ $# -gt 0 ]; do
  case "$1" in
    -q|--quiet) QUIET=1; shift ;;
    -h|--help)
      echo "Usage: $0 [-q|--quiet]"
      echo "  Installs gstack runtime to \$GSTACK_HOME (default: ~/.claude/skills/gstack)"
      echo "  with --host \$GSTACK_HOST (default: cursor)."
      exit 0
      ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

ensure_bun() {
  if command -v bun >/dev/null 2>&1; then
    return 0
  fi
  echo "Installing Bun (required by gstack setup) …"
  curl -fsSL https://bun.sh/install | bash
  export PATH="$HOME/.bun/bin:$PATH"
  if ! command -v bun >/dev/null 2>&1; then
    echo "error: bun install failed — add ~/.bun/bin to PATH and retry" >&2
    exit 1
  fi
}

install_gstack() {
  ensure_bun
  export PATH="${HOME}/.bun/bin:${PATH}"

  if [[ -d "$GSTACK_HOME/.git" ]]; then
    echo "Updating gstack at $GSTACK_HOME …"
    git -C "$GSTACK_HOME" pull --ff-only
  else
    echo "Cloning gstack into $GSTACK_HOME …"
    mkdir -p "$(dirname "$GSTACK_HOME")"
    git clone --single-branch --depth 1 "$GSTACK_REPO" "$GSTACK_HOME"
  fi

  echo "Running gstack setup (--host $GSTACK_HOST) …"
  local setup_args=(--host "$GSTACK_HOST")
  [ "$QUIET" -eq 1 ] && setup_args+=(-q)
  (cd "$GSTACK_HOME" && ./setup "${setup_args[@]}")
}

verify_gstack() {
  local start="$GSTACK_HOME/bin/gstack-skill-start"
  if [[ ! -x "$start" ]]; then
    echo "error: gstack setup did not produce $start" >&2
    exit 1
  fi
  if ! "$start" --skill health --model claude --parent-pid "$$" >/dev/null 2>&1; then
    echo "warning: gstack-skill-start smoke test failed (skills may run in degraded mode)"
  fi
  echo "gstack runtime OK: $GSTACK_HOME"
  if [[ -d "$HOME/.cursor/skills" ]]; then
    echo "Cursor skills: $(find "$HOME/.cursor/skills" -maxdepth 1 \( -name 'gstack-*' -o -name 'gstack' \) | wc -l | tr -d ' ') entries under ~/.cursor/skills/"
  fi
}

install_gstack
verify_gstack
