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
CONTEXT_TEMPLATES_DIR="$TEMPLATES_DIR/claude-context"
CONTEXT_DIR_NAME="Meta/Claude Context"   # see claude-context skill: this path is configurable

FOLDERS=(
  "00-Inbox"
  "01-Projects"
  "02-Areas"
  "03-Resources"
  "04-Archive"
  "05-Meeting-Transcripts"
  "06-People"
  "$CONTEXT_DIR_NAME"
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

# Seed the session-context layer (see .claude/skills/claude-context/SKILL.md)
# with starter, empty-but-structured files - not copied into Templates/,
# since these are living files, not reusable new-note templates.
CONTEXT_SOURCE_NAMES=("about.md" "current-focus.md" "open-threads.md" "decisions-log.md")
CONTEXT_DEST_NAMES=("About.md" "Current Focus.md" "Open Threads.md" "Decisions Log.md")

if [ -d "$CONTEXT_TEMPLATES_DIR" ]; then
  for i in "${!CONTEXT_SOURCE_NAMES[@]}"; do
    src="$CONTEXT_TEMPLATES_DIR/${CONTEXT_SOURCE_NAMES[$i]}"
    dest="$VAULT_PATH/$CONTEXT_DIR_NAME/${CONTEXT_DEST_NAMES[$i]}"
    if [ -f "$dest" ]; then
      echo "skip (exists) $dest"
    else
      cp "$src" "$dest"
      echo "copied $dest"
    fi
  done
fi

# Wire up the session-context trigger for Claude Code, which auto-loads
# CLAUDE.md from the working directory at the start of every session (see
# README section 5). Not needed for Claude Desktop - that wiring is manual,
# see the README.
CLAUDE_MD_TEMPLATE="$TEMPLATES_DIR/CLAUDE.md.example"
CLAUDE_MD_DEST="$VAULT_PATH/CLAUDE.md"

if [ -f "$CLAUDE_MD_TEMPLATE" ]; then
  if [ -f "$CLAUDE_MD_DEST" ]; then
    echo "skip (exists) $CLAUDE_MD_DEST"
  else
    sed "s#{{CONTEXT_DIR}}#$CONTEXT_DIR_NAME#g" "$CLAUDE_MD_TEMPLATE" > "$CLAUDE_MD_DEST"
    echo "created $CLAUDE_MD_DEST"
  fi
fi

echo ""
echo "Vault ready at: $VAULT_PATH"
echo "Open it in Obsidian via: Open folder as vault -> select '$VAULT_PATH'"
