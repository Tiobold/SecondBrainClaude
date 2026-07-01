#!/usr/bin/env python3
"""Merge MCP server entries into an existing MCP config file (Claude
Desktop's claude_desktop_config.json or Claude Code's .mcp.json - both use
the same {"mcpServers": {...}} shape).

Only the given top-level server keys are touched. Every other key in the
file - other mcpServers entries, or anything else at the top level - is
left exactly as-is. Refuses to touch a file that isn't valid JSON rather
than risk clobbering something.

Usage: merge-mcp-config.py <config_path> <entries_json>
  entries_json is a JSON object string, e.g. '{"obsidian": {...}}'
"""

import json
import os
import sys


def main():
    if len(sys.argv) != 3:
        sys.stderr.write(__doc__)
        sys.exit(2)

    config_path, entries_json = sys.argv[1], sys.argv[2]
    new_entries = json.loads(entries_json)

    config = {}
    if os.path.isfile(config_path):
        try:
            config = json.load(open(config_path))
        except json.JSONDecodeError as e:
            sys.stderr.write(
                f"{config_path} exists but isn't valid JSON ({e}) - "
                "leaving it untouched. Fix or remove it and re-run.\n"
            )
            sys.exit(1)

    servers = config.setdefault("mcpServers", {})

    for key, value in new_entries.items():
        action = "updated" if key in servers else "added"
        servers[key] = value
        print(f"{action} mcpServers.{key}")

    os.makedirs(os.path.dirname(config_path) or ".", exist_ok=True)
    with open(config_path, "w") as f:
        json.dump(config, f, indent=2)
        f.write("\n")


if __name__ == "__main__":
    main()
