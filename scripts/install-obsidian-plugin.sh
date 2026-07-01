#!/usr/bin/env bash
# Downloads the latest release of the "Local REST API" Obsidian community
# plugin (coddingtonbear/obsidian-local-rest-api) and stages it directly
# into a vault, so you don't have to find it via Settings -> Community
# plugins -> Browse by hand. Safe to re-run.
#
# What this does NOT do: turn on "Community plugins" in Obsidian if your
# vault has them off (a one-time per-vault toggle in Settings), or enable
# HTTPS / generate the API key (the plugin does that on first load inside
# Obsidian - it can't happen before Obsidian has actually run once).
#
# Usage: ./scripts/install-obsidian-plugin.sh /path/to/vault

set -euo pipefail

VAULT_PATH="${1:?Usage: install-obsidian-plugin.sh /path/to/vault}"
REPO="coddingtonbear/obsidian-local-rest-api"
OBSIDIAN_DIR="$VAULT_PATH/.obsidian"
PLUGINS_DIR="$OBSIDIAN_DIR/plugins"
COMMUNITY_PLUGINS_FILE="$OBSIDIAN_DIR/community-plugins.json"

command -v curl >/dev/null || { echo "curl is required" >&2; exit 1; }
command -v python3 >/dev/null || { echo "python3 is required" >&2; exit 1; }

if [ ! -d "$VAULT_PATH" ]; then
  echo "Vault not found at $VAULT_PATH — run scripts/setup-vault.sh first." >&2
  exit 1
fi

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

echo "Fetching latest release info for $REPO..."
RELEASE_JSON="$TMP_DIR/release.json"
if ! curl -fsSL "https://api.github.com/repos/$REPO/releases/latest" -o "$RELEASE_JSON"; then
  cat >&2 <<EOF
Could not reach the GitHub releases API for $REPO.
Install the plugin manually instead: in Obsidian, Settings -> Community
plugins -> Browse -> search "Local REST API" -> Install -> Enable.
EOF
  exit 1
fi

# Pull the download URLs for main.js / manifest.json / styles.css from the
# release assets (styles.css is optional - not every plugin ships one),
# then fetch each with curl. Deliberately not urllib here - it handles the
# GitHub releases redirect chain (github.com -> objects.githubusercontent.com)
# far less reliably than curl through some network setups.
ASSET_LIST="$TMP_DIR/assets.tsv"
python3 - "$RELEASE_JSON" > "$ASSET_LIST" <<'PYEOF'
import json, sys

release = json.load(open(sys.argv[1]))
assets = {a["name"]: a["browser_download_url"] for a in release.get("assets", [])}

required = ["main.js", "manifest.json"]
missing = [f for f in required if f not in assets]
if missing:
    sys.stderr.write(
        f"Release assets missing {missing} - the release layout may have "
        "changed. Install the plugin manually via Obsidian's Community "
        "plugins browser instead.\n"
    )
    sys.exit(1)

for name in required + ["styles.css"]:
    url = assets.get(name)
    if url:
        print(f"{name}\t{url}")
PYEOF

while IFS=$'\t' read -r name url; do
  if curl -fsSL "$url" -o "$TMP_DIR/$name"; then
    echo "downloaded $name"
  else
    echo "Failed to download $name from $url" >&2
    exit 1
  fi
done < "$ASSET_LIST"

MANIFEST_ID="$(python3 -c "import json; print(json.load(open('$TMP_DIR/manifest.json'))['id'])")"
DEST_DIR="$PLUGINS_DIR/$MANIFEST_ID"

mkdir -p "$DEST_DIR"
cp "$TMP_DIR/main.js" "$TMP_DIR/manifest.json" "$DEST_DIR/"
[ -f "$TMP_DIR/styles.css" ] && cp "$TMP_DIR/styles.css" "$DEST_DIR/"

echo "staged plugin '$MANIFEST_ID' into $DEST_DIR"

# Enable it in community-plugins.json (a flat JSON array of enabled plugin
# IDs) without disturbing any other plugins already enabled there.
python3 - "$COMMUNITY_PLUGINS_FILE" "$MANIFEST_ID" <<'PYEOF'
import json, os, sys

path, plugin_id = sys.argv[1], sys.argv[2]
enabled = []
if os.path.isfile(path):
    try:
        enabled = json.load(open(path))
    except json.JSONDecodeError:
        sys.stderr.write(f"{path} isn't valid JSON - leaving it untouched.\n")
        sys.exit(1)

if plugin_id not in enabled:
    enabled.append(plugin_id)
    json.dump(enabled, open(path, "w"), indent=2)
    print(f"enabled '{plugin_id}' in {path}")
else:
    print(f"'{plugin_id}' already enabled in {path}")
PYEOF

cat <<EOF

Plugin staged. Two things only you can do (they require Obsidian to
actually run):
  1. Open the vault in Obsidian. If this is the first community plugin for
     this vault, you may be prompted to turn on "Community plugins" once —
     confirm it, and this plugin will already be enabled.
  2. Settings -> Community plugins -> Local REST API -> enable HTTPS and
     copy the generated API key (needed for scripts/configure-claude-*.sh).
EOF
