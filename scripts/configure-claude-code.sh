#!/usr/bin/env bash
# Wires obsidian-mcp-server into this vault for Claude Code, via a
# project-scoped .mcp.json at the vault root (Claude Code auto-loads this
# when you run `claude` inside the vault). Only touches the "obsidian" key
# - everything else already in .mcp.json is left alone.
#
# No filesystem MCP server is added here - Claude Code already reads/writes
# vault files natively when the vault is your working directory (see
# README Option A). This script is only for Option B's structured tools.
#
# Usage: ./scripts/configure-claude-code.sh /path/to/vault [--api-key KEY]

set -euo pipefail

VAULT_PATH="${1:?Usage: configure-claude-code.sh /path/to/vault [--api-key KEY]}"
shift || true

API_KEY=""
while [ $# -gt 0 ]; do
  case "$1" in
    --api-key) API_KEY="$2"; shift 2 ;;
    *) echo "Unknown argument: $1" >&2; exit 1 ;;
  esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MERGE_TOOL="$SCRIPT_DIR/lib/merge-mcp-config.py"
VAULT_PATH_ABS="$(cd "$VAULT_PATH" && pwd)"
CONFIG_PATH="$VAULT_PATH_ABS/.mcp.json"

if [ -f "$CONFIG_PATH" ]; then
  BACKUP="${CONFIG_PATH}.bak-$(date +%Y%m%d%H%M%S)"
  cp "$CONFIG_PATH" "$BACKUP"
  echo "backed up existing config to $BACKUP"
fi

# Same best-effort auto-detection as configure-claude-desktop.sh.
if [ -z "$API_KEY" ]; then
  DATA_JSON="$VAULT_PATH_ABS/.obsidian/plugins/obsidian-local-rest-api/data.json"
  if [ -f "$DATA_JSON" ]; then
    FOUND_KEY="$(python3 -c "
import json
try:
    d = json.load(open('$DATA_JSON'))
except Exception:
    d = {}
for k in ('apiKey', 'api_key', 'apiToken'):
    if d.get(k):
        print(d[k])
        break
" 2>/dev/null || true)"
    if [ -n "$FOUND_KEY" ]; then
      API_KEY="$FOUND_KEY"
      echo "found an API key in $DATA_JSON"
    fi
  fi
fi

if [ -z "$API_KEY" ]; then
  API_KEY="paste-your-local-rest-api-key-here"
  echo "no API key given or found — writing a placeholder; edit it in manually"
fi

ENTRIES=$(python3 -c "
import json
print(json.dumps({
    'obsidian': {
        'command': 'npx',
        'args': ['-y', 'obsidian-mcp-server@latest'],
        'env': {
            'MCP_TRANSPORT_TYPE': 'stdio',
            'OBSIDIAN_API_KEY': '$API_KEY',
            'OBSIDIAN_BASE_URL': 'https://127.0.0.1:27124',
            'OBSIDIAN_VERIFY_SSL': 'false',
        },
    },
}))
")

python3 "$MERGE_TOOL" "$CONFIG_PATH" "$ENTRIES"

echo ""
echo "Wrote $CONFIG_PATH. Claude Code picks this up automatically the next"
echo "time you run 'claude' with this vault as your working directory."
