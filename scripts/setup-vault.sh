#!/usr/bin/env bash
# Create a PARA-method Obsidian vault structure and seed it with the
# note templates from this repo. Safe to re-run — never overwrites
# existing files.
#
# Usage: ./scripts/setup-vault.sh /path/to/vault

set -euo pipefail

VAULT_PATH="${1:?Usage: setup-vault.sh /path/to/vault}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATES_DIR="$SCRIPT_DIR/../templates"

FOLDERS=(
  "00-Inbox"
  "01-Projects"
  "02-Areas"
  "03-Resources"
  "04-Archive"
  "05-Meeting-Transcripts"
  "Daily"
  "Templates"
)

mkdir -p "$VAULT_PATH"

for folder in "${FOLDERS[@]}"; do
  mkdir -p "$VAULT_PATH/$folder"
  echo "created $VAULT_PATH/$folder"
done

if [ -d "$TEMPLATES_DIR" ]; then
  for template in "$TEMPLATES_DIR"/*.md; do
    dest="$VAULT_PATH/Templates/$(basename "$template")"
    if [ -f "$dest" ]; then
      echo "skip (exists) $dest"
    else
      cp "$template" "$dest"
      echo "copied $dest"
    fi
  done
fi

echo ""
echo "Vault ready at: $VAULT_PATH"
echo "Open it in Obsidian via: Open folder as vault -> select '$VAULT_PATH'"
