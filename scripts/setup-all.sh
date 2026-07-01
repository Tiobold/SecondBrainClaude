#!/usr/bin/env bash
# One-shot setup: creates the vault, stages the Local REST API plugin, and
# wires up Claude Desktop and/or Claude Code. Runs the other scripts in
# this folder in sequence - see each one for what it does on its own.
#
# A network hiccup or a step that needs your input (Obsidian has to
# actually run once to generate the API key) doesn't abort the whole run -
# each step is reported at the end so you know exactly what's left.
#
# Usage:
#   ./scripts/setup-all.sh /path/to/vault [options]
#
# Options:
#   --desktop         Configure Claude Desktop only (default: both)
#   --code            Configure Claude Code only (default: both)
#   --skip-plugin     Don't auto-install the Local REST API plugin
#   --api-key KEY     Use this API key instead of trying to auto-detect one

set -uo pipefail

VAULT_PATH="${1:?Usage: setup-all.sh /path/to/vault [--desktop] [--code] [--skip-plugin] [--api-key KEY]}"
shift || true

DO_DESKTOP=0
DO_CODE=0
SKIP_PLUGIN=0
API_KEY=""

while [ $# -gt 0 ]; do
  case "$1" in
    --desktop) DO_DESKTOP=1; shift ;;
    --code) DO_CODE=1; shift ;;
    --skip-plugin) SKIP_PLUGIN=1; shift ;;
    --api-key) API_KEY="$2"; shift 2 ;;
    *) echo "Unknown argument: $1" >&2; exit 1 ;;
  esac
done

# Default to wiring up both clients if neither flag was given - harmless
# to configure both even if you only use one.
if [ "$DO_DESKTOP" -eq 0 ] && [ "$DO_CODE" -eq 0 ]; then
  DO_DESKTOP=1
  DO_CODE=1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
API_KEY_ARGS=()
[ -n "$API_KEY" ] && API_KEY_ARGS=(--api-key "$API_KEY")

STATUS_VAULT="skipped"
STATUS_PLUGIN="skipped"
STATUS_DESKTOP="skipped"
STATUS_CODE="skipped"

echo "== 1/4: vault structure =="
if "$SCRIPT_DIR/setup-vault.sh" "$VAULT_PATH"; then
  STATUS_VAULT="ok"
else
  echo "Vault setup failed - stopping, nothing else can proceed without it." >&2
  exit 1
fi

echo ""
echo "== 2/4: Local REST API plugin =="
if [ "$SKIP_PLUGIN" -eq 1 ]; then
  echo "skipped (--skip-plugin)"
else
  if "$SCRIPT_DIR/install-obsidian-plugin.sh" "$VAULT_PATH"; then
    STATUS_PLUGIN="ok"
  else
    STATUS_PLUGIN="failed (install it manually via Obsidian's Community plugins browser)"
    echo "$STATUS_PLUGIN" >&2
  fi
fi

if [ "$DO_DESKTOP" -eq 1 ]; then
  echo ""
  echo "== 3/4: Claude Desktop config =="
  if "$SCRIPT_DIR/configure-claude-desktop.sh" "$VAULT_PATH" "${API_KEY_ARGS[@]}"; then
    STATUS_DESKTOP="ok"
  else
    STATUS_DESKTOP="failed - see output above"
  fi
fi

if [ "$DO_CODE" -eq 1 ]; then
  echo ""
  echo "== 4/4: Claude Code config =="
  if "$SCRIPT_DIR/configure-claude-code.sh" "$VAULT_PATH" "${API_KEY_ARGS[@]}"; then
    STATUS_CODE="ok"
  else
    STATUS_CODE="failed - see output above"
  fi
fi

cat <<EOF

============================================================
Setup summary
============================================================
Vault structure:        $STATUS_VAULT
Local REST API plugin:  $STATUS_PLUGIN
Claude Desktop config:  $STATUS_DESKTOP
Claude Code config:     $STATUS_CODE

Manual steps nothing can script for you:
  1. Open the vault in Obsidian at least once (turns on community plugins
     if this is the first one, and lets the Local REST API plugin
     initialize and generate its API key).
  2. In Obsidian: Settings -> Community plugins -> Local REST API ->
     confirm HTTPS is on. If configure-claude-*.sh above found an API key
     automatically it's already wired in; if it printed a placeholder
     instead, copy the real key from that settings screen and re-run
     configure-claude-desktop.sh / configure-claude-code.sh with
     --api-key.
  3. Restart Claude Desktop (quit fully) if you configured it.
============================================================
EOF
