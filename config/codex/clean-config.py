#!/usr/bin/env python
"""Git clean filter for mutable Codex config state.

Reads TOML from stdin and removes values Codex writes as local UI/project state.
Formatting outside removed entries is preserved; live working-tree data is never
modified because Git clean filters only transform the blob sent to the index.
"""

from __future__ import annotations

import re
import sys


TABLE_HEADER = re.compile(r"^\s*\[{1,2}\s*(.+?)\s*\]{1,2}\s*(?:#.*)?$")
MODEL_KEY = re.compile(r"^\s*model\s*=")
KEY_ASSIGN = re.compile(r'^\s*(?:"([^"]*)"|([A-Za-z0-9_.\-]+))\s*=')

# Keys Codex rewrites whenever the ChatGPT app updates or re-signs its bundled
# browser client. Volatile wherever they appear -- currently both
# [mcp_servers.node_repl.env] and [shell_environment_policy.set].
VOLATILE_KEYS = frozenset(
    {
        "NODE_REPL_TRUSTED_BROWSER_CLIENT_SHA256S",
        "BROWSER_USE_CODEX_APP_VERSION",
    }
)

# Keys that are only volatile within one table family.
VOLATILE_KEYS_BY_TABLE_PREFIX: tuple[tuple[str, frozenset[str]], ...] = (
    # Refresh timestamps; the marketplace registration itself is worth tracking.
    ("marketplaces.", frozenset({"last_updated"})),
)


def is_ephemeral_table(name: str) -> bool:
    """Return whether a TOML table contains machine-local Codex state."""
    return (
        name == "tui.model_availability_nux"
        or name.startswith('projects."')
        # Trust cache keyed by absolute hook path and content hash.
        or name == "hooks.state"
        or name.startswith('hooks.state."')
    )


def is_ephemeral_key(table: str, line: str) -> bool:
    """Return whether a key assignment holds machine-local Codex state."""
    match = KEY_ASSIGN.match(line)
    if not match:
        return False

    key = match.group(1) or match.group(2)
    if key in VOLATILE_KEYS:
        return True

    return any(
        table.startswith(prefix) and key in keys
        for prefix, keys in VOLATILE_KEYS_BY_TABLE_PREFIX
    )


def clean(source: str) -> str:
    """Remove ephemeral root keys and tables while preserving other text."""
    output: list[str] = []
    skip_table = False
    at_root = True
    table = ""

    for line in source.splitlines(keepends=True):
        header = TABLE_HEADER.match(line)
        if header:
            at_root = False
            table = header.group(1)
            skip_table = is_ephemeral_table(table)
            if skip_table:
                while output and not output[-1].strip():
                    output.pop()
                continue

        if skip_table:
            continue
        if at_root and MODEL_KEY.match(line):
            continue
        if not header and is_ephemeral_key(table, line):
            continue
        output.append(line)

    return "".join(output)


def main() -> None:
    sys.stdout.write(clean(sys.stdin.read()))


if __name__ == "__main__":
    main()
